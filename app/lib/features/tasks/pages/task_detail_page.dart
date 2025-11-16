import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        title: Text(AppLocalizations.of(context).taskDetails),
        elevation: 0,
      ),
      body: Center(
        child: Text(AppLocalizations.of(context).taskDetailPageToBeImplemented),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
