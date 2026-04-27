import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';

class CostVarianceChart extends StatelessWidget {
  final List<dynamic> sprints;

  const CostVarianceChart({super.key, required this.sprints});

  @override
  Widget build(BuildContext context) {
    if (sprints.isEmpty) return const Center(child: Text('No data', style: TextStyle(color: AppColors.textMuted)));

    final bars = sprints.asMap().entries.map((e) {
      final cv = (e.value.plannedValue as double) - (e.value.actualCost as double);
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: cv,
            color: cv >= 0 ? AppColors.success : AppColors.danger,
            width: 24,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    final allVals = sprints.map<double>((s) => (s.plannedValue as double) - (s.actualCost as double)).toList();
    final maxAbs = allVals.map((v) => v.abs()).reduce((a, b) => a > b ? a : b) * 1.3;

    return BarChart(
      BarChartData(
        minY: -maxAbs,
        maxY: maxAbs,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) => FlLine(
            color: v == 0 ? AppColors.border : AppColors.border.withOpacity(0.5),
            strokeWidth: v == 0 ? 1.5 : 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (v, _) => Text(
                '£${(v / 1000).toStringAsFixed(1)}k',
                style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Text(
                'S${v.toInt() + 1}',
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: bars,
      ),
    );
  }
}
