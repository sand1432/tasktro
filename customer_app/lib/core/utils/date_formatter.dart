import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);
  static String formatTime(DateTime date) => DateFormat('h:mm a').format(date);
  static String formatDateTime(DateTime date) => DateFormat('MMM d, yyyy h:mm a').format(date);
  static String formatShort(DateTime date) => DateFormat('MM/dd/yy').format(date);

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y ago';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }

  static String formatPriceRange(double min, double max) {
    return '${formatCurrency(min)} - ${formatCurrency(max)}';
  }
}
