import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';

class CpiTrendChart extends StatelessWidget {
  final List<dynamic> snapshots;

  const CpiTrendChart({super.key, required this.snapshots});

  @override
  Widget build(BuildContext context) {
    if (snapshots.isEmpty) {
      return const Center(child: Text('No data', style: TextStyle(color: AppColors.textMuted)));
    }

    final reversed = snapshots.reversed.toList();
    final spots = reversed.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), (e.value.cpi as double).clamp(0.5, 1.5)))
        .toList();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (reversed.length - 1).toDouble(),
        minY: 0.7,
        maxY: 1.3,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) => FlLine(
            color: v == 1.0 ? AppColors.primary.withOpacity(0.3) : AppColors.border,
            strokeWidth: v == 1.0 ? 1.5 : 1,
            dashArray: v == 1.0 ? [4, 4] : null,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, _) => Text(
                v.toStringAsFixed(1),
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ),
          ),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          // Target = 1.0 reference line
          LineChartBarData(
            spots: [
              FlSpot(0, 1.0),
              FlSpot((reversed.length - 1).toDouble(), 1.0),
            ],
            isCurved: false,
            color: AppColors.textMuted,
            barWidth: 1,
            dotData: const FlDotData(show: false),
            dashArray: [4, 4],
          ),
          // Actual CPI
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.roshan,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                radius: 3,
                color: AppColors.roshan,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.roshan.withOpacity(0.08),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots
                .where((s) => s.barIndex == 1)
                .map((s) => LineTooltipItem(
                      'CPI: ${s.y.toStringAsFixed(2)}',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
