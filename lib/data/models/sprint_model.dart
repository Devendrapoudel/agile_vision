import 'package:cloud_firestore/cloud_firestore.dart';

class SprintModel {
  final String id;
  final int sprintNumber;
  final String goal;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final int plannedPoints;
  final int completedPoints;
  final double plannedValue;
  final double actualCost;
  final double velocity;

  // Earned Schedule fields (Lipke et al., 2009)
  final double? earnedSchedule;
  final double? scheduleVarianceTime;
  final double? schedulePerformanceIndexTime;

  // Monte Carlo fields (P10/P50/P90)
  final bool monteCarloAvailable;
  final DateTime? monteCarloP10;
  final DateTime? monteCarloP50;
  final DateTime? monteCarloP90;
  final double? monteCarloSpreadSprints;

  // WMA comparison fields
  final double? wmaPredictedVelocity;
  final double? simpleAvgPredictedVelocity;
  final double? wmaAbsoluteError;
  final double? baselineAbsoluteError;

  const SprintModel({
    required this.id,
    required this.sprintNumber,
    required this.goal,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.plannedPoints,
    required this.completedPoints,
    required this.plannedValue,
    required this.actualCost,
    required this.velocity,
    this.earnedSchedule,
    this.scheduleVarianceTime,
    this.schedulePerformanceIndexTime,
    this.monteCarloAvailable = false,
    this.monteCarloP10,
    this.monteCarloP50,
    this.monteCarloP90,
    this.monteCarloSpreadSprints,
    this.wmaPredictedVelocity,
    this.simpleAvgPredictedVelocity,
    this.wmaAbsoluteError,
    this.baselineAbsoluteError,
  });

  double get completionPercentage =>
      plannedPoints > 0 ? (completedPoints / plannedPoints) * 100 : 0;

  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  factory SprintModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SprintModel(
      id: doc.id,
      sprintNumber: (data['sprintNumber'] as num?)?.toInt() ?? 0,
      goal: data['goal'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'planned',
      plannedPoints: (data['plannedPoints'] as num?)?.toInt() ?? 0,
      completedPoints: (data['completedPoints'] as num?)?.toInt() ?? 0,
      plannedValue: (data['plannedValue'] as num?)?.toDouble() ?? 0,
      actualCost: (data['actualCost'] as num?)?.toDouble() ?? 0,
      velocity: (data['velocity'] as num?)?.toDouble() ?? 0,
      earnedSchedule: (data['earnedSchedule'] as num?)?.toDouble(),
      scheduleVarianceTime: (data['scheduleVarianceTime'] as num?)?.toDouble(),
      schedulePerformanceIndexTime: (data['schedulePerformanceIndexTime'] as num?)?.toDouble(),
      monteCarloAvailable: data['monteCarloAvailable'] as bool? ?? false,
      monteCarloP10: data['monteCarloP10'] is Timestamp ? (data['monteCarloP10'] as Timestamp).toDate() : null,
      monteCarloP50: data['monteCarloP50'] is Timestamp ? (data['monteCarloP50'] as Timestamp).toDate() : null,
      monteCarloP90: data['monteCarloP90'] is Timestamp ? (data['monteCarloP90'] as Timestamp).toDate() : null,
      monteCarloSpreadSprints: (data['monteCarloSpreadSprints'] as num?)?.toDouble(),
      wmaPredictedVelocity: (data['wmaPredictedVelocity'] as num?)?.toDouble(),
      simpleAvgPredictedVelocity: (data['simpleAvgPredictedVelocity'] as num?)?.toDouble(),
      wmaAbsoluteError: (data['wmaAbsoluteError'] as num?)?.toDouble(),
      baselineAbsoluteError: (data['baselineAbsoluteError'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'sprintNumber': sprintNumber,
    'goal': goal,
    'startDate': Timestamp.fromDate(startDate),
    'endDate': Timestamp.fromDate(endDate),
    'status': status,
    'plannedPoints': plannedPoints,
    'completedPoints': completedPoints,
    'plannedValue': plannedValue,
    'actualCost': actualCost,
    'velocity': velocity,
  };
}
