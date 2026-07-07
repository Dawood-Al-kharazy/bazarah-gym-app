import 'package:intl/intl.dart';

class DateFormatter {
  static String formatArabic(DateTime date) {
    return DateFormat('yyyy MMM d', 'ar').format(date);
  }

  static bool isExpired(DateTime endDate) {
    final now = DateTime.now();
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return end.difference(today).inDays < 0;
  }

  static int daysLeft(DateTime endDate) {
    final now = DateTime.now();
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return end.difference(today).inDays;
  }
}
