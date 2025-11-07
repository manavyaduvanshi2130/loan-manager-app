import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loan_model.dart';
import '../models/payment_model.dart';
import '../services/database_service.dart';
import '../services/loan_calculator.dart';
import '../services/sms_service.dart';
import '../providers/customer_provider.dart';

class LoanNotifier extends Notifier<List<Loan>> {
  final DatabaseService _dbService = DatabaseService();

  @override
  List<Loan> build() {
    loadLoans().catchError((error) {
      // Handle error silently or log it
      debugPrint('Error loading loans: $error');
    });
    return [];
  }

  Future<void> loadLoans() async {
    final loans = await _dbService.getLoans();
    state = loans;
  }

  Future<void> addLoan(Loan loan) async {
    final id = await _dbService.insertLoan(loan);
    final newLoan = loan.copyWith(id: id);
    state = [...state, newLoan];
  }

  Future<void> updateLoan(Loan loan) async {
    await _dbService.updateLoan(loan);
    state = state.map((l) => l.id == loan.id ? loan : l).toList();
  }

  Future<void> deleteLoan(int id) async {
    await _dbService.deleteLoan(id);
    state = state.where((l) => l.id != id).toList();
  }

  Loan? getLoanById(int id) {
    return state.where((l) => l.id == id).firstOrNull;
  }

  List<Loan> getLoansByCustomer(int customerId) {
    return state.where((l) => l.customerId == customerId).toList();
  }

  List<Loan> getLoansByStatus(LoanStatus status) {
    return state.where((l) => l.status == status).toList();
  }

  Future<double> calculateEMI(int loanId) async {
    final loan = getLoanById(loanId);
    if (loan == null) return 0;
    return LoanCalculator.calculateEMI(
      loan.principalAmount,
      loan.interestRate,
      loan.tenureMonths,
    );
  }

  Future<List<Map<String, dynamic>>> getEMISchedule(int loanId) async {
    final loan = getLoanById(loanId);
    if (loan == null) return [];
    return LoanCalculator.generateEMISchedule(
      loan.principalAmount,
      loan.interestRate,
      loan.tenureMonths,
      loan.startDate,
    );
  }

  Future<void> makePayment(int loanId, double amount, {String? notes}) async {
    final payment = Payment(
      loanId: loanId,
      amount: amount,
      paymentDate: DateTime.now(),
      notes: notes,
    );
    await _dbService.insertPayment(payment);

    // Update loan outstanding amount
    final loan = getLoanById(loanId);
    if (loan != null) {
      final newOutstanding = (loan.outstandingAmount ?? 0) - amount;
      final updatedLoan = loan.copyWith(
        outstandingAmount: newOutstanding > 0 ? newOutstanding : 0,
        status: newOutstanding <= 0 ? LoanStatus.completed : loan.status,
      );
      await updateLoan(updatedLoan);

      // Send SMS notification to customer
      try {
        final customer = ref
            .read(customerProvider.notifier)
            .getCustomerById(loan.customerId);
        if (customer != null) {
          await SmsService.sendPaymentConfirmationSms(
            customer: customer,
            payment: payment,
            loan: loan,
          );
        }
      } catch (e) {
        // Log SMS error but don't fail the payment
        debugPrint('Failed to send SMS notification: $e');
      }
    }
  }

  Future<List<Payment>> getPaymentsByLoan(int loanId) async {
    return await _dbService.getPaymentsByLoan(loanId);
  }
}

final loanProvider = NotifierProvider<LoanNotifier, List<Loan>>(() {
  return LoanNotifier();
});
