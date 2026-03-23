import 'package:flutter/material.dart';
import '../models/task_model.dart';

class HistoryScreen extends StatefulWidget {
  final List<TaskModel> tasks;
  final int lifetimeXp;
  final int totalTasksEverAdded;
  final int totalTasksRemoved;
  final List<Map<String, dynamic>> xpHistory;

  const HistoryScreen({
    super.key,
    required this.tasks,
    required this.lifetimeXp,
    required this.totalTasksEverAdded,
    required this.totalTasksRemoved,
    required this.xpHistory,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool showXpHistory = false;

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: Color(0xFF111827),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.tasks.where((t) => t.completed).length;
    final inProgress = widget.tasks.where((t) => !t.completed).length;
    final recentXp = widget.xpHistory.take(10).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                setState(() {
                  showXpHistory = !showXpHistory;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_graph_rounded, color: Colors.white),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Lifetime XP Earned",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          "${widget.lifetimeXp} XP",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          showXpHistory
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    if (showXpHistory) ...[
                      const SizedBox(height: 14),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 8),
                      if (recentXp.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            "No XP history yet",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        ...recentXp.map((entry) {
                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.bolt_rounded,
                                  color: Color(0xFFFBBF24),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    entry["taskName"],
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "+${entry["xp"]} XP",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _statCard(
              icon: Icons.playlist_add_check_circle_rounded,
              title: "Total Tasks Ever Added",
              value: "${widget.totalTasksEverAdded}",
              color: const Color(0xFF2563EB),
            ),
            _statCard(
              icon: Icons.check_circle_rounded,
              title: "Completed Tasks",
              value: "$completed",
              color: const Color(0xFF10B981),
            ),
            _statCard(
              icon: Icons.delete_outline_rounded,
              title: "Removed Tasks",
              value: "${widget.totalTasksRemoved}",
              color: const Color(0xFFEF4444),
            ),
            _statCard(
              icon: Icons.pending_actions_rounded,
              title: "Tasks In Progress",
              value: "$inProgress",
              color: const Color(0xFFF59E0B),
            ),
          ],
        ),
      ),
    );
  }
}