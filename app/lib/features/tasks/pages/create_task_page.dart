import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/validators.dart';
import '../../../app/router.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';

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
  final _assignedToController = TextEditingController();
  int _selectedPriority = 3; // Default to Medium (3)
  bool _taskCompleted = false;
  bool _isLoadingLocation = false;
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _assignedToController.dispose();
    super.dispose();
  }

  /// Get priority label
  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 1:
        return 'Lowest';
      case 2:
        return 'Low';
      case 3:
        return 'Medium';
      case 4:
        return 'High';
      case 5:
        return 'Critical';
      default:
        return 'Medium';
    }
  }

  /// Get priority color
  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return const Color(0xFF4CAF50); // Green
      case 2:
        return const Color(0xFF8BC34A); // Light Green
      case 3:
        return const Color(0xFFFFC107); // Amber
      case 4:
        return const Color(0xFFFF9800); // Orange
      case 5:
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFFFFC107);
    }
  }

  /// Get current location
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
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final address = [
            placemark.street,
            placemark.locality,
            placemark.administrativeArea,
            placemark.postalCode,
            placemark.country,
          ].where((e) => e != null && e.isNotEmpty).join(', ');

          _addressController.text = address;
        }
      } catch (e) {
        // Reverse geocoding failed, that's okay
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Current location set')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  /// Validate and geocode address
  Future<bool> _validateAndGeocodeAddress() async {
    final address = _addressController.text.trim();

    if (address.isEmpty) {
      // No address provided, use default coordinates
      setState(() {
        _latitude = 0.0;
        _longitude = 0.0;
      });
      return true;
    }

    try {
      final locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        setState(() {
          _latitude = locations.first.latitude;
          _longitude = locations.first.longitude;
        });
        return true;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not find this address')),
          );
        }
        return false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid address: $e')),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: Text(AppLocalizations.of(context).createTask),
        elevation: 0,
      ),
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is TaskCreated) {
            final localizations = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.taskCreatedSuccessfully.replaceAll('{taskName}', state.task.taskName)),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.add_task,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                
                Text(
                  AppLocalizations.of(context).createNewTask,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                Text(
                  AppLocalizations.of(context).createANewTaskOrLog,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).taskTitle,
                    hintText: AppLocalizations.of(context).enterTaskTitle,
                    prefixIcon: const Icon(Icons.title_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).taskDescription,
                    hintText: AppLocalizations.of(context).enterTaskDescription,
                    prefixIcon: const Icon(Icons.description_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context).pleaseEnterADescription;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).location,
                          hintText: AppLocalizations.of(context).enterTaskLocationOrLeaveEmptyForCurrentLocation,
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: _isLoadingLocation
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                      onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                      tooltip: 'Use current location',
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

                // Priority selector - 5 levels
                DropdownButtonFormField<int>(
                  value: _selectedPriority,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).priority,
                    prefixIcon: const Icon(Icons.priority_high_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  items: [1, 2, 3, 4, 5].map((int priority) {
                    return DropdownMenuItem<int>(
                      value: priority,
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 12,
                            color: _getPriorityColor(priority),
                          ),
                          const SizedBox(width: 8),
                          Text(_getPriorityLabel(priority)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedPriority = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _assignedToController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).assignedToOptional,
                    hintText: AppLocalizations.of(context).enterUserEmailOrId,
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                CheckboxListTile(
                  value: _taskCompleted,
                  onChanged: (bool? value) {
                    setState(() {
                      _taskCompleted = value ?? false;
                    });
                  },
                  title: Text(AppLocalizations.of(context).markAsCompleted),
                  subtitle: Text(AppLocalizations.of(context).checkIfThisTaskIsAlreadyCompleted),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                  ),
                  tileColor: AppColors.surface,
                ),
                const SizedBox(height: 24),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.info,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context).taskInformation,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.info,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).taskInformationDescription,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is TaskLoading
                          ? null
                          : _handleCreateTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state is TaskLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context).createTask,
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
    );
  }

  Future<void> _handleCreateTask() async {
    if (_formKey.currentState!.validate()) {
      // Validate and geocode address if provided
      if (_addressController.text.trim().isNotEmpty) {
        final isValid = await _validateAndGeocodeAddress();
        if (!isValid) {
          return;
        }
      } else {
        // No address provided, use default coordinates
        setState(() {
          _latitude = 0.0;
          _longitude = 0.0;
        });
      }

      final authState = context.read<AuthBloc>().state;

      if (authState is! AuthAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).youMustBeLoggedInToCreateTasks),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
        return;
      }

      final user = authState.user;
      final teamId = user.teamId ?? 'default_team';
      final teamName = 'Default Team';
      final assignedTo = _assignedToController.text.trim().isEmpty
          ? user.id
          : _assignedToController.text.trim();

      context.read<TaskBloc>().add(
        CreateTaskRequested(
          taskName: _titleController.text.trim(),
          taskSeverity: _selectedPriority,
          taskDescription: _descriptionController.text.trim(),
          taskCompleted: _taskCompleted,
          assignedTo: assignedTo,
          teamName: teamName,
          teamId: teamId,
          latitude: _latitude ?? 0.0,
          longitude: _longitude ?? 0.0,
          createdBy: user.id,
        ),
      );
    }
  }
}
