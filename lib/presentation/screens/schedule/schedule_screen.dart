import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/kpi_calculator.dart';
import '../../../research/devendra/schedule_algorithm.dart';
import '../../providers/kpi_provider.dart';
import '../../providers/sprint_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/info_icon_button.dart';
import '../../widgets/charts/burndown_chart.dart';
import '../../widgets/charts/velocity_chart.dart';

class ScheduleScreen extends StatelessWidget {
  final String projectId;
  const ScheduleScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final kpiProvider = context.watch<KpiProvider>();
    final sprintProvider = context.watch<SprintProvider>();
    final kpi = kpiProvider.latestSnapshot;
    final sprints = sprintProvider.sprints;
    final activeSprint = sprintProvider.activeSprint;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: AppColors.devendra, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            const Text('Schedule Engine'),
          ],
        ),
        actions: [
          if (kpi != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.devendra.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Calc: ${kpi.calculationLatencyMs}ms',
                style: const TextStyle(fontSize: 12, color: AppColors.devendra, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: !kpiProvider.loaded
          ? const LoadingWidget(message: 'Loading schedule data...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Devendra banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.devendra.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.devendra.withOpacity(0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.person_outlined, color: AppColors.devendra, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Devendra Poudel — Schedule Prediction Engine\nWeighted Moving Average + KPI Forecasting',
                            style: TextStyle(fontSize: 12, color: AppColors.devendra),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // KPI cards row 1
                  _sectionTitle('Schedule KPIs',
                    infoTitle: 'Schedule KPIs',
                    infoSummary: 'These four metrics give an at-a-glance view of whether the project is on schedule and how accurately velocity is being forecast.',
                    infoMetrics: const [
                      (label: 'SPI', value: 'Earned Value ÷ Planned Value  →  > 1.0 ahead of schedule, < 1.0 behind'),
                      (label: 'SV', value: 'Earned Value − Planned Value  →  negative = behind schedule (in £)'),
                      (label: 'WMA Velocity', value: 'Weighted Moving Average of story points/sprint — recent sprints weighted higher for responsiveness'),
                      (label: 'MAE Score', value: 'Mean Absolute Error between WMA forecast and actual velocity — lower is better'),
                    ],
                    infoReference: 'Devendra (Schedule) — OBJ 2: Earned Schedule & WMA Velocity.\nFleming & Koppelman (2010); Lipke (2003) "Schedule is Different".',
                    infoResearcher: 'Devendra — Schedule Performance Engine',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _KpiTile(
                          label: 'Schedule Variance',
                          value: kpi != null ? KpiCalculator.formatCurrency(kpi.sv) : '—',
                          good: (kpi?.sv ?? 0) >= 0,
                          color: AppColors.devendra,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _KpiTile(
                          label: 'SPI',
                          value: kpi != null ? KpiCalculator.formatIndex(kpi.spi) : '—',
                          good: (kpi?.spi ?? 1) >= 0.95,
                          warning: (kpi?.spi ?? 1) >= 0.80,
                          color: AppColors.devendra,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _KpiTile(
                          label: 'WMA Velocity',
                          value: kpi != null ? '${kpi.wmaVelocity.toStringAsFixed(1)} pts' : '—',
                          good: true,
                          color: AppColors.devendra,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _KpiTile(
                          label: 'MAE Score',
                          value: kpi != null ? kpi.maeScore.toStringAsFixed(2) : '—',
                          good: (kpi?.maeScore ?? 0) < 3,
                          warning: (kpi?.maeScore ?? 0) < 5,
                          color: AppColors.devendra,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Estimated completion
                  _sectionTitle('Completion Forecast',
                    infoTitle: 'Completion Forecast',
                    infoSummary: 'Predicts the project finish date using current WMA velocity. Confidence reflects velocity consistency — high sprint-to-sprint variance lowers confidence.',
                    infoMetrics: const [
                      (label: 'Sprints Remaining', value: 'Remaining Story Points ÷ WMA Velocity'),
                      (label: 'Forecast Date', value: 'Current Sprint End Date + (Sprints Remaining × Sprint Length)'),
                      (label: 'Confidence', value: 'High if velocity std-dev < 20 % of mean; Medium < 40 %; Low otherwise'),
                    ],
                    infoReference: 'Devendra (Schedule) — OBJ 3: Completion Forecasting.\nCohn (2005) Agile Estimating and Planning; Little (2006) Cone of Uncertainty.',
                    infoResearcher: 'Devendra — Schedule Performance Engine',
                  ),
                  const SizedBox(height: 12),
                  _ConeOfUncertaintyCard(
                    remainingPoints: activeSprint != null
                        ? activeSprint.plannedPoints - activeSprint.completedPoints
                        : 30,
                    wmaVelocity: kpi?.wmaVelocity ?? 0,
                    estimatedDate: kpi?.estimatedCompletionDate,
                  ),
                  const SizedBox(height: 20),

                  // Sprint Burndown Chart
                  _sectionTitle('Sprint Burndown',
                    infoTitle: 'Sprint Burndown Chart',
                    infoSummary: 'Tracks remaining story points day-by-day through the active sprint. The ideal line burns down evenly; the actual line reflects tasks marked Done.',
                    infoMetrics: const [
                      (label: 'Ideal Line', value: 'Total Points ÷ Sprint Days — linear daily reduction to zero'),
                      (label: 'Actual Line', value: 'Points remaining after each completed task'),
                      (label: 'Above ideal', value: 'Team is behind — more work remains than planned'),
                      (label: 'Below ideal', value: 'Team is ahead — work is completing faster than planned'),
                    ],
                    infoReference: 'Devendra (Schedule) — OBJ 1: Sprint Burndown.\nSchwaber & Sutherland (2020) The Scrum Guide.',
                    infoResearcher: 'Devendra — Schedule Performance Engine',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: BurndownChart(
                      totalPoints: activeSprint?.plannedPoints ?? 30,
                      actualRemaining: _buildBurndown(activeSprint?.plannedPoints ?? 30, activeSprint?.completedPoints ?? 14),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Velocity Chart
                  _sectionTitle('Sprint Velocity Trend',
                    infoTitle: 'Sprint Velocity Trend',
                    infoSummary: 'Velocity = story points completed per sprint. A rising trend means the team is improving; falling trend signals impediments or scope creep.',
                    infoMetrics: const [
                      (label: 'Simple Average', value: 'Sum of all sprint velocities ÷ number of sprints'),
                      (label: 'WMA', value: 'Weighted Moving Average — most recent sprint weighted highest, giving a more responsive forecast'),
                      (label: 'WMA Formula', value: 'Σ (velocity × weight) ÷ Σ weights, where weight = sprint index'),
                    ],
                    infoReference: 'Devendra (Schedule) — OBJ 2: WMA Velocity Forecasting.\nCohn (2005) Agile Estimating and Planning.',
                    infoResearcher: 'Devendra — Schedule Performance Engine',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 180,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: VelocityChart(
                      velocities: sprints.map((s) => s.velocity).toList(),
                      wmaVelocity: kpi?.wmaVelocity ?? 0,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Earned Schedule (Lipke et al., 2009)
                  _sectionTitle('Earned Schedule — SVt & SPIt',
                    infoTitle: 'Earned Schedule (ES)',
                    infoSummary: 'Earned Schedule extends EVM into the time domain. Unlike classic SV (in £), these time-based metrics remain accurate even late in the project when classic SV becomes misleading.',
                    infoMetrics: const [
                      (label: 'ES', value: 'Time at which the Planned Value equals the current Earned Value — measured in sprints'),
                      (label: 'SVt', value: 'ES − Actual Time  →  negative = behind schedule by that many time units'),
                      (label: 'SPIt', value: 'ES ÷ Actual Time  →  < 1.0 = behind schedule; > 1.0 = ahead'),
                    ],
                    infoReference: 'Devendra (Schedule) — OBJ 4: Earned Schedule.\nLipke (2003) "Schedule is Different"; Lipke et al. (2009).',
                    infoResearcher: 'Devendra — Schedule Performance Engine',
                  ),
                  const SizedBox(height: 12),
                  _EarnedScheduleCard(sprints: sprints),
                  const SizedBox(height: 20),

                  // Monte Carlo P10 / P50 / P90
                  _sectionTitle('Monte Carlo Simulation (n=1000)',
                    infoTitle: 'Monte Carlo Simulation',
                    infoSummary: 'Runs 1,000 simulated sprint sequences by randomly sampling from historical velocity range. Produces a probability distribution of finish sprints — more honest than a single-point estimate.',
                    infoMetrics: const [
                      (label: 'Input', value: 'Min and max observed sprint velocity from sprint history'),
                      (label: 'P50', value: '50 % of simulations finish by this sprint — median outcome'),
                      (label: 'P80', value: '80 % of simulations finish by this sprint — recommended planning target'),
                      (label: 'P95', value: '95 % of simulations finish by this sprint — conservative, high-confidence bound'),
                    ],
                    infoReference: 'Devendra (Schedule) — OBJ 5: Monte Carlo Risk Simulation.\nVose (2008) Risk Analysis; Cohn (2005).',
                    infoResearcher: 'Devendra — Schedule Performance Engine',
                  ),
                  const SizedBox(height: 12),
                  _MonteCarloCard(sprints: sprints),
                  const SizedBox(height: 20),

                  // WMA Comparison table
                  _sectionTitle('WMA vs Actual — Last 3 Sprints',
                    infoTitle: 'WMA vs Actual Comparison',
                    infoSummary: 'Compares the WMA velocity forecast against actual story points delivered. A small gap means the model is well-calibrated; a large gap suggests the velocity pattern has shifted.',
                    infoMetrics: const [
                      (label: 'WMA Forecast', value: 'Predicted velocity for that sprint using weighted average of prior sprints'),
                      (label: 'Actual', value: 'Story points actually completed and marked Done'),
                      (label: 'MAE', value: 'Mean Absolute Error = avg |Forecast − Actual| across sprints — lower is better'),
                    ],
                    infoReference: 'Devendra (Schedule) — OBJ 3: Forecast Accuracy (MAE).\nHyndman & Athanasopoulos (2018) Forecasting: Principles and Practice.',
                    infoResearcher: 'Devendra — Schedule Performance Engine',
                  ),
                  const SizedBox(height: 12),
                  _WmaComparisonTable(sprints: sprints),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title,
      {String? infoTitle,
      String? infoSummary,
      List<({String label, String value})> infoMetrics = const [],
      String? infoReference,
      String? infoResearcher}) {
    if (infoTitle != null && infoSummary != null) {
      return Row(children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(width: 4),
        InfoIconButton(
          title: infoTitle,
          summary: infoSummary,
          metrics: infoMetrics,
          reference: infoReference ?? '',
          researcher: infoResearcher ?? '',
        ),
      ]);
    }
    return Text(title,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary));
  }

  List<double> _buildBurndown(int planned, int completed) {
    final points = <double>[];
    final daily = planned / 14;
    final doneIndex = (completed / planned * 14).round();
    for (int i = 0; i <= doneIndex; i++) {
      points.add((planned - daily * i).clamp(0, planned.toDouble()));
    }
    return points;
  }
}

class _KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final bool good;
  final bool warning;
  final Color color;

  const _KpiTile({
    required this.label,
    required this.value,
    required this.good,
    this.warning = false,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = good ? AppColors.success : warning ? AppColors.warning : AppColors.danger;
    final statusBg = good ? AppColors.successLight : warning ? AppColors.warningLight : AppColors.dangerLight;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
            child: Text(
              good ? 'Good' : warning ? 'At Risk' : 'Critical',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConeOfUncertaintyCard extends StatelessWidget {
  final int remainingPoints;
  final double wmaVelocity;
  final DateTime? estimatedDate;

  const _ConeOfUncertaintyCard({
    required this.remainingPoints,
    required this.wmaVelocity,
    this.estimatedDate,
  });

  @override
  Widget build(BuildContext context) {
    final cone = ScheduleAlgorithm.coneOfUncertainty(remainingPoints, wmaVelocity, 14);
    final fmt = DateFormat('dd MMM yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Expected', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text(
                fmt.format(cone['expected']!),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.devendra),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Optimistic', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text(
                fmt.format(cone['optimistic']!),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pessimistic', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              Text(
                fmt.format(cone['pessimistic']!),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.danger),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Remaining', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              Text(
                '$remainingPoints pts @ ${wmaVelocity.toStringAsFixed(1)} pts/sprint',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EarnedScheduleCard extends StatelessWidget {
  final List<dynamic> sprints;
  const _EarnedScheduleCard({required this.sprints});

  @override
  Widget build(BuildContext context) {
    final completed = sprints
        .where((s) => s.status == 'completed' && s.earnedSchedule != null)
        .toList();

    if (completed.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text('No Earned Schedule data yet',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Expanded(child: Text('Sprint', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                Expanded(child: Text('ES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                Expanded(child: Text('SVt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                Expanded(child: Text('SPIt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
              ],
            ),
          ),
          ...completed.map((s) {
            final svt = s.scheduleVarianceTime as double? ?? 0;
            final spit = s.schedulePerformanceIndexTime as double? ?? 1;
            final es = s.earnedSchedule as double? ?? 0;
            final svtColor = svt >= 0 ? AppColors.success : AppColors.danger;
            final spitColor = spit >= 0.95 ? AppColors.success : spit >= 0.80 ? AppColors.warning : AppColors.danger;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
              child: Row(
                children: [
                  Expanded(child: Text('Sprint ${s.sprintNumber}', style: const TextStyle(fontSize: 13))),
                  Expanded(
                    child: Text(es.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center),
                  ),
                  Expanded(
                    child: Text(
                      '${svt >= 0 ? '+' : ''}${svt.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: svtColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      spit.toStringAsFixed(3),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: spitColor),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.devendra.withOpacity(0.05),
              border: Border(top: BorderSide(color: AppColors.border)),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: AppColors.devendra),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Earned Schedule (Lipke, 2009) — fixes SV→0 at project end. SVt in sprints, SPIt dimensionless.',
                    style: TextStyle(fontSize: 11, color: AppColors.devendra),
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

class _MonteCarloCard extends StatelessWidget {
  final List<dynamic> sprints;
  const _MonteCarloCard({required this.sprints});

  @override
  Widget build(BuildContext context) {
    // Find the latest sprint with Monte Carlo data
    final mcSprints = sprints
        .where((s) => s.monteCarloAvailable == true && s.monteCarloP50 != null)
        .toList();

    if (mcSprints.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text('Monte Carlo requires ≥3 sprints of velocity data',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
      );
    }

    final latest = mcSprints.last;
    final fmt = DateFormat('dd MMM yyyy');
    final p10 = latest.monteCarloP10 as DateTime?;
    final p50 = latest.monteCarloP50 as DateTime?;
    final p90 = latest.monteCarloP90 as DateTime?;
    final spread = latest.monteCarloSpreadSprints as double?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.devendra.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '1,000 iterations • Sprint ${latest.sprintNumber}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.devendra),
                ),
              ),
              if (spread != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Spread: ${spread.toStringAsFixed(1)} sprints',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _mcRow('P10 — Optimistic (10th %ile)', p10 != null ? fmt.format(p10) : 'N/A', AppColors.success),
          const Divider(height: 16),
          _mcRow('P50 — Most Likely (Median)', p50 != null ? fmt.format(p50) : 'N/A', AppColors.devendra),
          const Divider(height: 16),
          _mcRow('P90 — Pessimistic (90th %ile)', p90 != null ? fmt.format(p90) : 'N/A', AppColors.danger),
          const Divider(height: 16),
          const Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Monte Carlo simulates 1,000 completion paths using velocity distribution. Cone narrows as project progresses (Little, 2006).',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mcRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _WmaComparisonTable extends StatelessWidget {
  final List<dynamic> sprints;
  const _WmaComparisonTable({required this.sprints});

  @override
  Widget build(BuildContext context) {
    final completed = sprints.where((s) => s.status == 'completed').toList();
    final last3 = completed.length > 3 ? completed.sublist(completed.length - 3) : completed;
    final velocities = completed.map<double>((s) => s.velocity).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Expanded(child: Text('Sprint', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                Expanded(child: Text('Actual', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                Expanded(child: Text('WMA Pred.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
              ],
            ),
          ),
          ...last3.asMap().entries.map((e) {
            final sprint = e.value;
            final vSubset = velocities.sublist(0, completed.indexOf(sprint));
            final wma = ScheduleAlgorithm.calculateWMAVelocity(vSubset);
            final diff = sprint.velocity - wma;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(child: Text('Sprint ${sprint.sprintNumber}', style: const TextStyle(fontSize: 13))),
                  Expanded(
                    child: Text(
                      '${sprint.velocity.toStringAsFixed(0)} pts',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      wma > 0 ? '${wma.toStringAsFixed(1)} pts' : 'N/A',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: wma > 0
                            ? (diff.abs() < 3 ? AppColors.success : diff.abs() < 6 ? AppColors.warning : AppColors.danger)
                            : AppColors.textMuted,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
