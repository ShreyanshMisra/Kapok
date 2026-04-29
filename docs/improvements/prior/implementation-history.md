# Kapok Implementation History

A compact, canonical record of all development sprints completed on the Kapok app. This document replaces the prior per-sprint summaries (`sprint-1-2-completed.md`, `sprint-3-4-progress.md`, `final-touches-completed.md`, `roadmap.md`, `kapok_fixes.md`) and the per-phase implementation files (`phase-1-2-implementation.md`, `phase-3-4-implementation.md`, `phase-5-6-implementation.md`, `phase-7-implementation.md`).

All 35 items from the Phase 1–7 "Kapok Fixes" spec, plus earlier sprint work and two post-Phase 6 fixes, are now complete.

---

## Earlier Sprints (Pre-Phase 1)

Foundational work captured in the previous sprint docs:

- **Sprint 1–2:** initial clean architecture scaffolding, BLoC wiring, Firestore/Hive offline-first plumbing, Mapbox integration, auth flows, teams and tasks CRUD.
- **Sprint 3–4:** onboarding, role selection, offline map bubble (~3 mile radius), sync service, settings, language (EN/ES) + theme providers, data export, analytics/crash opt-ins.
- **Final touches:** KapokLogo widget on all AppBars, first-login About landing, iOS app name set to "Kapok", category/date filters on tasks page, PriorityStars widget, map search via Mapbox Geocoding, role-based assignment filtering, 5-tab bottom nav with About as default.

---

## Phase 1 — Global UI Consistency

- **1.1** `KapokLogo` uses right/vertical padding so spacing matches the leading back arrow across all AppBars.
- **1.2** Curved bottom corners on every AppBar (global `appBarTheme` shape in light + dark); curved top corners on the bottom nav via `ClipRRect`. Signup and Forgot Password pages updated to inherit the theme blue AppBar.
- **1.3** Font consistency audit — app uses system default throughout; only legitimate uses of `fontFamily` are `monospace` in the map coordinate readout and icon-font rendering.
- **1.4** Tasks page filter chips made legible in dark mode (`theme.colorScheme.surface` / `primary` / `onSurface`, `withValues(alpha:)`).

## Phase 2 — Text & Content Changes

- **2.1** "disaster relief" → "disaster response" across localizations (EN/ES), `app_strings.dart`, `terms_of_service.dart`, onboarding slides, data export share subject, iOS location usage description, and `pubspec.yaml`.
- **2.2** About page "Kapok Icon" description rewritten ("Inspiration: The Living Tree …") in EN and ES.
- **2.3** "Digging Deeper: Tech Roots" description rewritten in EN and ES.
- **2.4** Map cache page title → "Maps Stored Offline Temporarily".
- **2.5** Technology section text cleaned up (removed "reliably", capitalized "Internet").
- **2.6** Legal section rewritten ("© 2006 A Fair Resolution, LLC …") in EN and ES.
- **2.7** Clear Cache dialog wording: "locally cached data" → "locally saved data".
- **2.8** Theme option user-facing label: "System" → "Default" (EN/ES).
- **2.9** App icon label is "Kapok" on iOS (`CFBundleName` + `CFBundleDisplayName`) and Android (`AndroidManifest.xml`).

## Phase 3 — About & Settings Structural Changes

- **3.1** "A Fair Resolution, LLC" section removed from the About page.
- **3.2** Key Features bullets render with a hanging indent (`_buildBulletSection`).
- **3.3** About page shows "App Version 1.0.0" + "Built with ❤️ for disaster response coordination." between Technology and Legal.
- **3.4** Notifications section removed from Settings.
- **3.5** Privacy section (Analytics / Crash Reporting toggles) removed from Settings; underlying `AnalyticsService` defaults still apply.
- **3.6** Feedback & Support section removed from Settings.
- **3.7** Tagline added to Settings → About subsection, between the version tile and the legal links.
- **3.8** About page as post-login landing — first-time logins route to `/about` with a Continue button; subsequent logins go straight to Home.

## Phase 4 — Feature Removals & Map

- **4.1** Due date / overdue UI removed from Tasks list, create task form, task detail view/edit, share text, and map preview sheet. `TaskModel.dueDate` + `isOverdue` preserved on the model to avoid Firestore/Hive migration.
- **4.2** All active map markers are blue (`AppColors.primary`, `#013576`); completed markers stay grey. Priority is shown via star count on the marker rather than pin color. Applied to web overlay markers, native Mapbox annotations, and the task detail pin painter.
- **4.3** Per-page help (`?`) overlays corrected: Task Detail page lost the incorrect "Swipe Actions" tip and gained a "Delete" tip; Create Task page lost the obsolete "Due Date" tip.

## Phase 5 — Feature Implementations & Bug Fixes

- **5.1** Share Team Code uses the native share sheet via `share_plus`; Copy Code copies via `Clipboard.setData()` with a blue confirmation snackbar.
- **5.2** Full-screen `edit_team_page.dart` replaces the placeholder Edit Team dialog; dispatches `UpdateTeamRequested`.
- **5.3** `removeMember` Firestore transaction fixed — team doc is now read via `transaction.get(teamRef)` instead of an out-of-transaction read.
- **5.4** Task edit bugs fixed:
  - Assigned-to dropdown rebuild loss → switched to `BlocListener` with cached members + `ValueKey`.
  - Double-pop / page freeze on save → dispatch a single event per save and guard with `_isSaving`.
  - Stale form state on re-entry → controllers explicitly reinitialized from `widget.task` on edit entry.
- **5.5** Spanish locale switching fixed by removing `ValueKey` from `MaterialApp` in `kapok_app.dart`; localization delegate's `shouldReload` handles in-place updates.
- **5.6** Team join confirmation snackbar verified against spec (blue `AppColors.primary`, 3-second auto-dismiss, "Successfully joined team …").

## Phase 6 — Permissions & Admin Page

- **6.1** Team members can only edit tasks assigned to them. Leaders and admins can edit any task. Enforced in the Task Detail page `canEdit` getter and at the repository layer via `canEditTask(userRole:)`; `EditTaskRequested` and the task bloc forward `userRole`.
- **6.2** `admin_permissions_page.dart` added under `features/profile/pages/`, routed at `/admin-permissions`, reachable from Settings → About → Administrator Permissions. Shows an **Action | Who Can Perform** DataTable.
- **6.3** Profile page gained a permissions DataTable with columns **Action | Team Member | Team Leader | Admin** (11 action rows, current role highlighted, horizontally scrollable, with a "Your Role" chip). New EN/ES localization keys added.

## Phase 7 — Documentation Reconciliation

- **7.1** Full audit of all 14 `docs/*.md` files against the current codebase produced a per-document findings list covering terminology, route tables, permissions wording, theme labels, map pin colors, due date UI removal, Settings section changes, new pages, and map/task detail behavior.
- **7.2** All 14 docs were updated surgically to match current behavior: "disaster response" wording; Default theme label; new routes (`/about`, `/analytics`, `/admin-permissions`); corrected task edit permissions; category field + filter documented; map marker colors + task detail pin documented; Settings simplified sections listed; Administrator Permissions page and Profile permissions table documented; pubspec description updated; user manual corrected (Edit Team via overflow menu, task edit perms, Sync instead of pull-to-refresh).

## Additional Post-Phase 6 Fixes

- **A.1 — Task detail map pin on mobile.** `task_detail_page.dart` now passes `tasks: [widget.task]` to `MapboxMapView` and uses `onMobileControllerReady` to center the map; a blue pin renders at the task location on Android/iOS.
- **A.2 — Sync button re-fetches from Firebase.** Settings → Sync now runs `SyncService.syncPendingChanges()` and then dispatches `LoadTasksRequested` + `LoadUserTeams`, so data is pulled back from the cloud even when the local sync queue is empty.

---

## Completion Summary

| Phase | Items | Count |
|-------|-------|-------|
| 1 — Global UI Consistency | 1.1–1.4 | 4 |
| 2 — Text & Content Changes | 2.1–2.9 | 9 |
| 3 — About & Settings Structural | 3.1–3.8 | 8 |
| 4 — Feature Removals & Map | 4.1–4.3 | 3 |
| 5 — Feature Implementations & Bugs | 5.1–5.6 | 6 |
| 6 — Permissions & Admin Page | 6.1–6.3 | 3 |
| 7 — Documentation Reconciliation | 7.1–7.2 | 2 |
| **Total** | | **35** |

Plus additional post-Phase 6 fixes A.1 (task detail map pin) and A.2 (sync re-fetch). All spec items are complete.

## Post-Phase 7 Fixes

- **B.1** Map page: filter-markers FAB repositioned above the global Create Task FAB (no longer overlaps).
- **B.2** Task edit mode: form fields now receive taps/keyboard and scroll works — embedded map hidden during edit and Confetti overlay wrapped in `IgnorePointer` so it no longer absorbs pointer events.
- **B.3** Tasks page: added a "date created" filter chip (Any / Past day / Past week / Custom range via `showDateRangePicker`).
- **B.4** Map cache page retitled "Maps Stored Offline" with a short description of what cached maps are and how to clear them.
- **B.5** Settings: Sync section/button removed; Administrator Permissions link removed from About and `admin_permissions_page.dart` + its route deleted.

## Team Management Hardening (2026-04-07)

### C.1 — Remove member permission hardening
- `removeMember()` in `team_repository.dart` now enforces server-side: actor must equal `team.leaderId`, member must exist in `memberIds`, and the leader cannot be removed via this path.
- Firestore transaction atomically `arrayRemove`s from `team.memberIds` and clears `users/{memberId}.teamId` via `FieldValue.delete()`.
- Hive cache updated after transaction success.
- `PermissionService.canRemoveMember()` rewritten: only the assigned `team.leaderId` may remove members — admin and global-`teamLeader` role no longer grant this right in other teams.

### C.2 — Admin hard delete
- `deleteTeam()` now issues `batch.delete(teamRef)` (hard delete) instead of the former `isActive: false` soft-delete.
- Batch write clears `teamId` from every member (including leader) via `FieldValue.delete()`.
- Hive cache mirrors the deletion and clears each member's cached `teamId`.
- Authorization: leader may delete own team; admin may delete any team (checked at repository layer and in `PermissionService.canDeleteTeam()`).
- `team_detail_page.dart` overflow menu now shows "Delete Team" for admins who are not the team leader.

### C.3 — Leadership transfer ("Make Team Leader")
- New `TransferLeadershipRequested` BLoC event and `LeadershipTransferred` BLoC state added.
- `TeamBloc` handles the event, dispatches `LoadTeamMembers` on success, and emits `LeadershipTransferred` for UI.
- `TeamRepository.transferLeadership()` added: verifies network, checks `currentLeaderId == team.leaderId` inside transaction, verifies new leader is in `memberIds` and has `userRole` containing `"leader"` (checked pre-transaction against Firestore), atomically updates `leaderId + updatedAt`, then saves updated team to Hive.
- `PermissionService.canTransferLeadership()` added: only the currently assigned leader may initiate.
- UI: "MAKE TEAM LEADER" button shown inside the expandable member card when the current user is team leader and the member has `userRole == teamLeader`. Confirmation dialog dispatches the event. `BlocListener` shows success snackbar on `LeadershipTransferred`.

### C.4 — Firestore rules alignment
- **users collection:** write rule extended — team leaders and admins may update only the `teamId` + `updatedAt` fields on other users (required for `removeMember` and `deleteTeam` flows that clear `teamId` of affected members).
- **teams collection:** new update condition allows the current `leaderId` to write only `leaderId + updatedAt` (leadership transfer), resolving the prior block on `leaderId` changes.

### Files changed
| File | Change |
|------|--------|
| `app/lib/data/repositories/team_repository.dart` | Hard delete, `removeMember` guard, `transferLeadership()` method |
| `app/lib/features/teams/bloc/team_event.dart` | `TransferLeadershipRequested` event |
| `app/lib/features/teams/bloc/team_state.dart` | `LeadershipTransferred` state |
| `app/lib/features/teams/bloc/team_bloc.dart` | Handler registration + `_onTransferLeadershipRequested` |
| `app/lib/features/teams/pages/team_detail_page.dart` | Admin delete in menu, `LeadershipTransferred` listener, "MAKE TEAM LEADER" button, `_showTransferLeadershipDialog()` |
| `app/lib/core/services/permission_service.dart` | `canRemoveMember` fix, `canTransferLeadership`, `canDeleteTeam` |
| `firebase/firestore.rules` | Users write rule + leadership transfer update condition |

### Tests added
`app/test/features/teams/team_permission_test.dart` — 14 model/permission-level tests covering:
- Assigned leader can remove member; non-assigned leader and admin cannot
- Leader cannot remove themselves
- Admin can delete any team; non-leader cannot
- Only assigned leader can initiate transfer
- Transfer succeeds only for in-team user with `teamLeader` role; rejected for outsider or wrong role
- Hard-delete member ID de-duplication logic
- `copyWith(leaderId:)` preserves old leader in `memberIds`

### Migration / security notes
- No Firestore data migration needed; the `isActive` field remains on existing team documents but is no longer set to `false` on delete (documents are simply removed).
- Firestore rules deployed to project `build-kapok` on 2026-04-07 via `npx firebase-tools deploy --only firestore:rules`.

## Team BLoC State Bug + Remove-Member Hardening (2026-04-07)

### Root cause of disappearing Teams list

After a successful remove-member operation, `_onRemoveMemberRequested` emitted `const TeamLoading()` (no teams preserved) then dispatched `LoadTeam(teamId)` which in turn emitted `TeamLoaded(teams: [singleTeam])`. When the user navigated back to `TeamsPage`, the BLoC state held only the one reloaded team (or empty members). `TeamsPage.didChangeDependencies` only triggered a reload for `TeamInitial` or empty `TeamLoaded` — not for empty `TeamLoading` or `TeamError` — so the page could stay blank.

### D.1 — BLoC state preservation (`team_bloc.dart`)

- `_onRemoveMemberRequested`: now emits `TeamLoading(teams: state.teams, members: state.members)` instead of `const TeamLoading()`. On success dispatches `LoadTeamMembers(teamId)` + `LoadUserTeams(userId)` instead of `LoadTeam(teamId)` alone. Error branch preserves `teams`/`members` in `TeamError`.
- `_onLoadTeam`: now emits `TeamLoading(teams: state.teams, ...)`, updates the single refreshed team **within** the existing list (replaces by index, or appends if new), and emits `TeamLoaded(teams: updatedTeams)` — never discards sibling teams. Error branch preserves list.
- Added missing `import '../../../data/models/team_model.dart'` to team_bloc.dart.

### D.2 — TeamsPage recovery (`teams_page.dart`)

- `didChangeDependencies` simplified: triggers `_loadTeams()` whenever `state.teams.isEmpty` (regardless of state subtype). This covers `TeamInitial`, empty `TeamLoaded`, empty `TeamLoading`, and empty `TeamError` — all previously stuck states.

### D.3 — Task unassignment on remove-member (`team_repository.dart`)

- `removeMember` now mirrors `leaveTeam`: pre-queries `tasks` by `teamId + assignedTo == memberId`, clears `assignedTo` inside the same transaction, and refreshes Hive cache from Firestore for each affected task (avoids `copyWith` null-out bug in `TaskModel`).
- Added `import '../models/task_model.dart'` to team_repository.dart.

### D.4 — Firestore rules deployed

Rules compiled without errors and deployed to `build-kapok`. The updated rules (from C.4 above) allow:
- Team leaders/admins to clear `teamId + updatedAt` on other users (removes-member, delete-team flows).
- Current leader to update only `leaderId + updatedAt` on a team (leadership transfer).
- Tasks `update` rule already covered unassignment by `teamLeader`/`admin` — no change needed.

### Files changed

| File | Change |
|------|--------|
| `app/lib/features/teams/bloc/team_bloc.dart` | Preserve state in removeMember + loadTeam handlers; add TeamModel import |
| `app/lib/features/teams/pages/teams_page.dart` | Broadened didChangeDependencies reload condition |
| `app/lib/data/repositories/team_repository.dart` | Task unassignment in removeMember; TaskModel import |
| `firebase/firestore.rules` | Deployed to build-kapok (rules unchanged from C.4) |

### Test results

33/33 tests pass (`flutter test test/features/teams/`). `flutter analyze` on changed files: 0 errors, pre-existing info warnings only.

## Navigation Shell + Leadership Transfer UX (2026-04-07)

### E.1 — Create team no longer breaks bottom nav (`create_team_page.dart`)

Root cause: `_TeamCreatedDialog` OK button called `pushNamedAndRemoveUntil('/teams', …)`, which pushed the **standalone** `TeamsPage` route (no `HomePage` shell → no bottom nav).

Fix: replaced with `Navigator.popUntil((route) => route.settings.name == AppRouter.home || route.isFirst)`. This unwinds back to the already-live `HomePage` without pushing a new route, so the `IndexedStack` and bottom nav remain intact.

Audit: `join_team_page.dart` was already correct (`pop()` / `pushNamedAndRemoveUntil('/home', …)`). No other file pushes `/teams` as a post-auth destination.

### E.2 — Leadership transfer discoverability (`team_detail_page.dart`)

Three additions:

1. **AppBar overflow menu** — "Transfer Leadership…" item appears for the current team leader whenever at least one eligible candidate (Team Leader account type, in memberIds, not current leader) is loaded. Tapping opens `_showTransferLeadershipPickerDialog`, a list of eligible members to choose from, then hands off to the existing confirmation dialog.

2. **Members section hint banner** — a subtle tinted row reading "Transfer Leadership: tap ⋮ menu above or expand a member below." shown only to the current leader when eligible candidates exist. Disappears otherwise.

3. **In-card button** — existing "MAKE TEAM LEADER" button inside `ExpansionTile` now uses `AppLocalizations.makeTeamLeader` and a `swap_horiz` icon for consistency with the menu item.

All dialog strings (title, body, confirm button, success snackbar) now use `AppLocalizations` keys instead of hard-coded English.

### E.3 — Localization (`app_localizations.dart`)

New keys added in EN + ES: `makeTeamLeader`, `transferLeadership`, `confirmTransferLeadership`, `transferLeadershipSuccess`, `eligibleForLeadershipTransfer`.

### Files changed

| File | Change |
|------|--------|
| `app/lib/features/teams/pages/create_team_page.dart` | `pushNamedAndRemoveUntil('/teams')` → `popUntil('/home')` |
| `app/lib/features/teams/pages/team_detail_page.dart` | Overflow menu item, discoverability hint, picker dialog, localized strings |
| `app/lib/core/localization/app_localizations.dart` | 5 new leadership-transfer keys in EN + ES |

### Test / analyze results

33/33 tests pass. `flutter analyze` on changed files: 0 errors.
