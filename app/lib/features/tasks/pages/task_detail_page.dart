import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/task_model.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';

/// Task detail page with editing functionality
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
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late int _selectedPriority;
  late bool _isCompleted;
  bool _isEditing = false;
  bool _isLoadingLocation = false;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task.taskName);
    _descriptionController = TextEditingController(text: widget.task.taskDescription);
    _addressController = TextEditingController(text: widget.task.address ?? '');
    _selectedPriority = widget.task.taskSeverity;
    _isCompleted = widget.task.taskCompleted;
    _latitude = widget.task.latitude != 0.0 ? widget.task.latitude : null;
    _longitude = widget.task.longitude != 0.0 ? widget.task.longitude : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Check if user can edit this task
  bool get canEdit {
    return widget.task.createdBy == widget.currentUserId ||
        widget.task.assignedTo == widget.currentUserId;
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
      // Check permissions
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

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // Try to get address from coordinates
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
      // No address provided, that's okay
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

  /// Save changes
  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task name cannot be empty')),
      );
      return;
    }

    // Validate address if provided
    if (_addressController.text.trim().isNotEmpty) {
      final isValid = await _validateAndGeocodeAddress();
      if (!isValid) {
        return;
      }
    }

    // Dispatch edit event
    context.read<TaskBloc>().add(
          EditTaskRequested(
            taskId: widget.task.id,
            userId: widget.currentUserId,
            taskName: _nameController.text.trim(),
            taskSeverity: _selectedPriority,
            taskDescription: _descriptionController.text.trim(),
            taskCompleted: _isCompleted,
          ),
        );

    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task updated successfully')),
          );
          // Pop with true to indicate task was updated
          Navigator.of(context).pop(true);
        } else if (state is TaskError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          title: Text(_isEditing ? 'Edit Task' : 'Task Details'),
          elevation: 0,
          actions: [
            if (canEdit && !_isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _saveChanges,
              ),
          ],
        ),
        body: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task Name
                  _buildSection(
                    title: 'Task Name',
                    child: _isEditing
                        ? TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              hintText: 'Enter task name',
                              border: OutlineInputBorder(),
                            ),
                          )
                        : Text(
                            widget.task.taskName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Priority
                  _buildSection(
                    title: 'Priority',
                    child: _isEditing
                        ? _buildPrioritySelector()
                        : _buildPriorityBadge(_selectedPriority),
                  ),
                  const SizedBox(height: 16),

                  // Status
                  _buildSection(
                    title: 'Status',
                    child: _isEditing
                        ? SwitchListTile(
                            title: const Text('Completed'),
                            value: _isCompleted,
                            onChanged: (value) {
                              setState(() {
                                _isCompleted = value;
                              });
                            },
                          )
                        : Chip(
                            label: Text(
                              widget.task.taskCompleted ? 'Completed' : 'Pending',
                            ),
                            backgroundColor: widget.task.taskCompleted
                                ? Colors.green
                                : Colors.orange,
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  _buildSection(
                    title: 'Description',
                    child: _isEditing
                        ? TextField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              hintText: 'Enter task description',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 4,
                          )
                        : Text(widget.task.taskDescription),
                  ),
                  const SizedBox(height: 16),

                  // Location/Address
                  _buildSection(
                    title: 'Location',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isEditing) ...[
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _addressController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter address',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: _isLoadingLocation
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.my_location),
                                onPressed: _isLoadingLocation
                                    ? null
                                    : _getCurrentLocation,
                                tooltip: 'Use current location',
                              ),
                            ],
                          ),
                        ] else ...[
                          if (widget.task.address != null &&
                              widget.task.address!.isNotEmpty)
                            Text(widget.task.address!)
                          else
                            const Text('No address provided'),
                        ],
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Team Info
                  _buildSection(
                    title: 'Team',
                    child: Text(widget.task.teamName),
                  ),
                  const SizedBox(height: 16),

                  // Assignment Info
                  _buildSection(
                    title: 'Assigned To',
                    child: Text(widget.task.assignedTo),
                  ),
                  const SizedBox(height: 16),

                  // Created By
                  _buildSection(
                    title: 'Created By',
                    child: Text(widget.task.createdBy),
                  ),
                  const SizedBox(height: 16),

                  // Timestamps
                  _buildSection(
                    title: 'Created',
                    child: Text(_formatDateTime(widget.task.createdAt)),
                  ),
                  const SizedBox(height: 8),
                  _buildSection(
                    title: 'Last Updated',
                    child: Text(_formatDateTime(widget.task.updatedAt)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      children: List.generate(5, (index) {
        final priority = index + 1;
        return RadioListTile<int>(
          title: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getPriorityColor(priority),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(_getPriorityLabel(priority)),
            ],
          ),
          value: priority,
          groupValue: _selectedPriority,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPriority = value;
              });
            }
          },
        );
      }),
    );
  }

  Widget _buildPriorityBadge(int priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getPriorityColor(priority),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getPriorityColor(priority),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _getPriorityLabel(priority),
            style: TextStyle(
              color: _getPriorityColor(priority),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
