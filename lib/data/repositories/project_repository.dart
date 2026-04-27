import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';

class ProjectRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ProjectModel>> watchProjects() {
    return _db.collection('projects').snapshots().map(
      (snap) => snap.docs.map(ProjectModel.fromFirestore).toList(),
    );
  }

  Future<ProjectModel?> getProject(String projectId) async {
    final doc = await _db.collection('projects').doc(projectId).get();
    if (!doc.exists) return null;
    return ProjectModel.fromFirestore(doc);
  }

  Future<void> createProject(ProjectModel project) async {
    await _db.collection('projects').add(project.toFirestore());
  }
}
