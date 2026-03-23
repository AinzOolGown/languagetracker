import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final bool isExpanded;
  final bool isRemoving;
  final int xp;

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
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isRemoving ? 0 : 1,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: isRemoving ? const Offset(1, 0) : Offset.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
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

                          const SizedBox(height: 8),

                          Text("+$xp XP"),
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