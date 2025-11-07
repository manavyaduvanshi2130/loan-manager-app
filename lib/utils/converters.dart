import '../models/customer_model.dart';
import '../models/loan_model.dart';
import '../models/payment_model.dart';

class DataConverters {
  // JSON Converters for API communication (if needed in future)
  static Map<String, dynamic> customerToJson(Customer customer) {
    return customer.toMap();
  }

  static Customer customerFromJson(Map<String, dynamic> json) {
    return Customer.fromMap(json);
  }

  static Map<String, dynamic> loanToJson(Loan loan) {
    return loan.toMap();
  }

  static Loan loanFromJson(Map<String, dynamic> json) {
    return Loan.fromMap(json);
  }

  static Map<String, dynamic> paymentToJson(Payment payment) {
    return payment.toMap();
  }

  static Payment paymentFromJson(Map<String, dynamic> json) {
    return Payment.fromMap(json);
  }

  // List converters
  static List<Map<String, dynamic>> customersToJson(List<Customer> customers) {
    return customers.map((customer) => customerToJson(customer)).toList();
  }

  static List<Customer> customersFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => customerFromJson(json)).toList();
  }

  static List<Map<String, dynamic>> loansToJson(List<Loan> loans) {
    return loans.map((loan) => loanToJson(loan)).toList();
  }

  static List<Loan> loansFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => loanFromJson(json)).toList();
  }

  static List<Map<String, dynamic>> paymentsToJson(List<Payment> payments) {
    return payments.map((payment) => paymentToJson(payment)).toList();
  }

  static List<Payment> paymentsFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => paymentFromJson(json)).toList();
  }

  // CSV Converters for export functionality
  static String customersToCsv(List<Customer> customers) {
    if (customers.isEmpty) return '';

    List<String> headers = [
      'ID',
      'Name',
      'Email',
      'Phone',
      'Address',
      'Created At',
    ];
    List<List<String>> rows = [headers];

    for (Customer customer in customers) {
      rows.add([
        customer.id?.toString() ?? '',
        customer.name,
        customer.email,
        customer.phone,
        customer.address,
        customer.createdAt.toIso8601String(),
      ]);
    }

    return _listToCsv(rows);
  }

  static String loansToCsv(List<Loan> loans) {
    if (loans.isEmpty) return '';

    List<String> headers = [
      'ID',
      'Customer ID',
      'Principal Amount',
      'Interest Rate',
      'Tenure (Months)',
      'Start Date',
      'Status',
      'Outstanding Amount',
      'Created At',
    ];
    List<List<String>> rows = [headers];

    for (Loan loan in loans) {
      rows.add([
        loan.id?.toString() ?? '',
        loan.customerId.toString(),
        loan.principalAmount.toString(),
        loan.interestRate.toString(),
        loan.tenureMonths.toString(),
        loan.startDate.toIso8601String(),
        loan.status.toString(),
        loan.outstandingAmount?.toString() ?? '',
        loan.createdAt.toIso8601String(),
      ]);
    }

    return _listToCsv(rows);
  }

  static String paymentsToCsv(List<Payment> payments) {
    if (payments.isEmpty) return '';

    List<String> headers = [
      'ID',
      'Loan ID',
      'Amount',
      'Payment Date',
      'Notes',
      'Created At',
    ];
    List<List<String>> rows = [headers];

    for (Payment payment in payments) {
      rows.add([
        payment.id?.toString() ?? '',
        payment.loanId.toString(),
        payment.amount.toString(),
        payment.paymentDate.toIso8601String(),
        payment.notes ?? '',
        payment.createdAt.toIso8601String(),
      ]);
    }

    return _listToCsv(rows);
  }

  static String _listToCsv(List<List<String>> rows) {
    return rows
        .map((row) {
          return row.map((cell) => '"${cell.replaceAll('"', '""')}"').join(',');
        })
        .join('\n');
  }

  // Type converters for database compatibility
  static int boolToInt(bool value) {
    return value ? 1 : 0;
  }

  static bool intToBool(int value) {
    return value == 1;
  }

  static String? stringToNullable(String? value) {
    return value?.isEmpty ?? true ? null : value;
  }

  // Enum converters
  static String loanStatusToString(LoanStatus status) {
    return status.toString().split('.').last;
  }

  static LoanStatus stringToLoanStatus(String status) {
    switch (status) {
      case 'active':
        return LoanStatus.active;
      case 'completed':
        return LoanStatus.completed;
      case 'defaulted':
        return LoanStatus.defaulted;
      default:
        return LoanStatus.active;
    }
  }

  // Safe parsing with defaults
  static double safeParseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  static int safeParseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  static DateTime safeParseDateTime(dynamic value, {DateTime? defaultValue}) {
    if (value == null) return defaultValue ?? DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? defaultValue ?? DateTime.now();
    }
    return defaultValue ?? DateTime.now();
  }
}
