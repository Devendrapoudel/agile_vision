class AppConstants {
  // App info
  static const String appName = 'AgileVision';
  static const String appVersion = '1.0.0';
  static const String universityName = 'University of the West of Scotland';

  // Firebase collections
  static const String usersCollection = 'users';
  static const String projectsCollection = 'projects';
  static const String sprintsCollection = 'sprints';
  static const String tasksCollection = 'tasks';
  static const String kpiSnapshotsCollection = 'kpi_snapshots';

  // User roles
  static const String roleManager = 'manager';
  static const String roleDeveloper = 'developer';

  // Task statuses
  static const String taskBacklog = 'backlog';
  static const String taskInProgress = 'in_progress';
  static const String taskDone = 'done';

  // Sprint statuses
  static const String sprintActive = 'active';
  static const String sprintCompleted = 'completed';
  static const String sprintPlanned = 'planned';

  // Project statuses
  static const String projectActive = 'active';
  static const String projectCompleted = 'completed';
  static const String projectPlanned = 'planned';

  // KPI thresholds
  static const double spiGoodThreshold = 0.95;
  static const double spiWarningThreshold = 0.80;
  static const double cpiGoodThreshold = 0.95;
  static const double cpiWarningThreshold = 0.80;

  // Emulator hosts
  static const String emulatorHost = 'localhost';
  static const int firestorePort = 8080;
  static const int authPort = 9099;
  static const int functionsPort = 5001;
}
