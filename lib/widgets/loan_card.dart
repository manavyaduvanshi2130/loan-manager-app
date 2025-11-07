import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/loan_model.dart';
import '../utils/helpers.dart';

class LoanCard extends StatelessWidget {
  final Loan loan;
  final String customerName;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onMakePayment;
  final int delay;

  const LoanCard({
    super.key,
    required this.loan,
    required this.customerName,
    this.onTap,
    this.onEdit,
    this.onMakePayment,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(loan.status);
    final statusText = loan.status.name.toUpperCase();

    return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with loan ID and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Loan #${loan.id}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Customer name
                  Text(
                    customerName,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),

                  // Loan details
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'Principal',
                          AppHelpers.formatCurrency(loan.principalAmount),
                        ),
                      ),
                      Expanded( 
                        child: _buildDetailItem(
                          'Outstanding',
                          AppHelpers.formatCurrency(
                            loan.outstandingAmount ?? 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          'Rate',
                          '${loan.interestRate}%',
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          'Tenure',
                          '${loan.tenureMonths} months',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Start date
                  Text(
                    'Started: ${AppHelpers.formatDate(loan.startDate)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),

                  // Action buttons
                  if (onEdit != null || onMakePayment != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          if (onEdit != null)
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: onEdit,
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Edit'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                          if (onEdit != null && onMakePayment != null)
                            const SizedBox(width: 8),
                          if (onMakePayment != null)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: onMakePayment,
                                icon: const Icon(Icons.payment, size: 16),
                                label: const Text('Pay'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0, duration: 300.ms);
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Color _getStatusColor(LoanStatus status) {
    switch (status) {
      case LoanStatus.active:
        return Colors.green;
      case LoanStatus.completed:
        return Colors.blue;
      case LoanStatus.defaulted:
        return Colors.red;
    }
  }
}
