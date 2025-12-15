import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';

/// Edit task page for modifying existing tasks
class EditTaskPage extends StatelessWidget {
  final dynamic task; // TODO: Replace with TaskModel

  const EditTaskPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(AppLocalizations.of(context).editTask),
        elevation: 0,
      ),
      body: Center(
        child: Text(AppLocalizations.of(context).editTaskPageToBeImplemented),
      ),
    );
  }
}
