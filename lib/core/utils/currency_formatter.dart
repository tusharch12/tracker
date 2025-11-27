import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    symbol: AppConstants.currencySymbol,
    decimalDigits: AppConstants.decimalPlaces,
    locale: 'en_IN', // Indian locale for comma placement
  );

  /// Format amount as currency (e.g., ₹1,25,000.00)
  static String format(double amount) {
    return _formatter.format(amount);
  }

  /// Format amount in compact form (e.g., ₹1.25L, ₹1.5Cr)
  static String formatCompact(double amount) {
    if (amount >= 10000000) {
      // 1 crore or more
      return '${AppConstants.currencySymbol}${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      // 1 lakh or more
      return '${AppConstants.currencySymbol}${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      // 1 thousand or more
      return '${AppConstants.currencySymbol}${(amount / 1000).toStringAsFixed(2)}K';
    } else {
      return format(amount);
    }
  }

  /// Format amount without symbol (e.g., 1,25,000.00)
  static String formatWithoutSymbol(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: AppConstants.decimalPlaces,
      locale: 'en_IN',
    );
    return formatter.format(amount).trim();
  }

  /// Parse currency string to double
  static double? parse(String value) {
    try {
      // Remove currency symbol and commas
      final cleaned = value
          .replaceAll(AppConstants.currencySymbol, '')
          .replaceAll(',', '')
          .trim();
      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }

  /// Format for input field (no symbol, with commas)
  static String formatForInput(double amount) {
    return formatWithoutSymbol(amount);
  }
}
