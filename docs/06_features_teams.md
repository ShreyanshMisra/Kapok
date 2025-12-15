# Teams Feature

## Overview

Teams are the organizational unit for task coordination. Each team has a leader who manages members and task assignments. Teams use unique 6-character codes for joining.

## Team Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | Unique identifier (format: `team_{timestamp}`) |
| `teamName` | String | Display name of the team |
| `leaderId` | String | User ID of the team leader (immutable) |
| `teamCode` | String | 6-character alphanumeric join code |
| `memberIds` | List<String> | User IDs of all members (includes leader) |
| `taskIds` | List<String> | IDs of tasks associated with the team |
| `description` | String? | Optional description (max 200 characters) |
| `createdAt` | DateTime | Creation timestamp |
| `updatedAt` | DateTime | Last modification |
| `isActive` | bool | Soft-deletion flag |

## Team Code Generation

- 6 uppercase alphanumeric characters (A-Z, 0-9)
- Generated using `Random.secure()` for cryptographic randomness
- Uniqueness verified against Firestore before acceptance
- Retries up to 5 times if collision occurs
- Example: `ABC123`, `X7YZ9K`

## Team Limits

- Maximum 50 members per team
- Join code is permanent once created
- Only one leader per team

## Pages

### TeamsPage (`lib/features/teams/pages/teams_page.dart`)

Main teams list view.

**Features:**
- Displays all teams user belongs to
- Team cards show name, member count, active status
- Role-based action buttons in app bar:
  - Team Leaders/Admins: "Create Team" button
  - Team Members: "Join Team" button
- Empty state with contextual action based on user role
- Pull-to-refresh support

### CreateTeamPage (`lib/features/teams/pages/create_team_page.dart`)

Form for creating new teams.

**Features:**
- Team name field (required)
- Description field (optional, max 200 characters)
- Role verification (only Team Leaders or Admins)
- Info card explaining team leader benefits
- Success dialog displays generated team code
- Copy-to-clipboard functionality

**Success Flow:**
1. Form validates
2. Team created with unique code
3. Modal shows team code
4. User copies code to share with members
5. Navigate to teams list

### JoinTeamPage (`lib/features/teams/pages/join_team_page.dart`)

Form for joining existing teams.

**Features:**
- Team code input (6 characters, auto-uppercase)
- Validation (required, exactly 6 characters)
- Role verification (only Team Members)
- Info card explaining how to get team code

**Error Handling:**
- Invalid code → "Invalid team code"
- Already member → "Already a member of this team"
- Team full → "Team is full (max 50 members)"

### TeamDetailPage (`lib/features/teams/pages/team_detail_page.dart`)

Detailed team view with management capabilities.

**Sections:**

1. **Team Info Card**
   - Team name and member count
   - Active/Inactive status badge
   - Optional description

2. **Team Code Card** (Leader only)
   - Large display of 6-character code
   - Copy-to-clipboard button

3. **Members Section**
   - Expandable member cards showing:
     - Member name, role, email
     - Assigned tasks list
     - Leader badge (star icon)
     - Remove button (leader only)

4. **Tasks Section**
   - List of team tasks
   - Create Task button
   - Task cards with priority/status badges
   - Tap to view task detail

**Leader Actions (Popup Menu):**
- Edit Team (placeholder)
- Close Team → Deactivates team
- Delete Team → Permanent with confirmation
- Remove Member → Confirmation dialog

**Member Actions:**
- Leave Team → Confirmation dialog

## BLoC Structure

### Events (`lib/features/teams/bloc/team_event.dart`)

| Event | Parameters | Purpose |
|-------|------------|---------|
| `CreateTeamRequested` | teamName, leaderId, description? | Create new team |
| `JoinTeamRequested` | teamCode, userId | Join team by code |
| `LeaveTeamRequested` | teamId, userId | Leave current team |
| `LoadUserTeams` | userId | Load user's teams |
| `LoadTeam` | teamId | Load single team |
| `UpdateTeamRequested` | team | Update team info |
| `CloseTeamRequested` | teamId | Soft-close team |
| `DeleteTeamRequested` | teamId, userId | Delete team |
| `RemoveMemberRequested` | teamId, memberId, leaderId | Remove member |
| `LoadTeamMembers` | teamId | Load member details |
| `TeamReset` | none | Clear state (on logout) |

### States (`lib/features/teams/bloc/team_state.dart`)

| State | Properties | Meaning |
|-------|------------|---------|
| `TeamInitial` | none | Initial state |
| `TeamLoading` | none | Operation in progress |
| `TeamLoaded` | teams | Teams loaded |
| `TeamCreated` | team | Team created |
| `TeamJoined` | team | User joined team |
| `TeamUpdated` | team | Team updated |
| `TeamMembersLoaded` | members | Members loaded |
| `TeamDeleted` | teamId | Team deleted |
| `TeamError` | message | Operation failed |

## Repository (`lib/data/repositories/team_repository.dart`)

### Key Methods

```dart
// Create team with generated code
Future<TeamModel> createTeam(String teamName, String leaderId, String? description)

// Join team by code
Future<TeamModel> joinTeam(String teamCode, String userId)

// Leave team
Future<void> leaveTeam(String teamId, String userId)

// Get user's teams
Future<List<TeamModel>> getUserTeams(String userId)

// Get team by ID
Future<TeamModel?> getTeam(String teamId)

// Get team by code
Future<TeamModel?> getTeamByCode(String teamCode)

// Get team members with details
Future<List<UserModel>> getTeamMembers(String teamId)

// Update team
Future<TeamModel> updateTeam(TeamModel team)

// Delete team (soft delete)
Future<void> deleteTeam(String teamId, String userId)

// Remove member
Future<void> removeMember(String teamId, String memberId, String leaderId)
```

### Transaction Safety

Join and leave operations use Firestore transactions to:
- Update team's `memberIds` array atomically
- Update user's `teamId` field atomically
- Prevent race conditions with concurrent joins

### Offline Support

1. **Create**: Saves to Hive, syncs to Firebase when online
2. **Join**: Requires online connection (code verification needed)
3. **Leave**: Requires online connection (transaction needed)
4. **Read**: Falls back to Hive cache if offline
5. **Update**: Updates Hive first, syncs when online
6. **Delete**: Requires online connection (batch write needed)

## Firestore Structure

Teams are stored at `teams/{teamId}`:

```json
{
  "id": "team_1234567890",
  "teamName": "Relief Squad Alpha",
  "leaderId": "user_abc",
  "teamCode": "ABC123",
  "memberIds": ["user_abc", "user_xyz", "user_123"],
  "taskIds": ["task_001", "task_002"],
  "description": "First response team for downtown area",
  "createdAt": "2024-01-15T09:00:00Z",
  "updatedAt": "2024-01-15T10:30:00Z",
  "isActive": true
}
```

## Permission Model

| Action | Who Can Perform |
|--------|-----------------|
| Create Team | Team Leaders, Admins |
| Join Team | Team Members |
| View Team | Any team member |
| Edit Team | Team Leader, Admin |
| Close Team | Team Leader, Admin |
| Delete Team | Team Leader, Admin |
| Remove Member | Team Leader only |
| Leave Team | Any member (except leader) |
| View All Teams | Admin only |

## Soft Deletion

When a team is deleted:
1. `isActive` set to `false`
2. `deletedAt` timestamp added
3. `deletedBy` user ID recorded
4. All members' `teamId` cleared
5. Team data preserved for historical records
