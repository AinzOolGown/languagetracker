import 'package:flutter/material.dart';

class XpProgressBar extends StatelessWidget {
  final int currentXp;
  final int maxXp;

  const XpProgressBar({
    super.key,
    required this.currentXp,
    required this.maxXp,
  });

  @override
  Widget build(BuildContext context) {
    double progress = currentXp / maxXp;
    if (progress > 1) progress = 1;
    if (progress < 0) progress = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(
              Icons.bolt_rounded,
              color: Color(0xFFF59E0B),
              size: 20,
            ),
            SizedBox(width: 6),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          "$currentXp / $maxXp XP",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 13,
            backgroundColor: Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation(Color(0xFF58CC02)),
          ),
        ),
      ],
    );
  }
}