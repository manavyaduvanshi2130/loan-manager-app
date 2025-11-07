enum LoanStatus { active, completed, defaulted }

class Loan {
  final int? id;
  final int customerId;
  final double principalAmount;
  final double interestRate; // Annual interest rate in percentage
  final int tenureMonths;
  final DateTime startDate;
  final LoanStatus status;
  final double? outstandingAmount;
  final DateTime createdAt;

  Loan({
    this.id,
    required this.customerId,
    required this.principalAmount,
    required this.interestRate,
    required this.tenureMonths,
    required this.startDate,
    this.status = LoanStatus.active,
    double? outstandingAmount,
    DateTime? createdAt,
  }) : outstandingAmount = outstandingAmount ?? principalAmount,
       createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'principal_amount': principalAmount,
      'interest_rate': interestRate,
      'tenure_months': tenureMonths,
      'start_date': startDate.toIso8601String(),
      'status': status.index,
      'outstanding_amount': outstandingAmount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Loan.fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'],
      customerId: map['customer_id'],
      principalAmount: map['principal_amount'],
      interestRate: map['interest_rate'],
      tenureMonths: map['tenure_months'],
      startDate: DateTime.parse(map['start_date']),
      status: LoanStatus.values[map['status']],
      outstandingAmount: map['outstanding_amount'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Loan copyWith({
    int? id,
    int? customerId,
    double? principalAmount,
    double? interestRate,
    int? tenureMonths,
    DateTime? startDate,
    LoanStatus? status,
    double? outstandingAmount,
    DateTime? createdAt,
  }) {
    return Loan(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      principalAmount: principalAmount ?? this.principalAmount,
      interestRate: interestRate ?? this.interestRate,
      tenureMonths: tenureMonths ?? this.tenureMonths,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      outstandingAmount: outstandingAmount ?? this.outstandingAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
