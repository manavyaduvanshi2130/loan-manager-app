class Payment {
  final int? id;
  final int loanId;
  final double amount;
  final DateTime paymentDate;
  final String? notes;
  final DateTime createdAt;

  Payment({
    this.id,
    required this.loanId,
    required this.amount,
    required this.paymentDate,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loanId': loanId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      loanId: map['loanId'],
      amount: map['amount'],
      paymentDate: DateTime.parse(map['paymentDate']),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Payment copyWith({
    int? id,
    int? loanId,
    double? amount,
    DateTime? paymentDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      loanId: loanId ?? this.loanId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
