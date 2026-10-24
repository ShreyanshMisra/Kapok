# Teams Feature

_Last verified against the codebase: 2026-10-24._

## Overview

Teams are the organizational unit for task coordination. Each team has a leader who manages members and task assignments. Teams use unique 6-character codes for joining.

## Team Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | Unique identifier (format: `team_{timestamp}`) |
| `teamName` | String | Display name of the team |
| `leaderId` | String | User ID of the team leader (changes only via Transfer Leadership) |
| `teamCode` | String | 6-character alphanumeric join code |
| `memberIds` | List<String> | User IDs of all members (includes leader) |
| `taskIds` | List<String> | IDs of tasks associated with the team |
| `description` | String? | Optional description (max 200 characters) |
| `createdAt` | DateTime | Creation timestamp |
| `updatedAt` | DateTime | Last modification |
| `isActive` | bool | `false` once the team is closed (defaults to `true` when missing) |

## Team Code Generation

- 6 uppercase alphanumeric characters (A-Z, 0-9)
- Generated using `Random.secure()` for cryptographic randomness
- Uniqueness verified against Firestore before acceptance
- Retries up to 5 times if collision occurs
- Example: `ABC123`, `X7YZ9K`

## Team Limits

- Maximum 50 members per team
- Join code is permanent once created
- Only one leader per team; leadership can be transferred to a member whose account type is Team Leader

## Pages

### TeamsPage (`lib/features/teams/pages/teams_page.dart`)

Main teams list view.

**Features:**
- Displays all teams user belongs to
- Team cards show name, member count, active status
- Role-based action buttons in app bar:
  - Team Leaders/Admins: "Create Team" button
  - Team Members/Team Leaders: "Join Team" button
- Empty state with contextual action based on user role:
  - Team Members: Join Team button
  - Team Leaders: Create Team + Join Team buttons
  - Admins: Create Team button
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
- Team Members and Team Leaders can join; Admins are sent back (they already see all teams)
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
   - Info note explaining that leadership can only be transferred to members with a Team Leader account
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
- Edit Team → opens full-screen `EditTeamPage` (pushed with `MaterialPageRoute`)
- Transfer Leadership → pick an eligible member
- Close Team → sets `isActive: false` (soft close; data kept)
- Delete Team → permanent, with confirmation
- Remove Member → confirmation dialog (from the member card)
- Copy Code / Share → on the Team Code card (`share_plus` share sheet)

**Data note:** this page loads only this team's tasks into the shared `TaskBloc`. On exit it re-dispatches `LoadUserTeams` so the rest of the app reloads all of the user's tasks.

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
| `ChangeMemberRoleRequested` | teamId, memberId, leaderId, newRole | Change a member's professional role |
| `TransferLeadershipRequested` | teamId, currentLeaderId, newLeaderId | Hand leadership to another member |
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
| `LeadershipTransferred` | team | Leadership handed off |
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

// Close team (soft: isActive = false)
Future<void> closeTeam({required String teamId, required String userId})

// Delete team (hard delete of the team document)
Future<void> deleteTeam({required String teamId, required String userId})

// Transfer leadership
Future<TeamModel> transferLeadership({required String teamId, required String currentLeaderId, required String newLeaderId})

// Remove member
Future<void> removeMember(String teamId, String memberId, String leaderId)
```

Signatures above are abbreviated: the mutating methods take **named, required** parameters (e.g. `createTeam({required teamName, required leaderId, description})`, `joinTeam({required teamCode, required userId})`).

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
| Join Team | Team Members, Team Leaders (Admins already see all teams) |
| View Team | Any team member |
| Edit Team | Team Leader, Admin |
| Close Team | Team Leader, Admin |
| Transfer Leadership | Team Leader (to a member with a Team Leader account) |
| Delete Team | Team Leader, Admin |
| Remove Member | Team Leader only |
| Leave Team | Any member (except leader) |
| View All Teams | Admin only |

## Closing vs. Deleting

**Close Team** (soft): sets `isActive` to `false`. The team document, members, and tasks are kept; closed teams can't be updated or joined (enforced in `firestore.rules`).

**Delete Team** (hard), leader or admin only:
1. The `teams/{teamId}` document is deleted
2. `teamId` is cleared on each member's user document (individual writes, so one failure doesn't block the rest)
3. The team is removed from the local Hive cache

Tasks that belonged to the team are not deleted.
