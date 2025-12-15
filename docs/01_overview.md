# Kapok App Overview

## What is Kapok?

Kapok is a mobile application designed for disaster relief coordination. It enables volunteer teams to organize, assign, and track tasks during disaster response operations. The app prioritizes offline functionality, making it suitable for field conditions where network connectivity may be unreliable.

## Who is it for?

Based on the application's implementation, Kapok serves:

- **Disaster relief volunteers** who need to coordinate tasks in the field
- **Team leaders** who manage volunteer groups and assign tasks
- **Administrators** who oversee multiple teams and operations

## Core Functionality

### Team Management
- Create teams with unique 6-character join codes
- Join existing teams using join codes
- View team members and their assigned tasks
- Team leaders can manage membership (add/remove members)

### Task Management
- Create location-based tasks with map integration
- Assign tasks to team members
- Track task status (Pending, In Progress, Completed)
- Set task priorities (Low, Medium, High)
- Filter tasks by status, priority, and assignment

### Interactive Maps
- View tasks on a Mapbox-powered map
- Create tasks by selecting locations on the map
- Offline map caching for field use (3-mile radius around current location)
- Task markers with priority-based color coding

### Offline-First Architecture
- All data stored locally using Hive database
- Automatic synchronization when network is available
- Queued operations for offline changes
- Works without internet connectivity

### User Roles
The app implements three user roles with different permissions:

| Role | Capabilities |
|------|-------------|
| **Team Member** | View and complete assigned tasks, join teams |
| **Team Leader** | Create teams, manage members, assign tasks |
| **Admin** | Full access to all teams and operations |

## Supported Languages

- English
- Spanish

## Supported Platforms

- iOS
- Android
- Web (limited functionality)

## Key Technical Features

- **State Management**: BLoC pattern with flutter_bloc
- **Local Storage**: Hive for offline data persistence
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Maps**: Mapbox GL for interactive mapping
- **Dependency Injection**: GetIt service locator
