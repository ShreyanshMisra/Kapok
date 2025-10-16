import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Create task page for adding new tasks
class CreateTaskPage extends StatelessWidget {
  const CreateTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: const Text('Create Task'),
        elevation: 0,
      ),
      body: const Center(
        child: Text('Create Task page - To be implemented'),
      ),
    );
  }
}
