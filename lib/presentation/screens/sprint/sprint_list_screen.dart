import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/sprint_model.dart';
import '../../../data/repositories/sprint_repository.dart';
import 'sprint_detail_screen.dart';

class SprintListScreen extends StatelessWidget {
  final ProjectModel project;
  final String userRole;

  const SprintListScreen({super.key, required this.project, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('${project.name} — Sprints')),
      body: StreamBuilder<List<SprintModel>>(
        stream: SprintRepository().watchSprints(project.id),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          final sprints = snap.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sprints.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _SprintCard(
              sprint: sprints[i],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SprintDetailScreen(
                    sprint: sprints[i],
                    projectId: project.id,
                    userRole: userRole,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SprintCard extends StatelessWidget {
  final SprintModel sprint;
  final VoidCallback onTap;

  const _SprintCard({required this.sprint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = sprint.status == 'active'
        ? AppColors.success
        : sprint.status == 'completed'
            ? AppColors.info
            : AppColors.textMuted;
    final statusBg = sprint.status == 'active'
        ? AppColors.successLight
        : sprint.status == 'completed'
            ? AppColors.infoLight
            : AppColors.surfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
                Expanded(
                  child: Text(
                    'Sprint ${sprint.sprintNumber}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                  child: Text(sprint.status.toUpperCase(),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(sprint.goal, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: sprint.completionPercentage / 100,
                backgroundColor: AppColors.surfaceVariant,
                color: statusColor,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${sprint.completedPoints}/${sprint.plannedPoints} pts',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                Text(
                  '${DateFormat('dd MMM').format(sprint.startDate)} — ${DateFormat('dd MMM').format(sprint.endDate)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
