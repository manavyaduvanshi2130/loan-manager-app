import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  void _navigateToLogin() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize =
        MediaQuery.of(context).size.width * 0.2; // Responsive icon size
    final double titleFontSize =
        MediaQuery.of(context).size.width * 0.08; // Responsive title size
    final double subtitleFontSize =
        MediaQuery.of(context).size.width * 0.05; // Responsive subtitle size

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon with scale animation
              Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      size: 60,
                      color: Colors.blue,
                    ),
                  )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                  )
                  .then(delay: 200.ms)
                  .shimmer(duration: 1000.ms),

              const SizedBox(height: 40),

              // App Title with slide animation
              Text(
                    'Loan Management',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  )
                  .animate(delay: 600.ms)
                  .slideY(
                    begin: 1,
                    end: 0,
                    duration: 600.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(duration: 600.ms),

              const SizedBox(height: 8),

              Text(
                    'System',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w300,
                      color: Colors.white70,
                      letterSpacing: 2,
                    ),
                  )
                  .animate(delay: 800.ms)
                  .slideY(
                    begin: 1,
                    end: 0,
                    duration: 600.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(duration: 600.ms),

              const SizedBox(height: 60),

              // Loading indicator
              SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.8),
                      ),
                      strokeWidth: 3,
                    ),
                  )
                  .animate(delay: 1200.ms)
                  .fadeIn(duration: 400.ms)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                  ),

              const SizedBox(height: 20),

              const Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w300,
                ),
              ).animate(delay: 1400.ms).fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
