import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  /// Format date as 'MMM dd, yyyy' (e.g., 'Jan 15, 2025')
  String toFormattedDate() {
    return DateFormat('MMM dd, yyyy').format(this);
  }

  /// Format date as 'dd/MM/yyyy'
  String toShortDate() {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// Format date and time as 'MMM dd, yyyy hh:mm a'
  String toFormattedDateTime() {
    return DateFormat('MMM dd, yyyy hh:mm a').format(this);
  }

  /// Get timestamp in milliseconds
  int toTimestamp() {
    return millisecondsSinceEpoch;
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is in the past
  bool get isPast {
    return isBefore(DateTime.now());
  }

  /// Check if date is in the future
  bool get isFuture {
    return isAfter(DateTime.now());
  }

  /// Get start of day (00:00:00)
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get end of day (23:59:59)
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59);
  }

  /// Add months handling edge cases (e.g., Jan 31 + 1 month = Feb 28/29)
  DateTime addMonthsSafe(int months) {
    int newYear = year;
    int newMonth = month + months;

    while (newMonth > 12) {
      newMonth -= 12;
      newYear++;
    }

    while (newMonth < 1) {
      newMonth += 12;
      newYear--;
    }

    // Handle day overflow (e.g., Jan 31 -> Feb 28)
    int newDay = day;
    int daysInNewMonth = DateTime(newYear, newMonth + 1, 0).day;
    if (newDay > daysInNewMonth) {
      newDay = daysInNewMonth;
    }

    return DateTime(newYear, newMonth, newDay, hour, minute, second);
  }

  /// Get relative time string (e.g., 'Today', 'Yesterday', '2 days ago')
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (isToday) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }
}

/// Create DateTime from timestamp
DateTime dateTimeFromTimestamp(int timestamp) {
  return DateTime.fromMillisecondsSinceEpoch(timestamp);
}

/// Get current timestamp
int getCurrentTimestamp() {
  return DateTime.now().millisecondsSinceEpoch;
}
