import 'package:flutter/foundation.dart';
import '../../data/models/sprint_model.dart';
import '../../data/repositories/sprint_repository.dart';

class SprintProvider extends ChangeNotifier {
  final SprintRepository _repo = SprintRepository();

  List<SprintModel> _sprints = [];
  SprintModel? _activeSprint;
  String? _error;

  List<SprintModel> get sprints => _sprints;
  SprintModel? get activeSprint => _activeSprint;
  String? get error => _error;

  void watchSprints(String projectId) {
    _repo.watchSprints(projectId).listen(
      (sprints) {
        _error = null;
        _sprints = sprints;
        _activeSprint = sprints.where((s) => s.status == 'active').isNotEmpty
            ? sprints.firstWhere((s) => s.status == 'active')
            : null;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('SprintProvider error: $e');
        _error = 'Unable to reach Firebase emulator.';
        notifyListeners();
      },
    );
  }

  List<double> get velocities => _sprints.map((s) => s.velocity).toList();
}
