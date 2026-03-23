import 'package:flutter/material.dart';
import '../models/task.dart';
import '../database/database_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool showXpHistory = false;
  bool showStats = false;

  List<Task> tasks = [];
  List<Map<String, dynamic>> xpHistory = [];
  Map<String, int> xpByType = {};
  Set<String> expandedTypes = {};

  int lifetimeXp = 0;
  int totalTasksEverAdded = 0;
  int totalTasksRemoved = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final db = DatabaseHelper.instance;

    final loadedTasks = await db.readAllTasks();
    final loadedXpHistory = await db.getXpHistory();
    final loadedLifetimeXp = await db.getLifetimeXp();
    final loadedTotalAdded = await db.getTotalTasksAdded();
    final loadedTotalRemoved = await db.getTotalTasksRemoved();
    final loadedXpByType = await db.getXpByType();

    setState(() {
      tasks = loadedTasks;
      xpHistory = loadedXpHistory;
      lifetimeXp = loadedLifetimeXp;
      totalTasksEverAdded = loadedTotalAdded;
      totalTasksRemoved = loadedTotalRemoved;
      xpByType = loadedXpByType;
      isLoading = false;
    });
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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

  // Widget for XP by type card with expandable recent entries
  Widget _xpTypeCard(String type, int xp) {
    final isExpanded = expandedTypes.contains(type);

    // Filter XP history for this type and take recent 5 entries
    final filteredXp = xpHistory
        .where((entry) => entry["type"] == type)
        .take(5)
        .toList();

    // Sort by most recent
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        setState(() {
          if (isExpanded) {
            expandedTypes.remove(type);
          } else {
            expandedTypes.add(type);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.category, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    type,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  "$xp XP",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: 10),
              const Divider(color: Colors.white24),
              if (filteredXp.isEmpty)
                const Text(
                  "No entries yet",
                  style: TextStyle(color: Colors.white70),
                )
              else
                ...filteredXp.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "+${entry["xp"]} XP — ${entry["taskName"]}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final completed = tasks.where((t) => t.completed).length;
    final inProgress = tasks.where((t) => !t.completed).length;
    final recentXp = xpHistory.take(10).toList();

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
                        const Icon(Icons.auto_graph_rounded,
                            color: Colors.white),
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
                          "$lifetimeXp XP",
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
                        // List of recent XP entries for all types
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
                        }
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            // XP by type cards
            ...xpByType.entries.map((entry) {
              return _xpTypeCard(entry.key, entry.value);
            }).toList(),
            const SizedBox(height: 10),
            // Overall stats card
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                setState(() {
                  showStats = !showStats;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.analytics_outlined),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Task Statistics",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Icon(
                          showStats
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Overview of your task activity",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                    if (showStats) ...[
                      const SizedBox(height: 12),
                      _statCard(
                        icon: Icons.playlist_add_check_circle_rounded,
                        title: "Total Tasks Ever Added",
                        value: "$totalTasksEverAdded",
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
                        value: "$totalTasksRemoved",
                        color: const Color(0xFFEF4444),
                      ),
                      _statCard(
                        icon: Icons.pending_actions_rounded,
                        title: "Tasks In Progress",
                        value: "$inProgress",
                        color: const Color(0xFFF59E0B),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}