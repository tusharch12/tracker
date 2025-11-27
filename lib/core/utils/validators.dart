import '../constants/app_constants.dart';

class Validators {
  /// Validate name (required, min/max length)
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    
    final trimmed = value.trim();
    if (trimmed.length < AppConstants.minNameLength) {
      return 'Name must be at least ${AppConstants.minNameLength} characters';
    }
    
    if (trimmed.length > AppConstants.maxNameLength) {
      return 'Name must not exceed ${AppConstants.maxNameLength} characters';
    }
    
    return null;
  }

  /// Validate phone number (optional, but must be valid if provided)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    final trimmed = value.trim();
    // Basic phone validation: 10 digits, may start with +91
    final phoneRegex = RegExp(r'^(\+91)?[6-9]\d{9}$');
    
    if (!phoneRegex.hasMatch(trimmed.replaceAll(RegExp(r'[\s-]'), ''))) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  /// Validate email (optional, but must be valid if provided)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    final trimmed = value.trim();
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validate amount (required, must be positive and within range)
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    
    final amount = double.tryParse(value.replaceAll(',', ''));
    
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    
    if (amount < AppConstants.minLoanAmount) {
      return 'Amount must be at least ${AppConstants.currencySymbol}${AppConstants.minLoanAmount}';
    }
    
    if (amount > AppConstants.maxLoanAmount) {
      return 'Amount must not exceed ${AppConstants.currencySymbol}${AppConstants.maxLoanAmount}';
    }
    
    return null;
  }

  /// Validate installment amount (required, must be positive and less than principal)
  static String? validateInstallmentAmount(String? value, double? principalAmount) {
    final amountError = validateAmount(value);
    if (amountError != null) return amountError;
    
    if (principalAmount != null) {
      final installment = double.parse(value!.replaceAll(',', ''));
      if (installment > principalAmount) {
        return 'Installment cannot exceed principal amount';
      }
    }
    
    return null;
  }

  /// Validate installments count (optional, but must be valid if provided)
  static String? validateInstallments(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    final count = int.tryParse(value);
    
    if (count == null) {
      return 'Please enter a valid number';
    }
    
    if (count < AppConstants.minInstallments) {
      return 'Installments must be at least ${AppConstants.minInstallments}';
    }
    
    if (count > AppConstants.maxInstallments) {
      return 'Installments must not exceed ${AppConstants.maxInstallments}';
    }
    
    return null;
  }

  /// Validate notes (optional, but must not exceed max length)
  static String? validateNotes(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }
    
    if (value.length > AppConstants.maxNotesLength) {
      return 'Notes must not exceed ${AppConstants.maxNotesLength} characters';
    }
    
    return null;
  }

  /// Validate date is not too far in the past
  static String? validateDate(DateTime? date) {
    if (date == null) {
      return 'Date is required';
    }
    
    final now = DateTime.now();
    final maxPastDate = DateTime(
      now.year - AppConstants.maxPastYears,
      now.month,
      now.day,
    );
    
    if (date.isBefore(maxPastDate)) {
      return 'Date cannot be more than ${AppConstants.maxPastYears} years in the past';
    }
    
    final maxFutureDate = now.add(Duration(days: AppConstants.maxFutureDays));
    if (date.isAfter(maxFutureDate)) {
      return 'Date cannot be more than ${AppConstants.maxFutureDays} days in the future';
    }
    
    return null;
  }

  /// Validate PIN (4-6 digits)
  static String? validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN is required';
    }
    
    if (value.length < 4 || value.length > 6) {
      return 'PIN must be 4-6 digits';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'PIN must contain only digits';
    }
    
    return null;
  }
}
