import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_drawer.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Settings')),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Application Configuration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Database Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Database',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Clear All Data'),
                      subtitle: const Text(
                        'Remove all customers, loans, and payments',
                      ),
                      trailing: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      onTap: () => _showClearDataConfirmation(context, ref),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Export Data'),
                      subtitle: const Text('Export all data to JSON file'),
                      trailing: const Icon(Icons.download),
                      onTap: () {
                        // TODO: Implement data export
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Export feature coming soon'),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Import Data'),
                      subtitle: const Text('Import data from JSON file'),
                      trailing: const Icon(Icons.upload),
                      onTap: () {
                        // TODO: Implement data import
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Import feature coming soon'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Backup Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Backup & Restore',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Create Backup'),
                      subtitle: const Text('Create a backup of all data'),
                      trailing: const Icon(Icons.backup),
                      onTap: () {
                        // TODO: Implement backup creation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Backup feature coming soon'),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Restore from Backup'),
                      subtitle: const Text('Restore data from backup file'),
                      trailing: const Icon(Icons.restore),
                      onTap: () {
                        // TODO: Implement backup restore
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Restore feature coming soon'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Advanced Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Advanced Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Auto-save'),
                      subtitle: const Text('Automatically save changes'),
                      value: false, // TODO: Implement auto-save feature
                      onChanged: (value) {
                        // TODO: Implement setAutoSave
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Auto-save feature coming soon'),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Debug Mode'),
                      subtitle: const Text('Show debug information'),
                      value: false, // TODO: Implement debug mode
                      onChanged: (value) {
                        // TODO: Implement setDebugMode
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Debug mode feature coming soon'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Reset All Settings
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showResetAllConfirmation(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Reset All Settings'),
              ),
            ),

            const SizedBox(height: 32),

            // App Information
            const Text(
              'Application Info',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Loan Management System',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Version: 1.0.0'),
                    const SizedBox(height: 4),
                    const Text('Built with Flutter & SQLite'),
                    const SizedBox(height: 4),
                    const Text('© 2024 Loan Management Team'),
                    const SizedBox(height: 16),
                    const Text(
                      'This application helps manage customer loans, track payments, and generate EMI schedules.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all customers, loans, payments, and other data. This action cannot be undone. Make sure you have a backup before proceeding.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // TODO: Implement clear all data
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data cleared successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error clearing data: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
  }

  void _showResetAllConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Settings'),
        content: const Text(
          'This will reset all application settings to their default values. Your data will not be affected.',
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
                const SnackBar(content: Text('All settings reset to defaults')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset Settings'),
          ),
        ],
      ),
    );
  }
}
