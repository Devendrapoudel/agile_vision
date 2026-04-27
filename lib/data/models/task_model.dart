import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final int storyPoints;
  final String status;
  final String assigneeId;
  final String sprintId;
  final DateTime? completedAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.storyPoints,
    required this.status,
    required this.assigneeId,
    required this.sprintId,
    this.completedAt,
    required this.updatedAt,
  });

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      storyPoints: (data['storyPoints'] as num?)?.toInt() ?? 0,
      status: data['status'] ?? 'backlog',
      assigneeId: data['assigneeId'] ?? '',
      sprintId: data['sprintId'] ?? '',
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'description': description,
    'storyPoints': storyPoints,
    'status': status,
    'assigneeId': assigneeId,
    'sprintId': sprintId,
    'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  TaskModel copyWith({String? status, DateTime? completedAt, DateTime? updatedAt}) {
    return TaskModel(
      id: id,
      title: title,
      description: description,
      storyPoints: storyPoints,
      status: status ?? this.status,
      assigneeId: assigneeId,
      sprintId: sprintId,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
