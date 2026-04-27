import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/kpi_calculator.dart';
import '../../providers/project_provider.dart';
import '../../providers/sprint_provider.dart';
import '../../providers/kpi_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/common/metric_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/info_icon_button.dart';
import '../../widgets/charts/burndown_chart.dart';
import '../schedule/schedule_screen.dart';
import '../cost/cost_screen.dart';
import '../infrastructure/infrastructure_screen.dart';
import '../tasks/task_list_screen.dart';
import '../ux/ux_screen.dart';
import '../project/project_list_screen.dart';
import '../../../data/services/auth_service.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userRole;
  const DashboardScreen({super.key, required this.userRole});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTab = 0;
  static const String _projectId = 'demo_project_1';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().watchProjects();
      context.read<SprintProvider>().watchSprints(_projectId);
      context.read<TaskProvider>().watchTasks(_projectId);
      context.read<KpiProvider>().watchKpis(_projectId);
      context.read<KpiProvider>().loadHistory(_projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _DashboardTab(userRole: widget.userRole),
      ScheduleScreen(projectId: _projectId),
      CostScreen(projectId: _projectId),
      InfrastructureScreen(projectId: _projectId),
      const UXScreen(),
      TaskListScreen(projectId: _projectId, userRole: widget.userRole),
    ];

    return Scaffold(
      body: tabs[_selectedTab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (i) => setState(() => _selectedTab = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.schedule_outlined), selectedIcon: Icon(Icons.schedule), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.attach_money_outlined), selectedIcon: Icon(Icons.attach_money), label: 'Cost'),
          NavigationDestination(icon: Icon(Icons.cloud_outlined), selectedIcon: Icon(Icons.cloud), label: 'Infra'),
          NavigationDestination(icon: Icon(Icons.palette_outlined), selectedIcon: Icon(Icons.palette), label: 'UX'),
          NavigationDestination(icon: Icon(Icons.task_outlined), selectedIcon: Icon(Icons.task), label: 'Tasks'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final String userRole;
  const _DashboardTab({required this.userRole});

  @override
  Widget build(BuildContext context) {
    final kpiProvider = context.watch<KpiProvider>();
    final sprintProvider = context.watch<SprintProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final kpi = kpiProvider.latestSnapshot;
    final activeSprint = sprintProvider.activeSprint;

    final statusLabel = kpi != null
        ? KpiCalculator.getStatusLabel(kpi.cpi, kpi.spi)
        : 'No Data';
    final statusColor = statusLabel == 'On Track'
        ? AppColors.success
        : statusLabel == 'At Risk'
            ? AppColors.warning
            : AppColors.danger;
    final statusBg = statusLabel == 'On Track'
        ? AppColors.successLight
        : statusLabel == 'At Risk'
            ? AppColors.warningLight
            : AppColors.dangerLight;

    final kpiError = context.watch<KpiProvider>().error;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AgileVision'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProjectListScreen(userRole: userRole)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: !kpiProvider.loaded
          ? const LoadingWidget(message: 'Loading dashboard...')
          : Column(
              children: [
                if (kpiError != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: const Color(0xFFFFF3CD),
                    child: const Row(
                      children: [
                        Icon(Icons.wifi_off_rounded, size: 16, color: Color(0xFF856404)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Firebase emulator unreachable — run: firebase emulators:start',
                            style: TextStyle(fontSize: 12, color: Color(0xFF856404), fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<KpiProvider>().loadHistory('demo_project_1'),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Project header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AgileVision Research Project',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activeSprint != null
                                ? 'Sprint ${activeSprint.sprintNumber} — ${activeSprint.daysRemaining} days remaining'
                                : 'No active sprint',
                            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  statusLabel,
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: statusColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SectionHeading(
                      title: 'Key Performance Indicators',
                      infoTitle: 'Key Performance Indicators (EVM)',
                      infoSummary: 'Four EVM metrics giving an instant health check — combining schedule and cost performance in a single view. Calculated automatically on every task status change.',
                      infoMetrics: const [
                        (label: 'SV', value: 'Earned Value − Planned Value  →  negative = behind schedule (in £)'),
                        (label: 'SPI', value: 'EV ÷ PV  →  < 1.0 behind schedule · > 1.0 ahead'),
                        (label: 'CPI', value: 'EV ÷ AC  →  < 1.0 over budget · > 1.0 under budget'),
                        (label: 'Burn Rate', value: 'AC ÷ BAC × 100  →  % of £50,000 budget consumed'),
                      ],
                      infoReference: 'Devendra (Schedule OBJ 2) + Roshan (Cost OBJ 2).\nFleming & Koppelman (2010); PMI PMBOK Guide (2021).',
                      infoResearcher: 'Cross-team — Schedule & Cost Engines',
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.1,
                      children: [
                        MetricCard(
                          label: 'Schedule Variance',
                          value: kpi != null ? KpiCalculator.formatCurrency(kpi.sv) : '—',
                          subtitle: 'SPI: ${kpi != null ? KpiCalculator.formatIndex(kpi.spi) : '—'}',
                          accentColor: AppColors.devendra,
                          icon: Icons.schedule_outlined,
                          status: (kpi?.spi ?? 1) >= 0.95
                              ? MetricStatus.good
                              : (kpi?.spi ?? 1) >= 0.80
                                  ? MetricStatus.warning
                                  : MetricStatus.danger,
                        ),
                        MetricCard(
                          label: 'Cost Performance',
                          value: kpi != null ? KpiCalculator.formatIndex(kpi.cpi) : '—',
                          subtitle: 'CV: ${kpi != null ? KpiCalculator.formatCurrency(kpi.cv) : '—'}',
                          accentColor: AppColors.roshan,
                          icon: Icons.attach_money_outlined,
                          status: (kpi?.cpi ?? 1) >= 0.95
                              ? MetricStatus.good
                              : (kpi?.cpi ?? 1) >= 0.80
                                  ? MetricStatus.warning
                                  : MetricStatus.danger,
                        ),
                        MetricCard(
                          label: 'Sprint Progress',
                          value: activeSprint != null
                              ? '${activeSprint.completionPercentage.toStringAsFixed(0)}%'
                              : '0%',
                          subtitle: activeSprint != null
                              ? '${activeSprint.completedPoints}/${activeSprint.plannedPoints} pts'
                              : 'No active sprint',
                          accentColor: AppColors.shambhu,
                          icon: Icons.trending_up_outlined,
                          status: (activeSprint?.completionPercentage ?? 0) >= 70
                              ? MetricStatus.good
                              : (activeSprint?.completionPercentage ?? 0) >= 40
                                  ? MetricStatus.warning
                                  : MetricStatus.danger,
                        ),
                        MetricCard(
                          label: 'Budget Burn Rate',
                          value: kpi != null ? '${((kpi.actualCost / 50000) * 100).toStringAsFixed(1)}%' : '—',
                          subtitle: 'AC: ${kpi != null ? KpiCalculator.formatCurrency(kpi.actualCost) : '—'}',
                          accentColor: AppColors.shiva,
                          icon: Icons.account_balance_wallet_outlined,
                          status: (kpi?.actualCost ?? 0) / 50000 <= 0.85
                              ? MetricStatus.good
                              : (kpi?.actualCost ?? 0) / 50000 <= 1.0
                                  ? MetricStatus.warning
                                  : MetricStatus.danger,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SectionHeading(
                      title: 'Sprint Burndown',
                      infoTitle: 'Sprint Burndown Chart',
                      infoSummary: 'Tracks story points remaining day-by-day through the active sprint. Compares actual progress against the ideal linear reduction to zero.',
                      infoMetrics: const [
                        (label: 'Ideal line', value: 'Total Points ÷ Sprint Days — linear daily target to reach zero by sprint end'),
                        (label: 'Actual line', value: 'Remaining points after each task is marked Done'),
                        (label: 'Above ideal', value: 'Team is behind — more work remains than the plan allows'),
                        (label: 'Below ideal', value: 'Team is ahead — completing work faster than planned'),
                      ],
                      infoReference: 'Devendra (Schedule) — OBJ 1: Sprint Burndown.\nSchwaber & Sutherland (2020) The Scrum Guide.',
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
                      child: BurndownChart(
                        totalPoints: activeSprint?.plannedPoints ?? 30,
                        actualRemaining: _buildBurndownData(activeSprint?.plannedPoints ?? 30, taskProvider),
                        sprintDays: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SectionHeading(
                      title: 'Latest KPI Snapshot',
                      infoTitle: 'Latest KPI Snapshot',
                      infoSummary: 'The most recent full EVM calculation — triggered automatically by a Firebase Cloud Function on every task status change. All values are computed, never entered manually.',
                      infoMetrics: const [
                        (label: 'EV', value: '% Story Points Done × £50,000  →  budget value of work completed'),
                        (label: 'PV', value: '% Story Points Planned × £50,000  →  budget value of work scheduled'),
                        (label: 'AC', value: 'Actual cost spent to date'),
                        (label: 'EAC', value: 'BAC ÷ CPI  →  predicted total cost at current efficiency'),
                        (label: 'TCPI', value: '(BAC − EV) ÷ (BAC − AC)  →  efficiency needed on remaining work'),
                        (label: 'Calc Latency', value: 'Cloud Function execution time in ms — evidence of real-time automated computation'),
                      ],
                      infoReference: 'All four researchers — computed by Cloud Functions on every task event.\nPMI PMBOK Guide (2021); Lipke (2003).',
                      infoResearcher: 'Cross-team — Automated KPI Engine',
                    ),
                    const SizedBox(height: 12),
                    if (kpi != null) _KpiDetailCard(kpi: kpi) else Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Text('KPI snapshots not yet available.\nRestart emulators and relaunch app to seed data.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
                ),
              ],
            ),
    );
  }

  List<double> _buildBurndownData(int totalPoints, TaskProvider taskProvider) {
    // Build burndown using actual story points from completed tasks
    final doneTasks = taskProvider.doneTasks;
    if (doneTasks.isEmpty) return [totalPoints.toDouble()];
    // Sort by completedAt or fall back to cumulative ordering
    double remaining = totalPoints.toDouble();
    final points = <double>[remaining];
    for (final task in doneTasks) {
      remaining = (remaining - task.storyPoints).clamp(0, totalPoints.toDouble());
      points.add(remaining);
    }
    return points;
  }
}

class _KpiDetailCard extends StatelessWidget {
  final dynamic kpi;
  const _KpiDetailCard({required this.kpi});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Earned Value', KpiCalculator.formatCurrency(kpi.earnedValue)),
      ('Planned Value', KpiCalculator.formatCurrency(kpi.plannedValue)),
      ('Actual Cost', KpiCalculator.formatCurrency(kpi.actualCost)),
      ('EAC', KpiCalculator.formatCurrency(kpi.eac)),
      ('TCPI', KpiCalculator.formatIndex(kpi.tcpi)),
      ('WMA Velocity', '${kpi.wmaVelocity.toStringAsFixed(1)} pts'),
      ('Calc Latency', '${kpi.calculationLatencyMs}ms'),
      ('MAE Score', kpi.maeScore.toStringAsFixed(2)),
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
          return Column(
            children: [
              if (e.key > 0) const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.value.$1, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text(e.value.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
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
