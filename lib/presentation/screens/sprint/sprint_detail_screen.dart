import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/kpi_calculator.dart';
import '../../../data/models/sprint_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../data/repositories/kpi_repository.dart';
import '../../../data/models/kpi_snapshot_model.dart';
import '../../widgets/charts/burndown_chart.dart';
import '../tasks/task_detail_screen.dart';

class SprintDetailScreen extends StatelessWidget {
  final SprintModel sprint;
  final String projectId;
  final String userRole;

  const SprintDetailScreen({
    super.key,
    required this.sprint,
    required this.projectId,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Sprint ${sprint.sprintNumber}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sprint header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sprint.goal, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Chip('${DateFormat('dd MMM').format(sprint.startDate)} — ${DateFormat('dd MMM').format(sprint.endDate)}'),
                      _Chip('${sprint.daysRemaining} days left'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: sprint.completionPercentage / 100,
                      backgroundColor: AppColors.surfaceVariant,
                      color: AppColors.primary,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${sprint.completedPoints}/${sprint.plannedPoints} pts',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text('${sprint.completionPercentage.toStringAsFixed(0)}% complete',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // KPI snapshot
            const Text('KPI Snapshot', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            FutureBuilder<KpiSnapshotModel?>(
              future: KpiRepository().getSnapshots(projectId, limit: 1)
                  .then((list) => list.isNotEmpty ? list.first : null),
              builder: (context, snap) {
                if (!snap.hasData) return const SizedBox.shrink();
                final kpi = snap.data;
                if (kpi == null) return const SizedBox.shrink();
                return _KpiCard(kpi: kpi);
              },
            ),
            const SizedBox(height: 20),

            // Burndown
            const Text('Burndown Chart', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
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
                totalPoints: sprint.plannedPoints,
                actualRemaining: _buildBurndown(),
              ),
            ),
            const SizedBox(height: 20),

            // Task board
            const Text('Task Board', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            StreamBuilder<List<TaskModel>>(
              stream: TaskRepository().watchTasks(projectId),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                final tasks = snap.data!.where((t) => t.sprintId == sprint.id).toList();
                return _TaskBoard(tasks: tasks, projectId: projectId, userRole: userRole);
              },
            ),
          ],
        ),
      ),
    );
  }

  List<double> _buildBurndown() {
    final pointsPerDay = sprint.plannedPoints / 14;
    final doneRatio = sprint.completedPoints / (sprint.plannedPoints == 0 ? 1 : sprint.plannedPoints);
    final doneDay = (doneRatio * 14).round();
    return List.generate(doneDay + 1, (i) => (sprint.plannedPoints - pointsPerDay * i).clamp(0, sprint.plannedPoints.toDouble()));
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final KpiSnapshotModel kpi;
  const _KpiCard({required this.kpi});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Metric('SV', KpiCalculator.formatCurrency(kpi.sv), kpi.sv >= 0),
          _Divider(),
          _Metric('SPI', KpiCalculator.formatIndex(kpi.spi), kpi.spi >= 0.95),
          _Divider(),
          _Metric('CPI', KpiCalculator.formatIndex(kpi.cpi), kpi.cpi >= 0.95),
          _Divider(),
          _Metric('CV', KpiCalculator.formatCurrency(kpi.cv), kpi.cv >= 0),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final bool good;
  const _Metric(this.label, this.value, this.good);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: good ? AppColors.success : AppColors.danger,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: AppColors.border);
  }
}

class _TaskBoard extends StatelessWidget {
  final List<TaskModel> tasks;
  final String projectId;
  final String userRole;

  const _TaskBoard({required this.tasks, required this.projectId, required this.userRole});

  @override
  Widget build(BuildContext context) {
    final columns = [
      ('Backlog', tasks.where((t) => t.status == 'backlog').toList(), AppColors.textMuted),
      ('In Progress', tasks.where((t) => t.status == 'in_progress').toList(), AppColors.warning),
      ('Done', tasks.where((t) => t.status == 'done').toList(), AppColors.success),
    ];

    return Column(
      children: columns.map((col) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: col.$3, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(col.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(width: 6),
                Text('(${col.$2.length})', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 8),
            ...col.$2.map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskDetailScreen(task: task, projectId: projectId, userRole: userRole),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(task.title, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${task.storyPoints} pts',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }
}
