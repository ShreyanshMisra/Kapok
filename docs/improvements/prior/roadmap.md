# Kapok App Implementation Roadmap

## Document Overview

This document outlines all requested changes and improvements for the Kapok disaster relief coordination app, organized into implementation phases. Each section includes specific requirements, affected screens, and implementation details.

---

## Phase 1: Critical Functionality Fixes

These are blocking issues that prevent core features from working properly and should be addressed first.

### 1.1 Offline Map Functionality

**Affected Screens:** Map Page, Map Cache Page

**Issues Identified:**
- Offline map caching is not persisting properly between sessions
- Cached regions are not displaying correctly when offline
- Map tiles fail to load from cache in offline mode

**Required Changes:**

1. **Fix Map Cache Persistence**
   - Ensure Hive storage for cached map tiles persists across app restarts
   - Verify MapBloc properly saves and retrieves cache metadata
   - Test cache retention after app termination and device restart

2. **Improve Offline Map Loading**
   - Update MapPage to check for cached tiles before attempting network requests
   - Implement proper fallback when offline with cached regions
   - Add visual indicator when using cached vs. live map data

3. **Cache Management Improvements**
   - Fix the "Latest Region" display to show accurate cache status
   - Ensure Clear Cache functionality properly removes all cached tiles
   - Add validation to prevent duplicate cache entries for same region

**Implementation Notes:**
- Review `/lib/features/map/presentation/blocs/map_bloc.dart`
- Check Hive box initialization in `/lib/injection_container.dart`
- Verify Mapbox offline region management in map widgets

### 1.2 Task Assignment and Reassignment

**Affected Screens:** Create Task Page, Task Details Page, Tasks List Page

**Issues Identified:**
- Cannot reassign tasks after initial assignment
- Task assignment dropdown doesn't show all team members
- "Unassigned" option doesn't work properly

**Required Changes:**

1. **Enable Task Reassignment**
   - Add "Reassign Task" option in Task Details page (currently only shows status change)
   - Allow task owners and team leaders to change assignee at any time
   - Update Firestore rules to permit reassignment by authorized users

2. **Fix Assignment Dropdown**
   - Ensure dropdown shows all current team members plus "Unassigned" option
   - Sort members alphabetically for easier selection
   - Display member roles (Medical, Construction, etc.) next to names
   - Handle members who have left the team (display as "Former Member")

3. **Unassigned Task Handling**
   - Fix backend logic to properly handle null or empty assignee field
   - Update task filtering to show unassigned tasks in "All Tasks" view
   - Add dedicated "Unassigned Tasks" filter option

**Implementation Notes:**
- Update TaskBloc to handle reassignment events
- Modify CreateTaskPage and EditTaskPage forms
- Update Firestore security rules in Firebase console
- Review TaskRepository assignment logic

### 1.3 Team Management - Leave Team

**Affected Screens:** Team Details Page, My Teams Page

**Issues Identified:**
- "Leave Team" option is not functional
- No confirmation dialog before leaving
- Tasks assigned to leaving member are not handled

**Required Changes:**

1. **Implement Leave Team Functionality**
   - Add working "Leave Team" button in Team Details page options menu
   - Show confirmation dialog: "Are you sure you want to leave [Team Name]?"
   - Remove user from team members list in Firestore
   - Update local Hive database to reflect team departure

2. **Handle Assigned Tasks**
   - When leaving team, reassign all user's tasks to "Unassigned"
   - Notify team leader of reassignment via in-app mechanism
   - Update task cards to show "Previously assigned to: [User]"

3. **Prevent Team Leader from Leaving**
   - Block team leader from leaving if they're the only leader
   - Require team leader to transfer leadership before leaving
   - Show explanatory message if attempted

**Implementation Notes:**
- Add LeaveTeamRequested event to TeamBloc
- Update TeamRepository.leaveTeam() method
- Add dialog widget for confirmation
- Update team member count automatically

### 1.4 Task Location Selection

**Affected Screens:** Create Task Page

**Issues Identified:**
- Double-click to select location is not intuitive
- No visual feedback when location is selected
- Selected coordinates not clearly displayed

**Required Changes:**

1. **Improve Location Selection UX**
   - Change from double-click to single tap for location selection
   - Add temporary pin marker at selected location
   - Show snackbar: "Location set: [Address]" after selection
   - Allow user to tap different location to change before creating task

2. **Visual Feedback Enhancements**
   - Display crosshair or target icon at map center
   - Add pulsing animation on selected location
   - Show coordinates and approximate address in bottom sheet
   - Add "Clear Location" button to reset selection

3. **Instruction Improvements**
   - Update instruction text from "Double-click on the map" to "Tap on the map to select a location"
   - Show instruction as overlay that dismisses after first tap
   - Add help icon with tooltip explaining location selection

**Implementation Notes:**
- Update CreateTaskPage map event listeners
- Add marker layer for selection visualization
- Integrate geocoding for address display
- Update instruction text in localization files (English/Spanish)

---

## Phase 2: Core Feature Enhancements

These improvements enhance existing features and add important missing functionality.

### 2.1 Task Filtering and Search

**Affected Screens:** Tasks Page

**Issues Identified:**
- Cannot filter by multiple criteria simultaneously
- No search functionality for tasks
- "My Tasks" filter doesn't persist

**Required Changes:**

1. **Enhanced Multi-Filter System**
   - Allow combining filters (e.g., "My Tasks" + "High Priority" + "Pending")
   - Add "Clear Filters" button when filters are active
   - Display active filter chips below filter buttons
   - Persist filter selections across app sessions

2. **Task Search Implementation**
   - Add search bar at top of Tasks page
   - Search across: task title, description, location, assignee name
   - Show search results in real-time as user types
   - Add "No results found" state with suggestion to adjust filters

3. **Filter Improvements**
   - Add "Date Range" filter for task creation/due dates
   - Add "Location Radius" filter (within X miles of current location)
   - Add "Team" filter for users in multiple teams
   - Save filter presets for quick access

**Implementation Notes:**
- Create TaskFiltersModel to hold multiple filter criteria
- Update TaskBloc to handle complex filtering logic
- Add search bar widget to TasksPage
- Store filter preferences in Hive

### 2.2 Task Status Workflow

**Affected Screens:** Task Details Page, Tasks List Page

**Issues Identified:**
- Status changes are not tracked/logged
- Cannot see task history
- No validation of status transitions

**Required Changes:**

1. **Status Change Tracking**
   - Record timestamp and user for each status change
   - Store status history in task document
   - Display status timeline in task details
   - Show who marked task as completed and when

2. **Status Transition Rules**
   - Prevent skipping from Pending directly to Completed
   - Require task to be "In Progress" before completion
   - Allow team leaders to override and change any status
   - Show warning when trying invalid transition

3. **Status Indicators**
   - Add status badge with color coding on task cards
   - Show time in current status (e.g., "Pending for 2 hours")
   - Add progress bar for tasks in progress
   - Display estimated completion time based on priority

**Implementation Notes:**
- Add statusHistory array field to Task model
- Update TaskBloc status update logic
- Create status timeline widget
- Add validation in TaskRepository

### 2.3 Team Member Roles and Permissions

**Affected Screens:** Team Details Page, Create Team Page, Profile Page

**Issues Identified:**
- Member roles are not clearly indicated
- Cannot assign custom roles
- Permissions are not enforced consistently

**Required Changes:**

1. **Role Management**
   - Display member role badges (Medical, Construction, etc.) on team member cards
   - Allow team leaders to change member roles
   - Add "Remove Member" option for team leaders
   - Show role icons in task assignment dropdown

2. **Role-Based Task Assignment**
   - Filter assignable members by role when creating tasks
   - Add "Suggested Assignees" based on task type and member role
   - Mark role requirements on task cards
   - Allow tasks to specify required role (optional)

3. **Enhanced Profile Editing**
   - Make role selection more prominent in Edit Profile
   - Add custom role option with text input
   - Display role history in profile
   - Show role-specific statistics (tasks completed by role)

**Implementation Notes:**
- Update UserModel to include role history
- Add role filtering in assignment logic
- Create role badge widgets
- Update team member management UI

### 2.4 Offline Data Synchronization

**Affected Screens:** All screens with data modification

**Issues Identified:**
- Sync conflicts when multiple users edit same task offline
- No indication of pending sync operations
- Failed syncs are not retried automatically

**Required Changes:**

1. **Sync Status Indicators**
   - Add sync icon in app bar showing sync status
   - Display "Pending sync" badge on modified items
   - Show sync progress during upload
   - Notify user when sync completes or fails

2. **Conflict Resolution**
   - Implement last-write-wins with timestamp comparison
   - Show conflict dialog when detected: "This task was modified by [User]. Use your version or theirs?"
   - Log conflicts for team leader review
   - Prevent data loss during conflicts

3. **Automatic Retry Logic**
   - Queue failed operations for retry
   - Retry with exponential backoff (1s, 5s, 30s, 5min)
   - Allow manual "Retry Sync" from settings
   - Show persistent notification for critical sync failures

4. **Offline Indicators**
   - Show "Offline Mode" banner when network unavailable
   - Disable features that require internet (e.g., team creation)
   - Cache team member data for offline assignment
   - Display last successful sync timestamp

**Implementation Notes:**
- Enhance NetworkChecker service
- Update all BLoCs to queue offline operations
- Create sync status widget
- Add retry logic to repositories

### 2.5 Task Due Dates and Notifications

**Affected Screens:** Create Task Page, Task Details Page, Tasks List

**Issues Identified:**
- No due date field for tasks
- No reminders or notifications
- Cannot see overdue tasks easily

**Required Changes:**

1. **Due Date Implementation**
   - Add optional due date/time picker in Create/Edit Task
   - Display due date on task cards with countdown
   - Sort tasks by due date in lists
   - Add "Overdue" status for tasks past due date

2. **Notification System** (Note: Push notifications noted as "not yet implemented")
   - Send push notification 24 hours before due date
   - Send push notification 1 hour before due date
   - Notify assignee when task is assigned
   - Notify team leader when task is completed

3. **Overdue Task Handling**
   - Highlight overdue tasks in red
   - Add "Overdue" filter option
   - Show overdue count badge on Tasks tab
   - Alert team leader of overdue tasks

**Implementation Notes:**
- Add dueDate field to Task model
- Integrate Firebase Cloud Messaging for push notifications
- Create notification service in `/lib/core/services/`
- Add date picker widget to task forms
- Update Firestore to trigger notifications

---

## Phase 3: UI/UX Improvements

These changes improve usability and visual design without adding major new features.

### 3.1 Task Cards Redesign

**Affected Screens:** Tasks List Page, Team Details Page

**Issues Identified:**
- Task cards are visually cluttered
- Priority not immediately visible
- Too much information on one line

**Required Changes:**

1. **Card Layout Improvements**
   - Use color-coded left border for priority (Red=High, Yellow=Medium, Green=Low)
   - Move status badge to top-right corner
   - Display assignee avatar/initial instead of full name
   - Use icons for location, team, and due date

2. **Information Hierarchy**
   - Make task title larger and bold
   - Show description preview (first 50 characters)
   - Display location as "Distance from you: X miles" when available
   - Group metadata (created date, assignee, team) in footer row

3. **Interactive Elements**
   - Add swipe actions: swipe right to mark complete, swipe left for more options
   - Show task preview on long press
   - Add quick-assign button for unassigned tasks
   - Display task count per status in section headers

**Implementation Notes:**
- Create new EnhancedTaskCard widget
- Implement swipe gesture detection
- Add distance calculation using Geolocator
- Update task list rendering logic

### 3.2 Map Visualization Enhancements

**Affected Screens:** Map Page

**Issues Identified:**
- Task markers all look the same
- Cannot distinguish between task priorities on map
- No clustering for dense task areas

**Required Changes:**

1. **Marker Customization**
   - Use distinct marker colors for priority levels
   - Add marker icons based on task category/role
   - Scale marker size based on priority
   - Show status indicator on marker (checkmark for completed)

2. **Map Interactions**
   - Implement marker clustering when zoomed out
   - Show task preview card on marker tap
   - Add "Navigate to Task" button in preview
   - Filter map markers by active task filters

3. **Current Location Features**
   - Add "Center on Me" button
   - Show compass/orientation indicator
   - Display user's GPS accuracy radius
   - Add "Nearby Tasks" mode (only show tasks within X miles)

**Implementation Notes:**
- Customize Mapbox marker symbols
- Add clustering layer configuration
- Create map preview card widget
- Integrate with device compass if available

### 3.3 Form Validation and Error Handling

**Affected Screens:** Create Task Page, Create Team Page, Login/Signup Pages, Edit Profile Page

**Issues Identified:**
- Validation errors are generic
- No inline validation before submit
- Error messages not localized

**Required Changes:**

1. **Inline Validation**
   - Show validation errors as user types (after first blur)
   - Use red border and error text for invalid fields
   - Display checkmark for valid fields
   - Disable submit button until form is valid

2. **Improved Error Messages**
   - Specific messages: "Email must be valid" instead of "Invalid input"
   - Localize all error messages (English/Spanish)
   - Add helpful hints: "Password must be at least 8 characters"
   - Show error summary at top of form if multiple errors

3. **Field-Specific Validation**
   - Email: Valid format, not already in use (check on blur)
   - Password: Min 8 characters, requires number and letter
   - Team Code: Exactly 6 characters, alphanumeric only
   - Task Title: Min 3 characters, max 100 characters
   - Task Description: Max 500 characters, show counter

**Implementation Notes:**
- Create reusable ValidatedTextField widget
- Add validation methods to form pages
- Update localization files for error messages
- Implement real-time character counters

### 3.4 Settings and Preferences

**Affected Screens:** Settings Page

**Issues Identified:**
- Theme switching requires app restart
- Language change doesn't update all text immediately
- No confirmation when clearing cache

**Required Changes:**

1. **Theme Switching**
   - Apply theme changes immediately without restart
   - Add theme preview before applying
   - Remember theme preference in Hive
   - Support system default theme option

2. **Language Switching**
   - Update all text immediately on language change
   - Re-translate dynamic content (task names, team names)
   - Show language-specific date/time formats
   - Add more language options (prepare infrastructure)

3. **Data Management**
   - Add confirmation dialog for "Clear Cache": "This will clear X MB of cached map data"
   - Show storage usage breakdown (maps, images, database)
   - Add "Export Data" option to save tasks/teams as JSON
   - Add "Delete Account" option with strong confirmation

4. **Additional Settings**
   - Add "Default Map Zoom Level" slider
   - Add "Auto-sync Interval" dropdown (5min, 15min, 30min, Manual)
   - Add "GPS Accuracy" preference (High, Balanced, Low Power)
   - Add "Compact View" toggle for task lists

**Implementation Notes:**
- Use Provider to manage theme changes
- Update LanguageProvider for instant switching
- Add file export functionality
- Create settings data model

### 3.5 Navigation and Flow Improvements

**Affected Screens:** All navigation screens

**Issues Identified:**
- Back button behavior inconsistent
- No breadcrumb navigation in deep screens
- Difficult to return to specific screen

**Required Changes:**

1. **Navigation Consistency**
   - Ensure back button returns to previous logical screen
   - Add "Back to Tasks" quick link in task details
   - Add "Back to Teams" quick link in team details
   - Implement navigation drawer for quick access to main sections

2. **Bottom Navigation Enhancements**
   - Add badge counts on tabs (unread tasks, team invites)
   - Highlight active tab more prominently
   - Add haptic feedback on tab switch
   - Remember scroll position when switching tabs

3. **Deep Linking Support**
   - Generate shareable links for tasks: `kapok://task/[taskId]`
   - Generate shareable links for teams: `kapok://team/[teamCode]`
   - Handle links when app is closed
   - Show preview before navigating

**Implementation Notes:**
- Review all Navigator.pop() calls
- Implement custom navigation observer
- Add deep linking package
- Create link generation utility

---

## Phase 4: Advanced Features and Polish

These are enhancements that add new capabilities and improve the overall experience.

### 4.1 Team Communication

**Affected Screens:** Team Details Page (new tab/section)

**Required Changes:**

1. **Team Chat/Comments**
   - Add "Discussion" tab in team details
   - Allow team members to post updates and comments
   - Support @mentions for specific members
   - Show unread message count

2. **Task Comments**
   - Add comment section in task details
   - Allow assignee to post progress updates
   - Show comment count on task cards
   - Send notification on new comment

3. **Announcements**
   - Allow team leaders to post announcements
   - Pin important announcements at top
   - Mark announcements as read
   - Send push notification for announcements

**Implementation Notes:**
- Create new Message model
- Add Firestore subcollection for messages
- Create chat UI components
- Implement notification triggers

### 4.2 Analytics and Reporting

**Affected Screens:** New "Reports" section in Teams page

**Required Changes:**

1. **Team Performance Dashboard**
   - Show tasks completed vs. total
   - Display average completion time
   - Show member activity levels
   - Display priority distribution

2. **Individual Statistics**
   - Show tasks completed by user
   - Display average response time
   - Show roles most frequently assigned
   - Display location coverage map

3. **Export Capabilities**
   - Export team report as PDF
   - Export task history as CSV
   - Generate sharable summary for stakeholders
   - Schedule automatic weekly reports

**Implementation Notes:**
- Create analytics calculation service
- Build chart widgets (use fl_chart package)
- Implement PDF generation (use pdf package)
- Create export functionality

### 4.3 Accessibility Improvements

**Affected Screens:** All screens

**Required Changes:**

1. **Screen Reader Support**
   - Add semantic labels to all interactive elements
   - Provide descriptive hints for actions
   - Ensure proper focus order
   - Support TalkBack (Android) and VoiceOver (iOS)

2. **Visual Accessibility**
   - Support larger text sizes
   - Ensure color contrast meets WCAG AA standards
   - Add high-contrast mode option
   - Support reduce motion preference

3. **Input Accessibility**
   - Ensure minimum tap target size (48x48dp)
   - Support keyboard navigation on web
   - Add voice input for task creation
   - Support switch control

**Implementation Notes:**
- Add Semantics widgets throughout app
- Test with screen readers
- Add accessibility settings section
- Audit color contrast ratios

### 4.4 Advanced Offline Features

**Affected Screens:** All data-driven screens

**Required Changes:**

1. **Offline Media Support**
   - Cache task-related images
   - Support offline team logos
   - Download attachments for offline access
   - Show download progress and storage used

2. **Offline Team Directory**
   - Cache full team member profiles
   - Support offline team browsing
   - Pre-download team data for likely-needed teams
   - Show staleness indicator for cached data

3. **Conflict Prevention**
   - Lock tasks being edited by others
   - Show "User X is editing" indicator
   - Warn before editing recently modified items
   - Suggest alternative tasks if conflict likely

**Implementation Notes:**
- Implement media caching strategy
- Add file download manager
- Create conflict detection service
- Add WebSocket for real-time updates

### 4.5 Onboarding and Help

**Affected Screens:** New onboarding flow, Help section

**Required Changes:**

1. **First-Time User Experience**
   - Create 3-4 screen onboarding flow explaining key features
   - Show interactive tutorial on first login
   - Highlight key actions with tooltips
   - Allow skip/complete later option

2. **In-App Help**
   - Add help icon (?) in app bar of complex screens
   - Create help overlay explaining screen elements
   - Add "Quick Start Guide" in settings
   - Include FAQ section

3. **Contextual Tips**
   - Show tips when user seems stuck (e.g., no tasks created after 5 minutes)
   - Suggest best practices (e.g., "Set priorities for faster response")
   - Celebrate milestones (first task completed, team created)
   - Add "Tip of the Day" in home screen

**Implementation Notes:**
- Create onboarding page flow
- Build help overlay widget
- Add tips database
- Implement user progress tracking

---

## Implementation Priority Summary

### Sprint 1 (Critical Fixes)
- Offline map functionality
- Task assignment/reassignment
- Leave team functionality
- Task location selection

### Sprint 2 (Core Enhancements)
- Task filtering and search
- Task status workflow
- Team roles and permissions
- Offline sync improvements

### Sprint 3 (UX Polish)
- Task cards redesign
- Map visualization enhancements
- Form validation improvements
- Settings enhancements

### Sprint 4 (Advanced Features)
- Due dates and notifications
- Navigation improvements
- Team communication
- Analytics and reporting

### Sprint 5 (Final Polish)
- Accessibility improvements
- Advanced offline features
- Onboarding and help
- Performance optimization

---

## Testing Requirements

For each phase, ensure:

### 1. Unit Tests
- Test all new BLoC events and states
- Test repository methods
- Test model serialization/deserialization

### 2. Widget Tests
- Test UI components in isolation
- Test user interactions
- Test responsive layouts

### 3. Integration Tests
- Test complete user flows
- Test offline-to-online transitions
- Test multi-user scenarios

### 4. Platform Tests
- Test on iOS devices
- Test on Android devices
- Test on web browsers
- Test on tablets

### 5. Accessibility Tests
- Test with screen readers
- Test with large text
- Test with reduced motion
- Test color contrast

---

## Notes for Implementation

1. **Backward Compatibility:** Ensure all changes maintain compatibility with existing data in Firestore and Hive. Write migration scripts if schema changes are needed.

2. **Localization:** All new text strings must be added to both English and Spanish localization files. Use the existing translator package pattern for consistency.

3. **Offline First:** Every feature must work offline first, then sync when connection is restored. Test extensively in airplane mode.

4. **Performance:** Monitor app size, memory usage, and battery consumption. Optimize as needed, especially for map rendering and data sync.

5. **Security:** Update Firestore security rules for any new data access patterns. Ensure user permissions are properly enforced.

6. **Documentation:** Update code comments and README for significant architectural changes. Document any new environment variables in `.env.example`.

This roadmap provides a structured approach to implementing all requested changes while maintaining code quality and app stability.
