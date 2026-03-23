import 'package:flutter/material.dart';
import '../widgets/task_card.dart';
import '../widgets/xp_progress_bar.dart';
import '../models/task_model.dart';
import '../services/storage_serveice.dart';
import 'add_task_screen.dart';
import 'history_screen.dart';
import 'task_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TaskModel> tasks = StorageService.getInitialTasks();

  int level = 3;
  int xp = 120;
  int lifetimeXp = 120;
  int streak = 5;
  int totalTasksEverAdded = 4;
  int totalTasksRemoved = 0;

  List<Map<String, dynamic>> xpHistory = [
    {"taskName": "Practice Vocabulary", "xp": 10},
    {"taskName": "Short Reading Practice", "xp": 15},
    {"taskName": "Listening Exercise", "xp": 20},
    {"taskName": "Speaking Practice", "xp": 12},
  ];

  void toggleTask(int index) {
    setState(() {
      tasks[index].completed = !tasks[index].completed;

      if (tasks[index].completed) {
        xp += tasks[index].xp;
        lifetimeXp += tasks[index].xp;

        xpHistory.insert(0, {
          "taskName": tasks[index].title,
          "xp": tasks[index].xp,
        });
      } else {
        xp -= tasks[index].xp;
        if (xp < 0) xp = 0;
      }
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      totalTasksRemoved += 1;
    });
  }

  void addTask(TaskModel task) {
    setState(() {
      tasks.add(task);
      totalTasksEverAdded += 1;
    });
  }

  void openTask(int index) async {
    final task = tasks[index];

    if (task.category == "Reading" || task.category == "Writing") {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TaskDetailScreen(task: task),
        ),
      );
      setState(() {});
      return;
    }

    if (task.category == "Listening" ||
        task.category == "Speaking" ||
        task.category == "Vocabulary") {
      setState(() {
        task.isExpanded = !task.isExpanded;
      });
    }
  }

  Widget _summaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
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
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = tasks.where((t) => t.completed).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Language Tracker"),
        actions: [
          IconButton(
            tooltip: "History",
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(
                    tasks: tasks,
                    lifetimeXp: lifetimeXp,
                    totalTasksEverAdded: totalTasksEverAdded,
                    totalTasksRemoved: totalTasksRemoved,
                    xpHistory: xpHistory,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_rounded),
        onPressed: () async {
          final task = await Navigator.push<TaskModel>(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );

          if (task != null) {
            addTask(task);
          }
        },
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
                      child: XpProgressBar(currentXp: xp, maxXp: 200),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}