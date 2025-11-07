import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }
    final mobileRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!mobileRegex.hasMatch(value)) {
      return 'Please enter a valid mobile number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authProvider.notifier)
          .login(
            fullName: _fullNameController.text.trim(),
            mobileNumber: _mobileController.text.trim(),
            email: _emailController.text.trim(),
            context: context,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
              Colors.blue.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),

                  // Header with animation
                  Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.account_circle,
                              size: 80,
                              color: Colors.black,
                            ).animate().scale(
                              begin: const Offset(0, 0),
                              end: const Offset(1, 1),
                              duration: 600.ms,
                              curve: Curves.elasticOut,
                            ),

                            const SizedBox(height: 16),

                            Text(
                                  'Welcome Back',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                )
                                .animate(delay: 200.ms)
                                .slideY(begin: -1, end: 0, duration: 500.ms)
                                .fadeIn(duration: 500.ms),

                            const SizedBox(height: 8),

                            Text(
                                  'Please sign in to continue',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Colors.black.withValues(
                                          alpha: 0.8,
                                        ),
                                      ),
                                )
                                .animate(delay: 400.ms)
                                .slideY(begin: 1, end: 0, duration: 500.ms)
                                .fadeIn(duration: 500.ms),
                          ],
                        ),
                      )
                      .animate(delay: 100.ms)
                      .slideY(begin: -0.5, end: 0, duration: 600.ms)
                      .fadeIn(duration: 600.ms),

                  const SizedBox(height: 40),

                  // Form fields
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    validator: _validateFullName,
                    delay: 600,
                  ),

                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _mobileController,
                    label: 'Mobile Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: _validateMobile,
                    delay: 700,
                  ),

                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    delay: 800,
                  ),

                  const SizedBox(height: 40),

                  // Login button
                  ElevatedButton(
                        onPressed: authState == AuthState.loading
                            ? null
                            : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: Colors.black.withValues(alpha: 0.3),
                        ),
                        child: authState == AuthState.loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue,
                                  ),
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      )
                      .animate(delay: 900.ms)
                      .slideY(begin: 1, end: 0, duration: 500.ms)
                      .fadeIn(duration: 500.ms),

                  const SizedBox(height: 20),

                  // Error message
                  if (authState == AuthState.error)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade300),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Login failed. Please try again.',
                              style: TextStyle(color: Colors.red.shade300),
                            ),
                          ),
                        ],
                      ),
                    ).animate().shake(duration: 500.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    required int delay,
  }) {
    return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.black.withValues(alpha: 0.8)),
              prefixIcon: Icon(
                icon,
                color: Colors.black.withValues(alpha: 0.8),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              errorStyle: const TextStyle(color: Colors.orange),
            ),
            validator: validator,
          ),
        )
        .animate(delay: delay.ms)
        .slideX(begin: -0.5, end: 0, duration: 500.ms)
        .fadeIn(duration: 500.ms);
  }
}
