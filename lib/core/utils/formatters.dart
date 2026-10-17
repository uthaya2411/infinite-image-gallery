class AppFormatters {
  /// Formats numbers to compact representations (e.g., 14.5k, 2.3M)
  static String formatCompactNumber(int number) {
    if (number >= 1000000) {
      final value = (number / 1000000).toStringAsFixed(1);
      return value.endsWith('.0') ? '${number ~/ 1000000}M' : '${value}M';
    } else if (number >= 1000) {
      final value = (number / 1000).toStringAsFixed(1);
      return value.endsWith('.0') ? '${number ~/ 1000}k' : '${value}k';
    }
    return number.toString();
  }

  /// Formats file size in bytes to human-readable string
  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double d = bytes.toDouble();
    while (d >= 1024 && i < suffixes.length - 1) {
      d /= 1024;
      i++;
    }
    return '${d.toStringAsFixed(1)} ${suffixes[i]}';
  }
}
