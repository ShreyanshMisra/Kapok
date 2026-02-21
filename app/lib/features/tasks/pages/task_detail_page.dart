import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/widgets/help_overlay.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/enums/task_priority.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/enums/task_status.dart';
import '../../../data/models/task_model.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../teams/bloc/team_bloc.dart';
import '../../teams/bloc/team_event.dart';
import '../../teams/bloc/team_state.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../../map/widgets/mapbox_map_view.dart';
import '../../map/web/mapbox_web_controller_stub.dart'
    if (dart.library.html) '../../map/web/mapbox_web_controller.dart';
import '../../../core/widgets/kapok_logo.dart';
import '../../../core/widgets/priority_stars.dart';
import '../../../core/enums/task_category.dart';
import '../../../core/utils/role_icons.dart';

/// Task detail page with map, editing, and deletion functionality
class TaskDetailPage extends StatefulWidget {
  final TaskModel task;
  final String currentUserId;

  const TaskDetailPage({
    super.key,
    required this.task,
    required this.currentUserId,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  TaskPriority _selectedPriority = TaskPriority.medium;
  TaskStatus _selectedStatus = TaskStatus.pending;
  String? _selectedAssignedTo;
  TaskCategory _selectedCategory = TaskCategory.other;
  DateTime? _selectedDueDate;
  MapboxWebController? _mapController;
  bool _showMap = true;
  Offset? _pinScreenPosition;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description ?? '',
    );
    _addressController = TextEditingController(text: widget.task.address ?? '');
    _selectedPriority = widget.task.priority;
    _selectedStatus = widget.task.status;
    _selectedAssignedTo = widget.task.assignedTo;
    _selectedCategory = widget.task.category;
    _selectedDueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Check if user can edit this task
  bool get canEdit {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      return widget.task.createdBy == user.id ||
          widget.task.assignedTo == user.id ||
          user.userRole.toString().contains('admin') ||
          user.userRole.toString().contains('teamLeader');
    }
    return false;
  }

  /// Get assignment display text with user name
  String get assignmentDisplay {
    final assignedTo = widget.task.assignedTo;
    if (assignedTo == null || assignedTo.isEmpty) {
      return 'Unassigned';
    }

    try {
      final teamState = context.read<TeamBloc>().state;
      final member = teamState.members.firstWhere(
        (m) => m.id == assignedTo,
        orElse: () => throw Exception('User not found'),
      );
      return '${member.name} (${member.role})';
    } catch (e) {
      // Try current user
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated && authState.user.id == assignedTo) {
        return '${authState.user.name} (${authState.user.role})';
      }
      // Fallback to showing ID if user not found in cache
      return assignedTo;
    }
  }

  /// Check if user can delete this task
  bool get canDelete {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      return widget.task.createdBy == user.id ||
          user.userRole.toString().contains('admin') ||
          user.userRole.toString().contains('teamLeader');
    }
    return false;
  }

  /// Update pin position based on current map camera
  void _updatePinPosition() {
    if (_mapController == null) return;

    final screenPos = _mapController!.projectLatLonToScreen(
      widget.task.geoLocation.latitude,
      widget.task.geoLocation.longitude,
    );

    if (screenPos != null) {
      setState(() {
        _pinScreenPosition = screenPos;
      });
    }
  }

  /// Get current user role string
  String get _currentUserRole {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final role = authState.user.userRole;
      if (role == UserRole.admin) return 'admin';
      if (role == UserRole.teamLeader) return 'teamLeader';
    }
    return 'teamMember';
  }

  /// Save changes
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // If status changed, use StatusChangeRequested for validation + history
    if (_selectedStatus != widget.task.status) {
      context.read<TaskBloc>().add(
        StatusChangeRequested(
          taskId: widget.task.id,
          newStatus: _selectedStatus,
          userId: widget.currentUserId,
          userRole: _currentUserRole,
        ),
      );
    }

    // Convert priority to severity for backward compatibility
    int severity;
    switch (_selectedPriority) {
      case TaskPriority.low:
        severity = 2;
        break;
      case TaskPriority.medium:
        severity = 3;
        break;
      case TaskPriority.high:
        severity = 4;
        break;
    }

    // Only send EditTaskRequested if something other than status changed
    if (_titleController.text.trim() != widget.task.title ||
        _descriptionController.text.trim() != (widget.task.description ?? '') ||
        _selectedPriority != widget.task.priority ||
        _selectedAssignedTo != widget.task.assignedTo ||
        _selectedCategory != widget.task.category ||
        _selectedDueDate != widget.task.dueDate) {
      context.read<TaskBloc>().add(
        EditTaskRequested(
          taskId: widget.task.id,
          userId: widget.currentUserId,
          taskName: _titleController.text.trim(),
          taskSeverity: severity,
          taskDescription: _descriptionController.text.trim(),
          taskCompleted: _selectedStatus == TaskStatus.completed,
          assignedTo: _selectedAssignedTo,
          category: _selectedCategory.value,
          dueDate: _selectedDueDate,
          clearDueDate: widget.task.dueDate != null && _selectedDueDate == null,
        ),
      );
    }

    // Fire confetti when a task is marked complete
    final wasNotComplete = widget.task.status != TaskStatus.completed;
    final nowComplete = _selectedStatus == TaskStatus.completed;
    if (wasNotComplete && nowComplete) {
      _confettiController.play();
    }

    setState(() {
      _isEditing = false;
    });
  }

  /// Delete task
  void _deleteTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text(
          'Are you sure you want to delete this task? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TaskBloc>().add(
                DeleteTaskRequested(taskId: widget.task.id),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
      Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(
          _isEditing ? 'Edit Task' : AppLocalizations.of(context).taskDetails,
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: 'Help',
              onPressed: () => HelpOverlay.show(
                context,
                title: 'Task Details',
                tips: const [
                  HelpTip(icon: Icons.edit, title: 'Editing', description: 'Tap the pencil icon to edit the task name, description, priority, and more.'),
                  HelpTip(icon: Icons.check_circle, title: 'Completing', description: 'Change the status to "Completed" and save to mark the task done.'),
                  HelpTip(icon: Icons.share, title: 'Sharing', description: 'Use the share button to send task details to others.'),
                  HelpTip(icon: Icons.swipe, title: 'Swipe Actions', description: 'On the Tasks list, swipe right to complete or swipe left for options.'),
                ],
              ),
            ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share task',
              onPressed: () {
                final task = widget.task;
                final duePart = task.dueDate != null
                    ? '\nDue: ${DateFormat.yMd().format(task.dueDate!)}'
                    : '';
                Share.share(
                  '[Kapok Task]\n'
                  '${task.title}\n'
                  'Priority: ${task.priority.displayName}\n'
                  'Status: ${task.status.displayName}\n'
                  'Category: ${task.category.displayName}'
                  '$duePart\n'
                  '${task.description ?? ''}',
                  subject: task.title,
                );
              },
            ),
          if (!_isEditing && canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Load team members for reassignment dropdown
                context.read<TeamBloc>().add(
                  LoadTeamMembers(teamId: widget.task.teamId),
                );
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: 'Edit Task',
            ),
          if (!_isEditing && canDelete)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTask,
              tooltip: 'Delete Task',
            ),
          if (_isEditing) ...[
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  // Reset controllers
                  _titleController.text = widget.task.title;
                  _descriptionController.text = widget.task.description ?? '';
                  _addressController.text = widget.task.address ?? '';
                  _selectedPriority = widget.task.priority;
                  _selectedStatus = widget.task.status;
                  _selectedAssignedTo = widget.task.assignedTo;
                });
              },
              child: const Text('Cancel'),
            ),
            TextButton(onPressed: _saveChanges, child: const Text('Save')),
          ],
          const KapokLogo(),
        ],
      ),
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task updated successfully'),
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.of(context).pop(true); // Return true to indicate update
          } else if (state is TaskDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task deleted successfully'),
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.of(context).pop(true); // Return true to indicate deletion
          } else if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primary,
              ),
            );
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate available height (screen - appBar - statusBar)
            final screenHeight = MediaQuery.of(context).size.height;
            final statusBarHeight = MediaQuery.of(context).padding.top;
            final appBarHeight = AppBar().preferredSize.height;
            final availableHeight =
                screenHeight - statusBarHeight - appBarHeight;
            final mapHeight = availableHeight * 0.5; // 50% of available height

            return Column(
              children: [
                // Map section - exactly 50% of available height, full width
                if (_showMap &&
                    widget.task.geoLocation.latitude != 0.0 &&
                    widget.task.geoLocation.longitude != 0.0)
                  SizedBox(
                    height: mapHeight,
                    width: double.infinity, // Full width
                    child: Stack(
                      children: [
                        // Map fills entire container
                        Positioned.fill(
                          child: MapboxMapView(
                            initialLatitude: widget.task.geoLocation.latitude,
                            initialLongitude: widget.task.geoLocation.longitude,
                            initialZoom: 16.0,
                            interactive: true,
                            onControllerReady: (controller) {
                              setState(() {
                                _mapController = controller;
                              });
                              // Update pin position when controller is ready
                              _updatePinPosition();
                              // Center map on task location
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _mapController?.setCenter(
                                  widget.task.geoLocation.latitude,
                                  widget.task.geoLocation.longitude,
                                  zoom: 16.0,
                                );
                              });
                            },
                            onCameraIdle: (cameraState) {
                              // Update pin position whenever camera moves
                              _updatePinPosition();
                            },
                          ),
                        ),
                        // Dynamic pin marker overlay
                        if (_pinScreenPosition != null)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: TaskLocationPinPainter(
                                  pinPosition: _pinScreenPosition!,
                                ),
                              ),
                            ),
                          ),
                        // Toggle map button
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(
                              _showMap
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _showMap = !_showMap;
                              });
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
                              foregroundColor: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Task details form - scrollable
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          TextFormField(
                            controller: _titleController,
                            enabled: _isEditing,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              prefixIcon: const Icon(Icons.title),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: _isEditing
                                  ? theme.colorScheme.surface
                                  : theme.colorScheme.surfaceContainerHighest,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Description
                          TextFormField(
                            controller: _descriptionController,
                            enabled: _isEditing,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              prefixIcon: const Icon(Icons.description),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: _isEditing
                                  ? theme.colorScheme.surface
                                  : theme.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Location/Address
                          TextFormField(
                            controller: _addressController,
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'Location',
                              prefixIcon: const Icon(Icons.location_on),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          if (widget.task.geoLocation.latitude != 0.0 &&
                              widget.task.geoLocation.longitude != 0.0)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Coordinates: ${widget.task.geoLocation.latitude.toStringAsFixed(6)}, ${widget.task.geoLocation.longitude.toStringAsFixed(6)}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Status
                          DropdownButtonFormField<TaskStatus>(
                            value: _selectedStatus,
                            decoration: InputDecoration(
                              labelText: 'Status',
                              prefixIcon: const Icon(Icons.flag),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: _isEditing
                                  ? theme.colorScheme.surface
                                  : theme.colorScheme.surfaceContainerHighest,
                            ),
                            items: TaskStatus.values.map((TaskStatus status) {
                              return DropdownMenuItem<TaskStatus>(
                                value: status,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 12,
                                      color: _getStatusColor(status),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(status.displayName),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: _isEditing
                                ? (TaskStatus? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedStatus = newValue;
                                      });
                                    }
                                  }
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Category
                          DropdownButtonFormField<TaskCategory>(
                            value: _selectedCategory,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context).taskCategory,
                              prefixIcon: const Icon(Icons.category_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: _isEditing
                                  ? theme.colorScheme.surface
                                  : theme.colorScheme.surfaceContainerHighest,
                            ),
                            items: TaskCategory.values.map((
                              TaskCategory category,
                            ) {
                              return DropdownMenuItem<TaskCategory>(
                                value: category,
                                child: Text(category.displayName),
                              );
                            }).toList(),
                            onChanged: _isEditing
                                ? (TaskCategory? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedCategory = newValue;
                                      });
                                    }
                                  }
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Priority
                          DropdownButtonFormField<TaskPriority>(
                            value: _selectedPriority,
                            decoration: InputDecoration(
                              labelText: 'Priority',
                              prefixIcon: const Icon(Icons.priority_high),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: _isEditing
                                  ? theme.colorScheme.surface
                                  : theme.colorScheme.surfaceContainerHighest,
                            ),
                            items: TaskPriority.values.map((
                              TaskPriority priority,
                            ) {
                              return DropdownMenuItem<TaskPriority>(
                                value: priority,
                                child: Row(
                                  children: [
                                    PriorityStars(priority: priority, size: 14),
                                    const SizedBox(width: 8),
                                    Text(priority.displayName),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: _isEditing
                                ? (TaskPriority? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedPriority = newValue;
                                      });
                                    }
                                  }
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Due date (editable when editing)
                          if (_isEditing)
                            InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 1)),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) {
                                  setState(() => _selectedDueDate = date);
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).dueDate,
                                  prefixIcon: const Icon(Icons.calendar_today),
                                  suffixIcon: _selectedDueDate != null
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () => setState(() => _selectedDueDate = null),
                                          tooltip: AppLocalizations.of(context).clearDueDate,
                                        )
                                      : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _selectedDueDate != null
                                      ? DateFormat.yMd().format(_selectedDueDate!)
                                      : AppLocalizations.of(context).selectDueDate,
                                  style: _selectedDueDate != null
                                      ? null
                                      : Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                ),
                              ),
                            )
                          else if (widget.task.dueDate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                Icon(Icons.event, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                                const SizedBox(width: 8),
                                Text(
                                    '${AppLocalizations.of(context).dueDate}: ${DateFormat.yMd().format(widget.task.dueDate!)}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_isEditing || widget.task.dueDate != null)
                            const SizedBox(height: 16),

                          // Assigned To
                          if (_isEditing)
                            BlocBuilder<TeamBloc, TeamState>(
                              builder: (context, teamState) {
                                final members = teamState.members;
                                // Filter members based on role
                                final currentAuthState = context.read<AuthBloc>().state;
                                final isTeamMember = currentAuthState is AuthAuthenticated &&
                                    currentAuthState.user.userRole == UserRole.teamMember;
                                final currentUserId = widget.currentUserId;
                                final filteredMembers = isTeamMember
                                    ? members.where((m) => m.id == currentUserId).toList()
                                    : members;

                                // Ensure current selection is valid
                                final validIds = filteredMembers.map((m) => m.id).toSet();
                                final effectiveValue =
                                    (_selectedAssignedTo != null &&
                                            _selectedAssignedTo!.isNotEmpty &&
                                            validIds.contains(_selectedAssignedTo))
                                        ? _selectedAssignedTo
                                        : null;

                                return DropdownButtonFormField<String>(
                                  value: effectiveValue,
                                  decoration: InputDecoration(
                                    labelText: 'Assigned To',
                                    prefixIcon: const Icon(Icons.person),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('Unassigned'),
                                    ),
                                    ...filteredMembers.map((member) {
                                      return DropdownMenuItem<String>(
                                        value: member.id,
                                        child: Row(
                                          children: [
                                            Icon(
                                              getRoleIcon(member.role),
                                              size: 16,
                                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '${member.name} (${member.role})',
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedAssignedTo = newValue;
                                    });
                                  },
                                );
                              },
                            )
                          else
                            TextFormField(
                              initialValue: assignmentDisplay,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Assigned To',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surfaceContainerHighest,
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Created/Updated dates
                          _buildInfoCard(
                            'Created',
                            DateFormat(
                              'MMM d, y • h:mm a',
                            ).format(widget.task.createdAt),
                            Icons.calendar_today,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoCard(
                            'Last Updated',
                            DateFormat(
                              'MMM d, y • h:mm a',
                            ).format(widget.task.updatedAt),
                            Icons.update,
                          ),
                          if (widget.task.completedAt != null) ...[
                            const SizedBox(height: 8),
                            _buildInfoCard(
                              'Completed',
                              DateFormat(
                                'MMM d, y • h:mm a',
                              ).format(widget.task.completedAt!),
                              Icons.check_circle,
                            ),
                          ],
                          // Time in current status
                          const SizedBox(height: 8),
                          _buildInfoCard(
                            'Time in ${widget.task.status.displayName}',
                            _getTimeInCurrentStatus(),
                            Icons.timer_outlined,
                          ),
                          // Status History Timeline
                          if (widget.task.statusHistory.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildStatusTimeline(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isEditing)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.surface,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'SAVE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    ), // end Scaffold
    // Confetti overlay — plays when task is marked complete
    Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        numberOfParticles: 30,
        colors: const [Colors.green, Colors.blue, Colors.orange, Colors.pink, Colors.purple],
      ),
    ),
    ], // end Stack children
  ); // end Stack
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Calculate time in current status
  String _getTimeInCurrentStatus() {
    // Find last status change from history, or use createdAt
    DateTime lastChange = widget.task.createdAt;
    if (widget.task.statusHistory.isNotEmpty) {
      final lastEntry = widget.task.statusHistory.last;
      final changedAt = lastEntry['changedAt'] as String?;
      if (changedAt != null) {
        lastChange = DateTime.parse(changedAt);
      }
    }

    final duration = DateTime.now().difference(lastChange);
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  /// Build status history timeline widget
  Widget _buildStatusTimeline() {
    final teamState = context.read<TeamBloc>().state;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status History',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        ...widget.task.statusHistory.reversed.map((entry) {
          final status = entry['status'] as String? ?? 'unknown';
          final changedBy = entry['changedBy'] as String? ?? '';
          final changedAt = entry['changedAt'] as String?;
          final previousStatus = entry['previousStatus'] as String?;

          // Resolve user name
          String userName = changedBy;
          try {
            final member = teamState.members.firstWhere((m) => m.id == changedBy);
            userName = member.name;
          } catch (_) {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated && authState.user.id == changedBy) {
              userName = authState.user.name;
            }
          }

          final formattedDate = changedAt != null
              ? DateFormat('MMM d, y • h:mm a').format(DateTime.parse(changedAt))
              : 'Unknown date';

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColorForValue(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 30,
                      color: theme.colorScheme.onSurface.withOpacity(0.18),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        previousStatus != null
                            ? '${TaskStatus.fromString(previousStatus).displayName} → ${TaskStatus.fromString(status).displayName}'
                            : TaskStatus.fromString(status).displayName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '$userName • $formattedDate',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _getStatusColorForValue(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFF9E9E9E); // Gray
      case 'inProgress':
        return const Color(0xFF2196F3); // Blue
      case 'completed':
        return const Color(0xFF4CAF50); // Green
      default:
        return AppColors.primary;
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return const Color(0xFF9E9E9E);
      case TaskStatus.inProgress:
        return const Color(0xFF2196F3);
      case TaskStatus.completed:
        return const Color(0xFF4CAF50);
    }
  }
}

/// Custom painter to draw task location pin that updates dynamically with map camera
class TaskLocationPinPainter extends CustomPainter {
  final Offset pinPosition;

  TaskLocationPinPainter({required this.pinPosition});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw pin shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(pinPosition + const Offset(2, 2), 8, shadowPaint);

    // Draw pin icon (location_on style)
    final pinPaint = Paint()
      ..color = AppColors.error
      ..style = PaintingStyle.fill;

    // Draw pin circle
    canvas.drawCircle(pinPosition, 12, pinPaint);

    // Draw white border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(pinPosition, 12, borderPaint);

    // Draw inner dot
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(pinPosition, 6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant TaskLocationPinPainter oldDelegate) {
    // Repaint if pin position changed significantly (more than 1 pixel)
    return (oldDelegate.pinPosition - pinPosition).distance > 1.0;
  }
}
