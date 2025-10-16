import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Edit task page for modifying existing tasks
class EditTaskPage extends StatelessWidget {
  final dynamic task; // TODO: Replace with TaskModel

  const EditTaskPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Edit Task'),
        elevation: 0,
      ),
      body: const Center(
        child: Text('Edit Task page - To be implemented'),
      ),
    );
  }
}
