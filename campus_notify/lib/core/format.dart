/// Utility fungsi murni untuk format tanggal dan parsing rute
class AppFormatters {
  AppFormatters._();

  /// Format DateTime ke format ringkas YYYY-MM-DD HH:mm
  static String formatDateTime(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    final h = dateTime.hour.toString().padLeft(2, '0');
    final min = dateTime.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }

  /// Ekstraksi ID dari rute bertipe path parameter (misal: "/announcements/42" -> "42")
  static String? extractIdFromPath(String path, String prefix) {
    if (!path.startsWith(prefix)) return null;
    final sub = path.substring(prefix.length);
    final segments = sub.split('/').where((s) => s.isNotEmpty).toList();
    return segments.isEmpty ? null : segments.first;
  }
}