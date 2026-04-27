import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/kpi_calculator.dart';
import '../../../research/roshan/cost_algorithm.dart';
import '../../providers/kpi_provider.dart';
import '../../providers/sprint_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/info_icon_button.dart';
import '../../widgets/charts/cost_variance_chart.dart';
import '../../widgets/charts/cpi_trend_chart.dart';

class CostScreen extends StatelessWidget {
  final String projectId;
  const CostScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final kpiProvider = context.watch<KpiProvider>();
    final sprintProvider = context.watch<SprintProvider>();
    final kpi = kpiProvider.latestSnapshot;
    final history = kpiProvider.history;
    final sprints = sprintProvider.sprints;

    const bac = 50000.0;
    final burnRate = kpi != null ? CostAlgorithm.calculateBurnRate(kpi.actualCost, bac) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: AppColors.roshan, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            const Text('Cost Engine'),
          ],
        ),
        actions: [
          if (kpi != null)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.roshan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Updated: ${kpi.calculationLatencyMs}ms',
                style: const TextStyle(fontSize: 12, color: AppColors.roshan, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: !kpiProvider.loaded
          ? const LoadingWidget(message: 'Loading cost data...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Roshan banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.roshan.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.roshan.withOpacity(0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.person_outlined, color: AppColors.roshan, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Roshan Sharma Chapagain — Cost Performance Engine\nAgile EVM: CPI, EAC, MAPE Evaluation',
                            style: TextStyle(fontSize: 12, color: AppColors.roshan),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _sectionTitle('AgileEVM Metrics',
                    infoTitle: 'AgileEVM Metrics',
                    infoSummary: 'AgileEVM adapts traditional Earned Value Management to iterative sprints — measuring cost health using three core data points: planned work, completed work, and actual spend.',
                    infoMetrics: const [
                      (label: 'EV', value: '% Story Points Done × BAC  →  budget value of work completed'),
                      (label: 'PV', value: '% Story Points Planned × BAC  →  budget value of work scheduled'),
                      (label: 'AC', value: 'Actual Cost — real money spent to date'),
                      (label: 'EAC', value: 'BAC ÷ CPI  →  predicted total cost at current efficiency'),
                      (label: 'ETC', value: 'EAC − AC  →  estimated remaining spend to finish'),
                      (label: 'TCPI', value: '(BAC − EV) ÷ (BAC − AC)  →  efficiency needed on remaining work to finish on budget'),
                    ],
                    infoReference: 'Roshan (Cost) — OBJ 2: Full AgileEVM Suite.\nFleming & Koppelman (2010) Earned Value Project Management; PMI PMBOK Guide (2021).',
                    infoResearcher: 'Roshan — Cost Performance Engine',
                  ),
                  const SizedBox(height: 12),
                  _EvmSummaryCard(kpi: kpi, bac: bac),
                  const SizedBox(height: 12),

                  // KPI tiles
                  Row(
                    children: [
                      Expanded(
                        child: _KpiTile(
                          label: 'CPI',
                          value: kpi != null ? KpiCalculator.formatIndex(kpi.cpi) : '—',
                          good: (kpi?.cpi ?? 1) >= 0.95,
                          warning: (kpi?.cpi ?? 1) >= 0.80,
                          color: AppColors.roshan,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _KpiTile(
                          label: 'TCPI',
                          value: kpi != null ? KpiCalculator.formatIndex(kpi.tcpi) : '—',
                          good: (kpi?.tcpi ?? 1) <= 1.05,
                          warning: (kpi?.tcpi ?? 1) <= 1.15,
                          color: AppColors.roshan,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _KpiTile(
                          label: 'MAPE Score',
                          value: kpi != null ? '${kpi.mapeScore.toStringAsFixed(1)}%' : '—',
                          good: (kpi?.mapeScore ?? 0) < 5,
                          warning: (kpi?.mapeScore ?? 0) < 10,
                          color: AppColors.roshan,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _KpiTile(
                          label: 'Burn Rate',
                          value: '${burnRate.toStringAsFixed(1)}%',
                          good: burnRate <= 85,
                          warning: burnRate <= 100,
                          color: AppColors.roshan,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Budget burn bar
                  _sectionTitle('Budget Consumption',
                    infoTitle: 'Budget Consumption',
                    infoSummary: 'Visual comparison of actual spend (AC) against earned value (EV) relative to the £50,000 budget. When the AC bar exceeds EV, money is being spent faster than value is being delivered.',
                    infoMetrics: const [
                      (label: 'Burn Rate', value: 'AC ÷ BAC × 100  →  > 100% means over budget'),
                      (label: 'AC bar (red)', value: 'Cumulative actual spend to date'),
                      (label: 'EV bar (blue)', value: 'Budget value of work actually completed'),
                      (label: 'Gap', value: 'AC − EV  →  positive gap = cost overrun in progress'),
                    ],
                    infoReference: 'Roshan (Cost) — OBJ 2: AgileEVM & Budget Tracking.\nPMI PMBOK Guide (2021).',
                    infoResearcher: 'Roshan — Cost Performance Engine',
                  ),
                  const SizedBox(height: 12),
                  _BudgetBurnBar(actualCost: kpi?.actualCost ?? 0, bac: bac, earnedValue: kpi?.earnedValue ?? 0),
                  const SizedBox(height: 20),

                  // Cost Variance Chart
                  _sectionTitle('Cost Variance by Sprint',
                    infoTitle: 'Cost Variance by Sprint',
                    infoSummary: 'CV plotted per sprint reveals whether cost control is improving or deteriorating. A single negative bar is a warning; a sustained downward trend requires immediate action.',
                    infoMetrics: const [
                      (label: 'CV', value: 'Earned Value − Actual Cost  →  positive = under budget, negative = overspent'),
                      (label: 'Green bar', value: 'Under budget that sprint — team delivered more value than it cost'),
                      (label: 'Red bar', value: 'Over budget that sprint — actual cost exceeded value earned'),
                    ],
                    infoReference: 'Roshan (Cost) — OBJ 2: AgileEVM Cost Variance.\nFleming & Koppelman (2010); PMI PMBOK Guide (2021).',
                    infoResearcher: 'Roshan — Cost Performance Engine',
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
                    child: CostVarianceChart(sprints: sprints),
                  ),
                  const SizedBox(height: 20),

                  // CPI Trend Chart
                  _sectionTitle('CPI Trend',
                    infoTitle: 'CPI Trend',
                    infoSummary: 'CPI trend across sprints is one of the most reliable early warning signals in EVM. Research shows CPI rarely recovers after sprint 3 — making early detection critical.',
                    infoMetrics: const [
                      (label: 'CPI', value: 'Earned Value ÷ Actual Cost  →  > 1.0 under budget, < 1.0 over budget'),
                      (label: 'CPI = 1.0', value: 'Perfect efficiency — earning exactly £1 of value per £1 spent'),
                      (label: 'Declining trend', value: 'Early warning: cost efficiency is worsening sprint-on-sprint'),
                      (label: 'Update trigger', value: 'Recalculated automatically on every task status change (Continuous Auditing)'),
                    ],
                    infoReference: 'Roshan (Cost) — OBJ 3: Continuous Auditing Pattern.\nFleming & Koppelman (2010); Lipke (2003).',
                    infoResearcher: 'Roshan — Cost Performance Engine',
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
                    child: CpiTrendChart(snapshots: history),
                  ),
                  const SizedBox(height: 20),

                  // Optimism Bias
                  _sectionTitle('Optimism Bias Analysis',
                    infoTitle: 'Optimism Bias Analysis',
                    infoSummary: 'Tracks how the manager\'s manual EAC estimate compares to the algorithm\'s EAC sprint-by-sprint. Optimism Bias causes managers to consistently underestimate final cost — often until it is too late to recover.',
                    infoMetrics: const [
                      (label: 'Algorithm EAC', value: 'BAC ÷ CPI  →  objective data-driven forecast'),
                      (label: 'Manager Estimate', value: 'Manual cost-to-complete entered by the Scrum Master each sprint'),
                      (label: 'MAPE', value: '|Manager EAC − Algorithm EAC| ÷ Algorithm EAC × 100  →  lower = more accurate manager'),
                      (label: 'Bias direction', value: 'Manager estimate below algorithm EAC = underestimating overrun (optimism bias confirmed)'),
                    ],
                    infoReference: 'Roshan (Cost) — OBJ 5: Optimism Bias.\nKahneman & Tversky (1979) Prospect Theory; Flyvbjerg (2006) Over Budget, Over Time.',
                    infoResearcher: 'Roshan — Cost Performance Engine',
                  ),
                  const SizedBox(height: 12),
                  _OptimismBiasCard(algorithmEac: kpi?.eac ?? 0, bac: bac),
                  const SizedBox(height: 20),

                  // Sensitivity Analysis
                  _sectionTitle('Sensitivity Analysis (7 Scenarios)',
                    infoTitle: 'Sensitivity Analysis — 7 Scenarios',
                    infoSummary: '7 velocity scenarios model how final cost changes if the team performs better or worse than current rate. Each scenario recalculates the full EVM suite — giving stakeholders a clear decision matrix.',
                    infoMetrics: const [
                      (label: 'Scenario input', value: 'Velocity multiplier applied to current EV (e.g. −30 % to +30 %)'),
                      (label: 'Adj. EAC', value: 'BAC ÷ Adjusted CPI  →  new predicted final cost under that scenario'),
                      (label: 'TCPI', value: '(BAC − Adj.EV) ÷ (BAC − AC)  →  efficiency required on remaining work'),
                      (label: 'VaR ±15 %', value: 'Probabilistic cost band: [EAC × 0.85, EAC × 1.15]'),
                      (label: 'Viability', value: 'Recoverable: TCPI < 1.2 | Difficult: < 1.5 | Unrecoverable: ≥ 1.5'),
                    ],
                    infoReference: 'Roshan (Cost) — OBJ 4: Sensitivity Analysis & VaR.\nMarshall (2007) TCPI Decision Support; Jorion (2006) Value at Risk.',
                    infoResearcher: 'Roshan — Cost Performance Engine',
                  ),
                  const SizedBox(height: 12),
                  _SensitivityCard(kpi: kpi, bac: bac),
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
    const style = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
    if (infoTitle != null && infoSummary != null) {
      return Row(children: [
        Text(title, style: style),
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
    return Text(title, style: style);
  }
}

class _EvmSummaryCard extends StatelessWidget {
  final dynamic kpi;
  final double bac;
  const _EvmSummaryCard({required this.kpi, required this.bac});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Budget at Completion (BAC)', KpiCalculator.formatCurrency(bac)),
      ('Earned Value (EV)', kpi != null ? KpiCalculator.formatCurrency(kpi.earnedValue) : '—'),
      ('Actual Cost (AC)', kpi != null ? KpiCalculator.formatCurrency(kpi.actualCost) : '—'),
      ('Cost Variance (CV)', kpi != null ? KpiCalculator.formatCurrency(kpi.cv) : '—'),
      ('Estimate at Completion (EAC)', kpi != null ? KpiCalculator.formatCurrency(kpi.eac) : '—'),
      ('Estimate to Complete (ETC)', kpi != null ? KpiCalculator.formatCurrency(kpi.etc) : '—'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final isNegative = e.value.$2.startsWith('-');
          return Column(
            children: [
              if (e.key > 0) const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.value.$1, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text(
                      e.value.$2,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: (e.value.$1.contains('Variance'))
                            ? (isNegative ? AppColors.danger : AppColors.success)
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
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
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
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

class _BudgetBurnBar extends StatelessWidget {
  final double actualCost;
  final double bac;
  final double earnedValue;

  const _BudgetBurnBar({required this.actualCost, required this.bac, required this.earnedValue});

  @override
  Widget build(BuildContext context) {
    final burnRatio = (actualCost / bac).clamp(0.0, 1.0);
    final evRatio = (earnedValue / bac).clamp(0.0, 1.0);
    final isOverBudget = actualCost > earnedValue;

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
              const Text('Actual Cost', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(KpiCalculator.formatCurrency(actualCost),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isOverBudget ? AppColors.danger : AppColors.success)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(height: 10, color: AppColors.surfaceVariant),
                FractionallySizedBox(
                  widthFactor: evRatio,
                  child: Container(height: 10, color: AppColors.success.withOpacity(0.4)),
                ),
                FractionallySizedBox(
                  widthFactor: burnRatio,
                  child: Container(height: 10, color: isOverBudget ? AppColors.danger : AppColors.roshan),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.roshan, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                const Text('Actual Cost', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ]),
              Row(children: [
                Container(width: 8, height: 8, color: AppColors.success.withOpacity(0.4)),
                const SizedBox(width: 4),
                const Text('Earned Value', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ]),
              Text(
                'BAC: ${KpiCalculator.formatCurrency(bac)}',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptimismBiasCard extends StatefulWidget {
  final double algorithmEac;
  final double bac;

  const _OptimismBiasCard({required this.algorithmEac, required this.bac});

  @override
  State<_OptimismBiasCard> createState() => _OptimismBiasCardState();
}

class _OptimismBiasCardState extends State<_OptimismBiasCard> {
  double? _managerEac;
  double? _biasGap;
  String? _biasTrend;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadManagerEstimate();
  }

  Future<void> _loadManagerEstimate() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('manager_estimates')
          .orderBy('week', descending: true)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty && mounted) {
        final data = snap.docs.first.data();
        setState(() {
          _managerEac = (data['managerEAC'] as num?)?.toDouble();
          _biasGap = (data['biasGap'] as num?)?.toDouble();
          _biasTrend = data['biasGapTrend'] as String?;
          _loading = false;
        });
      } else if (mounted) {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fall back to bac*1.05 if Firestore fetch failed
    final managerEac = _managerEac ?? widget.bac * 1.05;
    final bias = ((widget.algorithmEac - managerEac) / managerEac * 100);
    final biasGap = _biasGap ?? bias.abs();
    final trend = _biasTrend;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: _loading
          ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Manager Estimate (EAC)', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text(KpiCalculator.formatCurrency(managerEac),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Algorithm EAC', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text(KpiCalculator.formatCurrency(widget.algorithmEac),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.roshan)),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Optimism Bias Gap', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: bias > 0 ? AppColors.dangerLight : AppColors.successLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${bias > 0 ? '+' : ''}${bias.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: bias > 0 ? AppColors.danger : AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                if (trend != null) ...[
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Bias Trend', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Row(
                        children: [
                          Icon(
                            trend == 'widening' ? Icons.trending_up : trend == 'closing' ? Icons.trending_down : Icons.trending_flat,
                            size: 16,
                            color: trend == 'widening' ? AppColors.danger : trend == 'closing' ? AppColors.success : AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            trend[0].toUpperCase() + trend.substring(1),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: trend == 'widening' ? AppColors.danger : trend == 'closing' ? AppColors.success : AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
                const Divider(height: 16),
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Optimism Bias: managers underestimate costs by £${biasGap.toStringAsFixed(0)} on average (Kahneman & Tversky, 1979).',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _SensitivityCard extends StatefulWidget {
  final dynamic kpi;
  final double bac;

  const _SensitivityCard({required this.kpi, required this.bac});

  @override
  State<_SensitivityCard> createState() => _SensitivityCardState();
}

class _SensitivityCardState extends State<_SensitivityCard> {
  List<Map<String, dynamic>> _scenarios = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadScenarios();
  }

  Future<void> _loadScenarios() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('sensitivity_analysis')
          .orderBy('scenarioIndex')
          .get();
      if (snap.docs.isNotEmpty && mounted) {
        setState(() {
          _scenarios = snap.docs.map((d) => d.data()).toList();
          _loading = false;
        });
        return;
      }
    } catch (_) {}
    // Fallback: compute 3 scenarios locally
    if (mounted) {
      final baseCpi = (widget.kpi?.cpi as double?) ?? 1.0;
      setState(() {
        _scenarios = [
          {'scenarioName': '−20% velocity', 'adjustedCPI': baseCpi * 0.8, 'adjustedEAC': CostAlgorithm.calculateEAC(widget.bac, baseCpi * 0.8), 'viability': 'critical'},
          {'scenarioName': 'Base case', 'adjustedCPI': baseCpi, 'adjustedEAC': CostAlgorithm.calculateEAC(widget.bac, baseCpi), 'viability': 'viable'},
          {'scenarioName': '+20% velocity', 'adjustedCPI': baseCpi * 1.2, 'adjustedEAC': CostAlgorithm.calculateEAC(widget.bac, baseCpi * 1.2), 'viability': 'optimal'},
        ];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
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
                Expanded(flex: 3, child: Text('Scenario', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text('CPI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('EAC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
              ],
            ),
          ),
          ..._scenarios.asMap().entries.map((e) {
            final s = e.value;
            final name = s['scenarioName'] as String? ?? 'Scenario ${e.key + 1}';
            final cpi = (s['adjustedCPI'] as num?)?.toDouble() ?? 1.0;
            final eac = (s['adjustedEAC'] as num?)?.toDouble() ?? widget.bac;
            final viability = s['viability'] as String? ?? 'viable';
            final isBase = name.toLowerCase().contains('base');
            final viabilityColor = viability == 'optimal'
                ? AppColors.success
                : viability == 'viable'
                    ? AppColors.roshan
                    : viability == 'warning'
                        ? AppColors.warning
                        : AppColors.danger;
            final viabilityBg = viability == 'optimal'
                ? AppColors.successLight
                : viability == 'viable'
                    ? AppColors.roshan.withValues(alpha: 0.1)
                    : viability == 'warning'
                        ? AppColors.warningLight
                        : AppColors.dangerLight;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isBase ? AppColors.roshan.withValues(alpha: 0.04) : null,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(name,
                        style: TextStyle(fontSize: 12, fontWeight: isBase ? FontWeight.w600 : FontWeight.w400)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(cpi.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cpi >= 0.95 ? AppColors.success : cpi >= 0.80 ? AppColors.warning : AppColors.danger,
                        ),
                        textAlign: TextAlign.center),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(KpiCalculator.formatCurrency(eac),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: eac > widget.bac ? AppColors.danger : AppColors.success,
                        ),
                        textAlign: TextAlign.center),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: viabilityBg, borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        viability[0].toUpperCase() + viability.substring(1),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: viabilityColor),
                        textAlign: TextAlign.center,
                      ),
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
