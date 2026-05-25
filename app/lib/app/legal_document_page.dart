import 'package:flutter/material.dart';
import '../core/localization/app_localizations.dart';
import '../core/widgets/kapok_logo.dart';

/// Renders a scrollable legal document (Privacy Policy, Terms of Use) with the
/// same chrome as Acknowledgements / About so users land in a familiar place.
///
/// The content is plain prose with simple paragraph breaks; lines beginning
/// with "•" are rendered as bullets so the constants files can stay
/// human-readable.
class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({
    super.key,
    required this.title,
    required this.body,
    required this.lastUpdated,
    this.isDraft = true,
  });

  final String title;
  final String body;
  final String lastUpdated;
  final bool isDraft;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(title),
        centerTitle: true,
        actions: const [KapokLogo()],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDraft) ...[
              _buildDraftBanner(context),
              const SizedBox(height: 16),
            ],
            Text(
              '${localizations.lastUpdated}: $lastUpdated',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            ..._renderBody(context, body),
          ],
        ),
      ),
    );
  }

  Widget _buildDraftBanner(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context).legalDraftNotice,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _renderBody(BuildContext context, String body) {
    final theme = Theme.of(context);
    final widgets = <Widget>[];
    for (final raw in body.split('\n')) {
      final line = raw.trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }
      if (line.startsWith('•')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(
                  child: Text(
                    line.substring(1).trim(),
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            line,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ),
      );
    }
    return widgets;
  }
}
