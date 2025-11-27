// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Money Tracker';
  static const String appVersion = '1.0.0';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Validation
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int maxNotesLength = 500;
  static const double minLoanAmount = 1.0;
  static const double maxLoanAmount = 100000000.0; // 10 crore
  static const int minInstallments = 1;
  static const int maxInstallments = 1200; // 100 years
  
  // Date
  static const int maxFutureDays = 365;
  static const int maxPastYears = 10;
  
  // Currency
  static const String currencySymbol = '₹';
  static const String currencyCode = 'INR';
  static const int decimalPlaces = 2;
  
  // Storage Keys
  static const String pinKey = 'user_pin';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String themeKey = 'theme_mode';
  
  // Performance
  static const int debounceMilliseconds = 300;
  static const int searchMinCharacters = 2;
}
