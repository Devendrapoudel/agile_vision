import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/kpi_calculator.dart';
import '../../../data/models/project_model.dart';
import '../../../data/repositories/sprint_repository.dart';
import '../../../data/models/sprint_model.dart';
import '../sprint/sprint_list_screen.dart';

class ProjectDetailScreen extends StatelessWidget {
  final ProjectModel project;
  final String userRole;

  const ProjectDetailScreen({super.key, required this.project, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(project.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview card
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
                  Text(project.description, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
                  const Divider(height: 24),
                  _row('Status', project.status.toUpperCase()),
                  _row('Team Size', '${project.teamSize} members'),
                  _row('Budget (BAC)', KpiCalculator.formatCurrency(project.bac)),
                  _row('Story Points', '${project.totalStoryPoints} pts total'),
                  _row('Start Date', DateFormat('dd MMM yyyy').format(project.startDate)),
                  _row('End Date', DateFormat('dd MMM yyyy').format(project.endDate)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Sprints', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 12),

            FutureBuilder<List<SprintModel>>(
              future: SprintRepository().getSprints(project.id),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                final sprints = snap.data!;
                return Column(
                  children: [
                    ...sprints.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _SprintTile(sprint: s),
                        )),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.list_outlined),
                        label: const Text('View All Sprints'),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SprintListScreen(project: project, userRole: userRole),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _SprintTile extends StatelessWidget {
  final SprintModel sprint;
  const _SprintTile({required this.sprint});

  @override
  Widget build(BuildContext context) {
    final statusColor = sprint.status == 'active'
        ? AppColors.success
        : sprint.status == 'completed'
            ? AppColors.info
            : AppColors.textMuted;
    final progress = sprint.completionPercentage / 100;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sprint ${sprint.sprintNumber}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  sprint.status.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceVariant,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${sprint.completedPoints}/${sprint.plannedPoints} pts  •  ${sprint.completionPercentage.toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
