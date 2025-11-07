import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_drawer.dart';

class UserSettingsScreen extends ConsumerWidget {
  const UserSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Preferences',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Dark Mode Toggle
            Card(
              child: SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable dark theme'),
                value: settings.isDarkMode,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).toggleDarkMode();
                },
              ),
            ),

            const SizedBox(height: 16),

            // Currency Selection
            Card(
              child: ListTile(
                title: const Text('Currency'),
                subtitle: Text('Current: ${settings.currency}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showCurrencyPicker(context, ref),
              ),
            ),

            const SizedBox(height: 16),

            // Language Selection
            Card(
              child: ListTile(
                title: const Text('Language'),
                subtitle: Text('Current: ${settings.language}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguagePicker(context, ref),
              ),
            ),

            const SizedBox(height: 16),

            // Notifications Toggle
            Card(
              child: SwitchListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Enable push notifications'),
                value: settings.notificationsEnabled,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).toggleNotifications();
                },
              ),
            ),

            const SizedBox(height: 16),

            // Default Tenure
            Card(
              child: ListTile(
                title: const Text('Default Loan Tenure'),
                subtitle: Text(
                  'Current: ${settings.defaultTenureMonths} months',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showTenurePicker(context, ref),
              ),
            ),

            const SizedBox(height: 32),

            // Reset to Defaults
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showResetConfirmation(context, ref),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text(
                  'Reset to Defaults',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // App Info
            const Text(
              'About',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loan Management System',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Version: 1.0.0'),
                    SizedBox(height: 4),
                    Text('Built with Flutter & Riverpod'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    final currencies = ['INR', 'USD', 'EUR', 'GBP', 'JPY'];
    final currentCurrency = ref.read(settingsProvider).currency;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: currencies.map((currency) {
            return ListTile(
              title: Text(currency),
              leading: Radio<String>(
                value: currency,
                groupValue: currentCurrency,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsProvider.notifier).setCurrency(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final languages = {
      'en': 'English',
      'hi': 'Hindi',
      'es': 'Spanish',
      'fr': 'French',
    };
    final currentLanguage = ref.read(settingsProvider).language;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.entries.map((entry) {
            return ListTile(
              title: Text(entry.value),
              leading: Radio<String>(
                value: entry.key,
                groupValue: currentLanguage,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(settingsProvider.notifier).setLanguage(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTenurePicker(BuildContext context, WidgetRef ref) {
    final tenures = [6, 12, 24, 36, 48, 60];
    final currentTenure = ref.read(settingsProvider).defaultTenureMonths;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Default Tenure'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: tenures.map((tenure) {
            return ListTile(
              title: Text('$tenure months'),
              leading: Radio<int>(
                value: tenure,
                groupValue: currentTenure,
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(settingsProvider.notifier)
                        .setDefaultTenureMonths(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
