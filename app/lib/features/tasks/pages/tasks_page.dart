import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/task_priority.dart';
import '../../../core/enums/task_status.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/sync_service.dart';
import '../../../app/router.dart';
import '../../../data/models/task_model.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../teams/bloc/team_bloc.dart';
import '../../teams/bloc/team_event.dart';
import '../../teams/bloc/team_state.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../../../core/widgets/kapok_logo.dart';
import '../../../core/enums/task_category.dart';
import '../../../core/enums/user_role.dart';
import '../widgets/enhanced_task_card.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  // Filter state
  TaskStatus? _selectedStatus;
  TaskPriority? _selectedPriority;
  TaskCategory? _selectedCategory;
  String? _selectedDateFilter; // 'pastWeek' or 'custom'
  DateTimeRange? _customDateRange;
  String? _selectedAssignment; // 'me', 'unassigned', or null for all
  bool _filterOverdue = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isStale = false;

  @override
  void initState() {
    super.initState();
    _loadPersistedFilters();
    _loadTasks();
    _checkStaleness();
  }

  Future<void> _checkStaleness() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      final isOffline = connectivity.contains(ConnectivityResult.none);
      final ts = SyncService.instance.getLastSyncTimestamp();
      if (isOffline && ts != null) {
        final last = DateTime.tryParse(ts);
        if (last != null && DateTime.now().difference(last).inMinutes > 30) {
          if (mounted) setState(() => _isStale = true);
        }
      }
    } catch (_) {}
  }

  /// Load persisted filter selections from Hive
  void _loadPersistedFilters() {
    try {
      final hive = HiveService.instance;
      final statusStr = hive.getSetting<String>('taskFilter_status');
      if (statusStr != null) {
        _selectedStatus = TaskStatus.fromString(statusStr);
      }
      final priorityStr = hive.getSetting<String>('taskFilter_priority');
      if (priorityStr != null) {
        _selectedPriority = TaskPriority.fromString(priorityStr);
      }
      final categoryStr = hive.getSetting<String>('taskFilter_category');
      if (categoryStr != null) {
        _selectedCategory = TaskCategory.fromString(categoryStr);
      }
      final assignmentStr = hive.getSetting<String>('taskFilter_assignment');
      if (assignmentStr != null) {
        _selectedAssignment = assignmentStr;
      }
    } catch (_) {
      // Ignore errors loading persisted filters
    }
  }

  /// Persist a filter value to Hive
  void _persistFilter(String key, String? value) {
    try {
      if (value != null) {
        HiveService.instance.storeSetting(key, value);
      } else {
        HiveService.instance.settingsBox.delete(key);
      }
    } catch (_) {
      // Ignore errors persisting filters
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadTasks() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      // Load user's teams first to get team IDs for task filtering
      context.read<TeamBloc>().add(
        LoadUserTeams(userId: authState.user.id),
      );
    } else {
      context.read<TaskBloc>().add(const LoadTasksRequested());
    }
  }

  /// Filter tasks based on selected filters and search query
  /// Works entirely offline using cached task data
  List<TaskModel> _getFilteredTasks(List<TaskModel> tasks) {
    final authState = context.read<AuthBloc>().state;
    String? currentUserId;
    if (authState is AuthAuthenticated) {
      currentUserId = authState.user.id;
    }

    return tasks.where((task) {
      // Filter by status
      if (_selectedStatus != null && task.status != _selectedStatus) {
        return false;
      }

      // Filter by priority
      if (_selectedPriority != null && task.priority != _selectedPriority) {
        return false;
      }

      // Filter by assignment
      if (_selectedAssignment != null) {
        if (_selectedAssignment == 'me') {
          if (task.assignedTo != currentUserId) {
            return false;
          }
        } else if (_selectedAssignment == 'unassigned') {
          if (task.assignedTo != null && task.assignedTo!.isNotEmpty) {
            return false;
          }
        }
      }

      // Filter by category
      if (_selectedCategory != null && task.category != _selectedCategory) {
        return false;
      }

      // Filter by overdue
      if (_filterOverdue && !task.isOverdue) {
        return false;
      }

      // Filter by date
      if (_selectedDateFilter != null) {
        final now = DateTime.now();
        if (_selectedDateFilter == 'pastDay') {
          final dayAgo = now.subtract(const Duration(days: 1));
          if (task.createdAt.isBefore(dayAgo)) {
            return false;
          }
        } else if (_selectedDateFilter == 'pastWeek') {
          final weekAgo = now.subtract(const Duration(days: 7));
          if (task.createdAt.isBefore(weekAgo)) {
            return false;
          }
        } else if (_selectedDateFilter == 'custom' && _customDateRange != null) {
          if (task.createdAt.isBefore(_customDateRange!.start) ||
              task.createdAt.isAfter(_customDateRange!.end.add(const Duration(days: 1)))) {
            return false;
          }
        }
      }

      // Filter by search query (title, description, address, assignee name)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final titleMatch = task.title.toLowerCase().contains(query);
        final descriptionMatch = task.description?.toLowerCase().contains(query) ?? false;
        final addressMatch = task.address?.toLowerCase().contains(query) ?? false;
        // Resolve assignee name for matching
        bool assigneeMatch = false;
        if (task.assignedTo != null && task.assignedTo!.isNotEmpty) {
          try {
            final name = _getUserName(task.assignedTo);
            assigneeMatch = name.toLowerCase().contains(query);
          } catch (_) {}
        }
        if (!titleMatch && !descriptionMatch && !addressMatch && !assigneeMatch) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedPriority = null;
      _selectedCategory = null;
      _selectedDateFilter = null;
      _customDateRange = null;
      _selectedAssignment = null;
      _filterOverdue = false;
      _searchQuery = '';
      _searchController.clear();
    });
    _persistFilter('taskFilter_status', null);
    _persistFilter('taskFilter_priority', null);
    _persistFilter('taskFilter_category', null);
    _persistFilter('taskFilter_assignment', null);
  }

  bool get _hasActiveFilters {
    return _selectedStatus != null ||
        _selectedPriority != null ||
        _selectedCategory != null ||
        _selectedDateFilter != null ||
        _selectedAssignment != null ||
        _filterOverdue ||
        _searchQuery.isNotEmpty;
  }

  /// Get user name from user ID using team members cache
  /// Returns user name if found in team members, otherwise returns 'Unknown'
  String _getUserName(String? userId) {
    if (userId == null || userId.isEmpty) {
      return AppLocalizations.of(context).unassignedTasks;
    }

    final teamState = context.read<TeamBloc>().state;
    final member = teamState.members.firstWhere(
      (m) => m.id == userId,
      orElse: () => context.read<AuthBloc>().state is AuthAuthenticated &&
              (context.read<AuthBloc>().state as AuthAuthenticated).user.id == userId
          ? (context.read<AuthBloc>().state as AuthAuthenticated).user
          : throw Exception('User not found'),
    );

    return member.name;
  }

  /// Get assignment display text with fallback
  String _getAssignmentDisplay(String? assignedTo) {
    if (assignedTo == null || assignedTo.isEmpty) {
      return AppLocalizations.of(context).unassignedTasks;
    }

    try {
      return _getUserName(assignedTo);
    } catch (e) {
      // Fallback to showing ID if user not found in cache
      return assignedTo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(AppLocalizations.of(context).tasks),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTasks),
          const KapokLogo(),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          // Listen for team loading to trigger task loading
          BlocListener<TeamBloc, TeamState>(
            listener: (context, teamState) {
              // When teams are loaded, load tasks for those teams
              if (teamState is TeamLoaded) {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  final teamIds = teamState.teams.map((team) => team.id).toList();

                  // Load tasks for user's teams (or all tasks if admin)
                  context.read<TaskBloc>().add(
                    LoadTasksForUserTeamsRequested(
                      teamIds: teamIds,
                      userId: authState.user.id,
                    ),
                  );
                }
              }
            },
          ),
          // Listen for task deletion to trigger UI refresh
          BlocListener<TaskBloc, TaskState>(
            listener: (context, taskState) {
              if (taskState is TaskDeleted) {
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task deleted successfully'),
                    backgroundColor: AppColors.primary,
                    duration: Duration(seconds: 2),
                  ),
                );
                // Reload tasks to update the list
                _loadTasks();
              }
            },
          ),
        ],
        child: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
          return Column(
            children: [
              // Staleness banner
              if (_isStale)
                MaterialBanner(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  content: Row(
                    children: [
                      const Icon(Icons.warning_amber, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Data may be outdated — last synced over 30 min ago',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.orange.shade700,
                  actions: [
                    TextButton(
                      onPressed: () => setState(() => _isStale = false),
                      child: const Text('Dismiss', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              Expanded(
                child: Builder(builder: (context) {
          if (state is TaskLoading) {
            return Center(
              child: CircularProgressIndicator(color: theme.colorScheme.primary),
            );
          } else if (state is TasksLoaded) {
            if (state.tasks.isEmpty) {
              return _buildEmptyState();
            }
            final filteredTasks = _getFilteredTasks(state.tasks);
            return Column(
              children: [
                _buildFilterBar(),
                if (filteredTasks.isEmpty && _hasActiveFilters)
                  Expanded(child: _buildNoResultsState())
                else
                  Expanded(child: _buildTaskList(filteredTasks)),
              ],
            );
          } else if (state is TaskError) {
            return _buildErrorState(state.message);
          } else if (state is TaskCreated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadTasks();
            });
            return Center(
              child: CircularProgressIndicator(color: theme.colorScheme.primary),
            );
          }

          return _buildEmptyState();
                }), // Builder
              ), // Expanded (inner)
            ], // Column children
          ); // Column
        },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRouter.createTask);
        },
        backgroundColor: theme.floatingActionButtonTheme.backgroundColor,
        foregroundColor: theme.floatingActionButtonTheme.foregroundColor,
        child: const Icon(Icons.add),
      ),
      //body: const Center(child: Text('Tasks page - To be implemented')),
    );
  }

  Widget _buildFilterBar() {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: localizations.searchTasks,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          // Filter chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Status filter
              _buildFilterChip(
                label: _selectedStatus == null
                    ? localizations.allStatuses
                    : _selectedStatus == TaskStatus.completed
                        ? localizations.completed
                        : _selectedStatus == TaskStatus.inProgress
                            ? localizations.inProgress
                            : localizations.pending,
                icon: Icons.task_alt,
                isSelected: _selectedStatus != null,
                onTap: () => _showStatusFilterDialog(),
              ),
              // Priority filter
              _buildFilterChip(
                label: _selectedPriority == null
                    ? localizations.allPriorities
                    : _selectedPriority == TaskPriority.high
                        ? localizations.threeStars
                        : _selectedPriority == TaskPriority.medium
                            ? localizations.twoStars
                            : localizations.oneStar,
                icon: Icons.flag,
                isSelected: _selectedPriority != null,
                onTap: () => _showPriorityFilterDialog(),
              ),
              // Category filter
              _buildFilterChip(
                label: _selectedCategory == null
                    ? localizations.allCategories
                    : _selectedCategory!.displayName,
                icon: Icons.category,
                isSelected: _selectedCategory != null,
                onTap: () => _showCategoryFilterDialog(),
              ),
              // Date filter
              _buildFilterChip(
                label: _selectedDateFilter == null
                    ? localizations.allDates
                    : _selectedDateFilter == 'pastDay'
                        ? localizations.pastDay
                        : _selectedDateFilter == 'pastWeek'
                            ? localizations.pastWeek
                            : localizations.customDateRange,
                icon: Icons.calendar_today,
                isSelected: _selectedDateFilter != null,
                onTap: () => _showDateFilterDialog(),
              ),
              // Assignment filter
              _buildFilterChip(
                label: _selectedAssignment == null
                    ? localizations.allTasks
                    : _selectedAssignment == 'me'
                        ? localizations.myTasks
                        : localizations.unassignedTasks,
                icon: Icons.person,
                isSelected: _selectedAssignment != null,
                onTap: () => _showAssignmentFilterDialog(),
              ),
              // Overdue filter
              _buildFilterChip(
                label: localizations.overdueOnly,
                icon: Icons.schedule,
                isSelected: _filterOverdue,
                onTap: () {
                  setState(() => _filterOverdue = !_filterOverdue);
                },
              ),
              // Clear filters button
              if (_hasActiveFilters)
                ActionChip(
                  label: Text(localizations.clearFilters),
                  avatar: const Icon(Icons.clear_all, size: 18),
                  onPressed: _clearFilters,
                  backgroundColor: AppColors.error.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      avatar: Icon(icon, size: 18),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  void _setStatusFilter(TaskStatus? value) {
    setState(() => _selectedStatus = value);
    _persistFilter('taskFilter_status', value?.value);
  }

  void _showStatusFilterDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.filterByStatus),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(localizations.allStatuses),
              leading: Radio<TaskStatus?>(
                value: null,
                groupValue: _selectedStatus,
                onChanged: (value) {
                  _setStatusFilter(value);
                  Navigator.of(context).pop();
                },
              ),
              onTap: () {
                _setStatusFilter(null);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(localizations.pending),
              leading: Radio<TaskStatus?>(
                value: TaskStatus.pending,
                groupValue: _selectedStatus,
                onChanged: (value) {
                  _setStatusFilter(value);
                  Navigator.of(context).pop();
                },
              ),
              onTap: () {
                _setStatusFilter(TaskStatus.pending);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(localizations.inProgress),
              leading: Radio<TaskStatus?>(
                value: TaskStatus.inProgress,
                groupValue: _selectedStatus,
                onChanged: (value) {
                  _setStatusFilter(value);
                  Navigator.of(context).pop();
                },
              ),
              onTap: () {
                _setStatusFilter(TaskStatus.inProgress);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(localizations.completed),
              leading: Radio<TaskStatus?>(
                value: TaskStatus.completed,
                groupValue: _selectedStatus,
                onChanged: (value) {
                  _setStatusFilter(value);
                  Navigator.of(context).pop();
                },
              ),
              onTap: () {
                _setStatusFilter(TaskStatus.completed);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _setPriorityFilter(TaskPriority? value) {
    setState(() => _selectedPriority = value);
    _persistFilter('taskFilter_priority', value?.value);
  }

  void _showPriorityFilterDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.filterByPriority),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(localizations.allPriorities),
              leading: Radio<TaskPriority?>(
                value: null,
                groupValue: _selectedPriority,
                onChanged: (value) {
                  _setPriorityFilter(value);
                  Navigator.of(context).pop();
                },
              ),
              onTap: () {
                _setPriorityFilter(null);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(localizations.threeStars),
              leading: Radio<TaskPriority?>(
                value: TaskPriority.high,
                groupValue: _selectedPriority,
                onChanged: (value) {
                  _setPriorityFilter(value);
                  Navigator.of(context).pop();
                },
              ),
              onTap: () {
                _setPriorityFilter(TaskPriority.high);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(localizations.twoStars),
              leading: Radio<TaskPriority?>(
                value: TaskPriority.medium,
                groupValue: _selectedPriority,
                onChanged: (value) {
                  _setPriorityFilter(value);
                  Navigator.of(context).pop();
                },
              ),
              onTap: () {
                _setPriorityFilter(TaskPriority.medium);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(localizations.oneStar),
              leading: Radio<TaskPriority?>(
                value: TaskPriority.low,
                groupValue: _selectedPriority,
                onChanged: (value) {
                  _setPriorityFilter(value);
                  Navigator.of(context).pop();
                },
              ),
              onTap: () {
                _setPriorityFilter(TaskPriority.low);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _setCategoryFilter(TaskCategory? value) {
    setState(() => _selectedCategory = value);
    _persistFilter('taskFilter_category', value?.value);
  }

  void _showCategoryFilterDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.filterByCategory),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(localizations.allCategories),
                leading: Radio<TaskCategory?>(
                  value: null,
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    _setCategoryFilter(value);
                    Navigator.of(context).pop();
                  },
                ),
                onTap: () {
                  _setCategoryFilter(null);
                  Navigator.of(context).pop();
                },
              ),
              ...TaskCategory.values.map((category) => ListTile(
                title: Text(category.displayName),
                leading: Radio<TaskCategory?>(
                  value: category,
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    _setCategoryFilter(value);
                    Navigator.of(context).pop();
                  },
                ),
                onTap: () {
                  _setCategoryFilter(category);
                  Navigator.of(context).pop();
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showDateFilterDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.filterByDate),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(localizations.allDates),
              leading: Radio<String?>(
                value: null,
                groupValue: _selectedDateFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedDateFilter = null;
                    _customDateRange = null;
                  });
                  Navigator.of(context).pop();
                },
              ),
              onTap: () {
                setState(() {
                  _selectedDateFilter = null;
                  _customDateRange = null;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(localizations.pastDay),
              leading: Radio<String?>(
                value: 'pastDay',
                groupValue: _selectedDateFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedDateFilter = 'pastDay';
                    _customDateRange = null;
                  });
                  Navigator.of(context).pop();
                },
              ),
              onTap: () {
                setState(() {
                  _selectedDateFilter = 'pastDay';
                  _customDateRange = null;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(localizations.pastWeek),
              leading: Radio<String?>(
                value: 'pastWeek',
                groupValue: _selectedDateFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedDateFilter = 'pastWeek';
                    _customDateRange = null;
                  });
                  Navigator.of(context).pop();
                },
              ),
              onTap: () {
                setState(() {
                  _selectedDateFilter = 'pastWeek';
                  _customDateRange = null;
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(localizations.customDateRange),
              leading: Radio<String?>(
                value: 'custom',
                groupValue: _selectedDateFilter,
                onChanged: (_) async {
                  Navigator.of(context).pop();
                  await _showDateRangePicker();
                },
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await _showDateRangePicker();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final localizations = AppLocalizations.of(context);
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _customDateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
      helpText: localizations.selectDateRange,
    );
    if (picked != null) {
      setState(() {
        _selectedDateFilter = 'custom';
        _customDateRange = picked;
      });
    }
  }

  void _setAssignmentFilter(String? value) {
    setState(() => _selectedAssignment = value);
    _persistFilter('taskFilter_assignment', value);
  }

  void _showAssignmentFilterDialog() {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.filterByAssignment),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(localizations.allTasks),
              leading: Radio<String?>(
                value: null,
                groupValue: _selectedAssignment,
                onChanged: (value) {
                  _setAssignmentFilter(value);
                  Navigator.of(context).pop();
                },
              ),
              onTap: () {
                _setAssignmentFilter(null);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(localizations.myTasks),
              leading: Radio<String?>(
                value: 'me',
                groupValue: _selectedAssignment,
                onChanged: (value) {
                  _setAssignmentFilter(value);
                  Navigator.of(context).pop();
                },
              ),
              onTap: () {
                _setAssignmentFilter('me');
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(localizations.unassignedTasks),
              leading: Radio<String?>(
                value: 'unassigned',
                groupValue: _selectedAssignment,
                onChanged: (value) {
                  _setAssignmentFilter(value);
                  Navigator.of(context).pop();
                },
              ),
              onTap: () {
                _setAssignmentFilter('unassigned');
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              localizations.noTasksMatchFilters,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              localizations.tryAdjustingFilters,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all),
              label: Text(localizations.clearFilters),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_outlined,
              size: 100,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context).noTasksYet,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).createYourFirstTaskToGetStarted,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.createTask);
              },
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context).createTask),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.error),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context).errorLoadingTasks,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                _loadTasks();
              },
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTeamDisplay(String teamId) {
    final teamState = context.read<TeamBloc>().state;
    try {
      final team = teamState.teams.firstWhere((t) => t.id == teamId);
      return team.teamName;
    } catch (_) {
      return teamId;
    }
  }

  Widget _buildTaskList(List<TaskModel> tasks) {
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticated ? authState.user.id : '';
    final userRole = authState is AuthAuthenticated
        ? authState.user.userRole
        : UserRole.teamMember;
    final canComplete = userRole == UserRole.admin ||
        userRole == UserRole.teamLeader ||
        (userRole == UserRole.teamMember);
    final canReassign =
        userRole == UserRole.admin || userRole == UserRole.teamLeader;
    final loc = AppLocalizations.of(context);

    // Group by status: Overdue first (if dueDate exists), then Pending, In Progress, Completed
    final now = DateTime.now();
    final overdueIds = tasks
        .where((t) =>
            t.dueDate != null &&
            t.dueDate!.isBefore(now) &&
            t.status != TaskStatus.completed)
        .map((t) => t.id)
        .toSet();
    final overdue = tasks.where((t) => overdueIds.contains(t.id)).toList();
    final pending = tasks
        .where((t) =>
            t.status == TaskStatus.pending && !overdueIds.contains(t.id))
        .toList();
    final inProgress = tasks
        .where((t) =>
            t.status == TaskStatus.inProgress && !overdueIds.contains(t.id))
        .toList();
    final completed =
        tasks.where((t) => t.status == TaskStatus.completed).toList();

    final sections = <MapEntry<String, List<TaskModel>>>[];
    if (overdue.isNotEmpty) {
      sections.add(MapEntry(loc.overdue, overdue));
    }
    if (pending.isNotEmpty) {
      sections.add(MapEntry(loc.pending, pending));
    }
    if (inProgress.isNotEmpty) {
      sections.add(MapEntry(loc.inProgress, inProgress));
    }
    if (completed.isNotEmpty) {
      sections.add(MapEntry(loc.completed, completed));
    }
    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sections.fold<int>(
          0, (sum, s) => sum + 1 + s.value.length), // header + cards per section
      itemBuilder: (context, index) {
        int offset = 0;
        for (final section in sections) {
          if (index == offset) {
            return _buildSectionHeader(
                section.key, section.value.length,
                section.key == loc.overdue);
          }
          offset++;
          for (final task in section.value) {
            if (index == offset) {
              return EnhancedTaskCard(
                task: task,
                assigneeDisplay: _getAssignmentDisplay(task.assignedTo),
                teamDisplay: _getTeamDisplay(task.teamId),
                onTap: () => _openTaskDetail(task, currentUserId),
                onComplete: canComplete && task.status != TaskStatus.completed
                    ? () => _completeTask(task, currentUserId, userRole)
                    : null,
                onShowOptions: () => _showTaskOptionsSheet(
                    context, task, currentUserId, canComplete, canReassign),
                onQuickAssign: canReassign
                    ? () => _openTaskDetail(task, currentUserId)
                    : null,
                canComplete: canComplete,
                canReassign: canReassign,
              );
            }
            offset++;
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSectionHeader(String title, int count, bool isOverdue) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        children: [
          Text(
            '$title ($count)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isOverdue ? AppColors.error : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _openTaskDetail(TaskModel task, String currentUserId) async {
    final result = await Navigator.of(context).pushNamed(
      AppRouter.taskDetail,
      arguments: {'task': task, 'currentUserId': currentUserId},
    );
    if (result == true && mounted) {
      _loadTasks();
    }
  }

  void _completeTask(TaskModel task, String currentUserId, UserRole userRole) {
    context.read<TaskBloc>().add(StatusChangeRequested(
          taskId: task.id,
          newStatus: TaskStatus.completed,
          userId: currentUserId,
          userRole: userRole.value,
        ));
    _loadTasks();
  }

  void _showTaskOptionsSheet(BuildContext context, TaskModel task,
      String currentUserId, bool canComplete, bool canReassign) {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_new),
              title: Text(loc.taskDetails),
              onTap: () {
                Navigator.pop(ctx);
                _openTaskDetail(task, currentUserId);
              },
            ),
            if (canComplete && task.status != TaskStatus.completed)
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: Text(loc.markAsCompleted),
                onTap: () {
                  Navigator.pop(ctx);
                  final authState = context.read<AuthBloc>().state;
                  final role = authState is AuthAuthenticated
                      ? authState.user.userRole
                      : UserRole.teamMember;
                  _completeTask(task, currentUserId, role);
                  _loadTasks();
                },
              ),
          ],
        ),
      ),
    );
  }

}
