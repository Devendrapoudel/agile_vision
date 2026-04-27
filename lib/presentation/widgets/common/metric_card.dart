import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum MetricStatus { good, warning, danger, neutral }

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final Color accentColor;
  final IconData icon;
  final MetricStatus status;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    required this.accentColor,
    required this.icon,
    this.status = MetricStatus.neutral,
  });

  Color get _statusColor {
    switch (status) {
      case MetricStatus.good:    return AppColors.success;
      case MetricStatus.warning: return AppColors.warning;
      case MetricStatus.danger:  return AppColors.danger;
      default:                   return AppColors.textSecondary;
    }
  }

  Color get _statusBg {
    switch (status) {
      case MetricStatus.good:    return AppColors.successLight;
      case MetricStatus.warning: return AppColors.warningLight;
      case MetricStatus.danger:  return AppColors.dangerLight;
      default:                   return AppColors.surfaceVariant;
    }
  }

  String get _statusLabel {
    switch (status) {
      case MetricStatus.good:    return 'GOOD';
      case MetricStatus.warning: return 'AT RISK';
      case MetricStatus.danger:  return 'CRITICAL';
      default:                   return 'NEUTRAL';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
