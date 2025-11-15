import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';

/// Task detail page showing task information
class TaskDetailPage extends StatelessWidget {
  final dynamic task; // TODO: Replace with TaskModel

  const TaskDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: Text(AppLocalizations.of(context).taskDetails),
        elevation: 0,
      ),
      body: Center(
        child: Text(AppLocalizations.of(context).taskDetailPageToBeImplemented),
      ),
    );
  }
}
