import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/kpi_snapshot_model.dart';

class KpiRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<KpiSnapshotModel?> watchLatestSnapshot(String projectId) {
    // Watch the fixed 'kpi_live' document — always overwritten by the Cloud
    // Function and seeder with the latest values. Avoids orderBy timestamp
    // issues in the emulator where insertion order != timestamp order.
    return _db
        .collection('projects')
        .doc(projectId)
        .collection('kpi_snapshots')
        .doc('kpi_live')
        .snapshots()
        .map((snap) {
      if (!snap.exists) return null;
      return KpiSnapshotModel.fromFirestore(snap);
    });
  }

  Future<List<KpiSnapshotModel>> getSnapshots(String projectId, {int limit = 10}) async {
    final snap = await _db
        .collection('projects')
        .doc(projectId)
        .collection('kpi_snapshots')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map(KpiSnapshotModel.fromFirestore).toList();
  }

}
