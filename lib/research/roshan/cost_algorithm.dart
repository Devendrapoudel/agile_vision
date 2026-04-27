class CostAlgorithm {
  // Earned Value: EV = (Completed Story Points / Total Story Points) × BAC
  static double calculateEV(int completedPoints, int totalPoints, double bac) {
    if (totalPoints == 0) return 0;
    return (completedPoints / totalPoints) * bac;
  }

  // Cost Variance: CV = EV - AC
  static double calculateCV(double earnedValue, double actualCost) {
    return earnedValue - actualCost;
  }

  // Cost Performance Index: CPI = EV / AC
  static double calculateCPI(double earnedValue, double actualCost) {
    if (actualCost == 0) return 1.0;
    return earnedValue / actualCost;
  }

  // Estimate at Completion: EAC = BAC / CPI
  static double calculateEAC(double bac, double cpi) {
    if (cpi == 0) return bac;
    return bac / cpi;
  }

  // Estimate to Complete: ETC = EAC - AC
  static double calculateETC(double eac, double actualCost) {
    return eac - actualCost;
  }

  // To-Complete Performance Index: TCPI = (BAC - EV) / (BAC - AC)
  static double calculateTCPI(double bac, double earnedValue, double actualCost) {
    final denominator = bac - actualCost;
    if (denominator == 0) return 1.0;
    return (bac - earnedValue) / denominator;
  }

  // Mean Absolute Percentage Error — forecast accuracy
  static double calculateMAPE(List<double> predicted, List<double> actual) {
    if (predicted.isEmpty || predicted.length != actual.length) return 0;
    double totalError = 0;
    for (int i = 0; i < predicted.length; i++) {
      if (actual[i] != 0) {
        totalError += ((predicted[i] - actual[i]) / actual[i]).abs();
      }
    }
    return (totalError / predicted.length) * 100;
  }

  // Budget Burn Rate %
  static double calculateBurnRate(double actualCost, double bac) {
    if (bac == 0) return 0;
    return (actualCost / bac) * 100;
  }

  // Sensitivity analysis: CPI response to velocity changes
  static Map<String, double> sensitivityAnalysis({
    required int completedPoints,
    required int totalPoints,
    required double bac,
    required double actualCost,
    double variationPercent = 20,
  }) {
    final baseCPI = calculateCPI(
      calculateEV(completedPoints, totalPoints, bac),
      actualCost,
    );

    final optimisticPoints = (completedPoints * (1 + variationPercent / 100)).round();
    final pessimisticPoints = (completedPoints * (1 - variationPercent / 100)).round();

    final optimisticCPI = calculateCPI(
      calculateEV(optimisticPoints, totalPoints, bac),
      actualCost,
    );
    final pessimisticCPI = calculateCPI(
      calculateEV(pessimisticPoints, totalPoints, bac),
      actualCost,
    );

    return {
      'base': baseCPI,
      'optimistic': optimisticCPI,
      'pessimistic': pessimisticCPI,
    };
  }
}
