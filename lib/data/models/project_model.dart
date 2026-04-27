import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String status;
  final double bac;
  final int totalStoryPoints;
  final DateTime startDate;
  final DateTime endDate;
  final int teamSize;
  final String createdBy;

  const ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.bac,
    required this.totalStoryPoints,
    required this.startDate,
    required this.endDate,
    required this.teamSize,
    required this.createdBy,
  });

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'active',
      bac: (data['bac'] as num?)?.toDouble() ?? 0,
      totalStoryPoints: (data['totalStoryPoints'] as num?)?.toInt() ?? 0,
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      teamSize: (data['teamSize'] as num?)?.toInt() ?? 0,
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'description': description,
    'status': status,
    'bac': bac,
    'totalStoryPoints': totalStoryPoints,
    'startDate': Timestamp.fromDate(startDate),
    'endDate': Timestamp.fromDate(endDate),
    'teamSize': teamSize,
    'createdBy': createdBy,
  };
}
