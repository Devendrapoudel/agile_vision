import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SprintProgressBar extends StatelessWidget {
  final int completedPoints;
  final int plannedPoints;
  final Color? color;

  const SprintProgressBar({
    super.key,
    required this.completedPoints,
    required this.plannedPoints,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = plannedPoints > 0 ? (completedPoints / plannedPoints).clamp(0.0, 1.0) : 0.0;
    final barColor = color ?? (ratio >= 0.7 ? AppColors.success : ratio >= 0.4 ? AppColors.warning : AppColors.danger);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completedPoints / $plannedPoints pts',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            Text(
              '${(ratio * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: barColor),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: AppColors.surfaceVariant,
            color: barColor,
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
