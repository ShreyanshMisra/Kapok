import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/team_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/task_model.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/team_bloc.dart';
import '../bloc/team_event.dart';
import '../bloc/team_state.dart';
import '../../tasks/bloc/task_bloc.dart';
import '../../tasks/bloc/task_event.dart';
import '../../tasks/bloc/task_state.dart';
import '../../../app/router.dart';

/// Team detail page showing team information, members, and tasks
class TeamDetailPage extends StatefulWidget {
  final TeamModel team;

  const TeamDetailPage({
    super.key,
    required this.team,
  });

  @override
  State<TeamDetailPage> createState() => _TeamDetailPageState();
}

class _TeamDetailPageState extends State<TeamDetailPage> {
  final Map<String, bool> _expandedMembers = {};

  @override
  void initState() {
    super.initState();
    // Load team members and tasks when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeamBloc>().add(LoadTeamMembers(teamId: widget.team.id));
      context.read<TaskBloc>().add(LoadTasksByTeamRequested(teamId: widget.team.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(widget.team.teamName),
        elevation: 0,
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              if (authState is AuthAuthenticated) {
                final isLeader = authState.user.id == widget.team.leaderId;
                final localizations = AppLocalizations.of(context);
                
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditTeamDialog();
                        break;
                      case 'close':
                        _showCloseTeamDialog();
                        break;
                      case 'delete':
                        _showDeleteTeamDialog();
                        break;
                      case 'leave':
                        _showLeaveTeamDialog();
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    final items = <PopupMenuItem<String>>[];
                    
                    if (isLeader) {
                      items.addAll([
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit),
                              const SizedBox(width: 8),
                              Text(localizations.editTeam),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'close',
                          child: Row(
                            children: [
                              const Icon(Icons.close),
                              const SizedBox(width: 8),
                              Text(localizations.closeTeam),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete, color: AppColors.error),
                              const SizedBox(width: 8),
                              Text(
                                'Delete Team',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ]);
                    } else {
                      items.add(
                        PopupMenuItem(
                          value: 'leave',
                          child: Row(
                            children: [
                              const Icon(Icons.exit_to_app),
                              const SizedBox(width: 8),
                              Text(localizations.leaveTeam),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    return items;
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<TeamBloc, TeamState>(
            listener: (context, state) {
              if (state is TeamError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              } else if (state is TeamDeleted) {
                // Team was deleted, navigate back
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Team deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
          ),
          BlocListener<TaskBloc, TaskState>(
            listener: (context, state) {
              if (state is TaskCreated) {
                // Reload tasks when a new task is created
                context.read<TaskBloc>().add(LoadTasksByTeamRequested(teamId: widget.team.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task created successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else if (state is TaskError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
          ),
        ],
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<TeamBloc>().add(LoadTeamMembers(teamId: widget.team.id));
            context.read<TaskBloc>().add(LoadTasksByTeamRequested(teamId: widget.team.id));
          },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team info card
              _buildTeamInfoCard(),
              const SizedBox(height: 16),
              
              // Team code card (for team leaders)
              if (_isCurrentUserLeader()) _buildTeamCodeCard(),
              if (_isCurrentUserLeader()) const SizedBox(height: 16),
              
              // Members section
              _buildMembersSection(),
              const SizedBox(height: 16),
              
              // Tasks section
              _buildTasksSection(),
            ],
          ),
        ),
        ),
      ),
    );
  }

  /// Build team information card
  Widget _buildTeamInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.group,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.team.teamName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.team.memberIds.length} member${widget.team.memberIds.length != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.team.isActive 
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.team.isActive ? 'Active' : 'Inactive',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.team.isActive ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (widget.team.description != null && widget.team.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.team.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build team code card (for team leaders)
  Widget _buildTeamCodeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.vpn_key,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Team Code',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    widget.team.teamCode,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share this code with team members',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Copy team code to clipboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context).teamCodeCopiedToClipboard),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: Text(AppLocalizations.of(context).copyCode),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Share team code
                    },
                    icon: const Icon(Icons.share),
                    label: Text(AppLocalizations.of(context).share),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build members section
  Widget _buildMembersSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).teamMembers,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BlocBuilder<TeamBloc, TeamState>(
              builder: (context, state) {
                if (state is TeamLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (state is TeamMembersLoaded) {
                  final members = state.members;
                  if (members.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No members found',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: members.map((member) => _buildExpandableMemberCard(member)).toList(),
                  );
                } else if (state is TeamError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error loading members: ${state.message}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    AppLocalizations.of(context).loading,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build expandable member card
  Widget _buildExpandableMemberCard(UserModel member) {
    final isLeader = member.id == widget.team.leaderId;
    final isExpanded = _expandedMembers[member.id] ?? false;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          member.name,
          style: TextStyle(
            fontWeight: isLeader ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          isLeader ? 'Team Leader' : member.userRole.displayName,
          style: TextStyle(
            color: isLeader ? AppColors.primary : AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: isLeader
            ? Icon(Icons.star, color: AppColors.primary, size: 20)
            : null,
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _expandedMembers[member.id] = expanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role
                _buildInfoRow(Icons.person, 'Role', member.userRole.displayName),
                const SizedBox(height: 8),
                // Specialty
                _buildInfoRow(Icons.work, 'Specialty', member.role),
                const SizedBox(height: 8),
                // Email
                _buildInfoRow(Icons.email, 'Email', member.email),
                const SizedBox(height: 16),
                // Assigned Tasks
                FutureBuilder<List<TaskModel>>(
                  future: _getAssignedTasks(member.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final tasks = snapshot.data ?? [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.assignment, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Assigned Tasks (${tasks.length})',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (tasks.isEmpty)
                          Text(
                            'No assigned tasks',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )
                        else
                          ...tasks.map((task) => _buildTaskDropdownItem(task)),
                      ],
                    );
                  },
                ),
                // Remove member button (only for leaders, and can't remove themselves)
                if (_isCurrentUserLeader() && !isLeader) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showRemoveMemberDialog(member),
                      icon: const Icon(Icons.person_remove),
                      label: Text(AppLocalizations.of(context).removeFromTeam),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build info row
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// Get assigned tasks for a user
  Future<List<TaskModel>> _getAssignedTasks(String userId) async {
    try {
      final taskState = context.read<TaskBloc>().state;
      if (taskState is TasksLoaded) {
        return taskState.tasks.where((task) => task.assignedTo == userId).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Build task dropdown item
  Widget _buildTaskDropdownItem(TaskModel task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      elevation: 0,
      color: AppColors.background,
      child: ListTile(
        dense: true,
        leading: Icon(
          Icons.circle,
          size: 8,
          color: _getPriorityColor(task.priority),
        ),
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Icon(Icons.chevron_right, size: 16),
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.taskDetail,
            arguments: {'task': task, 'currentUserId': _getCurrentUserId()},
          );
        },
      ),
    );
  }

  Color _getPriorityColor(dynamic priority) {
    if (priority is String) {
      switch (priority.toLowerCase()) {
        case 'high':
          return AppColors.error;
        case 'medium':
          return AppColors.warning;
        case 'low':
          return AppColors.success;
        default:
          return AppColors.textSecondary;
      }
    }
    // Handle TaskPriority enum
    switch (priority.toString()) {
      case 'TaskPriority.high':
        return AppColors.error;
      case 'TaskPriority.medium':
        return AppColors.warning;
      case 'TaskPriority.low':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Build tasks section
  Widget _buildTasksSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).teamTasks,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRouter.createTask,
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context).createTask),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (state is TasksLoaded) {
                  final tasks = state.tasks.where((t) => t.teamId == widget.team.id).toList();
                  if (tasks.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No tasks yet. Create one to get started!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: tasks.map((task) => _buildTaskCard(task)).toList(),
                  );
                } else if (state is TaskError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error loading tasks: ${state.message}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    AppLocalizations.of(context).loading,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build task card
  Widget _buildTaskCard(TaskModel task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          Icons.circle,
          size: 12,
          color: _getPriorityColor(task.priority),
        ),
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty)
              Text(
                task.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(task.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.status.value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(task.status),
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.priority.value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getPriorityColor(task.priority),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.taskDetail,
            arguments: {'task': task, 'currentUserId': _getCurrentUserId()},
          );
        },
      ),
    );
  }

  Color _getStatusColor(dynamic status) {
    if (status is String) {
      switch (status.toLowerCase()) {
        case 'completed':
          return AppColors.success;
        case 'inprogress':
          return AppColors.info;
        case 'pending':
          return AppColors.textSecondary;
        default:
          return AppColors.textSecondary;
      }
    }
    // Handle TaskStatus enum
    switch (status.toString()) {
      case 'TaskStatus.completed':
        return AppColors.success;
      case 'TaskStatus.inProgress':
        return AppColors.info;
      case 'TaskStatus.pending':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Get current user ID
  String _getCurrentUserId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.id;
    }
    return '';
  }

  /// Check if current user is the team leader
  bool _isCurrentUserLeader() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.id == widget.team.leaderId;
    }
    return false;
  }

  /// Show remove member confirmation dialog
  void _showRemoveMemberDialog(UserModel member) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final localizations = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(localizations.removeMember),
          content: Text(
            '${localizations.confirmRemoveMember}\n\n${member.name} will be removed from ${widget.team.teamName}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context.read<TeamBloc>().add(
                    RemoveMemberRequested(
                      teamId: widget.team.id,
                      memberId: member.id,
                      leaderId: authState.user.id,
                    ),
                  );
                  // Show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${member.name} removed from team'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: Text(localizations.remove),
            ),
          ],
        );
      },
    );
  }

  /// Show edit team dialog
  void _showEditTeamDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final localizations = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(localizations.editTeam),
          content: Text(localizations.editTeamFunctionalityWillBeImplementedHere),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.save),
            ),
          ],
        );
      },
    );
  }

  /// Show close team dialog
  void _showCloseTeamDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final localizations = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(localizations.closeTeam),
          content: Text(localizations.confirmCloseTeam),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context.read<TeamBloc>().add(
                    CloseTeamRequested(
                      teamId: widget.team.id,
                      userId: authState.user.id,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: Text(localizations.closeTeam),
            ),
          ],
        );
      },
    );
  }

  /// Show delete team dialog
  void _showDeleteTeamDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BlocListener<TeamBloc, TeamState>(
          listener: (context, state) {
            if (state is TeamDeleted) {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to teams list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Team deleted successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is TeamError) {
              Navigator.of(context).pop(); // Close dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to delete team: ${state.message}'),
                  backgroundColor: AppColors.error,
                  action: SnackBarAction(
                    label: 'Retry',
                    onPressed: () {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is AuthAuthenticated) {
                        context.read<TeamBloc>().add(
                          DeleteTeamRequested(
                            teamId: widget.team.id,
                            userId: authState.user.id,
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            }
          },
          child: BlocBuilder<TeamBloc, TeamState>(
            builder: (context, state) {
              final isLoading = state is TeamLoading;
              
              return AlertDialog(
                title: const Text('Delete Team'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Are you sure you want to permanently delete this team? This action cannot be undone. All team members will be removed from the team.',
                    ),
                    if (isLoading) ...[
                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      const Text('Deleting team...'),
                    ],
                  ],
                ),
                actions: [
                  if (!isLoading)
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            final authState = context.read<AuthBloc>().state;
                            if (authState is AuthAuthenticated) {
                              context.read<TeamBloc>().add(
                                DeleteTeamRequested(
                                  teamId: widget.team.id,
                                  userId: authState.user.id,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      disabledBackgroundColor: AppColors.error.withOpacity(0.5),
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// Show leave team dialog
  void _showLeaveTeamDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final localizations = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(localizations.leaveTeam),
          content: Text(localizations.confirmRemoveMember),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context.read<TeamBloc>().add(
                    LeaveTeamRequested(
                      teamId: widget.team.id,
                      userId: authState.user.id,
                    ),
                  );
                  Navigator.of(context).pop(); // Go back to teams page
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
              ),
              child: Text(localizations.leaveTeam),
            ),
          ],
        );
      },
    );
  }
}
