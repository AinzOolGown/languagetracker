import 'package:duoproject/screens/history_screen.dart';
import 'package:duoproject/widgets/xp_progress_bar.dart';
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

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadData() async {
    final db = DatabaseHelper.instance;

    final loadedTasks = await db.readActiveTasks();
    final loadedLifetimeXp = await db.getLifetimeXp();

    final xp = loadedLifetimeXp;
    final lvl = (xp ~/ 200) + 1;
    final current = xp % 200;

    setState(() {
      tasks = loadedTasks;
      lifetimeXp = loadedLifetimeXp;      

      level = lvl;
      currentXp = current;

      isLoading = false;
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

  Future loadTasks() async {
    final data = await DatabaseHelper.instance.readActiveTasks();

    setState(() {
      tasks = data;
    });
  }

  void openTaskCreator() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => TaskScreen(),
    );

    // refresh tasks after closing
    loadTasks();
  }

  Future toggleTask(Task task) async {
    if (!task.completed) {
      await completeTaskWithAnimation(task);
    }
  }

  Future deleteTask(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Task"),
        content: Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.instance.deleteTask(id);
    }
    loadTasks();
  }

  Future completeTaskWithAnimation(Task task) async {
    setState(() {
      removingTasks.add(task.id!);
    });

    await Future.delayed(Duration(milliseconds: 300));

    task.completed = true;

    final db = DatabaseHelper.instance;

    await db.updateTask(task);

    final xp = calculateXp(task);

    await db.insertXp(
      taskName: task.name,
      type: task.type,
      xp: xp,
    );

    loadTasks();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Language Tasks"),
        actions: [
          IconButton(
            tooltip: "History",
            icon: Icon(Icons.history_rounded),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF58CC02), Color(0xFF46A302)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF58CC02).withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Current Progress",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Level $level",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: XpProgressBar(currentXp: currentXp, maxXp: 200),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              /* -- Currently has no implementation with Database
              Row(
                children: [
                  _summaryCard(
                    icon: Icons.local_fire_department_rounded,
                    label: "Streak",
                    value: "$streak days",
                    color: const Color(0xFFF97316),
                  ),
                  const SizedBox(width: 12),
                  _summaryCard(
                    icon: Icons.check_circle_rounded,
                    label: "Completed",
                    value: "$completedCount",
                    color: const Color(0xFF10B981),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              */
              Row(
                children: const [
                  Icon(Icons.assignment_rounded, color: Color(0xFF374151)),
                  SizedBox(width: 8),
                  Text(
                    "Your Tasks",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Text(
                            "No tasks yet.\nTap + to add your first task.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {

                          final task = tasks[index];

                          return AnimatedOpacity(
                            duration: Duration(milliseconds: 300),
                            opacity: removingTasks.contains(task.id) ? 0.0 : 1.0,

                            child: AnimatedSlide(
                              duration: Duration(milliseconds: 300),
                              offset: removingTasks.contains(task.id)
                                  ? Offset(1, 0)
                                  : Offset(0, 0),

                              child: ListTile(
                                title: Text(task.name),

                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Type: ${task.type}"),
                                    Text(
                                      task.dueDate != null
                                        ? "Due: ${task.dueDate}"
                                        : "Goal (no due date)"
                                    ),
                                    Text("XP: ${calculateXp(task)}"),
                                  ],
                                ),

                                leading: Checkbox(
                                  value: task.completed,
                                  onChanged: (_) async {
                                    final confirm = await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Complete Task"),
                                        content: Text("Mark this task as completed?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: Text("Confirm"),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      completeTaskWithAnimation(task);
                                    }
                                  },
                                ),

                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    deleteTask(task.id!);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        /* -- previous hardcoded list
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          return TaskCard(
                            task: tasks[index],
                            onOpen: () => openTask(index),
                            onToggleComplete: () => toggleTask(index),
                            onDelete: () => deleteTask(index),
                          );
                        },
                        */
                      ),
              ),
            ],
          ),
        ),
      ),

      /*
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {

          final task = tasks[index];

          return AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: removingTasks.contains(task.id) ? 0.0 : 1.0,

            child: AnimatedSlide(
              duration: Duration(milliseconds: 300),
              offset: removingTasks.contains(task.id)
                  ? Offset(1, 0)
                  : Offset(0, 0),

              child: ListTile(
                title: Text(task.name),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Type: ${task.type}"),
                    Text(
                      task.dueDate != null
                        ? "Due: ${task.dueDate}"
                        : "Goal (no due date)"
                    ),
                    Text("XP: ${calculateXp(task)}"),
                  ],
                ),

                leading: Checkbox(
                  value: task.completed,
                  onChanged: (_) async {
                    final confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Complete Task"),
                        content: Text("Mark this task as completed?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text("Confirm"),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      completeTaskWithAnimation(task);
                    }
                  },
                ),

                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    deleteTask(task.id!);
                  },
                ),
              ),
            ),
          );
        },
      ),
      */

      floatingActionButton: FloatingActionButton(
        onPressed: openTaskCreator,
        child: const Icon(Icons.add),
      ),
    );
  }
}