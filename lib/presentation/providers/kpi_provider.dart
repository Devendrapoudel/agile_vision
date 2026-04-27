import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/kpi_snapshot_model.dart';
import '../../data/repositories/kpi_repository.dart';

class KpiProvider extends ChangeNotifier {
  final KpiRepository _repo = KpiRepository();

  KpiSnapshotModel? _latestSnapshot;
  List<KpiSnapshotModel> _history = [];
  String? _error;
  Timer? _timeoutTimer;
  bool _loaded = false;

  KpiSnapshotModel? get latestSnapshot => _latestSnapshot;
  List<KpiSnapshotModel> get history => _history;
  String? get error => _error;
  bool get loaded => _loaded;

  void watchKpis(String projectId) {
    _loaded = false;
    _timeoutTimer?.cancel();

    // If kpi_snapshots is empty or emulator is unreachable,
    // the stream emits null forever with no error.
    // After 5 seconds with no data, set loaded=true so screens stop spinning.
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (!_loaded) {
        _loaded = true;
        if (_latestSnapshot == null) {
          _error = 'kpi_snapshots empty — emulator may need restart or reseed';
        }
        notifyListeners();
      }
    });

    _repo.watchLatestSnapshot(projectId).listen(
      (snapshot) {
        _timeoutTimer?.cancel();
        _error = null;
        _loaded = true;
        _latestSnapshot = snapshot;
        notifyListeners();
      },
      onError: (e) {
        _timeoutTimer?.cancel();
        debugPrint('KpiProvider error: $e');
        _error = 'Unable to reach Firebase emulator.';
        _loaded = true;
        notifyListeners();
      },
    );
  }

  Future<void> loadHistory(String projectId) async {
    try {
      _history = await _repo.getSnapshots(projectId);
      _error = null;
    } catch (e) {
      debugPrint('KpiProvider.loadHistory error: $e');
      _error = 'Unable to reach Firebase emulator.';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }
}
