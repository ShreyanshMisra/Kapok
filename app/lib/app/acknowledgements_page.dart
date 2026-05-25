import 'package:flutter/material.dart';
import '../core/localization/app_localizations.dart';
import '../core/widgets/kapok_logo.dart';

class AcknowledgementsPage extends StatelessWidget {
  const AcknowledgementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(localizations.acknowledgements),
        centerTitle: true,
        actions: const [KapokLogo()],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildIntro(context),
            const SizedBox(height: 24),
            _buildNamesSection(
              context,
              localizations.acknowledgementsProjectLeaders,
              localizations.acknowledgementsProjectLeadersNames,
              Icons.workspace_premium,
            ),
            const SizedBox(height: 24),
            _buildNamesSection(
              context,
              localizations.acknowledgementsInspiration,
              localizations.acknowledgementsInspirationNames,
              Icons.auto_awesome,
            ),
            const SizedBox(height: 24),
            _buildNamesSection(
              context,
              localizations.acknowledgementsThankYou,
              localizations.acknowledgementsThankYouNames,
              Icons.favorite,
            ),
            const SizedBox(height: 24),
            _buildNamesSection(
              context,
              localizations.acknowledgementsThanksAlsoTo,
              localizations.acknowledgementsThanksAlsoToNames,
              Icons.people,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.diversity_3,
              color: theme.colorScheme.primary,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.acknowledgements,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            localizations.acknowledgementsSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIntro(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.15),
        ),
      ),
      child: Text(
        AppLocalizations.of(context).acknowledgementsIntro,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildNamesSection(
    BuildContext context,
    String title,
    String names,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final entries = names
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...entries.map(
          (name) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              name,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

}
