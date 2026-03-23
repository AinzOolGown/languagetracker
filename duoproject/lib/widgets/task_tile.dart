import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final bool isExpanded;
  final bool isRemoving;
  final int xp;

  // Callbacks
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onComplete;

  const TaskTile({
    super.key,
    required this.task,
    required this.isExpanded,
    required this.isRemoving,
    required this.xp,
    required this.onTap,
    required this.onDelete,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    // Slide out + fade out animation when removing a task
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isRemoving ? 0 : 1,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: isRemoving ? const Offset(1, 0) : Offset.zero,
        // Main card
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          // Card content
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: task.completed,
                      onChanged: (_) => onComplete(),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),

                          const SizedBox(height: 6),

                          Text(
                            task.dueDate != null
                                ? DateFormat('MMM d, yyyy')
                                    .format(DateTime.parse(task.dueDate!))
                                : "No due date",
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              // blue Type chip
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  task.type,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4338CA),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // red XP chip
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "+$xp XP",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFF97316),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      isExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                    ),

                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: onDelete,
                    ),
                  ],
                ),

                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      Text(task.comments),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}