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
