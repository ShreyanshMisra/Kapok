import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../app/legal_document_page.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/privacy_policy.dart';
import '../../../core/constants/terms_of_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/hive_service.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/widgets/sign_out_flow.dart';
import '../../teams/bloc/team_bloc.dart';
import '../../teams/bloc/team_event.dart';
import '../../tasks/bloc/task_bloc.dart';
import '../../tasks/bloc/task_event.dart';
import '../../map/bloc/map_bloc.dart';
import '../../map/bloc/map_event.dart';
import '../../../core/widgets/kapok_logo.dart';
import '../../../core/utils/logger.dart';

/// Settings page for app configuration
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _locationEnabled = true;
  bool _deletingAccount = false;

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

          // Data section
          _buildSection(AppLocalizations.of(context).data, [
            ListTile(
              leading: const Icon(Icons.delete_sweep),
              title: Text(AppLocalizations.of(context).clearCache),
              subtitle: Text(
                AppLocalizations.of(context).cachedLocallyKB(_estimateStorageKB()),
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 14),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showClearCacheDialog,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                AppLocalizations.of(context).builtWithLove,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ),
            const Divider(height: 1),
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
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Delete account button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _deletingAccount ? null : _showDeleteAccountDialog,
              icon: _deletingAccount
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_forever),
              label: Text(
                AppLocalizations.of(context).deleteAccount.toUpperCase(),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
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
                      // The tree hasn't rebuilt in the new locale yet, so
                      // build the message from the chosen locale directly.
                      final newLocalizations = AppLocalizations(value);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${newLocalizations.language}: ${newLocalizations.english}',
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
                      final newLocalizations = AppLocalizations(value);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${newLocalizations.language}: ${newLocalizations.spanish}',
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
    final sizeKB = _estimateStorageKB();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(localizations.clearCache),
        content: Text(
          localizations.clearCacheConfirmBody('$sizeKB'),
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
                if (!mounted) return;
                context.read<TaskBloc>().add(TaskReset());
                context.read<TeamBloc>().add(TeamReset());
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.cacheClearedSuccessfully)),
                  );
                }
              } catch (e) {
                Logger.error('Failed to clear cache', tag: 'SETTINGS', error: e);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.clearCacheFailed), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
            child: Text(localizations.clear),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentPage(
          title: AppLocalizations.of(context).privacyPolicy,
          body: PrivacyPolicy.content,
          lastUpdated: PrivacyPolicy.lastUpdated,
        ),
      ),
    );
  }

  void _showTermsOfService() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalDocumentPage(
          title: AppLocalizations.of(context).termsOfService,
          body: TermsOfService.content,
          lastUpdated: TermsOfService.lastUpdated,
        ),
      ),
    );
  }

  /// Asks for the user's password and for them to type "DELETE" before
  /// destroying their account. The password re-authenticates the session,
  /// which Firebase Auth requires before deleting a long-lived sign-in.
  Future<void> _showDeleteAccountDialog() async {
    final localizations = AppLocalizations.of(context);
    final password = await showDialog<String>(
      context: context,
      builder: (_) => _DeleteAccountDialog(localizations: localizations),
    );
    if (password == null || password.isEmpty || !mounted) return;
    _performAccountDeletion(password);
  }

  void _performAccountDeletion(String password) {
    final messenger = ScaffoldMessenger.of(context);
    final localizations = AppLocalizations.of(context);
    // Team/Task/Map BLoCs are reset by KapokApp's auth listener once the
    // account is gone (AuthUnauthenticated); a refused deletion keeps them.
    // On success, KapokApp's auth listener routes to /login on
    // AuthUnauthenticated.
    setState(() => _deletingAccount = true);
    context.read<AuthBloc>().add(DeleteAccountRequested(
      password: password,
      onComplete: (error) {
        if (error == null) {
          messenger.showSnackBar(
            SnackBar(content: Text(localizations.deleteAccountSuccess)),
          );
          return;
        }
        messenger.showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
        if (mounted) setState(() => _deletingAccount = false);
      },
    ));
  }

  /// Show sign out confirmation dialog
  void _showSignOutDialog() {
    confirmAndSignOut(
      context,
      onConfirmed: () {
        // Reset BLoCs first to stop the map and clear state.
        try {
          context.read<TeamBloc>().add(TeamReset());
          context.read<TaskBloc>().add(TaskReset());
          context.read<MapBloc>().add(MapReset());
        } catch (_) {}
      },
    ).then((signedOut) {
      if (signedOut && mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
      }
    });
  }
}

/// Confirmation dialog for account deletion. Pops with the entered password
/// once the user has typed the confirmation word, or null if cancelled.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.localizations});

  final AppLocalizations localizations;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _confirmController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  bool get _canConfirm =>
      _confirmController.text.trim() ==
          widget.localizations.deleteAccountConfirmWord &&
      _passwordController.text.isNotEmpty;

  @override
  void dispose() {
    _confirmController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_canConfirm) Navigator.of(context).pop(_passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.localizations;
    return AlertDialog(
      title: Text(l.deleteAccountWarningTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.deleteAccountWarningBody),
            const SizedBox(height: 16),
            Text(
              l.deleteAccountPasswordPrompt,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                hintText: l.password,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Text(
              l.deleteAccountConfirmPrompt,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmController,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                hintText: l.deleteAccountConfirmWord,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        ElevatedButton.icon(
          onPressed: _canConfirm ? _submit : null,
          icon: const Icon(Icons.delete_forever),
          label: Text(l.deleteAccount.toUpperCase()),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.error.withValues(alpha: 0.4),
            disabledForegroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
