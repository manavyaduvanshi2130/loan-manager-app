import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/customer_model.dart';
import '../models/payment_model.dart';
import '../models/loan_model.dart';
import '../models/user_model.dart';

class SmsService {
  static const String _smsScheme = 'sms';

  /// Sends an SMS notification to the customer after EMI payment
  static Future<bool> sendPaymentConfirmationSms({
    required Customer customer,
    required Payment payment,
    required Loan loan,
  }) async {
    try {
      // Format the SMS message
      final message = _formatPaymentConfirmationMessage(
        customer: customer,
        payment: payment,
        loan: loan,
      );

      // Create SMS URI
      final smsUri = Uri(
        scheme: _smsScheme,
        path: customer.phone,
        queryParameters: {'body': message},
      );

      // Launch SMS app
      final canLaunch = await canLaunchUrl(smsUri);
      if (canLaunch) {
        await launchUrl(smsUri);
        return true;
      } else {
        // Fallback: try without query parameters
        final fallbackUri = Uri(scheme: _smsScheme, path: customer.phone);
        return await launchUrl(fallbackUri);
      }
    } catch (e) {
      debugPrint('Error sending SMS: $e');
      return false;
    }
  }

  /// Formats the payment confirmation message
  static String _formatPaymentConfirmationMessage({
    required Customer customer,
    required Payment payment,
    required Loan loan,
  }) {
    final formattedAmount = '₹${payment.amount.toStringAsFixed(2)}';
    final formattedDate =
        '${payment.paymentDate.day}/${payment.paymentDate.month}/${payment.paymentDate.year}';

    return '''Dear ${customer.name},

Your EMI payment of $formattedAmount for Loan #${loan.id} has been successfully received on $formattedDate.

Thank you for your payment!

Regards,
Loan Management System''';
  }

  /// Sends a login confirmation SMS to the user
  static Future<bool> sendLoginConfirmationSms({required User user}) async {
    try {
      // Format the SMS message
      final message = _formatLoginConfirmationMessage(user);

      // Create SMS URI
      final smsUri = Uri(
        scheme: _smsScheme,
        path: user.mobileNumber,
        queryParameters: {'body': message},
      );

      // Launch SMS app
      final canLaunch = await canLaunchUrl(smsUri);
      if (canLaunch) {
        await launchUrl(smsUri);
        return true;
      } else {
        // Fallback: try without query parameters
        final fallbackUri = Uri(scheme: _smsScheme, path: user.mobileNumber);
        return await launchUrl(fallbackUri);
      }
    } catch (e) {
      debugPrint('Error sending login confirmation SMS: $e');
      return false;
    }
  }

  /// Formats the login confirmation message
  static String _formatLoginConfirmationMessage(User user) {
    return '''Congratulations ${user.fullName},

You have successfully logged in to the Loan Management System!

Welcome aboard!

Regards,
Loan Management System Team''';
  }

  /// Checks if SMS is supported on the device
  static Future<bool> isSmsSupported() async {
    final testUri = Uri(scheme: _smsScheme, path: '1234567890');
    return await canLaunchUrl(testUri);
  }
}
