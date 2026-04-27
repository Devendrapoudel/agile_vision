import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;
  final String projectId;
  final String userRole;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.projectId,
    required this.userRole,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late String _status;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.task.status;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() { _saving = true; });
    try {
      await TaskRepository().updateTaskStatus(widget.projectId, widget.task.id, newStatus);
      if (mounted) {
        setState(() { _status = newStatus; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'done'
                  ? 'Task marked done — KPI recalculation triggered!'
                  : 'Status updated to ${newStatus.replaceAll('_', ' ')}',
            ),
            backgroundColor: newStatus == 'done' ? AppColors.success : AppColors.primary,
          ),
        );
        if (newStatus == 'done') {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() { _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Task Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task card
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
                  Text(
                    task.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    task.description,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                  ),
                  const Divider(height: 24),
                  _Row('Story Points', '${task.storyPoints} pts'),
                  _Row('Sprint', task.sprintId),
                  _Row('Assignee', task.assigneeId),
                  _Row('Updated', DateFormat('dd MMM yyyy, HH:mm').format(task.updatedAt)),
                  if (task.completedAt != null)
                    _Row('Completed', DateFormat('dd MMM yyyy, HH:mm').format(task.completedAt!)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Update Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 12),

            // Status selector
            ...[('backlog', 'Backlog', Icons.inbox_outlined, AppColors.textMuted),
                ('in_progress', 'In Progress', Icons.pending_outlined, AppColors.warning),
                ('done', 'Done', Icons.check_circle_outline, AppColors.success)].map((s) {
              final isSelected = _status == s.$1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: (_saving || isSelected) ? null : () => _updateStatus(s.$1),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? s.$4.withOpacity(0.08) : AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? s.$4 : AppColors.border, width: isSelected ? 2 : 1),
                    ),
                    child: Row(
                      children: [
                        Icon(s.$3, color: isSelected ? s.$4 : AppColors.textMuted, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          s.$2,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? s.$4 : AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected) Icon(Icons.check, color: s.$4, size: 18),
                      ],
                    ),
                  ),
                ),
              );
            }),

            if (_saving) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ],

            const SizedBox(height: 20),
            if (_status != 'done') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Marking this task as Done will trigger the Cloud Function to recalculate all KPIs.',
                        style: TextStyle(fontSize: 12, color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
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
