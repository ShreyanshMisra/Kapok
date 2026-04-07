import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/kapok_logo.dart';

class AdminPermissionsPage extends StatelessWidget {
  const AdminPermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(localizations.administratorPermissions),
        centerTitle: true,
        elevation: 0,
        actions: const [KapokLogo()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
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
                        Icon(Icons.admin_panel_settings,
                            color: AppColors.primary, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            localizations.administratorPermissions,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.permissionsPageDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    AppColors.primary.withOpacity(0.1),
                  ),
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
                    DataColumn(
                      label: Text(
                        localizations.whoCanPerform,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                  rows: [
                    _buildRow(localizations.createTeam,
                        '${localizations.teamLeader}, ${localizations.admin}'),
                    _buildRow(localizations.joinTeam,
                        '${localizations.teamMember}, ${localizations.teamLeader}'),
                    _buildRow(localizations.viewTeam,
                        localizations.anyTeamMember),
                    _buildRow(localizations.editTeam,
                        '${localizations.teamLeader}, ${localizations.admin}'),
                    _buildRow(localizations.closeTeam,
                        '${localizations.teamLeader}, ${localizations.admin}'),
                    _buildRow(localizations.deleteTeam,
                        '${localizations.teamLeader}, ${localizations.admin}'),
                    _buildRow(localizations.removeMember,
                        localizations.teamLeaderOnly),
                    _buildRow(localizations.leaveTeam,
                        localizations.anyMemberExceptLeader),
                    _buildRow(localizations.viewAllTeams,
                        localizations.adminOnly),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.info, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        localizations.adminFeaturesPlannedNote,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildRow(String action, String whoCanPerform) {
    return DataRow(cells: [
      DataCell(Text(action)),
      DataCell(Text(whoCanPerform)),
    ]);
  }
}
