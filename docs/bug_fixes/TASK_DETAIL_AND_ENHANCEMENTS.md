# Task Detail Page and Enhancement Features

## Overview

This document describes the implementation of the task detail/edit page and several task management enhancements for the Kapok disaster relief application.

## Features Implemented

### 1. Task Detail/Edit Page

**Requirement:** Create a dedicated page for viewing and editing task details.

**Implementation:**

#### New Page: TaskDetailPage

Location: [app/lib/features/tasks/pages/task_detail_page.dart](app/lib/features/tasks/pages/task_detail_page.dart)

**Features:**
- View all task details in a clean, organized layout
- Edit mode with permission checks
- Real-time validation
- Offline support with BLoC integration

**Permission-Based Access:**
```dart
bool get canEdit {
  return widget.task.createdBy == widget.currentUserId ||
      widget.task.assignedTo == widget.currentUserId;
}
```

**Edit Flow:**
1. User taps Edit icon in app bar
2. Page switches to edit mode
3. Fields become editable
4. User makes changes
5. User taps Save (checkmark icon)
6. Validation runs
7. Changes saved with `EditTaskRequested` event
8. Page returns to view mode on success

**Usage:**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TaskDetailPage(
      task: taskModel,
      currentUserId: currentUser.id,
    ),
  ),
);
```

### 2. Five Priority Levels

**Requirement:** Replace 3-level priority (low, medium, high) with 5-level system.

**Implementation:**

#### Updated Priority Scale

| Level | Label | Color | Hex Code |
|-------|-------|-------|----------|
| 1 | Lowest | Green | #4CAF50 |
| 2 | Low | Light Green | #8BC34A |
| 3 | Medium | Amber | #FFC107 |
| 4 | High | Orange | #FF9800 |
| 5 | Critical | Red | #F44336 |

#### TaskModel Enhancements

Location: [app/lib/data/models/task_model.dart](app/lib/data/models/task_model.dart)

**Added Helpers:**
```dart
class TaskModel {
  final int taskSeverity; // 1-5

  /// Get human-readable priority label
  String get priorityLabel {
    switch (taskSeverity) {
      case 1: return 'Lowest';
      case 2: return 'Low';
      case 3: return 'Medium';
      case 4: return 'High';
      case 5: return 'Critical';
      default: return 'Medium';
    }
  }

  /// Priority color mapping
  static const priorityColors = {
    1: 0xFF4CAF50, // Green
    2: 0xFF8BC34A, // Light Green
    3: 0xFFFFC107, // Amber
    4: 0xFFFF9800, // Orange
    5: 0xFFF44336, // Red
  };

  /// Get priority color
  int get priorityColor => priorityColors[taskSeverity] ?? priorityColors[3]!;
}
```

#### UI Components

**Priority Selector (Edit Mode):**
```dart
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
          setState(() { _selectedPriority = value; });
        },
      );
    }),
  );
}
```

**Priority Badge (View Mode):**
```dart
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
```

### 3. Auto-Assign to Creator

**Requirement:** If a task is not assigned to anyone, automatically assign it to the creator.

**Implementation:**

#### Task Creation Logic

Location: [app/lib/features/tasks/bloc/task_bloc.dart:45](app/lib/features/tasks/bloc/task_bloc.dart#L45)

**Change:**
```dart
// BEFORE:
assignedTo: event.assignedTo,

// AFTER:
assignedTo: event.assignedTo.isEmpty ? event.createdBy : event.assignedTo,
```

**Behavior:**
- If `assignedTo` field is empty during task creation
- Task is automatically assigned to `createdBy` user
- Ensures every task has an assignee
- Creator can still assign to someone else during creation

**Example:**
```dart
// User creates task without selecting assignee
context.read<TaskBloc>().add(
  CreateTaskRequested(
    taskName: 'Emergency supplies needed',
    assignedTo: '', // Empty
    createdBy: 'user123',
    // ... other fields
  ),
);

// Result: Task is assigned to 'user123' automatically
```

### 4. Address Validation and Location Features

**Requirement:**
- Verify addresses are real
- Assign latitude/longitude based on address
- Add "current location" feature with pin icon

**Implementation:**

#### New Model Field

Location: [app/lib/data/models/task_model.dart](app/lib/data/models/task_model.dart)

**Added:**
```dart
@JsonSerializable()
class TaskModel {
  final String? address; // Optional address field
  final double latitude;
  final double longitude;

  // ... rest of model
}
```

**Note:** After adding this field, run:
```bash
cd app
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Dependencies

Added to `pubspec.yaml`:
```yaml
dependencies:
  geocoding: ^3.0.0      # Address validation and geocoding
  geolocator: ^13.0.2    # Current location access
```

#### Address Validation with Geocoding

Location: [app/lib/features/tasks/pages/task_detail_page.dart:183-216](app/lib/features/tasks/pages/task_detail_page.dart#L183-L216)

```dart
/// Validate and geocode address
Future<bool> _validateAndGeocodeAddress() async {
  final address = _addressController.text.trim();

  if (address.isEmpty) {
    // No address provided, that's okay
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

**How It Works:**
1. User enters an address
2. On save, `locationFromAddress()` validates the address
3. If valid, returns coordinates
4. Coordinates are saved with the task
5. If invalid, shows error and prevents save

#### Current Location Feature

Location: [app/lib/features/tasks/pages/task_detail_page.dart:100-180](app/lib/features/tasks/pages/task_detail_page.dart#L100-L180)

```dart
/// Get current location
Future<void> _getCurrentLocation() async {
  setState(() {
    _isLoadingLocation = true;
  });

  try {
    // Check location permissions
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

    // Get current position with high accuracy
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });

    // Try to reverse geocode to get address
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
- Requests location permission if needed
- Gets high-accuracy GPS coordinates
- Reverse geocodes to get address automatically
- Shows loading indicator while fetching
- Handles permission denials gracefully
- Updates both address and coordinates

#### Location UI

```dart
// Location section in edit mode
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
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.my_location), // Pin icon
      onPressed: _isLoadingLocation ? null : _getCurrentLocation,
      tooltip: 'Use current location',
    ),
  ],
)
```

**Pin Icon:** Uses `Icons.my_location` (standard Flutter GPS/location icon)

## Complete Feature Summary

### Task Detail Page
- ✅ View all task information
- ✅ Edit mode with permission checks
- ✅ Only creator or assignee can edit
- ✅ Validation before saving
- ✅ BLoC integration with `EditTaskRequested`
- ✅ Offline support via existing BLoC handlers

### Priority System
- ✅ 5 levels instead of 3
- ✅ Color-coded visual indicators
- ✅ Clear labels (Lowest → Critical)
- ✅ Radio button selector for editing
- ✅ Badge display for viewing
- ✅ Helper methods in TaskModel

### Auto-Assignment
- ✅ Tasks auto-assign to creator if unassigned
- ✅ One-line change in task creation logic
- ✅ Ensures every task has an assignee
- ✅ Still allows manual assignment during creation

### Location Features
- ✅ Address validation using geocoding
- ✅ Automatic coordinate assignment from address
- ✅ Current location button with GPS
- ✅ Reverse geocoding (coordinates → address)
- ✅ Permission handling for location access
- ✅ Loading states and error handling
- ✅ Coordinates displayed when available

## Usage Examples

### Creating a Task with Auto-Assignment

```dart
// Create task without assignee
context.read<TaskBloc>().add(
  CreateTaskRequested(
    taskName: 'Deliver medical supplies',
    taskSeverity: 4, // High priority
    taskDescription: 'Urgent delivery needed',
    assignedTo: '', // Empty - will auto-assign to creator
    createdBy: currentUserId,
    teamName: 'Medical Team',
    teamId: 'team_123',
    latitude: 0.0,
    longitude: 0.0,
  ),
);
// Result: Task assigned to currentUserId automatically
```

### Opening Task Detail Page

```dart
// From task list
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(
          task: task,
          currentUserId: currentUserId,
        ),
      ),
    );
  },
  child: TaskCard(task: task),
)
```

### Editing Task with Address

```dart
// User flow in TaskDetailPage:
// 1. Tap Edit icon
// 2. Enter address: "123 Main St, San Francisco, CA"
// 3. Tap Save
// 4. Address validated via geocoding API
// 5. If valid: Coordinates assigned, task saved
// 6. If invalid: Error shown, save prevented
```

### Using Current Location

```dart
// User flow in TaskDetailPage:
// 1. Tap Edit icon
// 2. Tap pin icon (my_location)
// 3. Permission requested (if needed)
// 4. GPS gets current coordinates
// 5. Reverse geocoding gets address
// 6. Both address and coordinates populated
// 7. User taps Save
```

## Platform Permissions

### iOS (ios/Runner/Info.plist)

Add location permission descriptions:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to set task locations</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location to set task locations</string>
```

### Android (android/app/src/main/AndroidManifest.xml)

Add location permissions:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

## Testing Checklist

### Task Detail Page
- [ ] Navigate to task detail page
- [ ] View mode shows all task information
- [ ] Edit button only visible for creator/assignee
- [ ] Edit mode enables all fields
- [ ] Save button triggers validation
- [ ] Successfully saved tasks update in list
- [ ] Permission denied for non-creator/assignee

### Priority System
- [ ] All 5 priority levels selectable
- [ ] Colors display correctly
- [ ] Priority badge shows in view mode
- [ ] Radio selector shows in edit mode
- [ ] Default priority is Medium (3)

### Auto-Assignment
- [ ] Create task with empty assignedTo
- [ ] Verify task assigned to creator
- [ ] Create task with specific assignee
- [ ] Verify specific assignee preserved

### Location Features
- [ ] Enter valid address → coordinates assigned
- [ ] Enter invalid address → error shown
- [ ] Tap current location button
- [ ] Permission requested if needed
- [ ] GPS coordinates fetched
- [ ] Address auto-populated from GPS
- [ ] Both address and coordinates saved
- [ ] Coordinates display in UI

## Files Modified

### New Files
- [app/lib/features/tasks/pages/task_detail_page.dart](app/lib/features/tasks/pages/task_detail_page.dart) - Complete task detail/edit page (562 lines)

### Modified Files
- [app/lib/data/models/task_model.dart](app/lib/data/models/task_model.dart) - Added address field, priority helpers
- [app/lib/features/tasks/bloc/task_bloc.dart](app/lib/features/tasks/bloc/task_bloc.dart) - Auto-assignment logic
- [app/pubspec.yaml](app/pubspec.yaml) - Added geocoding and geolocator dependencies

## Next Steps

1. **Run build_runner** to generate JSON serialization:
   ```bash
   cd app
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Add platform permissions** (see Platform Permissions section above)

3. **Integrate task detail page** into existing task list UI

4. **Test all features** using the testing checklist above

## Summary

All four requested features have been successfully implemented:

1. ✅ **Task Detail Page** - Complete edit interface with permission checks
2. ✅ **5 Priority Levels** - Color-coded system with visual indicators
3. ✅ **Auto-Assignment** - Tasks assign to creator when unassigned
4. ✅ **Location Features** - Address validation, geocoding, and current location with pin icon

All features integrate seamlessly with existing offline-first architecture and BLoC state management.
