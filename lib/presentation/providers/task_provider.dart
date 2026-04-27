import 'package:flutter/foundation.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repo = TaskRepository();

  List<TaskModel> _tasks = [];
  String? _error;

  List<TaskModel> get tasks => _tasks;
  String? get error => _error;

  List<TaskModel> get backlogTasks => _tasks.where((t) => t.status == 'backlog').toList();
  List<TaskModel> get inProgressTasks => _tasks.where((t) => t.status == 'in_progress').toList();
  List<TaskModel> get doneTasks => _tasks.where((t) => t.status == 'done').toList();

  int get completedPoints => doneTasks.fold(0, (sum, t) => sum + t.storyPoints);
  int get totalPoints => _tasks.fold(0, (sum, t) => sum + t.storyPoints);

  void watchTasks(String projectId) {
    _repo.watchTasks(projectId).listen(
      (tasks) {
        _error = null;
        _tasks = tasks;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('TaskProvider error: $e');
        _error = 'Unable to reach Firebase emulator.';
        notifyListeners();
      },
    );
  }

  Future<void> updateStatus(String projectId, String taskId, String status) async {
    await _repo.updateTaskStatus(projectId, taskId, status);
  }
}
