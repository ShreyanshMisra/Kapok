import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/localization/app_localizations.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

/// Card that lets a team member or team leader switch between the two roles.
/// Not shown for admins.
class AccountRoleSwitch extends StatefulWidget {
  const AccountRoleSwitch({super.key, required this.currentRole});

  final UserRole currentRole;

  @override
  State<AccountRoleSwitch> createState() => _AccountRoleSwitchState();
}

class _AccountRoleSwitchState extends State<AccountRoleSwitch> {
  bool _changingRole = false;

  /// Confirms, then switches the user between team member and team leader.
  Future<void> _confirmRoleChange(UserRole newRole) async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.changeRoleTitle),
        content: Text(
          newRole == UserRole.teamLeader
              ? localizations.changeRoleToLeaderBody
              : localizations.changeRoleToMemberBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(localizations.changeRoleConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _changingRole = true);
    final messenger = ScaffoldMessenger.of(context);
    context.read<AuthBloc>().add(UserRoleChangeRequested(
      newRole,
      onComplete: (error) {
        messenger.showSnackBar(
          error != null
              ? SnackBar(content: Text(error), backgroundColor: AppColors.error)
              : SnackBar(
                  content: Text(localizations.roleChangedTo(
                    newRole == UserRole.teamLeader
                        ? localizations.teamLeader
                        : localizations.teamMember,
                  )),
                ),
        );
        if (mounted) setState(() => _changingRole = false);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentRole == UserRole.admin) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final isLeader = widget.currentRole == UserRole.teamLeader;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              localizations.role,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            secondary: Icon(isLeader ? Icons.groups : Icons.person_outline),
            title: Text(localizations.teamLeader),
            subtitle: Text(
              '${isLeader ? localizations.teamLeader : localizations.teamMember}'
              ' · ${localizations.accountRoleSwitchSubtitle}',
            ),
            value: isLeader,
            onChanged: _changingRole
                ? null
                : (value) => _confirmRoleChange(
                      value ? UserRole.teamLeader : UserRole.teamMember,
                    ),
            activeThumbColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
