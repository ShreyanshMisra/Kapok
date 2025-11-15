# Create Task Page Fixes and Enhancements

## Issues Fixed

### Issue #1: Missing Features in Create Task Page
**Problem:** The create task page had 3 priority levels (Low, Medium, High) and no location features, while the edit task page had 5 priority levels and location features with address validation and current location button.

**Impact:** Inconsistent user experience between creating and editing tasks.

### Issue #2: Task List Not Refreshing After Edit
**Problem:** After editing a task and returning to the tasks list, the page showed "No tasks yet" until manually refreshed.

**Impact:** Users couldn't see their updated tasks without manually refreshing.

### Issue #3: Required Location Field Preventing Task Creation
**Problem:** The create task page validator required a location to be entered, contradicting the hint text "leave empty for current location."

**Impact:** Users couldn't create tasks without entering a location, even though the hint suggested it was optional.

---

## Fixes Applied

### Fix #1: Upgrade Create Task Page to Match Edit Task Page

#### 1.1 Five Priority Levels

**Location:** [app/lib/features/tasks/pages/create_task_page.dart:27](app/lib/features/tasks/pages/create_task_page.dart#L27), [app/lib/features/tasks/pages/create_task_page.dart:354-393](app/lib/features/tasks/pages/create_task_page.dart#L354-L393)

**Changes:**

**Before:**
```dart
String _selectedPriority = 'Medium';
final List<String> _priorities = ['Low', 'Medium', 'High'];

DropdownButtonFormField<String>(
  initialValue: _selectedPriority,
  items: _priorities.map((String priority) {
    return DropdownMenuItem<String>(
      value: priority,
      child: Row(
        children: [
          Icon(Icons.circle, size: 12, color: _getPriorityColor(priority)),
          const SizedBox(width: 8),
          Text(priority),
        ],
      ),
    );
  }).toList(),
  // ...
)
```

**After:**
```dart
int _selectedPriority = 3; // Default to Medium (3)

DropdownButtonFormField<int>(
  value: _selectedPriority,
  items: [1, 2, 3, 4, 5].map((int priority) {
    return DropdownMenuItem<int>(
      value: priority,
      child: Row(
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
    );
  }).toList(),
  onChanged: (int? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedPriority = newValue;
      });
    }
  },
)
```

**Priority Levels:**
| Level | Label | Color | Use Case |
|-------|-------|-------|----------|
| 1 | Lowest | Green | Low-priority maintenance |
| 2 | Low | Light Green | Routine tasks |
| 3 | Medium | Amber | Standard operations |
| 4 | High | Orange | Urgent tasks |
| 5 | Critical | Red | Emergency situations |

#### 1.2 Address Field with Current Location Button

**Location:** [app/lib/features/tasks/pages/create_task_page.dart:302-350](app/lib/features/tasks/pages/create_task_page.dart#L302-L350)

**Changes:**

**Before:**
```dart
TextFormField(
  controller: _locationController,
  decoration: InputDecoration(
    labelText: 'Location',
    hintText: 'Enter task location or leave empty for current location',
    prefixIcon: const Icon(Icons.location_on_outlined),
  ),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a location'; // ❌ Required field
    }
    return null;
  },
)
```

**After:**
```dart
Row(
  children: [
    Expanded(
      child: TextFormField(
        controller: _addressController,
        decoration: InputDecoration(
          labelText: 'Address (Optional)', // ✅ Clearly optional
          hintText: 'Enter address or use current location',
          prefixIcon: const Icon(Icons.location_on_outlined),
        ),
        // ✅ No validator - field is optional
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
          : const Icon(Icons.my_location), // ✅ Pin icon
      onPressed: _isLoadingLocation ? null : _getCurrentLocation,
      tooltip: 'Use current location',
      style: IconButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
      ),
    ),
  ],
),
// Show coordinates when available
if (_latitude != null && _longitude != null)
  Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      'Coordinates: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
    ),
  ),
```

#### 1.3 Address Validation and Geocoding

**Location:** [app/lib/features/tasks/pages/create_task_page.dart:158-196](app/lib/features/tasks/pages/create_task_page.dart#L158-L196)

**Added Methods:**

```dart
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
    // Use geocoding package to validate address
    final locations = await locationFromAddress(address);

    if (locations.isNotEmpty) {
      // Address is valid, update coordinates
      setState(() {
        _latitude = locations.first.latitude;
        _longitude = locations.first.longitude;
      });
      return true;
    } else {
      // Address not found
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not find this address')),
        );
      }
      return false;
    }
  } catch (e) {
    // Geocoding error
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid address: $e')),
      );
    }
    return false;
  }
}
```

**Features:**
- ✅ Validates address using geocoding API
- ✅ Converts valid addresses to coordinates
- ✅ Allows empty address (uses 0.0, 0.0 as default)
- ✅ Shows user-friendly error messages
- ✅ Prevents task creation if address is invalid

#### 1.4 Current Location Feature

**Location:** [app/lib/features/tasks/pages/create_task_page.dart:78-156](app/lib/features/tasks/pages/create_task_page.dart#L78-L156)

**Added Method:**

```dart
/// Get current location
Future<void> _getCurrentLocation() async {
  setState(() {
    _isLoadingLocation = true;
  });

  try {
    // Check and request location permissions
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

    // Get current GPS position
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });

    // Reverse geocode to get address
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
      // Coordinates are still saved
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
```

**Features:**
- ✅ Requests location permission if needed
- ✅ Gets high-accuracy GPS coordinates
- ✅ Reverse geocodes to get human-readable address
- ✅ Shows loading indicator while fetching
- ✅ Handles permission denials gracefully
- ✅ Updates both address field and coordinates

#### 1.5 Updated Task Creation Logic

**Location:** [app/lib/features/tasks/pages/create_task_page.dart:516-569](app/lib/features/tasks/pages/create_task_page.dart#L516-L569)

**Before:**
```dart
void _handleCreateTask() {
  if (_formKey.currentState!.validate()) {
    // ... auth check ...

    context.read<TaskBloc>().add(
      CreateTaskRequested(
        taskName: _titleController.text.trim(),
        taskSeverity: _getPrioritySeverity(_selectedPriority), // Old 3-level system
        // ...
        latitude: 0.0, // ❌ Always 0.0
        longitude: 0.0, // ❌ Always 0.0
        createdBy: user.id,
      ),
    );
  }
}
```

**After:**
```dart
Future<void> _handleCreateTask() async {
  if (_formKey.currentState!.validate()) {
    // Validate and geocode address if provided
    if (_addressController.text.trim().isNotEmpty) {
      final isValid = await _validateAndGeocodeAddress();
      if (!isValid) {
        return; // ✅ Stop if address is invalid
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('You must be logged in to create tasks'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.of(context).pushReplacementNamed(AppRouter.login);
      }
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
        taskSeverity: _selectedPriority, // ✅ Direct int (1-5)
        taskDescription: _descriptionController.text.trim(),
        taskCompleted: _taskCompleted,
        assignedTo: assignedTo,
        teamName: teamName,
        teamId: teamId,
        latitude: _latitude ?? 0.0, // ✅ Actual coordinates
        longitude: _longitude ?? 0.0, // ✅ Actual coordinates
        createdBy: user.id,
      ),
    );
  }
}
```

**Changes:**
- ✅ Validates address before creating task
- ✅ Uses actual coordinates from geocoding or GPS
- ✅ Uses 5-level priority system (1-5)
- ✅ Async to support address validation
- ✅ Proper mounted checks for async operations

### Fix #2: Task List Refresh After Edit

**Location:**
- [app/lib/features/tasks/pages/task_detail_page.dart:256-261](app/lib/features/tasks/pages/task_detail_page.dart#L256-L261)
- [app/lib/features/tasks/pages/tasks_page.dart:196-215](app/lib/features/tasks/pages/tasks_page.dart#L196-L215)

**Problem:** After editing a task, the task list wasn't automatically refreshed.

**Root Cause:** The navigation didn't trigger a reload of tasks when returning from the detail page.

**Solution:** Use navigation result to trigger reload.

#### Task Detail Page Changes

**Before:**
```dart
listener: (context, state) {
  if (state is TaskUpdated) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task updated successfully')),
    );
    Navigator.of(context).pop(); // ❌ No indication of update
  }
}
```

**After:**
```dart
listener: (context, state) {
  if (state is TaskUpdated) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task updated successfully')),
    );
    // Pop with true to indicate task was updated
    Navigator.of(context).pop(true); // ✅ Return true
  }
}
```

#### Tasks Page Changes

**Before:**
```dart
onTap: () {
  final authState = context.read<AuthBloc>().state;
  String currentUserId = '';
  if (authState is AuthAuthenticated) {
    currentUserId = authState.user.id;
  }

  Navigator.of(context).pushNamed(
    AppRouter.taskDetail,
    arguments: {
      'task': task,
      'currentUserId': currentUserId,
    },
  );
  // ❌ No reload after navigation
},
```

**After:**
```dart
onTap: () async { // ✅ Async to await navigation
  final authState = context.read<AuthBloc>().state;
  String currentUserId = '';
  if (authState is AuthAuthenticated) {
    currentUserId = authState.user.id;
  }

  final result = await Navigator.of(context).pushNamed(
    AppRouter.taskDetail,
    arguments: {
      'task': task,
      'currentUserId': currentUserId,
    },
  );

  // Reload tasks if task was updated
  if (result == true && mounted) { // ✅ Check result
    context.read<TaskBloc>().add(const LoadTasksRequested());
  }
},
```

**How It Works:**
1. User taps task card
2. Navigation awaits result from TaskDetailPage
3. If user edits task, TaskDetailPage pops with `true`
4. Tasks page receives `true` and reloads tasks
5. Updated task appears immediately in list

### Fix #3: Optional Location Field

**Location:** [app/lib/features/tasks/pages/create_task_page.dart:306-320](app/lib/features/tasks/pages/create_task_page.dart#L306-L320)

**Problem:** Location field had a validator that required a value, contradicting the hint text.

**Before:**
```dart
TextFormField(
  controller: _locationController,
  decoration: InputDecoration(
    labelText: 'Location',
    hintText: 'Enter task location or leave empty for current location', // Says optional
  ),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a location'; // ❌ But requires value
    }
    return null;
  },
)
```

**After:**
```dart
TextFormField(
  controller: _addressController,
  decoration: InputDecoration(
    labelText: 'Address (Optional)', // ✅ Clearly marked as optional
    hintText: 'Enter address or use current location',
    prefixIcon: const Icon(Icons.location_on_outlined),
  ),
  // ✅ No validator - truly optional
)
```

**Behavior:**
- If address is empty → Uses default coordinates (0.0, 0.0)
- If address is provided → Validates and geocodes it
- If geocoding fails → Shows error and prevents task creation
- User can also click pin icon to use current GPS location

---

## Files Modified

### Core Changes
1. **[app/lib/features/tasks/pages/create_task_page.dart](app/lib/features/tasks/pages/create_task_page.dart)** - Complete overhaul with all features
   - Added geocoding and geolocator imports
   - Updated state variables for coordinates and loading
   - Added 5 priority levels with helper methods
   - Added current location feature
   - Added address validation with geocoding
   - Updated task creation logic
   - Removed location field validator

2. **[app/lib/features/tasks/pages/task_detail_page.dart](app/lib/features/tasks/pages/task_detail_page.dart#L256-L261)** - Navigation result
   - Pop with `true` when task is updated

3. **[app/lib/features/tasks/pages/tasks_page.dart](app/lib/features/tasks/pages/tasks_page.dart#L196-L215)** - Refresh on return
   - Made onTap async
   - Await navigation result
   - Reload tasks if result is `true`

---

## Testing Checklist

### Create Task Page
- [ ] Open create task page
- [ ] Select each of 5 priority levels - verify colors
- [ ] Leave address empty - verify task creates successfully
- [ ] Enter valid address - verify coordinates appear
- [ ] Enter invalid address - verify error message
- [ ] Tap current location button - verify GPS coordinates and address populate
- [ ] Create task with address - verify it saves correctly
- [ ] Create task without address - verify it uses default coordinates (0.0, 0.0)

### Task List Refresh
- [ ] Open task list
- [ ] Tap a task card
- [ ] Edit the task (change name, priority, etc.)
- [ ] Save changes
- [ ] Verify task list shows updated task immediately (no manual refresh needed)
- [ ] Verify updated values are correct in the list

### Consistency
- [ ] Compare create task page with edit task page
- [ ] Verify both have same 5 priority levels
- [ ] Verify both have address field with current location button
- [ ] Verify both show coordinates when available
- [ ] Verify UI/UX is consistent between pages

---

## Summary

All three issues have been fixed:

1. ✅ **Create Task Page Updated** - Now matches edit task page with 5 priority levels, address validation, and current location button
2. ✅ **Task List Refresh** - Tasks now reload automatically after editing without manual refresh
3. ✅ **Optional Location** - Location field is now truly optional, allowing task creation without address

The create task and edit task pages now provide a consistent user experience with the same features and functionality.
