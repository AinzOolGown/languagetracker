import 'package:duoproject/screens/history_screen.dart';
import 'package:duoproject/widgets/xp_progress_bar.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import 'task_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> tasks = [];
  Set<int> removingTasks = {};
  int lifetimeXp = 0;
  int currentXp = 0;
  int level = 1;
  bool isLoading = true;

  int? expandedTaskId; // controls expansion

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void toggleExpanded(Task task) {
    setState(() {
      if (expandedTaskId == task.id) {
        expandedTaskId = null;
      } else {
        expandedTaskId = task.id;
      }
    });
  }

  Future<void> loadTasks() async {
    final db = DatabaseHelper.instance;

    final loadedTasks = await db.readActiveTasks();
    final loadedLifetimeXp = await db.getLifetimeXp();

    setState(() {
      tasks = loadedTasks;
      lifetimeXp = loadedLifetimeXp;

      currentXp = lifetimeXp % 200;
      level = (lifetimeXp ~/ 200) + 1;
    });
  }

  int calculateXp(Task task) {
    switch (task.difficulty) {
      case 1: return 10;
      case 2: return 20;
      case 3: return 35;
      case 4: return 50;
      default: return 10;
    }
  }

  void openTaskCreator() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TaskScreen(),
    );
    loadTasks();
  }

  Future completeTaskWithAnimation(Task task) async {
    setState(() {
      removingTasks.add(task.id!);
    });

    await Future.delayed(const Duration(milliseconds: 300));

    task.completed = true;
    final db = DatabaseHelper.instance;
    await db.updateTask(task);

    final xp = calculateXp(task);
    await db.insertXp(
      taskName: task.name,
      type: task.type,
      xp: xp,
    );

    await loadTasks();
  }

  Future deleteTask(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Task"),
        content: const Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteTask(id);
    }

    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Language Tasks"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              // progress card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF58CC02), Color(0xFF46A302)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Current Progress",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text("Level $level",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: XpProgressBar(
                        currentXp: currentXp,
                        maxXp: 200,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Row(
                children: [
                  Icon(Icons.assignment_rounded),
                  SizedBox(width: 8),
                  Text("Your Tasks",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: tasks.isEmpty
                    ? const Center(child: Text("No tasks yet"))
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];

                          return AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: removingTasks.contains(task.id) ? 0 : 1,
                            child: AnimatedSlide(
                              duration: const Duration(milliseconds: 300),
                              offset: removingTasks.contains(task.id)
                                  ? const Offset(1, 0)
                                  : Offset.zero,

                              // expanded tile
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => toggleExpanded(task),

                                child: Container(
                                  margin:
                                      const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(18),
                                    border: Border.all(
                                        color: const Color(0xFFE5E7EB)),
                                  ),

                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Checkbox(
                                            value: task.completed,
                                            onChanged: (_) async {
                                              final confirm =
                                                  await showDialog(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  title: const Text(
                                                      "Complete Task"),
                                                  content: const Text(
                                                      "Mark this task as completed?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, false),
                                                      child:
                                                          const Text("Cancel"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, true),
                                                      child:
                                                          const Text("Confirm"),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                completeTaskWithAnimation(task);
                                              }
                                            },
                                          ),

                                          const SizedBox(width: 10),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(task.name,
                                                    style:
                                                        const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700)),

                                                const SizedBox(height: 6),

                                                Text(
                                                  task.dueDate != null
                                                      ? DateFormat(
                                                              'MMM d, yyyy')
                                                          .format(DateTime.parse(
                                                              task.dueDate!))
                                                      : "No due date",
                                                ),

                                                const SizedBox(height: 8),

                                                Text(
                                                    "+${calculateXp(task)} XP"),
                                              ],
                                            ),
                                          ),

                                          Icon(
                                            expandedTaskId == task.id
                                                ? Icons.expand_less
                                                : Icons.expand_more,
                                          ),

                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () =>
                                                deleteTask(task.id!),
                                          ),
                                        ],
                                      ),

                                      // expanded section
                                      AnimatedCrossFade(
                                        duration: const Duration(
                                            milliseconds: 200),
                                        crossFadeState:
                                            expandedTaskId == task.id
                                                ? CrossFadeState.showSecond
                                                : CrossFadeState.showFirst,
                                        firstChild: const SizedBox(),
                                        secondChild: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Divider(),
                                            Text(
                                              task.comments.isNotEmpty
                                                  ? task.comments
                                                  : "No additional comments",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: openTaskCreator,
        child: const Icon(Icons.add),
      ),
    );
  }
}