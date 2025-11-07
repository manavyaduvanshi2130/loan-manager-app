import '../models/customer_model.dart';
import '../models/loan_model.dart';
import '../models/payment_model.dart';
import 'database_service.dart';

class AnalyticsService {
  final DatabaseService _dbService = DatabaseService();

  // Get total number of customers
  Future<int> getTotalCustomers() async {
    List<Customer> customers = await _dbService.getCustomers();
    return customers.length;
  }

  // Get total number of active loans
  Future<int> getTotalActiveLoans() async {
    List<Loan> loans = await _dbService.getLoans();
    return loans.where((loan) => loan.status == LoanStatus.active).length;
  }

  // Get total loan amount disbursed
  Future<double> getTotalLoanAmount() async {
    List<Loan> loans = await _dbService.getLoans();
    return loans.fold<double>(0.0, (sum, loan) => sum + loan.principalAmount);
  }

  // Get total outstanding amount
  Future<double> getTotalOutstandingAmount() async {
    List<Loan> loans = await _dbService.getLoans();
    return loans
        .where((loan) => loan.status == LoanStatus.active)
        .fold<double>(0.0, (sum, loan) => sum + (loan.outstandingAmount ?? 0));
  }

  // Get total payments received
  Future<double> getTotalPaymentsReceived() async {
    List<Payment> payments = await _dbService.getPayments();
    return payments.fold<double>(0.0, (sum, payment) => sum + payment.amount);
  }

  // Get monthly revenue (interest earned)
  Future<double> getMonthlyRevenue(DateTime month) async {
    List<Payment> payments = await _dbService.getPayments();
    double monthlyRevenue = 0;

    for (Payment payment in payments) {
      if (payment.paymentDate.year == month.year &&
          payment.paymentDate.month == month.month) {
        // Calculate interest portion of the payment
        // This is a simplified calculation - in reality, you'd need EMI breakdown
        monthlyRevenue += payment.amount * 0.1; // Assuming 10% is interest
      }
    }

    return monthlyRevenue;
  }

  // Get loan status distribution
  Future<Map<LoanStatus, int>> getLoanStatusDistribution() async {
    List<Loan> loans = await _dbService.getLoans();
    Map<LoanStatus, int> distribution = {};

    for (Loan loan in loans) {
      distribution[loan.status] = (distribution[loan.status] ?? 0) + 1;
    }

    return distribution;
  }

  // Get top customers by loan amount
  Future<List<Map<String, dynamic>>> getTopCustomersByLoanAmount({
    int limit = 10,
  }) async {
    List<Customer> customers = await _dbService.getCustomers();
    List<Map<String, dynamic>> customerLoans = [];

    for (Customer customer in customers) {
      List<Loan> loans = await _dbService.getLoansByCustomer(customer.id!);
      double totalLoanAmount = loans.fold(
        0.0,
        (sum, loan) => sum + loan.principalAmount,
      );

      if (totalLoanAmount > 0) {
        customerLoans.add({
          'customer': customer,
          'totalLoanAmount': totalLoanAmount,
          'loanCount': loans.length,
        });
      }
    }

    customerLoans.sort(
      (a, b) => b['totalLoanAmount'].compareTo(a['totalLoanAmount']),
    );
    return customerLoans.take(limit).toList();
  }

  // Get payment trends (last 12 months)
  Future<List<Map<String, dynamic>>> getPaymentTrends() async {
    List<Payment> payments = await _dbService.getPayments();
    Map<String, double> monthlyPayments = {};

    for (Payment payment in payments) {
      String key =
          '${payment.paymentDate.year}-${payment.paymentDate.month.toString().padLeft(2, '0')}';
      monthlyPayments[key] = (monthlyPayments[key] ?? 0) + payment.amount;
    }

    List<Map<String, dynamic>> trends = [];
    DateTime now = DateTime.now();

    for (int i = 11; i >= 0; i--) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      String key = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      trends.add({'month': month, 'amount': monthlyPayments[key] ?? 0});
    }

    return trends;
  }

  // Get default risk analysis
  Future<Map<String, dynamic>> getDefaultRiskAnalysis() async {
    List<Loan> loans = await _dbService.getLoans();
    int totalLoans = loans.length;
    int activeLoans = loans
        .where((loan) => loan.status == LoanStatus.active)
        .length;
    int defaultedLoans = loans
        .where((loan) => loan.status == LoanStatus.defaulted)
        .length;

    double defaultRate = totalLoans > 0
        ? (defaultedLoans / totalLoans) * 100
        : 0;

    return {
      'totalLoans': totalLoans,
      'activeLoans': activeLoans,
      'defaultedLoans': defaultedLoans,
      'defaultRate': defaultRate,
    };
  }
}
