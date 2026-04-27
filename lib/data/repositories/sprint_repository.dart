import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sprint_model.dart';

class SprintRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<SprintModel>> watchSprints(String projectId) {
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('sprints')
        .orderBy('sprintNumber')
        .snapshots()
        .map((snap) => snap.docs.map(SprintModel.fromFirestore).toList());
  }

  Future<List<SprintModel>> getSprints(String projectId) async {
    final snap = await _db
        .collection('projects')
        .doc(projectId)
        .collection('sprints')
        .orderBy('sprintNumber')
        .get();
    return snap.docs.map(SprintModel.fromFirestore).toList();
  }

  Future<SprintModel?> getActiveSprint(String projectId) async {
    final snap = await _db
        .collection('projects')
        .doc(projectId)
        .collection('sprints')
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return SprintModel.fromFirestore(snap.docs.first);
  }
}
