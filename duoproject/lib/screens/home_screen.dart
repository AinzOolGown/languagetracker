import 'package:duoproject/screens/history_screen.dart';
import 'package:duoproject/widgets/xp_progress_bar.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';
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

  // Toggle expansion of a task tile
  void toggleExpanded(Task task) {
    setState(() {
      if (expandedTaskId == task.id) {
        expandedTaskId = null;
      } else {
        expandedTaskId = task.id;
      }
    });
  }

  // Load tasks and XP from the database
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

  // Open task creation modal
  void openTaskCreator() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TaskScreen(),
    );
    loadTasks();
  }

  // Mark task as completed with animation and XP gain
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

  // Delete task with confirmation dialog
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

      // Main content area
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              // xp progress card called
              XpProgressBar(level: level, currentXp: currentXp),              

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

              // Task list
              Expanded(
                child: tasks.isEmpty
                    // placeholder when no tasks
                    ? const Center(child: Text("No tasks yet"))
                    // ListView of TaskTiles
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TaskTile(
                            task: task,
                            isExpanded: expandedTaskId == task.id,
                            isRemoving: removingTasks.contains(task.id),
                            xp: calculateXp(task),

                            onTap: () => toggleExpanded(task),

                            onDelete: () => deleteTask(task.id!),

                            // Show confirmation dialog before marking as completed
                            onComplete: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Complete Task"),
                                  content: const Text("Mark this task as completed?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("Confirm"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                completeTaskWithAnimation(task);
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),

      // Add task button
      floatingActionButton: FloatingActionButton(
        onPressed: openTaskCreator,
        child: const Icon(Icons.add),
      ),
    );
  }
}