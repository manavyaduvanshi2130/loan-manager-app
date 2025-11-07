import 'package:intl/intl.dart';
import 'constants.dart';

class AppHelpers {
  // Currency formatting
  static String formatCurrency(
    double amount, {
    String currency = AppConstants.currencyINR,
  }) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String _getCurrencySymbol(String currency) {
    switch (currency) {
      case AppConstants.currencyINR:
        return '₹';
      case AppConstants.currencyUSD:
        return '\$';
      case AppConstants.currencyEUR:
        return '€';
      default:
        return '₹';
    }
  }

  // Date formatting
  static String formatDate(
    DateTime date, {
    String format = AppConstants.dateFormat,
  }) {
    final formatter = DateFormat(format);
    return formatter.format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return formatDate(dateTime, format: AppConstants.dateTimeFormat);
  }

  static String formatMonthYear(DateTime date) {
    return formatDate(date, format: AppConstants.monthYearFormat);
  }

  // Percentage formatting
  static String formatPercentage(double value, {int decimalPlaces = 2}) {
    return '${value.toStringAsFixed(decimalPlaces)}%';
  }

  // Phone number formatting
  static String formatPhoneNumber(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    return phone;
  }

  // Validation helpers
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\d{10}$');
    return phoneRegex.hasMatch(phone);
  }

  static bool isValidLoanAmount(double amount) {
    return amount >= AppConstants.minLoanAmount &&
        amount <= AppConstants.maxLoanAmount;
  }

  static bool isValidTenure(int months) {
    return months >= AppConstants.minTenureMonths &&
        months <= AppConstants.maxTenureMonths;
  }

  static bool isValidInterestRate(double rate) {
    return rate >= 0 && rate <= 50; // 0% to 50%
  }

  // String helpers
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Loan status helpers
  static String getLoanStatusText(String status) {
    switch (status) {
      case 'active':
        return AppConstants.loanStatusActive;
      case 'completed':
        return AppConstants.loanStatusCompleted;
      case 'defaulted':
        return AppConstants.loanStatusDefaulted;
      default:
        return status;
    }
  }

  // Calculate age in years
  static int calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Generate unique ID (simple implementation)
  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Calculate days between dates
  static int daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    DateTime now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  // Get relative time string
  static String getRelativeTime(DateTime date) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return formatDate(date);
    }
  }
}
