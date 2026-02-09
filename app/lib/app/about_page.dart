import 'package:flutter/material.dart';
import '../core/localization/app_localizations.dart';
import '../core/widgets/kapok_logo.dart';

/// About page with information about Kapok and A Fair Resolution, LLC
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(AppLocalizations.of(context).about),
        centerTitle: true,
        actions: const [KapokLogo()],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon tagline wordmark
            Center(
              child: Image.asset(
                theme.brightness == Brightness.dark
                    ? 'assets/images/icon_tagline/Kapok_Icon_Dark_Tagline_Wordmark.png'
                    : 'assets/images/icon_tagline/KapokIcon_Light_Tagline_Wordmark.png',
                width: 220,
              ),
            ),
            const SizedBox(height: 32),

            // Mission section
            _buildSection(
              context,
              AppLocalizations.of(context).ourMission,
              AppLocalizations.of(context).ourMissionDescription,
              Icons.flag,
            ),
            const SizedBox(height: 24),

            // Kapok Icon section
            _buildSection(
              context,
              AppLocalizations.of(context).kapokIcon,
              AppLocalizations.of(context).kapokIconDescription,
              Icons.park,
            ),
            const SizedBox(height: 24),

            // Digging Deeper: Tech Roots section
            _buildSection(
              context,
              AppLocalizations.of(context).diggingDeeperTechRoots,
              AppLocalizations.of(context).diggingDeeperTechRootsDescription,
              Icons.memory,
            ),
            const SizedBox(height: 24),

            // A Fair Resolution, LLC section
            _buildSection(
              context,
              AppLocalizations.of(context).aFairResolutionLLC,
              AppLocalizations.of(context).aFairResolutionLLCDescription,
              Icons.business,
            ),
            const SizedBox(height: 24),

            // Features section
            _buildSection(
              context,
              AppLocalizations.of(context).keyFeatures,
              AppLocalizations.of(context).keyFeaturesDescription,
              Icons.star,
            ),
            const SizedBox(height: 24),

            // Technology section
            _buildSection(
              context,
              AppLocalizations.of(context).technology,
              AppLocalizations.of(context).technologyDescription,
              Icons.phone_android,
            ),
            const SizedBox(height: 24),

            // Legal section
            _buildSection(
              context,
              AppLocalizations.of(context).legal,
              AppLocalizations.of(context).legalDescription,
              Icons.gavel,
            ),
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
