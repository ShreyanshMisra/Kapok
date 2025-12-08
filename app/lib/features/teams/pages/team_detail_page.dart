import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/team_model.dart';
import '../../../data/models/user_model.dart';
import '../bloc/team_bloc.dart';
import '../bloc/team_event.dart';
import '../bloc/team_state.dart';

/// Team detail page showing team information and members
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
  @override
  void initState() {
    super.initState();
    // TODO: Load team members when page initializes
    // context.read<TeamBloc>().add(LoadTeamMembers(widget.team.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(widget.team.name),
        elevation: 0,
        actions: [
          // TODO: Add team settings menu for team leaders
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showEditTeamDialog();
                  break;
                case 'close':
                  _showCloseTeamDialog();
                  break;
                case 'leave':
                  _showLeaveTeamDialog();
                  break;
              }
            },
            itemBuilder: (context) {
              final localizations = AppLocalizations.of(context);
              return [
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
                  value: 'leave',
                  child: Row(
                    children: [
                      const Icon(Icons.exit_to_app),
                      const SizedBox(width: 8),
                      Text(localizations.leaveTeam),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: BlocBuilder<TeamBloc, TeamState>(
        builder: (context, state) {
          return SingleChildScrollView(
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
          );
        },
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
                        widget.team.name,
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
                const Spacer(),
                if (_isCurrentUserLeader())
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Navigate to manage members page
                    },
                    icon: const Icon(Icons.manage_accounts),
                    label: Text(AppLocalizations.of(context).manage),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // TODO: Load and display team members
            _buildMembersList(),
          ],
        ),
      ),
    );
  }

  /// Build members list
  Widget _buildMembersList() {
    // TODO: Replace with actual member data
    final members = <UserModel>[]; // This should come from the BLoC state
    
    if (members.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          AppLocalizations.of(context).loading,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    
    return Column(
      children: members.map((member) => _buildMemberTile(member)).toList(),
    );
  }

  /// Build member tile
  Widget _buildMemberTile(UserModel member) {
    final isLeader = member.id == widget.team.leaderId;
    
    return ListTile(
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
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(member.role),
          if (isLeader)
            Text(
              AppLocalizations.of(context).teamLeader,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
        ],
      ),
      trailing: isLeader
          ? Icon(
              Icons.star,
              color: AppColors.primary,
              size: 20,
            )
          : _isCurrentUserLeader()
              ? IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    _showMemberOptions(member);
                  },
                )
              : null,
    );
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
                    // TODO: Navigate to team tasks page
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(AppLocalizations.of(context).viewAll),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // TODO: Load and display recent team tasks
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppLocalizations.of(context).loading,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Check if current user is the team leader
  bool _isCurrentUserLeader() {
    // TODO: Get current user ID from auth state
    final currentUserId = 'current_user_id';
    return currentUserId == widget.team.leaderId;
  }

  /// Show edit team dialog
  void _showEditTeamDialog() {
    // TODO: Implement edit team dialog
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
                // TODO: Implement close team
                context.read<TeamBloc>().add(
                  CloseTeamRequested(
                    teamId: widget.team.id,
                    userId: 'current_user_id', // TODO: Get from auth state
                  ),
                );
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

  /// Show leave team dialog
  void _showLeaveTeamDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final localizations = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(localizations.leaveTeam),
          content: Text(localizations.confirmRemoveMember), // Using existing confirmation message
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement leave team
                context.read<TeamBloc>().add(
                  LeaveTeamRequested(
                    teamId: widget.team.id,
                    userId: 'current_user_id', // TODO: Get from auth state
                  ),
                );
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

  /// Show member options menu
  void _showMemberOptions(UserModel member) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_remove),
              title: Text(AppLocalizations.of(context).removeFromTeam),
              onTap: () {
                Navigator.of(context).pop();
                _showRemoveMemberDialog(member);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Show remove member dialog
  void _showRemoveMemberDialog(UserModel member) {
    showDialog(
      context: context,
      builder: (context) {
        final localizations = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(localizations.removeMember),
          content: Text(localizations.confirmRemoveMember),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement remove member
                context.read<TeamBloc>().add(
                  RemoveMemberRequested(
                    teamId: widget.team.id,
                    memberId: member.id,
                    leaderId: 'current_user_id', // TODO: Get from auth state
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: Text(localizations.remove),
            ),
          ],
        );
      },
    );
  }
}
