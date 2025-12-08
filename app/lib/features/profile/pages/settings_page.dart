import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../app/router.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../teams/bloc/team_bloc.dart';
import '../../teams/bloc/team_event.dart';
import '../../tasks/bloc/task_bloc.dart';
import '../../tasks/bloc/task_event.dart';
import '../../map/bloc/map_bloc.dart';
import '../../map/bloc/map_event.dart';

/// Settings page for app configuration
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(AppLocalizations.of(context).settings),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notifications section
          _buildSection(
            AppLocalizations.of(context).notifications,
            [
              SwitchListTile(
                title: Text(AppLocalizations.of(context).notifications),
                subtitle: Text(AppLocalizations.of(context).receiveNotificationsForNewTasksAndUpdates),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeThumbColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Location section
          _buildSection(
            AppLocalizations.of(context).location,
            [
              SwitchListTile(
                title: Text(AppLocalizations.of(context).locationServices),
                subtitle: Text(AppLocalizations.of(context).allowAppToAccessYourLocationForTaskMapping),
                value: _locationEnabled,
                onChanged: (value) {
                  setState(() {
                    _locationEnabled = value;
                  });
                },
                activeThumbColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Language section
          _buildSection(AppLocalizations.of(context).language, [
            Consumer<LanguageProvider>(
              builder: (context, languageProvider, _) {
                final currentLocale = languageProvider.currentLocale;
                final languageName = languageProvider.getLanguageName(
                  currentLocale,
                );
                final localizations = AppLocalizations.of(context);
                return ListTile(
                  title: Text(localizations.language),
                  subtitle: Text(languageName),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showLanguageDialog(context, languageProvider);
                  },
                );
              },
            ),
          ]),
          const SizedBox(height: 16),

          // Theme section
          _buildSection(
            AppLocalizations.of(context).appearance,
            [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  final currentMode = themeProvider.themeMode;
                  String themeText;
                  switch (currentMode) {
                    case ThemeMode.light:
                      themeText = AppLocalizations.of(context).light;
                      break;
                    case ThemeMode.dark:
                      themeText = AppLocalizations.of(context).dark;
                      break;
                    case ThemeMode.system:
                    default:
                      themeText = AppLocalizations.of(context).system;
                      break;
                  }
                  return ListTile(
                    title: Text(AppLocalizations.of(context).theme),
                    subtitle: Text(themeText),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showThemeDialog(context, themeProvider);
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Data section
          _buildSection(AppLocalizations.of(context).data, [
            ListTile(
              title: Text(AppLocalizations.of(context).clearCache),
              subtitle: Text(
                AppLocalizations.of(context).clearLocallyStoredData,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showClearCacheDialog();
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).exportData),
              subtitle: Text(
                AppLocalizations.of(context).exportYourTasksAndTeamData,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showExportDataDialog();
              },
            ),
          ]),
          const SizedBox(height: 16),

          // About section
          _buildSection(AppLocalizations.of(context).about, [
            ListTile(
              title: Text(AppLocalizations.of(context).appVersionLabel),
              subtitle: Text(AppLocalizations.of(context).appVersion),
              onTap: () {},
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).privacyPolicy),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showPrivacyPolicy();
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).termsOfService),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showTermsOfService();
              },
            ),
          ]),
          const SizedBox(height: 24),

          // Sign Out button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showSignOutDialog(),
              icon: const Icon(Icons.logout),
              label: Text(AppLocalizations.of(context).signOut),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Build settings section
  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  /// Show language selection dialog
  void _showLanguageDialog(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    final currentLocale = languageProvider.currentLocale;
    showDialog(
      context: context,
      builder: (context) {
        final dialogLocalizations = AppLocalizations.of(context);
        return AlertDialog(
          title: Text('${dialogLocalizations.language}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Locale>(
                title: Text(dialogLocalizations.english),
                value: const Locale('en'),
                groupValue: currentLocale,
                onChanged: (value) async {
                  if (value != null) {
                    await languageProvider.changeLanguage(value);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      final newLocalizations = AppLocalizations.of(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${newLocalizations.language} ${newLocalizations.english.toLowerCase()}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
              RadioListTile<Locale>(
                title: Text(dialogLocalizations.spanish),
                value: const Locale('es'),
                groupValue: currentLocale,
                onChanged: (value) async {
                  if (value != null) {
                    await languageProvider.changeLanguage(value);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      final newLocalizations = AppLocalizations.of(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${newLocalizations.language} ${newLocalizations.spanish.toLowerCase()}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(dialogLocalizations.close),
            ),
          ],
        );
      },
    );
  }

  /// Show theme selection dialog
  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    final localizations = AppLocalizations.of(context);
    final currentMode = themeProvider.themeMode;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.selectTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(localizations.system),
              value: ThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) async {
                if (value != null) {
                  await themeProvider.changeThemeMode(value);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(localizations.light),
              value: ThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) async {
                if (value != null) {
                  await themeProvider.changeThemeMode(value);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(localizations.dark),
              value: ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) async {
                if (value != null) {
                  await themeProvider.changeThemeMode(value);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(localizations.cancel),
          ),
        ],
      ),
    );
  }

  /// Show clear cache dialog
  void _showClearCacheDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.clearCache),
        content: Text(
          localizations
              .thisWillClearAllLocallyStoredDataYouWillNeedToSignInAgain,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement clear cache
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(localizations.cacheClearedSuccessfully)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: Text(localizations.clear),
          ),
        ],
      ),
    );
  }

  /// Show export data dialog
  void _showExportDataDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.exportData),
        content: Text(localizations.thisWillExportYourTasksAndTeamDataToAFile),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement data export
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.dataExportNotImplementedYet),
                ),
              );
            },
            child: Text(localizations.export),
          ),
        ],
      ),
    );
  }

  /// Show privacy policy
  void _showPrivacyPolicy() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.privacyPolicy),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy Policy content will be implemented here. This will include information about how we collect, use, and protect your data.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.close),
          ),
        ],
      ),
    );
  }

  /// Show terms of service
  void _showTermsOfService() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.termsOfService),
        content: const SingleChildScrollView(
          child: Text(
            'Terms of Service content will be implemented here. This will include the terms and conditions for using the Kapok app.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizations.close),
          ),
        ],
      ),
    );
  }

  /// Show sign out confirmation dialog
  void _showSignOutDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.signOut),
        content: Text(localizations.confirmSignOut),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              // Reset BLoCs first to stop map and clear state
              try {
                context.read<TeamBloc>().add(TeamReset());
                context.read<TaskBloc>().add(TaskReset());
                context.read<MapBloc>().add(MapReset());
              } catch (e) {
                // Ignore errors during reset
              }
              // Then sign out
              context.read<AuthBloc>().add(const SignOutRequested());
              // Navigate immediately to login page and close settings page
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(localizations.signOut),
          ),
        ],
      ),
    );
  }
}
