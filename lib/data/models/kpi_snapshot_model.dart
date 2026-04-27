import 'package:cloud_firestore/cloud_firestore.dart';

class KpiSnapshotModel {
  final String id;
  final DateTime timestamp;
  final String triggeredBy;
  final double sv;
  final double spi;
  final double cv;
  final double cpi;
  final double eac;
  final double etc;
  final double tcpi;
  final double earnedValue;
  final double actualCost;
  final double plannedValue;
  final double wmaVelocity;
  final DateTime? estimatedCompletionDate;
  final int calculationLatencyMs;
  final double maeScore;
  final double mapeScore;

  const KpiSnapshotModel({
    required this.id,
    required this.timestamp,
    required this.triggeredBy,
    required this.sv,
    required this.spi,
    required this.cv,
    required this.cpi,
    required this.eac,
    required this.etc,
    required this.tcpi,
    required this.earnedValue,
    required this.actualCost,
    required this.plannedValue,
    required this.wmaVelocity,
    this.estimatedCompletionDate,
    required this.calculationLatencyMs,
    required this.maeScore,
    required this.mapeScore,
  });

  factory KpiSnapshotModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KpiSnapshotModel(
      id: doc.id,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      triggeredBy: data['triggeredBy'] ?? '',
      sv: (data['sv'] as num?)?.toDouble() ?? 0,
      spi: (data['spi'] as num?)?.toDouble() ?? 1,
      cv: (data['cv'] as num?)?.toDouble() ?? 0,
      cpi: (data['cpi'] as num?)?.toDouble() ?? 1,
      eac: (data['eac'] as num?)?.toDouble() ?? 0,
      etc: (data['etc'] as num?)?.toDouble() ?? 0,
      tcpi: (data['tcpi'] as num?)?.toDouble() ?? 1,
      earnedValue: (data['earnedValue'] as num?)?.toDouble() ?? 0,
      actualCost: (data['actualCost'] as num?)?.toDouble() ?? 0,
      plannedValue: (data['plannedValue'] as num?)?.toDouble() ?? 0,
      wmaVelocity: (data['wmaVelocity'] as num?)?.toDouble() ?? 0,
      estimatedCompletionDate:
          (data['estimatedCompletionDate'] as Timestamp?)?.toDate(),
      calculationLatencyMs: (data['calculationLatencyMs'] as num?)?.toInt() ?? 0,
      maeScore: (data['maeScore'] as num?)?.toDouble() ?? 0,
      mapeScore: (data['mapeScore'] as num?)?.toDouble() ?? 0,
    );
  }
}
