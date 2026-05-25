import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../app/router.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_state.dart';
import 'edit_profile_page.dart';
import 'settings_page.dart';
import '../../../core/widgets/kapok_logo.dart';

/// Profile page showing user information
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(AppLocalizations.of(context).profile),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
          const KapokLogo(),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile header
                  _buildProfileHeader(context, state.user),
                  const SizedBox(height: 24),
                  
                  // Profile actions
                  _buildProfileActions(context),
                  const SizedBox(height: 24),
                  
                  // Account information
                  _buildAccountInfo(context, state.user),
                  const SizedBox(height: 24),

                  // Permissions table
                  _buildPermissionsTable(context, state.user.userRole),
                ],
              ),
            );
          } else {
            return Center(
              child: Text(AppLocalizations.of(context).userNotAuthenticated),
            );
          }
        },
      ),
    );
  }

  /// Build profile header
  Widget _buildProfileHeader(BuildContext context, user) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 32,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.role,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                user.userRole.displayName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build profile actions
  Widget _buildProfileActions(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text(AppLocalizations.of(context).editProfile),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(AppLocalizations.of(context).settings),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(AppLocalizations.of(context).about),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(AppRouter.about);
            },
          ),
        ],
      ),
    );
  }

  /// Build account information
  Widget _buildAccountInfo(BuildContext context, user) {
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
            Text(
              AppLocalizations.of(context).accountInformation,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, AppLocalizations.of(context).email, user.email),
            _buildInfoRow(context, AppLocalizations.of(context).accountType, user.userRole.displayName),
            _buildInfoRow(context, AppLocalizations.of(context).role, user.role),
            _buildInfoRow(context, AppLocalizations.of(context).userId, user.id),
          ],
        ),
      ),
    );
  }

  /// Build info row
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsTable(BuildContext context, UserRole currentRole) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    int roleIndex(UserRole role) {
      switch (role) {
        case UserRole.teamMember:
          return 0;
        case UserRole.teamLeader:
          return 1;
        case UserRole.admin:
          return 2;
      }
    }

    final currentIdx = roleIndex(currentRole);

    final actions = <String, List<bool>>{
      localizations.createTeam:    [false, true, true],
      localizations.joinTeam:      [true, true, true],
      localizations.viewTeam:      [true, true, true],
      localizations.editTeam:      [false, true, true],
      localizations.closeTeam:     [false, true, true],
      localizations.deleteTeam:    [false, true, true],
      localizations.removeMember:  [false, true, false],
      localizations.leaveTeam:     [true, false, true],
      localizations.viewAllTeams:  [false, false, true],
      localizations.editOwnTasks:  [true, true, true],
      localizations.editAllTasks:  [false, true, true],
    };

    final roleLabels = [
      localizations.teamMember,
      localizations.teamLeader,
      localizations.admin,
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  localizations.permissions,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${localizations.yourRole}: ${currentRole.displayName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _HorizontallyScrollableTable(
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  AppColors.primary.withOpacity(0.08),
                ),
                columnSpacing: 20,
                columns: [
                  DataColumn(
                    label: Text(
                      localizations.action,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  for (int i = 0; i < roleLabels.length; i++)
                    DataColumn(
                      label: Text(
                        roleLabels[i],
                        style: TextStyle(
                          fontWeight: i == currentIdx
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: i == currentIdx
                              ? AppColors.primary
                              : theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                ],
                rows: actions.entries.map((entry) {
                  return DataRow(
                    cells: [
                      DataCell(Text(entry.key)),
                      for (int i = 0; i < entry.value.length; i++)
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4,
                            ),
                            decoration: i == currentIdx
                                ? BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(6),
                                  )
                                : null,
                            child: Text(
                              entry.value[i] ? '✓' : '✗',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: i == currentIdx
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: entry.value[i]
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal scroll container that always shows its scrollbar so users
/// see at a glance that there's more content off-screen.
class _HorizontallyScrollableTable extends StatefulWidget {
  const _HorizontallyScrollableTable({required this.child});

  final Widget child;

  @override
  State<_HorizontallyScrollableTable> createState() =>
      _HorizontallyScrollableTableState();
}

class _HorizontallyScrollableTableState
    extends State<_HorizontallyScrollableTable> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      trackVisibility: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          child: widget.child,
        ),
      ),
    );
  }
}
