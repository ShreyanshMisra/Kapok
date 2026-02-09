import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/mapbox_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/geocode_service.dart';
import '../../../core/enums/task_priority.dart';
import '../../../core/enums/user_role.dart';
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
import '../../map/mobile/mapbox_mobile_controller.dart';
import '../../map/web/mapbox_web_controller_stub.dart'
    if (dart.library.html) '../../map/web/mapbox_web_controller.dart';
import '../../../core/widgets/kapok_logo.dart';
import '../../../core/widgets/priority_stars.dart';
import '../../../core/enums/task_category.dart';

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
  TaskCategory _selectedCategory = TaskCategory.other;
  bool _isLoadingLocation = false;
  bool _initialLocationLoaded = false; // Track if initial location fetch completed
  double? _latitude;
  double? _longitude;
  String? _selectedAddress;
  MapboxWebController? _mapController;
  MapboxMobileController? _mobileMapController;
  MapCameraState? _currentCamera;
  bool _showTaskForm = false;
  String? _selectedTeamId;
  String? _selectedAssignedTo;
  List<TeamModel> _userTeams = [];
  List<UserModel> _teamMembers = [];
  
  // Initial map center (set once when location is determined)
  late double _initialMapLatitude;
  late double _initialMapLongitude;

  @override
  void initState() {
    super.initState();
    // Initialize with fallback location first
    _initialMapLatitude = MapboxConstants.defaultLatitude;
    _initialMapLongitude = MapboxConstants.defaultLongitude;
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
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _useDefaultLocation('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _useDefaultLocation('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _useDefaultLocation('Location permission denied permanently');
        return;
      }

      // Get current position with timeout
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Validate coordinates
      if (position.latitude < -90 || position.latitude > 90 ||
          position.longitude < -180 || position.longitude > 180) {
        _useDefaultLocation('Invalid coordinates received');
        return;
      }

      if (mounted) {
        setState(() {
          _initialMapLatitude = position.latitude;
          _initialMapLongitude = position.longitude;
          _currentCamera = MapCameraState(
            latitude: position.latitude,
            longitude: position.longitude,
            zoom: 16.0,
          );
          _initialLocationLoaded = true;
          _isLoadingLocation = false;
        });
      }

      // Center map on current location if controller is ready
      _centerMapOnLocation(position.latitude, position.longitude);

      // Reverse geocode to get address (non-blocking)
      _reverseGeocodeLocation(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error getting location: $e');
      _useDefaultLocation('Could not get current location');
    }
  }

  /// Use default fallback location when current location is unavailable
  void _useDefaultLocation(String reason) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$reason. Using default location.'),
          duration: const Duration(seconds: 3),
        ),
      );
      setState(() {
        _initialMapLatitude = MapboxConstants.defaultLatitude;
        _initialMapLongitude = MapboxConstants.defaultLongitude;
        _currentCamera = MapCameraState(
          latitude: MapboxConstants.defaultLatitude,
          longitude: MapboxConstants.defaultLongitude,
          zoom: MapboxConstants.defaultZoom,
        );
        _initialLocationLoaded = true;
        _isLoadingLocation = false;
      });
    }
  }

  /// Center map on specified location
  void _centerMapOnLocation(double latitude, double longitude) {
    if (_mapController != null) {
      _mapController!.setCenter(latitude, longitude, zoom: 16.0);
    }
    if (_mobileMapController != null) {
      _mobileMapController!.setCenter(latitude, longitude, zoom: 16.0);
    }
  }

  /// Reverse geocode location to get address (non-blocking)
  Future<void> _reverseGeocodeLocation(double latitude, double longitude) async {
    try {
      final address = await GeocodeService.instance.reverseGeocode(
        latitude,
        longitude,
      );
      if (mounted) {
        setState(() {
          _selectedAddress = address;
          _addressController.text = address;
        });
      }
    } catch (e) {
      // Geocoding failed, that's okay - user can still select location
      debugPrint('Reverse geocoding failed: $e');
    }
  }

  /// Handle tap on map to set location
  Future<void> _handleMapTap(double latitude, double longitude) async {
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
    // Use the stored initial map coordinates (set once at location load)
    final initialLat = _initialMapLatitude;
    final initialLon = _initialMapLongitude;
    final initialZoom = _currentCamera?.zoom ?? 16.0;

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(AppLocalizations.of(context).createTask),
        centerTitle: true,
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
          const KapokLogo(),
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
                backgroundColor: AppColors.primary,
              ),
            );
          } else if (state is TaskCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Task "${state.task.title}" created successfully',
                ),
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.of(context).pop();
          }
        },
        child: Stack(
          children: [
            // Map view - full screen using Positioned.fill
            // Show loading indicator while fetching initial location
            if (!_initialLocationLoaded)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0xFFE8F4F8),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Fetching current location...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
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
                  onMobileControllerReady: (controller) {
                    setState(() {
                      _mobileMapController = controller;
                    });
                  },
                  onTap: _handleMapTap,
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
                  color: theme.cardColor.withValues(alpha: 0.95),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Tap on the map to select a location for your task',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: theme.colorScheme.onSurface),
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
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
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
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
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
                                          color: theme.colorScheme.primary,
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
                                          color: theme.colorScheme.primary,
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
                                          color: theme.colorScheme.primary,
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
                                                color: theme.colorScheme.primary,
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
                                          backgroundColor: theme.colorScheme.primary,
                                          foregroundColor: theme.colorScheme.onPrimary,
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
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                                              color: theme.colorScheme.primary,
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
                                        _teamMembers = List.of(teamState.members)
                                          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                                      }

                                      if (_selectedTeamId == null) {
                                        return Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: theme.colorScheme.outline
                                                  .withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                size: 16,
                                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Select a team first to assign task',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      // Filter members based on role
                                      final currentAuthState = context.read<AuthBloc>().state;
                                      final isTeamMember = currentAuthState is AuthAuthenticated &&
                                          currentAuthState.user.userRole == UserRole.teamMember;
                                      final currentUserId = currentAuthState is AuthAuthenticated
                                          ? currentAuthState.user.id
                                          : '';
                                      final filteredMembers = isTeamMember
                                          ? _teamMembers.where((m) => m.id == currentUserId).toList()
                                          : _teamMembers;

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
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                        items: [
                                          const DropdownMenuItem<String>(
                                            value: null,
                                            child: Text('Unassigned'),
                                          ),
                                          ...filteredMembers.map((
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
                                                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      member.role,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: theme.colorScheme.primary,
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

                                  // Category selector
                                  DropdownButtonFormField<TaskCategory>(
                                    value: _selectedCategory,
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(
                                        context,
                                      ).taskCategory,
                                      prefixIcon: const Icon(
                                        Icons.category_outlined,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    items: TaskCategory.values.map((
                                      TaskCategory category,
                                    ) {
                                      return DropdownMenuItem<TaskCategory>(
                                        value: category,
                                        child: Text(category.displayName),
                                      );
                                    }).toList(),
                                    onChanged: (TaskCategory? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _selectedCategory = newValue;
                                        });
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return AppLocalizations.of(context).taskCategory;
                                      }
                                      return null;
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
                                          color: theme.colorScheme.primary,
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
                                            PriorityStars(priority: priority, size: 14),
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
                                          backgroundColor: theme.colorScheme.primary,
                                          foregroundColor: theme.colorScheme.onPrimary,
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

  // Priority color replaced by PriorityStars widget

  Future<void> _handleCreateTask() async {
    if (_formKey.currentState!.validate()) {
      // Validate location
      if (_latitude == null || _longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select a location on the map or enter an address',
            ),
            backgroundColor: AppColors.primary,
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
            backgroundColor: AppColors.primary,
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
            backgroundColor: AppColors.primary,
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
          category: _selectedCategory.value,
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
