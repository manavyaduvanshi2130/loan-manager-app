import 'dart:math';

class LoanCalculator {
  // Calculate EMI using the standard formula
  // EMI = [P x R x (1+R)^N] / [(1+R)^N-1]
  // Where P = Principal, R = Monthly interest rate, N = Number of installments
  static double calculateEMI(
    double principal,
    double annualInterestRate,
    int tenureMonths,
  ) {
    double monthlyRate = annualInterestRate / 100 / 12;
    double emi =
        (principal * monthlyRate * pow(1 + monthlyRate, tenureMonths)) /
        (pow(1 + monthlyRate, tenureMonths) - 1);
    return emi;
  }

  // Calculate total amount payable
  static double calculateTotalAmount(
    double principal,
    double annualInterestRate,
    int tenureMonths,
  ) {
    double emi = calculateEMI(principal, annualInterestRate, tenureMonths);
    return emi * tenureMonths;
  }

  // Calculate total interest
  static double calculateTotalInterest(
    double principal,
    double annualInterestRate,
    int tenureMonths,
  ) {
    return calculateTotalAmount(principal, annualInterestRate, tenureMonths) -
        principal;
  }

  // Generate EMI schedule
  static List<Map<String, dynamic>> generateEMISchedule(
    double principal,
    double annualInterestRate,
    int tenureMonths,
    DateTime startDate,
  ) {
    double emi = calculateEMI(principal, annualInterestRate, tenureMonths);
    double monthlyRate = annualInterestRate / 100 / 12;
    List<Map<String, dynamic>> schedule = [];

    double remainingPrincipal = principal;

    for (int month = 1; month <= tenureMonths; month++) {
      double interestPayment = remainingPrincipal * monthlyRate;
      double principalPayment = emi - interestPayment;
      remainingPrincipal -= principalPayment;

      // Ensure remaining principal doesn't go negative due to rounding
      if (remainingPrincipal < 0) remainingPrincipal = 0;

      DateTime paymentDate = DateTime(
        startDate.year,
        startDate.month + month - 1,
        startDate.day,
      );

      schedule.add({
        'month': month,
        'paymentDate': paymentDate,
        'emi': emi,
        'principalPayment': principalPayment,
        'interestPayment': interestPayment,
        'remainingPrincipal': remainingPrincipal,
      });
    }

    return schedule;
  }

  // Calculate outstanding amount after certain payments
  static double calculateOutstandingAmount(
    double principal,
    double annualInterestRate,
    int tenureMonths,
    int paymentsMade,
  ) {
    List<Map<String, dynamic>> schedule = generateEMISchedule(
      principal,
      annualInterestRate,
      tenureMonths,
      DateTime.now(),
    );

    if (paymentsMade >= schedule.length) return 0;

    return schedule[paymentsMade]['remainingPrincipal'];
  }
}
