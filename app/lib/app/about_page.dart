import 'package:flutter/material.dart';
import '../core/localization/app_localizations.dart';

/// About page with information about Kapok and NCTDR
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
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/kapok_icon.png',
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).appName,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).appDescription,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
            
            // Contact section
            _buildSection(
              context,
              AppLocalizations.of(context).contactAndSupport,
              AppLocalizations.of(context).contactAndSupportDescription,
              Icons.contact_support,
            ),
            const SizedBox(height: 32),
            
            // Version info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '${AppLocalizations.of(context).appVersionLabel} ${AppLocalizations.of(context).appVersion}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context).builtWithLove,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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
