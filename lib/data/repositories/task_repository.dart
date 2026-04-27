import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<TaskModel>> watchTasks(String projectId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .snapshots()
        .map((snap) => snap.docs.map(TaskModel.fromFirestore).toList());
  }

  Future<List<TaskModel>> getTasks(String projectId) async {
    final snap = await _db
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .get();
    return snap.docs.map(TaskModel.fromFirestore).toList();
  }

  Future<void> updateTaskStatus(
    String projectId,
    String taskId,
    String newStatus,
  ) async {
    await _db
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc(taskId)
        .update({
      'status': newStatus,
      'completedAt': newStatus == 'done' ? DateTime.now() : null,
      'updatedAt': DateTime.now(),
    });

    // KPI recalculation is handled by the Cloud Function (onTaskStatusChange)
    // which triggers automatically on every task write.
  }
}
