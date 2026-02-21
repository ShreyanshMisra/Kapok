import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/sync_service.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../teams/bloc/team_bloc.dart';
import '../../teams/bloc/team_event.dart';
import '../../tasks/bloc/task_bloc.dart';
import '../../tasks/bloc/task_event.dart';
import '../../map/bloc/map_bloc.dart';
import '../../map/bloc/map_event.dart';
import '../../../core/widgets/kapok_logo.dart';

/// Settings page for app configuration
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _locationEnabled = true;
  bool _isSyncing = false;
  String? _lastSyncTimestamp;

  @override
  void initState() {
    super.initState();
    _refreshLastSync();
  }

  void _refreshLastSync() {
    setState(() {
      _lastSyncTimestamp = SyncService.instance.getLastSyncTimestamp();
    });
  }

  int _estimateStorageKB() {
    try {
      final hive = HiveService.instance;
      final taskCount = hive.tasksBox.length;
      final teamCount = hive.teamsBox.length;
      // Rough estimate: ~2 KB per task, ~1 KB per team
      return (taskCount * 2) + (teamCount * 1);
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(AppLocalizations.of(context).settings),
        centerTitle: true,
        elevation: 0,
        actions: const [KapokLogo()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notifications section
          // Note: Push notifications intentionally deferred pending infrastructure setup
          _buildSection(
            AppLocalizations.of(context).notifications,
            [
              ListTile(
                leading: Icon(Icons.notifications_off, color: AppColors.textSecondary),
                title: Text(AppLocalizations.of(context).notifications),
                subtitle: Text(
                  'Push notifications will be enabled in a future update',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                enabled: false,
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

          // Sync section
          _buildSection('Sync', [
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Last Synced'),
              subtitle: Text(
                _lastSyncTimestamp != null
                    ? _formatTimestamp(_lastSyncTimestamp!)
                    : 'Never synced',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              trailing: _isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Sync now',
                      onPressed: _handleRetrySync,
                    ),
            ),
          ]),
          const SizedBox(height: 16),

          // Data section
          _buildSection(AppLocalizations.of(context).data, [
            ListTile(
              leading: const Icon(Icons.delete_sweep),
              title: Text(AppLocalizations.of(context).clearCache),
              subtitle: Text(
                '~${_estimateStorageKB()} KB cached locally',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showClearCacheDialog,
            ),
          ]),
          const SizedBox(height: 16),

          // Privacy section
          _buildSection('Privacy', [
            SwitchListTile(
              title: Text(
                'Analytics',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              subtitle: Text(
                'Analytics will be enabled in a future update',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              value: false,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text(
                'Crash Reporting',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              subtitle: Text(
                'Crash reporting will be enabled in a future update',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              value: false,
              onChanged: null,
            ),
          ]),
          const SizedBox(height: 16),

          // Feedback section
          _buildSection('Feedback & Support', [
            ListTile(
              leading: Icon(Icons.email_outlined, color: AppColors.textSecondary),
              title: Text(
                'Email Support',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              subtitle: Text(
                'Support will be available in a future update',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              enabled: false,
            ),
            ListTile(
              leading: Icon(Icons.bug_report_outlined, color: AppColors.textSecondary),
              title: Text(
                'Report an Issue',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              subtitle: Text(
                'Issue reporting will be available in a future update',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              enabled: false,
            ),
            ListTile(
              leading: Icon(Icons.rate_review_outlined, color: AppColors.textSecondary),
              title: Text(
                'Send Feedback',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              subtitle: Text(
                'Feedback will be available in a future update',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              enabled: false,
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
              label: Text(AppLocalizations.of(context).signOut.toUpperCase()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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
          title: Text(dialogLocalizations.language),
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

  String _formatTimestamp(String ts) {
    try {
      final dt = DateTime.parse(ts).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return ts;
    }
  }

  Future<void> _handleRetrySync() async {
    setState(() => _isSyncing = true);
    try {
      await SyncService.instance.syncPendingChanges();
      _refreshLastSync();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync completed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  /// Show clear cache dialog
  void _showClearCacheDialog() {
    final localizations = AppLocalizations.of(context);
    final sizeKB = _estimateStorageKB();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(localizations.clearCache),
        content: Text(
          'This will clear approximately $sizeKB KB of locally cached data (tasks, teams, settings). You will need to sync again after clearing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await HiveService.instance.clearAllData();
                context.read<TaskBloc>().add(TaskReset());
                context.read<TeamBloc>().add(TeamReset());
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.cacheClearedSuccessfully)),
                  );
                  setState(() => _lastSyncTimestamp = null);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to clear cache: $e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(localizations.clear),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(localizations.signOut.toUpperCase()),
          ),
        ],
      ),
    );
  }
}
