class KpiCalculator {
  static String formatCurrency(double value) {
    final abs = value.abs();
    final prefix = value < 0 ? '-£' : '£';
    if (abs >= 1000) {
      return '$prefix${(abs / 1000).toStringAsFixed(1)}k';
    }
    return '$prefix${abs.toStringAsFixed(0)}';
  }

  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  static String formatIndex(double value) {
    return value.toStringAsFixed(2);
  }

  static String getStatusLabel(double cpi, double spi) {
    if (cpi >= 0.95 && spi >= 0.95) return 'On Track';
    if (cpi >= 0.80 && spi >= 0.80) return 'At Risk';
    return 'Critical';
  }

  static String formatMs(int ms) {
    return '${ms}ms';
  }
}
