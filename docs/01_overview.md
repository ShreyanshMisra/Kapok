# Kapok App Overview

_Last verified against the codebase: 2026-10-24 (version `1.0.0+2`)._

## What is Kapok?

Kapok is a mobile application designed for disaster response coordination. It enables volunteer teams to organize, assign, and track tasks during disaster response operations. The app prioritizes offline functionality, making it suitable for field conditions where network connectivity may be unreliable.

## Who is it for?

Based on the application's implementation, Kapok serves:

- **Disaster response volunteers** who need to coordinate tasks in the field
- **Team leaders** who manage volunteer groups and assign tasks
- **Administrators** who oversee multiple teams and operations

## Core Functionality

### Team Management
- Create teams with unique 6-character join codes
- Join existing teams using join codes
- View team members and their assigned tasks
- Team leaders can edit, close, or delete a team, remove members, and transfer leadership
- Share a team's join code through the system share sheet

### Task Management
- Create location-based tasks with map integration
- Assign tasks to team members
- Track task status (Pending, In Progress, Completed)
- Set task priorities (Low, Medium, High) and categories
- Filter tasks by status, priority, category, assignment, and date; search by text

### Interactive Maps
- View tasks on a Mapbox-powered map
- Create tasks by tapping a location on the map or searching an address
- Offline map caching for field use (3-mile radius around current location)
- Works without location permission: the map falls back to a default center
- Task markers are blue for active tasks, grey for completed; priority is conveyed via star count on the marker, not pin color

### Offline-First Architecture
- All data stored locally using Hive database
- Automatic synchronization when network is available
- Queued operations for offline changes
- Works without internet connectivity

### User Roles
The app implements three user roles with different permissions:

| Role | Capabilities |
|------|-------------|
| **Team Member** | View and complete assigned tasks, edit their own assigned tasks, join teams |
| **Team Leader** | Create teams, manage members, assign tasks |
| **Admin** | Full access to all teams and operations |

## UI & Navigation Notes

- AppBars use a blue header block with curved bottom corners across all pages.
- Home has four bottom tabs: **Map**, **Tasks**, **Teams**, **Profile**. The Tasks tab shows a badge with the number of open tasks.
- First-time logins land on the About page (with a **Continue** button); subsequent logins go to Home.
- Task detail pages embed a map with a blue pin marker at the task location.
- A role-aware permissions table on the Profile page documents what each role can do.
- Accounts can be deleted in-app (Profile → Settings → Delete Account), as both app stores require.

## Supported Languages

- English
- Spanish

## Supported Platforms

- iOS — **iPhone only**, iOS 15.0+
- Android — API 24+ (targets API 36)
- Web — limited functionality, used for development/QA only

## Key Technical Features

- **State Management**: BLoC pattern with flutter_bloc
- **Local Storage**: Hive for offline data persistence
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Maps**: Mapbox GL for interactive mapping
- **Dependency Injection**: GetIt service locator
