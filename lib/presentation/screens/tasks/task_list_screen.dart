import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../providers/task_provider.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  final String projectId;
  final String userRole;

  const TaskListScreen({super.key, required this.projectId, required this.userRole});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tasks'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'All (${provider.tasks.length})'),
            Tab(text: 'Backlog (${provider.backlogTasks.length})'),
            Tab(text: 'In Progress (${provider.inProgressTasks.length})'),
            Tab(text: 'Done (${provider.doneTasks.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _TaskList(tasks: provider.tasks, projectId: widget.projectId, userRole: widget.userRole),
          _TaskList(tasks: provider.backlogTasks, projectId: widget.projectId, userRole: widget.userRole),
          _TaskList(tasks: provider.inProgressTasks, projectId: widget.projectId, userRole: widget.userRole),
          _TaskList(tasks: provider.doneTasks, projectId: widget.projectId, userRole: widget.userRole),
        ],
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<TaskModel> tasks;
  final String projectId;
  final String userRole;

  const _TaskList({required this.tasks, required this.projectId, required this.userRole});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text('No tasks here', style: TextStyle(color: AppColors.textMuted)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _TaskCard(
        task: tasks[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailScreen(task: tasks[i], projectId: projectId, userRole: userRole),
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const _TaskCard({required this.task, required this.onTap});

  Color get _statusColor {
    switch (task.status) {
      case 'done': return AppColors.success;
      case 'in_progress': return AppColors.warning;
      default: return AppColors.textMuted;
    }
  }

  Color get _statusBg {
    switch (task.status) {
      case 'done': return AppColors.successLight;
      case 'in_progress': return AppColors.warningLight;
      default: return AppColors.surfaceVariant;
    }
  }

  String get _statusLabel {
    switch (task.status) {
      case 'done': return 'Done';
      case 'in_progress': return 'In Progress';
      default: return 'Backlog';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(color: _statusColor, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: _statusBg, borderRadius: BorderRadius.circular(20)),
                        child: Text(_statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _statusColor)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          '${task.storyPoints} pts',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
