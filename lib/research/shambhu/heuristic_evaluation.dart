class HeuristicEvaluation {
  // Nielsen's 10 Heuristics scores (1-10 scale)
  static const Map<String, String> heuristicNames = {
    'H1': 'Visibility of system status',
    'H2': 'Match between system and real world',
    'H3': 'User control and freedom',
    'H4': 'Consistency and standards',
    'H5': 'Error prevention',
    'H6': 'Recognition rather than recall',
    'H7': 'Flexibility and efficiency of use',
    'H8': 'Aesthetic and minimalist design',
    'H9': 'Help users recognise, diagnose, and recover from errors',
    'H10': 'Help and documentation',
  };

  // Benchmark heuristic scores for AgileVision
  static const Map<String, double> scores = {
    'H1': 9.0,
    'H2': 8.5,
    'H3': 7.5,
    'H4': 9.0,
    'H5': 8.0,
    'H6': 9.0,
    'H7': 7.5,
    'H8': 9.5,
    'H9': 7.0,
    'H10': 6.5,
  };

  static double get averageScore {
    final vals = scores.values;
    return vals.reduce((a, b) => a + b) / vals.length;
  }

  // Time-to-Insight benchmark (seconds to spot a risk from login)
  static const Map<String, double> ttiResults = {
    'Expert user': 8.2,
    'Intermediate user': 14.5,
    'Novice user': 22.1,
    'Target (SLA)': 30.0,
  };

  // Cognitive load: metrics per screen
  static const Map<String, int> metricsPerScreen = {
    'Dashboard': 4,
    'Schedule': 8,
    'Cost': 9,
    'Infrastructure': 10,
    'Task List': 3,
  };
}
