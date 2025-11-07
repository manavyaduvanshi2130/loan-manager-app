import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/sms_service.dart';

// Auth state
enum AuthState { initial, loading, authenticated, error }

// Auth provider
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState.initial;
  }

  User? _currentUser;

  User? get currentUser => _currentUser;

  // Login method
  Future<void> login({
    required String fullName,
    required String mobileNumber,
    required String email,
    required BuildContext context,
  }) async {
    state = AuthState.loading;

    try {
      // Create user object
      _currentUser = User(
        fullName: fullName,
        mobileNumber: mobileNumber,
        email: email,
      );

      state = AuthState.authenticated;

      // Navigate to dashboard immediately
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }

      // Send congratulatory SMS asynchronously (non-blocking)
      SmsService.sendLoginConfirmationSms(user: _currentUser!)
          .then((smsSent) {
            if (!smsSent) {
              debugPrint('Failed to send login confirmation SMS');
            }
          })
          .catchError((e) {
            debugPrint('Error sending login confirmation SMS: $e');
          });
    } catch (e) {
      state = AuthState.error;
      debugPrint('Login error: $e');
    }
  }

  // Logout method
  void logout() {
    _currentUser = null;
    state = AuthState.initial;
  }
}

// Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider.notifier).currentUser;
});
