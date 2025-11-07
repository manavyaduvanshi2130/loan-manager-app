import 'package:flutter/material.dart';
import '../utils/helpers.dart';

class EMIRow extends StatelessWidget {
  final Map<String, dynamic> emiData;
  final bool isHeader;

  const EMIRow({super.key, required this.emiData, this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: isHeader ? 14 : 13,
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      color: isHeader ? Colors.black : Colors.grey[800],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isHeader ? Colors.grey[100] : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              emiData['month']?.toString() ?? '',
              style: textStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              emiData['paymentDate'] != null
                  ? AppHelpers.formatDate(emiData['paymentDate'])
                  : '',
              style: textStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              emiData['emi'] != null
                  ? AppHelpers.formatCurrency(emiData['emi'])
                  : '',
              style: textStyle,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              emiData['principalPayment'] != null
                  ? AppHelpers.formatCurrency(emiData['principalPayment'])
                  : '',
              style: textStyle,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              emiData['interestPayment'] != null
                  ? AppHelpers.formatCurrency(emiData['interestPayment'])
                  : '',
              style: textStyle,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              emiData['remainingPrincipal'] != null
                  ? AppHelpers.formatCurrency(emiData['remainingPrincipal'])
                  : '',
              style: textStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
