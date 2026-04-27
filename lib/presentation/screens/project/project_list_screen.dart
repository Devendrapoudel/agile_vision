import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/project_model.dart';
import '../../providers/project_provider.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends StatelessWidget {
  final String userRole;
  const ProjectListScreen({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProjectProvider>();
    final projects = provider.projects;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Projects')),
      body: projects.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _ProjectCard(
                project: projects[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProjectDetailScreen(project: projects[i], userRole: userRole),
                  ),
                ),
              ),
            ),
      floatingActionButton: userRole == 'manager'
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create project — coming soon')),
              ),
            )
          : null,
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;

  const _ProjectCard({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = project.status == 'active'
        ? AppColors.success
        : project.status == 'planned'
            ? AppColors.info
            : AppColors.textMuted;
    final statusBg = project.status == 'active'
        ? AppColors.successLight
        : project.status == 'planned'
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
                    project.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    project.status.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              project.description,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _Chip(icon: Icons.people_outline, label: '${project.teamSize} members'),
                const SizedBox(width: 12),
                _Chip(icon: Icons.task_alt_outlined, label: '${project.totalStoryPoints} pts'),
                const SizedBox(width: 12),
                _Chip(
                  icon: Icons.account_balance_wallet_outlined,
                  label: '£${(project.bac / 1000).toStringAsFixed(0)}k BAC',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${DateFormat('dd MMM').format(project.startDate)} — ${DateFormat('dd MMM yyyy').format(project.endDate)}',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
