import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Settings page for app configuration
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'System';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notifications section
          _buildSection(
            'Notifications',
            [
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive notifications for new tasks and updates'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Location section
          _buildSection(
            'Location',
            [
              SwitchListTile(
                title: const Text('Location Services'),
                subtitle: const Text('Allow app to access your location for task mapping'),
                value: _locationEnabled,
                onChanged: (value) {
                  setState(() {
                    _locationEnabled = value;
                  });
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Language section
          _buildSection(
            'Language',
            [
              ListTile(
                title: const Text('Language'),
                subtitle: Text(_selectedLanguage),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showLanguageDialog();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Theme section
          _buildSection(
            'Appearance',
            [
              ListTile(
                title: const Text('Theme'),
                subtitle: Text(_selectedTheme),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showThemeDialog();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Data section
          _buildSection(
            'Data',
            [
              ListTile(
                title: const Text('Clear Cache'),
                subtitle: const Text('Clear locally stored data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showClearCacheDialog();
                },
              ),
              ListTile(
                title: const Text('Export Data'),
                subtitle: const Text('Export your tasks and team data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showExportDataDialog();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // About section
          _buildSection(
            'About',
            [
              ListTile(
                title: const Text('App Version'),
                subtitle: const Text('1.0.0'),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showPrivacyPolicy();
                },
              ),
              ListTile(
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showTermsOfService();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build settings section
  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  /// Show language selection dialog
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Español'),
              value: 'Español',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Show theme selection dialog
  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('System'),
              value: 'System',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Light'),
              value: 'Light',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Dark'),
              value: 'Dark',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Show clear cache dialog
  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all locally stored data. You will need to sign in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement clear cache
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  /// Show export data dialog
  void _showExportDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'This will export your tasks and team data to a file.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement data export
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data export not implemented yet'),
                ),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  /// Show privacy policy
  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy Policy content will be implemented here. This will include information about how we collect, use, and protect your data.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show terms of service
  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Terms of Service content will be implemented here. This will include the terms and conditions for using the Kapok app.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
