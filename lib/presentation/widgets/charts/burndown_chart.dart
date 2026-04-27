import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';

class BurndownChart extends StatelessWidget {
  final int totalPoints;
  final List<double> actualRemaining; // actual remaining points per day
  final int sprintDays;

  const BurndownChart({
    super.key,
    required this.totalPoints,
    required this.actualRemaining,
    this.sprintDays = 14,
  });

  @override
  Widget build(BuildContext context) {
    final idealLine = _buildIdealLine();
    final actualLine = _buildActualLine();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: sprintDays.toDouble(),
        minY: 0,
        maxY: totalPoints.toDouble(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Text(
                'D${v.toInt()}',
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [idealLine, actualLine],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
              '${s.y.toStringAsFixed(0)} pts',
              const TextStyle(color: Colors.white, fontSize: 12),
            )).toList(),
          ),
        ),
      ),
    );
  }

  LineChartBarData _buildIdealLine() {
    final spots = List.generate(sprintDays + 1, (i) {
      final remaining = totalPoints - (totalPoints / sprintDays) * i;
      return FlSpot(i.toDouble(), remaining.clamp(0, totalPoints.toDouble()));
    });
    return LineChartBarData(
      spots: spots,
      isCurved: false,
      color: AppColors.textMuted,
      barWidth: 1.5,
      dotData: const FlDotData(show: false),
      dashArray: [5, 5],
    );
  }

  LineChartBarData _buildActualLine() {
    final spots = actualRemaining.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: AppColors.devendra,
      barWidth: 2.5,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: AppColors.devendra.withOpacity(0.08),
      ),
    );
  }
}