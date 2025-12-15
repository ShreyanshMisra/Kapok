import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/geocode_service.dart';
import '../../../core/enums/task_priority.dart';
import '../../../data/models/team_model.dart';
import '../../../data/models/user_model.dart';
import '../../../app/router.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../teams/bloc/team_bloc.dart';
import '../../teams/bloc/team_event.dart';
import '../../teams/bloc/team_state.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../../map/widgets/mapbox_map_view.dart';
import '../../map/models/map_camera_state.dart';
import '../../map/web/mapbox_web_controller_stub.dart'
    if (dart.library.html) '../../map/web/mapbox_web_controller.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  TaskPriority _selectedPriority = TaskPriority.medium;
  bool _isLoadingLocation = false;
  double? _latitude;
  double? _longitude;
  String? _selectedAddress;
  MapboxWebController? _mapController;
  MapCameraState? _currentCamera;
  bool _showTaskForm = false;
  String? _selectedTeamId;
  String? _selectedAssignedTo;
  List<TeamModel> _userTeams = [];
  List<UserModel> _teamMembers = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadUserTeams();
  }

  /// Load user's teams
  Future<void> _loadUserTeams() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TeamBloc>().add(LoadUserTeams(userId: authState.user.id));
    }
  }

  /// Load team members when team is selected
  Future<void> _loadTeamMembers(String teamId) async {
    context.read<TeamBloc>().add(LoadTeamMembers(teamId: teamId));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Get current location and center map
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          // Use default location if permission denied
          _latitude = 0.0;
          _longitude = 0.0;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied permanently'),
            ),
          );
        }
        // Use default location
        _latitude = 0.0;
        _longitude = 0.0;
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _currentCamera = MapCameraState(
          latitude: position.latitude,
          longitude: position.longitude,
          zoom: 16.0,
        );
      });

      // Center map on current location
      if (_mapController != null) {
        _mapController!.setCenter(
          position.latitude,
          position.longitude,
          zoom: 16.0,
        );
      }

      // Reverse geocode to get address
      try {
        final address = await GeocodeService.instance.reverseGeocode(
          position.latitude,
          position.longitude,
        );
        setState(() {
          _selectedAddress = address;
          _addressController.text = address;
        });
      } catch (e) {
        // Geocoding failed, that's okay
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
      }
      // Use default location
      _latitude = 0.0;
      _longitude = 0.0;
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  /// Handle double-click on map to set location
  Future<void> _handleMapDoubleClick(double latitude, double longitude) async {
    setState(() {
      _latitude = latitude;
      _longitude = longitude;
      _isLoadingLocation = true;
    });

    // Reverse geocode to get address
    try {
      final address = await GeocodeService.instance.reverseGeocode(
        latitude,
        longitude,
      );
      setState(() {
        _selectedAddress = address;
        _addressController.text = address;
      });
    } catch (e) {
      // Geocoding failed, use coordinates
      setState(() {
        _selectedAddress =
            '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
        _addressController.text = _selectedAddress!;
      });
    } finally {
      setState(() {
        _isLoadingLocation = false;
        _showTaskForm = true;
      });
    }

    // Show snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location set: ${_selectedAddress ?? '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}'}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Validate and geocode address manually entered
  Future<bool> _validateAndGeocodeAddress() async {
    final address = _addressController.text.trim();

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter an address or select a location on the map',
          ),
        ),
      );
      return false;
    }

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final location = await GeocodeService.instance.forwardGeocode(address);

      setState(() {
        _latitude = location.latitude;
        _longitude = location.longitude;
        _selectedAddress = address;
      });

      // Center map on geocoded location
      if (_mapController != null) {
        _mapController!.setCenter(
          location.latitude,
          location.longitude,
          zoom: 16.0,
        );
      }

      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not find this address: $e')),
        );
      }
      return false;
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialLat = _latitude ?? 0.0;
    final initialLon = _longitude ?? 0.0;
    final initialZoom = _currentCamera?.zoom ?? 16.0;

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(AppLocalizations.of(context).createTask),
        elevation: 0,
        actions: [
          if (_isLoadingLocation)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: BlocListener<TaskBloc, TaskState>(
        listenWhen: (previous, current) {
          // Only listen to TaskCreated or TaskError states
          return current is TaskCreated || current is TaskError;
        },
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is TaskCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Task "${state.task.title}" created successfully',
                ),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          children: [
            // Map view - full screen using Positioned.fill
            Positioned.fill(
              child: MapboxMapView(
                initialLatitude: initialLat,
                initialLongitude: initialLon,
                initialZoom: initialZoom,
                interactive: true,
                onControllerReady: (controller) {
                  setState(() {
                    _mapController = controller;
                  });
                },
                onDoubleClick: _handleMapDoubleClick,
                onCameraIdle: (camera) {
                  setState(() {
                    _currentCamera = camera;
                  });
                },
              ),
            ),

            // Instructions overlay
            if (!_showTaskForm)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Card(
                  elevation: 4,
                  color: AppColors.surface.withOpacity(0.95),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Double-click on the map to select a location for your task',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Task form bottom sheet
            if (_showTaskForm || _latitude != null)
              DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.3,
                maxChildSize: 0.9,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Drag handle
                        Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // Form content
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    AppLocalizations.of(context).createNewTask,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Title field
                                  TextFormField(
                                    controller: _titleController,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(
                                        context,
                                      ).taskTitle,
                                      hintText: 'Enter task title',
                                      prefixIcon: const Icon(
                                        Icons.title_outlined,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter a task title';
                                      }
                                      if (value.length > 100) {
                                        return 'Title must be 100 characters or less';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Description field
                                  TextFormField(
                                    controller: _descriptionController,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(
                                        context,
                                      ).taskDescription,
                                      hintText:
                                          'Enter task description (optional)',
                                      prefixIcon: const Icon(
                                        Icons.description_outlined,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value != null && value.length > 500) {
                                        return 'Description must be 500 characters or less';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Location field with manual entry option
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _addressController,
                                          decoration: InputDecoration(
                                            labelText: 'Location',
                                            hintText: 'Address or coordinates',
                                            prefixIcon: const Icon(
                                              Icons.location_on_outlined,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                          onFieldSubmitted: (_) =>
                                              _validateAndGeocodeAddress(),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.search),
                                        onPressed: _validateAndGeocodeAddress,
                                        tooltip: 'Search address',
                                        style: IconButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: AppColors.surface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_latitude != null && _longitude != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Coordinates: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 16),

                                  // Team selector (required)
                                  BlocBuilder<TeamBloc, TeamState>(
                                    builder: (context, teamState) {
                                      if (teamState is TeamLoaded) {
                                        _userTeams = teamState.teams;
                                        if (_selectedTeamId == null &&
                                            _userTeams.isNotEmpty) {
                                          // Auto-select first team if none selected
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                                setState(() {
                                                  _selectedTeamId =
                                                      _userTeams.first.id;
                                                });
                                                _loadTeamMembers(
                                                  _userTeams.first.id,
                                                );
                                              });
                                        }
                                      }

                                      return DropdownButtonFormField<String>(
                                        value: _selectedTeamId,
                                        decoration: InputDecoration(
                                          labelText: 'Team *',
                                          hintText: 'Select a team',
                                          prefixIcon: const Icon(Icons.group),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        items: _userTeams.map((TeamModel team) {
                                          return DropdownMenuItem<String>(
                                            value: team.id,
                                            child: Text(team.teamName),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              _selectedTeamId = newValue;
                                              _selectedAssignedTo =
                                                  null; // Reset assignment when team changes
                                              _teamMembers =
                                                  []; // Clear members list
                                            });
                                            _loadTeamMembers(newValue);
                                          }
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please select a team';
                                          }
                                          return null;
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Assigned to dropdown (filtered by selected team)
                                  BlocBuilder<TeamBloc, TeamState>(
                                    builder: (context, teamState) {
                                      if (teamState is TeamMembersLoaded &&
                                          _selectedTeamId != null) {
                                        _teamMembers = teamState.members;
                                      }

                                      if (_selectedTeamId == null) {
                                        return Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: AppColors.textSecondary
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                size: 16,
                                                color: AppColors.textSecondary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Select a team first to assign task',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return DropdownButtonFormField<String>(
                                        value: _selectedAssignedTo,
                                        decoration: InputDecoration(
                                          labelText: 'Assign To (Optional)',
                                          hintText: 'Select a team member',
                                          prefixIcon: const Icon(
                                            Icons.person_outline,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        items: [
                                          const DropdownMenuItem<String>(
                                            value: null,
                                            child: Text('Unassigned'),
                                          ),
                                          ..._teamMembers.map((
                                            UserModel member,
                                          ) {
                                            return DropdownMenuItem<String>(
                                              value: member.id,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      member.name,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      member.role,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors.primary,
                                                      ),
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
                                  const SizedBox(height: 16),

                                  // Priority selector
                                  DropdownButtonFormField<TaskPriority>(
                                    value: _selectedPriority,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(
                                        context,
                                      ).priority,
                                      prefixIcon: const Icon(
                                        Icons.priority_high_outlined,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    items: TaskPriority.values.map((
                                      TaskPriority priority,
                                    ) {
                                      return DropdownMenuItem<TaskPriority>(
                                        value: priority,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              size: 12,
                                              color: _getPriorityColor(
                                                priority,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(priority.displayName),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (TaskPriority? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _selectedPriority = newValue;
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Create button
                                  BlocBuilder<TaskBloc, TaskState>(
                                    builder: (context, state) {
                                      return ElevatedButton(
                                        onPressed: state is TaskLoading
                                            ? null
                                            : _handleCreateTask,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: AppColors.surface,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: state is TaskLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                            : Text(
                                                AppLocalizations.of(
                                                  context,
                                                ).createTask,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return const Color(0xFF4CAF50); // Green
      case TaskPriority.medium:
        return const Color(0xFFFFC107); // Amber
      case TaskPriority.high:
        return const Color(0xFFF44336); // Red
    }
  }

  Future<void> _handleCreateTask() async {
    if (_formKey.currentState!.validate()) {
      // Validate location
      if (_latitude == null || _longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select a location on the map or enter an address',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final authState = context.read<AuthBloc>().state;

      if (authState is! AuthAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).youMustBeLoggedInToCreateTasks,
            ),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
        return;
      }

      final user = authState.user;

      if (_selectedTeamId == null || _selectedTeamId!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a team'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final assignedTo = _selectedAssignedTo;

      // Convert priority to severity (for backward compatibility with event)
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

      // Get team name for backward compatibility
      final selectedTeam = _userTeams.firstWhere(
        (team) => team.id == _selectedTeamId,
        orElse: () => _userTeams.first,
      );

      context.read<TaskBloc>().add(
        CreateTaskRequested(
          taskName: _titleController.text.trim(),
          taskSeverity: severity,
          taskDescription: _descriptionController.text.trim(),
          taskCompleted: false,
          assignedTo: assignedTo ?? '',
          teamName: selectedTeam.teamName,
          teamId: _selectedTeamId!,
          latitude: _latitude!,
          longitude: _longitude!,
          createdBy: user.id,
        ),
      );

      // Clear form and close bottom sheet after task creation
      _titleController.clear();
      _descriptionController.clear();
      _addressController.clear();
      setState(() {
        _latitude = null;
        _longitude = null;
        _selectedAddress = null;
        _showTaskForm = false;
      });
    }
  }
}
