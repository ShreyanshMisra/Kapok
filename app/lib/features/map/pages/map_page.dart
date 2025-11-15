import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Map page showing interactive map with task markers
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: Text(AppLocalizations.of(context).map),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show map filters
            },
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              // TODO: Navigate to tasks list view
            },
          ),
        ],
      ),
      body: Center(
        child: Text(AppLocalizations.of(context).mapPageToBeImplemented),
      ),
    );
  }
}
