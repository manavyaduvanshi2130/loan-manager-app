class AppConstants {
  // App Info
  static const String appName = 'Loan Management System';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'loan_management.db';
  static const int databaseVersion = 1;

  // Loan Status
  static const String loanStatusActive = 'Active';
  static const String loanStatusCompleted = 'Completed';
  static const String loanStatusDefaulted = 'Defaulted';

  // Currencies
  static const String currencyINR = 'INR';
  static const String currencyUSD = 'USD';
  static const String currencyEUR = 'EUR';

  // Languages
  static const String languageEnglish = 'en';
  static const String languageHindi = 'hi';
  static const String languageSpanish = 'es';

  // Default Values
  static const double defaultInterestRate = 12.0; // 12% per annum
  static const int defaultTenureMonths = 12;
  static const int minTenureMonths = 1;
  static const int maxTenureMonths = 360; // 30 years

  // Validation
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int phoneNumberLength = 10;
  static const double minLoanAmount = 1000.0;
  static const double maxLoanAmount = 10000000.0; // 1 crore

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultElevation = 2.0;

  // Colors (Hex codes for reference)
  static const String primaryColor = '#1976D2';
  static const String secondaryColor = '#DC004E';
  static const String successColor = '#4CAF50';
  static const String warningColor = '#FF9800';
  static const String errorColor = '#F44336';

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String monthYearFormat = 'MM/yyyy';

  // Payment Status
  static const String paymentStatusPending = 'Pending';
  static const String paymentStatusCompleted = 'Completed';
  static const String paymentStatusOverdue = 'Overdue';

  // Analytics
  static const int defaultAnalyticsLimit = 10;
  static const int paymentTrendsMonths = 12;

  // File Extensions
  static const String pdfExtension = '.pdf';
  static const String csvExtension = '.csv';
  static const String jsonExtension = '.json';
}
