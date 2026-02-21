import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/first_login_service.dart';
import '../core/widgets/kapok_logo.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_state.dart';

/// About page with information about Kapok and A Fair Resolution, LLC
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(AppLocalizations.of(context).about),
        centerTitle: true,
        automaticallyImplyLeading: canPop,
        actions: const [KapokLogo()],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                theme.brightness == Brightness.dark
                    ? 'assets/images/icon_tagline/KapokIcon_Dark_Tagline_Wordmark.png'
                    : 'assets/images/icon_tagline/Kapok_Icon_Light_Tagline_Wordmark.png',
                width: 220,
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              context,
              AppLocalizations.of(context).ourMission,
              AppLocalizations.of(context).ourMissionDescription,
              Icons.flag,
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              AppLocalizations.of(context).kapokIcon,
              AppLocalizations.of(context).kapokIconDescription,
              Icons.park,
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              AppLocalizations.of(context).diggingDeeperTechRoots,
              AppLocalizations.of(context).diggingDeeperTechRootsDescription,
              Icons.memory,
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              AppLocalizations.of(context).aFairResolutionLLC,
              AppLocalizations.of(context).aFairResolutionLLCDescription,
              Icons.business,
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              AppLocalizations.of(context).keyFeatures,
              AppLocalizations.of(context).keyFeaturesDescription,
              Icons.star,
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              AppLocalizations.of(context).technology,
              AppLocalizations.of(context).technologyDescription,
              Icons.phone_android,
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              AppLocalizations.of(context).legal,
              AppLocalizations.of(context).legalDescription,
              Icons.gavel,
            ),

            if (!canPop) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticated) {
                      FirstLoginService.instance.markLoggedIn(authState.user.id);
                    }
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/home',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(
                    AppLocalizations.of(context).continueText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build a section with icon, title, and content
  Widget _buildSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
