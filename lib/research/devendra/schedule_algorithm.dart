class ScheduleAlgorithm {
  // Weighted Moving Average Velocity (last 3 sprints, recent weighted higher)
  static double calculateWMAVelocity(List<double> velocities) {
    if (velocities.isEmpty) return 0;
    final recent = velocities.reversed.take(3).toList();
    final weights = [3.0, 2.0, 1.0];
    double weightedSum = 0;
    double weightTotal = 0;
    for (int i = 0; i < recent.length; i++) {
      weightedSum += recent[i] * weights[i];
      weightTotal += weights[i];
    }
    return weightedSum / weightTotal;
  }

  // Schedule Variance: SV = EV - PV
  static double calculateSV(double earnedValue, double plannedValue) {
    return earnedValue - plannedValue;
  }

  // Schedule Performance Index: SPI = EV / PV
  static double calculateSPI(double earnedValue, double plannedValue) {
    if (plannedValue == 0) return 1.0;
    return earnedValue / plannedValue;
  }

  // Estimate completion date based on remaining work and WMA velocity
  static DateTime estimateCompletionDate(
    int remainingStoryPoints,
    double wmaVelocity,
    int sprintLengthDays,
  ) {
    if (wmaVelocity <= 0) return DateTime.now().add(const Duration(days: 999));
    final sprintsRemaining = remainingStoryPoints / wmaVelocity;
    final daysRemaining = sprintsRemaining * sprintLengthDays;
    return DateTime.now().add(Duration(days: daysRemaining.round()));
  }

  // Mean Absolute Error — measures prediction accuracy
  static double calculateMAE(List<double> predicted, List<double> actual) {
    if (predicted.isEmpty || predicted.length != actual.length) return 0;
    double totalError = 0;
    for (int i = 0; i < predicted.length; i++) {
      totalError += (predicted[i] - actual[i]).abs();
    }
    return totalError / predicted.length;
  }

  // Cone of Uncertainty range
  static Map<String, DateTime> coneOfUncertainty(
    int remainingPoints,
    double wmaVelocity,
    int sprintLength,
  ) {
    final base = estimateCompletionDate(remainingPoints, wmaVelocity, sprintLength);
    return {
      'optimistic': base.subtract(const Duration(days: 7)),
      'expected': base,
      'pessimistic': base.add(const Duration(days: 14)),
    };
  }

  // Burndown ideal line: remaining points at each day
  static List<double> idealBurndown(int totalPoints, int sprintDays) {
    final pointsPerDay = totalPoints / sprintDays;
    return List.generate(
      sprintDays + 1,
      (i) => (totalPoints - (pointsPerDay * i)).clamp(0, totalPoints.toDouble()),
    );
  }
}
