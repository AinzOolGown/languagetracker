import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onOpen;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onOpen,
    required this.onToggleComplete,
    required this.onDelete,
  });

  String getTimer() {
    final diff = DateTime.now().difference(task.createdAt);

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} min";
    }
    if (diff.inHours < 24) {
      return "${diff.inHours} hr";
    }
    return "${diff.inDays} day";
  }

  Future<void> _openLink(String link) async {
    try {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Color _categoryColor() {
    switch (task.category) {
      case "Reading":
        return const Color(0xFF2563EB);
      case "Writing":
        return const Color(0xFF7C3AED);
      case "Listening":
        return const Color(0xFFF59E0B);
      case "Vocabulary":
        return const Color(0xFF10B981);
      case "Speaking":
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _categoryIcon() {
    switch (task.category) {
      case "Reading":
        return Icons.menu_book_rounded;
      case "Writing":
        return Icons.edit_note_rounded;
      case "Listening":
        return Icons.headphones_rounded;
      case "Vocabulary":
        return Icons.table_chart_rounded;
      case "Speaking":
        return Icons.mic_rounded;
      default:
        return Icons.task_alt_rounded;
    }
  }

  Widget buildExpandedContent(BuildContext context) {
    if (!task.isExpanded) return const SizedBox();

    if (task.category == "Listening") {
      final link = task.listeningLink?.trim() ?? "";

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: link.isEmpty
              ? const Text(
                  "No link added",
                  style: TextStyle(color: Color(0xFF6B7280)),
                )
              : InkWell(
                  onTap: () => _openLink(link),
                  child: Row(
                    children: [
                      const Icon(Icons.link_rounded, color: Color(0xFF2563EB)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          link,
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      );
    }

    if (task.category == "Speaking") {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.sticky_note_2_rounded, color: Color(0xFF6B7280)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  task.speakingNote?.isNotEmpty == true
                      ? task.speakingNote!
                      : "No speaking note added",
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (task.category == "Vocabulary") {
      final vocabList = task.vocabularyList ?? [];

      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                const Color(0xFFF3F4F6),
              ),
              columns: const [
                DataColumn(
                  label: Text(
                    "Vocabulary",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                DataColumn(
                  label: Text(
                    "Meaning",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
              rows: vocabList.take(10).map((item) {
                return DataRow(
                  cells: [
                    DataCell(Text(item["word"] ?? "")),
                    DataCell(Text(item["meaning"] ?? "")),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      );
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              onTap: onOpen,
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _categoryIcon(),
                  color: categoryColor,
                ),
              ),
              title: Text(
                task.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        task.category,
                        style: TextStyle(
                          color: categoryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      getTimer(),
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: task.completed,
                    activeColor: const Color(0xFF58CC02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    onChanged: (_) => onToggleComplete(),
                  ),
                  IconButton(
                    tooltip: "Delete task",
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: const Color(0xFFEF4444),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
            buildExpandedContent(context),
          ],
        ),
      ),
    );
  }
}