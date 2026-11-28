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
import '../../../data/models/user_model.dart';
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
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  TaskPriority _selectedPriority = TaskPriority.medium;
  TaskStatus _selectedStatus = TaskStatus.pending;
  String? _selectedAssignedTo;
  TaskCategory _selectedCategory = TaskCategory.other;
  MapboxWebController? _mapController;
  bool _showMap = true;
  Offset? _pinScreenPosition;
  late ConfettiController _confettiController;
  List<UserModel> _cachedMembers = [];

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
  /// Team members can only edit tasks assigned to them.
  /// Team leaders and admins can edit all tasks.
  bool get canEdit {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      if (user.userRole == UserRole.admin || user.userRole == UserRole.teamLeader) {
        return true;
      }
      return widget.task.assignedTo == user.id;
    }
    return false;
  }

  /// Get assignment display text with user name
  String get assignmentDisplay {
    final assignedTo = widget.task.assignedTo;
    if (assignedTo == null || assignedTo.isEmpty) {
      return AppLocalizations.of(context).unassigned;
    }

    try {
      final teamState = context.read<TeamBloc>().state;
      final member = teamState.members.firstWhere(
        (m) => m.id == assignedTo,
        orElse: () => throw Exception('User not found'),
      );
      return '${member.name} (${AppLocalizations.of(context).professionName(member.role)})';
    } catch (e) {
      // Try current user
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated && authState.user.id == assignedTo) {
        return '${authState.user.name} (${AppLocalizations.of(context).professionName(authState.user.role)})';
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
    if (!_formKey.currentState!.validate()) return;

    final statusChanged = _selectedStatus != widget.task.status;
    final fieldsChanged =
        _titleController.text.trim() != widget.task.title ||
        _descriptionController.text.trim() != (widget.task.description ?? '') ||
        _selectedPriority != widget.task.priority ||
        _selectedAssignedTo != widget.task.assignedTo ||
        _selectedCategory != widget.task.category;

    if (!statusChanged && !fieldsChanged) {
      setState(() { _isEditing = false; });
      return;
    }

    _isSaving = true;

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

    if (fieldsChanged) {
      context.read<TaskBloc>().add(
        EditTaskRequested(
          taskId: widget.task.id,
          userId: widget.currentUserId,
          userRole: _currentUserRole,
          taskName: _titleController.text.trim(),
          taskSeverity: severity,
          taskDescription: _descriptionController.text.trim(),
          taskCompleted: _selectedStatus == TaskStatus.completed,
          assignedTo: _selectedAssignedTo,
          category: _selectedCategory.value,
        ),
      );
    } else if (statusChanged) {
      context.read<TaskBloc>().add(
        StatusChangeRequested(
          taskId: widget.task.id,
          newStatus: _selectedStatus,
          userId: widget.currentUserId,
          userRole: _currentUserRole,
        ),
      );
    }

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
        title: Text(AppLocalizations.of(context).deleteTask),
        content: Text(AppLocalizations.of(context).deleteTaskConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TaskBloc>().add(
                DeleteTaskRequested(taskId: widget.task.id),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
            child: Text(AppLocalizations.of(context).delete.toUpperCase()),
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
          _isEditing ? AppLocalizations.of(context).editTask : AppLocalizations.of(context).taskDetails,
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: AppLocalizations.of(context).help,
              onPressed: () => HelpOverlay.show(
                context,
                title: AppLocalizations.of(context).taskDetails,
                tips: [
                  HelpTip(icon: Icons.edit, title: AppLocalizations.of(context).edit, description: AppLocalizations.of(context).helpEditTaskTip),
                  HelpTip(icon: Icons.share, title: AppLocalizations.of(context).share, description: AppLocalizations.of(context).helpShareTaskTip),
                  HelpTip(icon: Icons.delete, title: AppLocalizations.of(context).delete, description: AppLocalizations.of(context).helpDeleteTaskTip),
                  HelpTip(icon: Icons.check_circle, title: AppLocalizations.of(context).completing, description: AppLocalizations.of(context).helpCompletingTaskTip),
                ],
              ),
            ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: AppLocalizations.of(context).shareTask,
              onPressed: () {
                final task = widget.task;
                final l = AppLocalizations.of(context);
                Share.share(
                  '[Kapok Task]\n'
                  '${task.title}\n'
                  '${l.priority}: ${l.taskPriorityName(task.priority)}\n'
                  '${l.statusLabel}: ${l.taskStatusName(task.status)}\n'
                  '${l.category}: ${l.taskCategoryName(task.category)}\n'
                  '${task.description ?? ''}',
                  subject: task.title,
                );
              },
            ),
          if (!_isEditing && canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                final teamState = context.read<TeamBloc>().state;
                context.read<TeamBloc>().add(
                  LoadTeamMembers(teamId: widget.task.teamId),
                );
                setState(() {
                  _isEditing = true;
                  _isSaving = false;
                  _cachedMembers = teamState.members;
                  _titleController.text = widget.task.title;
                  _descriptionController.text = widget.task.description ?? '';
                  _addressController.text = widget.task.address ?? '';
                  _selectedPriority = widget.task.priority;
                  _selectedStatus = widget.task.status;
                  _selectedAssignedTo = widget.task.assignedTo;
                  _selectedCategory = widget.task.category;
                });
              },
              tooltip: AppLocalizations.of(context).editTask,
            ),
          if (!_isEditing && canDelete)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTask,
              tooltip: AppLocalizations.of(context).deleteTask,
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
              child: Text(AppLocalizations.of(context).cancel),
            ),
            TextButton(onPressed: _saveChanges, child: Text(AppLocalizations.of(context).save)),
          ],
          const KapokLogo(),
        ],
      ),
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskUpdated) {
            if (!_isSaving) return;
            _isSaving = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).taskUpdated),
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is TaskDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context).taskDeleted),
              ),
            );
            Navigator.of(context).pop(true); // Return true to indicate deletion
          } else if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
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
                // Map section - hidden during edit so the form is fully interactive
                if (_showMap &&
                    !_isEditing &&
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
                            tasks: [widget.task],
                            onControllerReady: (controller) {
                              setState(() {
                                _mapController = controller;
                              });
                              _updatePinPosition();
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _mapController?.setCenter(
                                  widget.task.geoLocation.latitude,
                                  widget.task.geoLocation.longitude,
                                  zoom: 16.0,
                                );
                              });
                            },
                            onMobileControllerReady: (controller) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                controller.setCenter(
                                  widget.task.geoLocation.latitude,
                                  widget.task.geoLocation.longitude,
                                  zoom: 16.0,
                                );
                              });
                            },
                            onCameraIdle: (cameraState) {
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
                              labelText: AppLocalizations.of(context).titleLabel,
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
                                return AppLocalizations.of(context).pleaseEnterATitle;
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
                              labelText: AppLocalizations.of(context).description,
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
                              labelText: AppLocalizations.of(context).location,
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
                                AppLocalizations.of(context).coordinatesValue('${widget.task.geoLocation.latitude.toStringAsFixed(6)}, ${widget.task.geoLocation.longitude.toStringAsFixed(6)}'),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Status
                          DropdownButtonFormField<TaskStatus>(
                            value: _selectedStatus,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context).statusLabel,
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
                                    Text(AppLocalizations.of(context).taskStatusName(status)),
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
                                child: Text(AppLocalizations.of(context).taskCategoryName(category)),
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
                              labelText: AppLocalizations.of(context).priority,
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
                                    Text(AppLocalizations.of(context).taskPriorityName(priority)),
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

                          // Assigned To
                          if (_isEditing)
                            BlocListener<TeamBloc, TeamState>(
                              listenWhen: (prev, curr) => curr.members != prev.members,
                              listener: (context, teamState) {
                                if (teamState.members.isNotEmpty) {
                                  setState(() { _cachedMembers = teamState.members; });
                                }
                              },
                              child: Builder(
                                builder: (context) {
                                  final currentAuthState = context.read<AuthBloc>().state;
                                  final isTeamMember = currentAuthState is AuthAuthenticated &&
                                      currentAuthState.user.userRole == UserRole.teamMember;
                                  final currentUserId = widget.currentUserId;
                                  final filteredMembers = isTeamMember
                                      ? _cachedMembers.where((m) => m.id == currentUserId).toList()
                                      : _cachedMembers;

                                  final validIds = filteredMembers.map((m) => m.id).toSet();
                                  final effectiveValue =
                                      (_selectedAssignedTo != null &&
                                              _selectedAssignedTo!.isNotEmpty &&
                                              validIds.contains(_selectedAssignedTo))
                                          ? _selectedAssignedTo
                                          : null;

                                  return DropdownButtonFormField<String>(
                                    key: ValueKey('assignedTo_${filteredMembers.length}_$effectiveValue'),
                                    value: effectiveValue,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context).assignedTo,
                                      prefixIcon: const Icon(Icons.person),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: null,
                                        child: Text(AppLocalizations.of(context).unassigned),
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
                                                  '${member.name} (${AppLocalizations.of(context).professionName(member.role)})',
                                                  overflow: TextOverflow.ellipsis,
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
                              ),
                            )
                          else
                            TextFormField(
                              initialValue: assignmentDisplay,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context).assignedTo,
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
                            AppLocalizations.of(context).created,
                            DateFormat(
                              'MMM d, y • h:mm a',
                            ).format(widget.task.createdAt),
                            Icons.calendar_today,
                          ),
                          const SizedBox(height: 8),
                          _buildInfoCard(
                            AppLocalizations.of(context).lastUpdated,
                            DateFormat(
                              'MMM d, y • h:mm a',
                            ).format(widget.task.updatedAt),
                            Icons.update,
                          ),
                          if (widget.task.completedAt != null) ...[
                            const SizedBox(height: 8),
                            _buildInfoCard(
                              AppLocalizations.of(context).completed,
                              DateFormat(
                                'MMM d, y • h:mm a',
                              ).format(widget.task.completedAt!),
                              Icons.check_circle,
                            ),
                          ],
                          // Time in current status
                          const SizedBox(height: 8),
                          _buildInfoCard(
                            AppLocalizations.of(context).timeInStatusNamed(AppLocalizations.of(context).taskStatusName(widget.task.status)),
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
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context).save.toUpperCase(),
                          style: const TextStyle(
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
    IgnorePointer(
      child: Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        numberOfParticles: 30,
        colors: const [Colors.green, Colors.blue, Colors.orange, Colors.pink, Colors.purple],
      ),
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
          AppLocalizations.of(context).statusHistory,
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
              : AppLocalizations.of(context).unknownDate;

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
                            ? '${AppLocalizations.of(context).taskStatusName(TaskStatus.fromString(previousStatus))} → ${AppLocalizations.of(context).taskStatusName(TaskStatus.fromString(status))}'
                            : AppLocalizations.of(context).taskStatusName(TaskStatus.fromString(status)),
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
      ..color = AppColors.primary
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
