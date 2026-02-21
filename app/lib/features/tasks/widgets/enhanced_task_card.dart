import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/enums/task_status.dart';
import '../../../data/models/task_model.dart';
import '../../../core/widgets/priority_stars.dart';

/// Enhanced task card with priority border, status badge, avatar, swipe actions,
/// long-press preview, and quick-assign for unassigned tasks.
class EnhancedTaskCard extends StatelessWidget {
  final TaskModel task;
  final String assigneeDisplay;
  final String teamDisplay;
  final VoidCallback onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onShowOptions;
  final VoidCallback? onQuickAssign;
  final bool canComplete;
  final bool canReassign;

  const EnhancedTaskCard({
    super.key,
    required this.task,
    required this.assigneeDisplay,
    required this.teamDisplay,
    required this.onTap,
    this.onComplete,
    this.onShowOptions,
    this.onQuickAssign,
    this.canComplete = false,
    this.canReassign = false,
  });

  Color _getStatusColor() {
    switch (task.status) {
      case TaskStatus.pending:
        return const Color(0xFF9E9E9E);
      case TaskStatus.inProgress:
        return const Color(0xFF2196F3);
      case TaskStatus.completed:
        return const Color(0xFF4CAF50);
    }
  }

  IconData _getStatusIcon() {
    switch (task.status) {
      case TaskStatus.pending:
        return Icons.schedule;
      case TaskStatus.inProgress:
        return Icons.play_arrow;
      case TaskStatus.completed:
        return Icons.check_circle;
    }
  }

  String _getTimeInStatus() {
    DateTime lastChange = task.createdAt;
    if (task.statusHistory.isNotEmpty) {
      final lastEntry = task.statusHistory.last;
      final changedAt = lastEntry['changedAt'] as String?;
      if (changedAt != null) {
        lastChange = DateTime.parse(changedAt);
      }
    }
    final duration = DateTime.now().difference(lastChange);
    if (duration.inDays > 0) return '${duration.inDays}d';
    if (duration.inHours > 0) return '${duration.inHours}h';
    return '${duration.inMinutes}m';
  }

  bool get _isUnassigned =>
      task.assignedTo == null || task.assignedTo!.isEmpty;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final statusColor = _getStatusColor();
    final descriptionPreview = (task.description ?? '').length > 50
        ? '${(task.description ?? '').substring(0, 50)}...'
        : (task.description ?? '');
    final locationText = task.address ?? 'Lat: ${task.latitude.toStringAsFixed(2)}, Lon: ${task.longitude.toStringAsFixed(2)}';

    Widget cardContent = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: () => _showPreviewSheet(context, loc),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row with status badge top-right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getStatusIcon(), size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            task.status.displayName,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Category + priority
                Row(
                  children: [
                    Text(
                      task.category.displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PriorityStars(priority: task.priority, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      '${_getTimeInStatus()} in status',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (descriptionPreview.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    descriptionPreview,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                // Footer: location, team, date, assignee
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        locationText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.group_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        teamDisplay,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d').format(task.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Assignee row or quick-assign
                Row(
                  children: [
                    if (_isUnassigned) ...[
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.textDisabled,
                        child: Icon(Icons.person_off, size: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 8),
                      if (canReassign && onQuickAssign != null)
                        TextButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            onQuickAssign!();
                          },
                          icon: const Icon(Icons.person_add, size: 16),
                          label: Text(loc.assignedToLabel),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                      else
                        Text(
                          loc.unassignedTasks,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ] else ...[
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: Text(
                          assigneeDisplay.isNotEmpty ? assigneeDisplay[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          assigneeDisplay,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Wrap in Dismissible for swipe actions if we have handlers
    if ((onComplete != null && canComplete && task.status != TaskStatus.completed) ||
        onShowOptions != null) {
      return Dismissible(
        key: ValueKey('task_${task.id}'),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            HapticFeedback.mediumImpact();
            onShowOptions?.call();
            return false; // Don't dismiss, we showed a sheet
          }
          if (direction == DismissDirection.startToEnd && canComplete) {
            HapticFeedback.mediumImpact();
            onComplete?.call();
            return true;
          }
          return false;
        },
        onDismissed: (_) {
          onComplete?.call();
        },
        background: Container(
          margin: const EdgeInsets.only(bottom: 16),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 24),
          decoration: BoxDecoration(
            color: AppColors.severity1.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.check_circle, color: AppColors.severity1, size: 32),
        ),
        secondaryBackground: Container(
          margin: const EdgeInsets.only(bottom: 16),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.more_horiz, color: AppColors.info, size: 32),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: cardContent,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: cardContent,
    );
  }

  void _showPreviewSheet(BuildContext context, AppLocalizations loc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textDisabled,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                task.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  PriorityStars(priority: task.priority),
                  const SizedBox(width: 12),
                  Text(
                    '${task.category.displayName} • ${task.status.displayName}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  task.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: Text(loc.location),
                subtitle: Text(task.address ?? '${task.latitude.toStringAsFixed(4)}, ${task.longitude.toStringAsFixed(4)}'),
              ),
              ListTile(
                leading: const Icon(Icons.group_outlined),
                title: Text(loc.teamName),
                subtitle: Text(teamDisplay),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(loc.assignedToLabel),
                subtitle: Text(_isUnassigned ? loc.unassignedTasks : assigneeDisplay),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onTap();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(loc.openTask),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
