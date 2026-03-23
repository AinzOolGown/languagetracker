import 'package:flutter/material.dart';

class XpProgressBar extends StatelessWidget {
  final int level;
  final int currentXp;
  final int maxXp;

  const XpProgressBar({
    super.key,
    required this.level,
    required this.currentXp,
    this.maxXp = 200,
  });

  @override
  Widget build(BuildContext context) {
    double progress = currentXp / maxXp;
    if (progress > 1) progress = 1;
    if (progress < 0) progress = 0;

    return Container(
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
          // Header
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

          // Inner white card
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // XP label row
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

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 400),
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 13,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF58CC02),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}