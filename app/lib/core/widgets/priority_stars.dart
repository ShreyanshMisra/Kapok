import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../enums/task_priority.dart';

/// Reusable widget that displays priority as 1/2/3 filled stars
class PriorityStars extends StatelessWidget {
  final TaskPriority priority;
  final double size;

  const PriorityStars({
    super.key,
    required this.priority,
    this.size = 16,
  });

  int get _starCount {
    switch (priority) {
      case TaskPriority.low:
        return 1;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.high:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        _starCount,
        (index) => Icon(
          Icons.star,
          size: size,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
