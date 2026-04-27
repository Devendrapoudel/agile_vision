import 'package:flutter/foundation.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/project_repository.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectRepository _repo = ProjectRepository();

  List<ProjectModel> _projects = [];
  ProjectModel? _selectedProject;
  String? _error;

  List<ProjectModel> get projects => _projects;
  ProjectModel? get selectedProject => _selectedProject;
  String? get error => _error;

  void watchProjects() {
    _repo.watchProjects().listen(
      (projects) {
        _error = null;
        _projects = projects;
        if (_selectedProject == null && projects.isNotEmpty) {
          _selectedProject = projects.first;
        }
        notifyListeners();
      },
      onError: (e) {
        debugPrint('ProjectProvider error: $e');
        _error = 'Unable to reach Firebase emulator. Is it running?\nRun: firebase emulators:start --only firestore,auth,functions';
        notifyListeners();
      },
    );
  }

  void selectProject(ProjectModel project) {
    _selectedProject = project;
    notifyListeners();
  }
}
