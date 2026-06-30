import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _inrFormatDecimal = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Format as whole INR (e.g., ₹1,45,000)
  static String formatINR(double amount) {
    return _inrFormat.format(amount);
  }

  /// Format with decimals (e.g., ₹1,45,000.50)
  static String formatINRDecimal(double amount) {
    return _inrFormatDecimal.format(amount);
  }

  /// Format date as short string
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'Today';
    } else if (checkDate == yesterday) {
      return 'Yesterday';
    }

    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format date and time
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} • ${DateFormat('hh:mm a').format(date)}';
  }
}
