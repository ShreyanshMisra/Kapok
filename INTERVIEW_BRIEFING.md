# Kapok — Interview Briefing

Prepared from a direct read of the repository (source, Firestore/Storage rules, CI config,
docs, `pubspec.yaml`, git history) on 2026-11-02. File paths are repo-relative to `app/` unless
otherwise noted (i.e. `lib/...` means `app/lib/...`).

---

## 1. One-Paragraph Summary

Kapok is a cross-platform mobile app (iOS/Android, plus a web build for QA) that helps
volunteer disaster-response organizations coordinate field operations. A **Team Leader**
creates a team and shares a 6-character join code; **Team Members** join with that code;
**Admins** oversee everything. Any team member can create location-based **Tasks**
(a shelter needing supplies, a downed tree needing clearing, etc.) by dropping a pin on a
Mapbox map, assigning a priority/category, and optionally assigning it to a specific
teammate. Tasks and teams sync through Firebase (Auth + Firestore), with a Hive-based local
cache so the app keeps working — and queues writes — when the device has no connectivity,
which matters a lot for disaster zones with unreliable signal. It was built for **A Fair
Resolution, LLC** (Dr. Leah Wing, UMass Amherst) for eventual handoff to the RN Response
Network, by BUILD UMass, a student dev team, across several semesters.

---

## 2. Tech Stack

| Layer | Technology | Version (from `pubspec.yaml`) |
|---|---|---|
| Language/Framework | Dart / Flutter | Dart SDK `^3.9.2`, Flutter 3.35.4 (pinned in CI and docs) |
| State management | `flutter_bloc` (BLoC pattern) | `^9.1.1` |
| State mgmt (UI prefs) | `provider` (`ChangeNotifier`) | `^6.1.5+1` |
| DI / service locator | `get_it` | `^8.3.0` |
| Backend auth | Firebase Auth | `firebase_auth '>=6.1.1 <6.3.0'` |
| Backend database | Cloud Firestore | `cloud_firestore '>=6.1.3 <6.2.0'` |
| Backend storage | Firebase Storage | `firebase_storage '>=13.1.0 <13.2.0'` (declared, but **storage rules deny all reads/writes** — see §7) |
| Crash/monitoring | Firebase Crashlytics | `'>=5.0.8 <5.1.0'` |
| Analytics | Firebase Analytics | `'>=12.0.3 <12.2.0'` |
| Local/offline DB | Hive + `hive_flutter` | `^2.2.3` / `^1.1.0` |
| Maps | Mapbox Maps SDK (mobile native), Mapbox GL JS v3.4.0 (web, injected at runtime) | `mapbox_maps_flutter ^2.31.1` |
| Geocoding/Location | `geocoding ^4.0.0`, `geolocator ^14.0.2` | — |
| Connectivity | `connectivity_plus ^6.1.5` | — |
| Localization | `flutter_localizations` + `intl ^0.20.2` (English + Spanish, hand-written maps, not `.arb`) | — |
| JSON codegen | `json_annotation`/`json_serializable` + `build_runner` | `^4.9.0` / `^6.11.2` |
| Charts | `fl_chart ^0.69.2` (Analytics page, not linked from UI) | — |
| Misc | `share_plus`, `badges`, `confetti`, `pointer_interceptor` (web click-through fix), `translator` (unused), `flutter_dotenv` | — |

**NOT FOUND IN CODE:** no server/cloud-functions backend — there are no Cloud Functions in
the repo (`firebase.json` only configures Firestore rules/indexes, Storage rules, and
emulators; no `functions` directory). All backend logic is Firestore security rules plus
client-side Dart. No REST/GraphQL API of Kapok's own exists — the client talks directly to
Firebase and Mapbox SDKs.

---

## 3. Architecture & Data Flow

### Layers (`docs/03_architecture.md`, confirmed in code)

```
Presentation  (Pages/Widgets)  →  Business Logic (BLoCs, Providers)  →  Data (Repositories)
                                                                            │
                                                     ┌──────────────────────┼──────────────────────┐
                                                     ▼                      ▼                      ▼
                                                   Hive                 Firestore               Mapbox
                                                (local cache)        (remote source of truth)   (tiles/geocoding)
```

Four BLoCs — `AuthBloc`, `TaskBloc`, `TeamBloc`, `MapBloc` — are each created **once** at the
app root via `MultiBlocProvider` in `lib/app/kapok_app.dart`, so every screen shares the same
instances (not re-created per page). Dependencies are wired through a `GetIt` service locator
in `lib/injection_container.dart`: services and data sources are lazy singletons, repositories
are lazy singletons built from those sources, and BLoCs are factories that are nonetheless
only ever resolved once (at the root).

### Concrete step-by-step: creating a task

1. User taps **+** → `CreateTaskPage` (`lib/features/tasks/pages/create_task_page.dart`) opens
   a full-screen Mapbox map.
2. User taps the map (reverse-geocoded via `GeocodeService.reverseGeocode`,
   `lib/core/services/geocode_service.dart`) or types an address and taps search
   (forward-geocoded via `GeocodeService.forwardGeocode`).
3. User fills the form sheet (title, description, team, assignee, category, priority) and
   submits, dispatching `CreateTaskRequested` to `TaskBloc` (`lib/features/tasks/bloc/task_bloc.dart`).
4. `TaskBloc` calls `TaskRepository.createTask()` (`lib/data/repositories/task_repository.dart`).
5. `TaskRepository` **always writes to Hive first** (`HiveSource.saveTask`), then checks
   `NetworkChecker.isConnected()`.
6. If online: it opens a Firestore transaction that (a) reads the team doc, (b) updates the
   team's `taskIds` array, (c) writes the new `tasks/{taskId}` document — in that order,
   because Firestore requires all transaction reads before any writes.
7. If the transaction fails, or the device is offline, the create is instead queued in the
   Hive `sync` box (`HiveSource.queueForSync`) with operation `create_task`.
8. `TaskBloc` emits `TaskCreated`; the UI pops back to the map/tasks list, and `MapBloc`
   reloads markers because it listens for `TaskCreated`/`TaskUpdated`/`TaskDeleted`.
9. Whenever connectivity returns, `SyncService` (`lib/core/services/sync_service.dart`),
   which subscribes to `connectivity_plus`, replays everything in the Hive sync queue against
   Firestore.

### App startup

```
main.dart
  → load .env (Mapbox token) → validate config
  → Firebase.initializeApp()
  → wire Crashlytics error handlers (iOS/Android only — no web SDK support)
  → injection_container.initializeDependencies() + initializeCoreServices()
     (Firebase + Hive init in parallel, then Theme/OfflineMapCache/RegionRepo in parallel,
      then SyncService last since it needs Hive)
  → AnalyticsService.initialize()
  → runApp(SplashWrapper)
     → SplashScreen (~500ms min)
     → OnboardingPage (first launch only)
     → AboutPage (first-ever login only)
     → KapokApp (BLoC providers + MaterialApp)
```

---

## 4. Back-End Details

There is no custom server; "back end" here means **Firebase** (Firestore + Auth) accessed
directly from the Flutter client, governed by Firestore Security Rules.

### "Endpoints"

Kapok has no REST/HTTP API of its own. Instead there are Firestore collections acting as the
data boundary, each read/written directly by the Dart SDK from `lib/data/sources/firebase_source.dart`:

| Collection | Typical operations | Source methods |
|---|---|---|
| `users/{userId}` | create, get, update (no delete except by owner via `deleteAccount`) | `FirebaseSource.createUser/getUser/updateUser`, `deleteAccount` |
| `teams/{teamId}` | create, get, get-by-code, update, delete, query by `memberIds arrayContains` / `leaderId` | `FirebaseSource` + `TeamRepository` (transactions for join/leave/remove/transfer) |
| `tasks/{taskId}` | create, get, update, delete, stream, query by `teamId`/`assignedTo`/`createdBy` | `FirebaseSource` + `TaskRepository` (transactions for create/delete) |
| `mapSnapshots/{userId}` | write only (one doc per user) | `FirebaseMapSnapshotSource` |

External "endpoints" actually used: **Mapbox Geocoding API** (via `GeocodeService`/
`MapboxRemoteDataSource`) and the **Mapbox tile/style APIs** for offline caching.

### Storage / data model

See `lib/data/models/{user,task,team,offline_map_region}_model.dart`. Summary:

- **`UserModel`**: `id, name, email, userRole (enum: teamLeader|teamMember|admin), role (free-text specialty, e.g. "Medical"), teamId?, createdAt, updatedAt, lastActiveAt?`.
- **`TaskModel`**: `id, title (3–100 chars), description? (≤500 chars), createdBy, assignedTo?, teamId, geoLocation (GeoPoint), address?, status (pending|inProgress|completed), priority (low|medium|high), category (enum, default other), dueDate? (stored, not shown in UI), createdAt, updatedAt, completedAt?, statusHistory (list of {status, changedBy, changedAt, previousStatus})`.
- **`TeamModel`**: `id, teamName, leaderId, teamCode (6-char), memberIds[], taskIds[], description? (≤200 chars), createdAt, updatedAt, isActive (soft-delete flag)`.
- Hive stores the same shapes as serialized maps in boxes: `users`, `teams`, `tasks`,
  `settings`, `sync` (`lib/core/services/hive_service.dart`).

### Authentication

Firebase Auth, email/password only (no OAuth/social login in code).

- **Sign up** (`lib/features/auth/pages/signup_page.dart` → `AuthBloc` →
  `AuthRepository.createUserWithEmailAndPassword`): creates the Firebase Auth user, then
  writes a `users/{uid}` Firestore document with `userRole` taken **directly from a dropdown
  the signer-upper fills in themselves** — see §4 Authorization below, this matters.
- **Sign in**: `AuthRepository.signInWithEmailAndPassword` → Firestore read of the profile →
  cached to Hive → `AuthAuthenticated` emitted. If the Firestore doc is missing, a temporary
  local-only `UserModel` is created to route the user through onboarding.
- **Session/tokens**: entirely delegated to the Firebase Auth SDK (it manages the ID
  token/refresh token under the hood: `FirebaseAuth.instance`); Kapok does not touch tokens
  directly. `AuthRepository.authStateChanges` (a `Stream<User?>`) drives the app's logged-in/out
  state in `kapok_app.dart`.
- **Password reset**: `sendPasswordResetEmail` → Firebase's built-in email flow.
- **Account deletion** (`FirebaseSource.deleteAccount`, `lib/data/sources/firebase_source.dart:663`):
  requires a sign-in within the last 5 minutes (else Firebase Auth throws
  `requires-recent-login`, checked **before** touching any data); refuses if the user leads any
  team with `isActive != false`; then in one Firestore `batch()`: anonymizes `createdBy`/
  `assignedTo` on the user's tasks to `"deleted_user"`, removes them from `memberIds` of teams
  they're in (except closed teams they led, left untouched), deletes `users/{uid}`; then
  deletes the Firebase Auth user and clears the Hive cache.

### Authorization / Role-Based Access — read this section carefully for interview purposes

**Three roles** (`lib/core/enums/user_role.dart`): `teamLeader`, `teamMember`, `admin`.
Permission logic is implemented in **two places that do not agree in strictness**:

1. **Client-side, UI-only**: `PermissionService` (`lib/core/services/permission_service.dart`)
   — 15 pure functions like `canEditTask`, `canDeleteTeam`, `canRemoveMember` that gate which
   buttons/menus render. This is advisory only; it runs on the user's own device and can be
   bypassed by anyone who talks to Firestore directly (e.g. via the Firebase SDK in a modified
   build, or a REST call with a stolen ID token).
2. **Server-side, actually enforced**: Firestore Security Rules
   (`firebase/firestore.rules`). This is the real boundary. Key clauses:

```js
match /users/{userId} {
  allow read: if request.auth != null;
  allow write: if request.auth.uid == userId ||
    (/* leader/admin may clear teamId+updatedAt on OTHER users, for removeMember/deleteTeam */
     request.resource.data.diff(resource.data).affectedKeys().hasOnly(['teamId', 'updatedAt']) &&
     ... (acting user is teamLeader/admin) ...);
}
```

```js
match /tasks/{taskId} {
  allow update: if request.auth != null && (
    resource.data.createdBy == request.auth.uid ||
    resource.data.assignedTo == request.auth.uid ||
    (/* acting user's own doc says teamLeader or admin */)
  );
}
```

- **Teams**: create requires only `request.auth != null` (any authenticated user — the rule
  does not check `userRole`, so Firestore itself does not stop a `teamMember` from creating a
  team; `PermissionService.canCreateTeam` is the only thing that does, client-side only).
  Update has several OR'd branches: soft-close by leader/admin, general leader/admin updates
  (blocked from touching `leaderId`/`teamCode`), self-join (user adds only themselves to
  `memberIds`), self-leave, and task-creation (`taskIds` bump). Hard delete: leader or admin
  only.
- **Tasks**: read requires admin, task creator, or team member/leader of `task.teamId`.
  Create requires `createdBy == auth.uid` and a non-null `teamId`; **team membership itself is
  checked only in application code (`TaskRepository.createTask`), not by the rule** — the rule
  comment explicitly says this is "simplified...to avoid reading team document in transaction
  context." Update/delete: creator, assignee, team leader, or admin.
- **`mapSnapshots/{userId}`**: owner-only read/write.

**Permission matrix** (from `docs/05_features_tasks.md` / `docs/06_features_teams.md`,
cross-checked against the rules and `PermissionService`):

| Action | Who (intended) | Actually enforced where |
|---|---|---|
| Create team | Team Leader, Admin | UI only (`PermissionService`) — **rule allows any authed user** |
| Create task | Any team member | App code checks membership before the transaction; rule does not |
| Edit task | Assignee, team leader, admin | Rule enforces this |
| Delete task | Creator, team leader, admin | Rule enforces this |
| Remove team member | Team leader only (of that specific team) | Rule enforces leader-of-this-team check |
| Transfer leadership | Current leader, to a `teamLeader`-typed member | **Application code only** (`TeamRepository.transferLeadership`) — the Firestore rule's transfer branch checks the *new* leader is in `memberIds` and is a `teamLeader`/`TeamLeader`/`team_leader` role via `get()`, so this one *is* also rule-enforced |
| Delete account | Any user, with 5-min-fresh session, not leading an active team | App code (`FirebaseSource.deleteAccount`) — rule-side, a user can already write/delete their own doc, so this is a client-side safety/UX gate, not a hard security boundary |

### Can a user change their own role or permissions? — Yes, two ways, confirmed in code

1. **At signup, directly**: `SignupPage` presents an **"Account type" dropdown with Team
   Member, Team Leader, and Admin as equal, unguarded options** (`docs/04_features_authentication.md`
   confirms the UI; `AuthRepository.createUserWithEmailAndPassword` takes `accountType` as a
   plain string parameter and writes it straight into the new `users/{uid}` doc via
   `FirebaseSource.createUser`). **Anyone can sign up and pick "Admin."** There is no
   invitation code, allow-list, email-domain check, or server-side validation of who may
   become an admin.
2. **After the fact, via `RoleSelectionPage`** (`lib/features/auth/pages/role_selection_page.dart`):
   this page is shown whenever `AuthBloc` computes `needsOnboarding = user.role.isEmpty &&
   user.userRole != admin` (`lib/features/auth/bloc/auth_bloc.dart:69`) — i.e. whenever the
   specialty field is unset (true for any locally-created "temporary" onboarding user). Tapping
   any of the three role cards calls `firebaseSource.updateUser()` with
   `currentUser.copyWith(userRole: selectedRole, ...)` — **the user writes their own `userRole`
   to Firestore directly**, with no role-transition check (nothing stops `teamMember` →
   `admin`).
3. **The Firestore rule itself has no field-level restriction on self-writes**:
   `allow write: if request.auth.uid == userId || (...)` — the owner branch is unconditional.
   Even without the two app-level paths above, any signed-in user could write
   `{"userRole": "admin"}` to their own `users/{uid}` document with a raw Firestore SDK/REST
   call and the rule would allow it.

**This is the single most important security/permission finding in the codebase** — see §7.
`UserRole.fromString` (`lib/core/enums/user_role.dart`) is also lenient: any string containing
`"admin"` (case-insensitive) parses to `UserRole.admin`.

---

## 5. Reliability & Failure Handling

- **Custom exceptions** (`lib/core/error/exceptions.dart`): `AuthException`, `NetworkException`,
  `DatabaseException`, `LocationException`, `ValidationException`, `PermissionException`,
  `CacheException`, `TeamException`, `TaskException`, `SyncException` — all extend a common
  `AppException` with `message`, `code?`, `originalError`. Flow: data sources throw → repos
  catch/re-wrap → BLoCs catch and emit `*Error` states → UI shows a SnackBar.
- **Retries**: `SyncService._processSyncItem` retries failed queue items with **exponential
  backoff: 1s, 5s, 30s, 5min, 5min**, capped at 5 attempts, then gives up silently (logs only).
  `TaskRepository.createTask` separately retries the Firestore read-back (not the write) up to
  3 times with linear 100ms/200ms/300ms delays, purely to populate server-generated fields in
  the return value — if all 3 fail, it just returns the original client-built object (the
  Firestore write itself already succeeded via the transaction).
- **Partial-failure / halfway-step handling**:
  - *Task create/delete* use a single Firestore **transaction** (team `taskIds` update + task
    doc write/delete together), so these two writes are atomic — a failure rolls back both,
    and the operation is queued for sync instead (`delete_task_and_update_team` for deletes,
    `create_task` for creates).
  - *Account deletion* uses a Firestore **batch** for the multi-document anonymization/removal
    step, then deletes the Firebase Auth user as a **separate, non-atomic** call afterward.
    If the batch succeeds but the Auth deletion fails, the user ends up with no Firestore
    profile but a still-working login — a real halfway-state gap (not told in the code), though
    the recent-sign-in check (§4) at least prevents the Auth call from failing due to a stale
    session, reducing (not eliminating) the odds of landing in it.
  - *`TeamRepository.deleteTeam`* deletes the team doc first, then loops writes clearing
    `teamId` on each member individually (not batched) specifically so "one failure doesn't
    block the rest" (code comment) — a crash mid-loop leaves some members still pointing at a
    deleted `teamId`, a real orphaned-reference risk the code tolerates by design for
    availability.
  - *`TeamRepository.removeMember`*: the team-doc update + task-unassignment run inside one
    transaction, but clearing the removed member's own `teamId` is a **separate** call outside
    the transaction (comment: current rules require the acting user to own that doc, so it's
    moved out so the "core removal" still works pre-rule-deploy) — another intentional,
    documented partial-consistency compromise.
- **Idempotency / retry-creates-duplicates risk**: `TaskModel`/`TeamModel` IDs are generated
  client-side as `task_${DateTime.now().millisecondsSinceEpoch}` /
  `team_${DateTime.now().millisecondsSinceEpoch}` **once**, then reused on every retry/queue
  replay (`Firestore.doc(task.id).set(...)`), so a retried create overwrites the same document
  rather than creating a duplicate — **creates are effectively idempotent by construction**
  because `set()` on a fixed ID is idempotent. There is no idempotency key beyond the ID itself,
  and two tasks created in the same millisecond (not observed as handled) would collide, though
  this is extremely unlikely in practice for a human-paced UI.
- **Single points of failure**: Firebase project `build-kapok` itself (no multi-region/backup
  story described anywhere in the repo); Mapbox access token/API availability for all new
  geocoding/tile downloads (offline cache only covers previously downloaded regions). There is
  no Cloud Functions layer or server, so there's also no backend redundancy to speak of — it's
  a 100%-client-driven architecture sitting directly on Firebase's own availability guarantees.
- **Offline/sync conflict resolution**: this is **last-write-wins, with no version vector or
  conflict detection**. `TaskRepository`/`TeamRepository` writes always use `updatedAt:
  DateTime.now()` and `Firestore.update()`/`set()` — nothing reads-before-overwriting to detect
  a newer remote version except inside the join/leave/create-code transactions (which re-read
  fresh state specifically to avoid race conditions on `memberIds`/code uniqueness). Two users
  editing the **same task's title offline simultaneously** will, on both reconnecting, each
  push their full local copy; whichever `SyncService` run commits last to Firestore wins, and
  the other user's edit is silently discarded — **no merge, no conflict UI, no warning**. This
  is a genuine, confirmed gap in the sync design.
- **Monitoring/logging**: `Logger` (`lib/core/utils/logger.dart`) — category-tagged
  (`Logger.task`, `Logger.team`, `Logger.auth`, `Logger.sync`, `Logger.firebase`, `Logger.network`),
  **prints only in debug builds** (stripped from release console output per `CHANGELOG.md`).
  Crashlytics captures uncaught Flutter/platform errors on iOS/Android only (no web SDK
  support — web keeps Flutter's default error handlers, per `main.dart`). `AnalyticsService`
  has helper methods for custom events (`logTaskCreated`, `logTeamJoined`, etc.) but
  **none of them are actually called anywhere in the UI** (`docs/10_services.md` confirms this
  explicitly) — only Firebase's automatic screen/session analytics fire. There are no health
  checks or uptime monitoring (none needed/applicable — no server to monitor).

---

## 6. Project-Specific Checks — Firebase

- **Firestore security rules**: see §4 for the full breakdown; the standout issue is the
  unrestricted owner-write on `users/{userId}` (§4, §7).
- **Custom claims**: **NOT FOUND IN CODE.** Roles live as a plain `userRole` string field on
  the Firestore document, not as a Firebase Auth custom claim. This is architecturally
  significant: custom claims are set server-side (via Admin SDK, typically in a Cloud
  Function) and are tamper-proof from the client; a plain Firestore field writable by the
  owner is not. This app has no Cloud Functions at all, so there's no code that *could* set
  claims even if the design were changed to use them.
- **Offline persistence**: Kapok does **not** use Firestore's built-in offline persistence
  cache (`Firestore.instance.settings.persistenceEnabled` — not found/configured anywhere).
  Offline support is entirely hand-rolled via **Hive** (`HiveSource`/`HiveService`) plus the
  manual `SyncService` queue described in §3/§5 — a deliberate architectural choice, not an
  oversight, since it also needs to cache non-Firestore data (Mapbox tiles).
- **Firebase config / project**: project id `build-kapok`, Firestore `location: nam7`
  (`firebase.json`). `GoogleService-Info.plist` / `google-services.json` / `key.properties`
  are all gitignored (developer re-downloads their own from the Firebase Console). `firebase_options.dart`
  — **generated by FlutterFire CLI and committed to the repo** — contains Firebase Web/iOS/Android
  **`apiKey` values in plaintext** (e.g. `AIzaSyCqzy...`). This is **not a secret leak** in the
  traditional sense: Firebase client API keys are designed to be public/embedded in shipped
  apps and only identify the Firebase project — real access control is the Firestore rules,
  not the key. It's still worth being able to explain this distinction cleanly in an interview
  (see §7).
- **Indexes**: `firebase/firestore.indexes.json` defines composite indexes for
  `teams(isActive, createdAt)`, `tasks(teamId, createdAt)`, `tasks(teamId, status, createdAt)`,
  and `tasks(createdAt)` — supporting the team-scoped and status-filtered task queries used by
  `TasksPage`/`TeamDetailPage`.
- **Storage rules deny everything**: `firebase/storage.rules` is `allow read, write: if false;`
  for all paths — Firebase Storage is a declared dependency (`firebase_storage` package) but is
  **not actually used for anything** (no profile picture upload, per `docs/12_development_notes.md`'s
  "Feature Limitations" table — "Profile Pictures: Upload not implemented").

---

## 7. Security Review

Findings, ranked by how likely an interviewer would probe them:

1. **Critical — unauthenticated privilege escalation to Admin.** Covered in depth in §4.
   Any signed-up user can either (a) pick "Admin" from the signup dropdown directly, or
   (b) later write `userRole: "admin"` to their own `users/{uid}` Firestore document, because
   the security rule's owner-write branch (`request.auth.uid == userId`) has no field
   restriction. This defeats the entire role system — an attacker with any account, or anyone
   who just signs up, can grant themselves admin and then read/write all teams and tasks
   (admin bypasses team-scoping everywhere in the rules and in `PermissionService`). **Fix**:
   move `userRole` assignment/changes to a Cloud Function (Admin SDK) that validates the
   request against an allow-list/invite flow and sets it via Firebase custom claims (or at
   minimum, restrict the Firestore rule so `userRole` is excluded from the owner's writable
   field set, and only a Cloud Function with elevated privilege can set it).
2. **Team creation isn't actually role-gated server-side.** The `teams` create rule only
   checks `request.auth != null` — a `teamMember` account can create a team even though the
   UI hides the button; this is a lower-severity version of finding #1 but compounds it.
3. **Firestore rules contain significant duplicated/legacy branching** (`userRole == "admin"`
   OR `"Admin"` OR `accountType == "team_leader"` checked in parallel throughout) — a sign of
   an in-flight migration from an older `accountType` field to `userRole` that was never fully
   cleaned up; more surface area for a rule-logic mistake. `docs/12_development_notes.md`
   independently confirms the repo's rules have, in the past, drifted from the deployed
   console rules and had to be manually diffed/reconciled before each deploy — a risky, manual
   deployment process with no rules tests committed to CI (no `firebase emulators:exec` test
   step in `.github/workflows/ci.yml`).
4. **Firebase Web API keys committed in `firebase_options.dart`.** As discussed in §6, this is
   standard/expected for a Firebase client app (these keys are not bearer secrets — project
   identification only, actual access control is the rules), but it's worth being able to
   explain *why* it's not a vulnerability rather than reflexively calling it one, and also
   worth noting the inverse: because the key is harmless to expose, the real security
   boundary is 100% the rules file, which raises the stakes on finding #1.
5. **No rate limiting/abuse controls anywhere in the app layer** for sign-up, sign-in, team-code
   guessing, etc. — Firebase Auth itself throttles repeated failed sign-ins
   (`too-many-requests`, handled/mapped in `AuthRepository`/`FirebaseSource`), but team join
   codes are 6-char alphanumeric (~2.2 billion combinations) generated via `Random.secure()`,
   checked for uniqueness — no evidence of brute-force protection on the `joinTeam` Firestore
   query path itself, though guessing a valid code only grants team membership, not elevated
   privilege.
6. **Input validation**: present but client-side only (`Validators` class,
   `lib/core/utils/validators.dart`) — email regex, 6-char min password, string length bounds
   on task/team names and descriptions. None of this is re-validated by Firestore rules (rules
   check *who* can write, not *what* they write, with the narrow exception of the `affectedKeys()`
   field-allow-lists seen on team/user updates). A malicious client could write an
   8000-character task title directly via the SDK; nothing server-side stops it.
7. **File upload risk**: effectively none — Storage rules deny everything and no upload code
   path exists (see §6). If profile pictures are added later, this is worth flagging as "needs
   its own rules + size/type validation," since the pattern isn't established anywhere in the
   codebase yet.
8. **Injection risks**: low. All Firestore access goes through the typed SDK's query builder
   (`.where(...)`, `.doc(...)`), not string-concatenated queries, so there's no SQL/NoSQL
   injection surface in the traditional sense. No raw HTML rendering of user content was found
   (Flutter widgets escape text by default).
9. **Data privacy for sensitive data**: task descriptions/addresses are real-world physical
   locations tied to disaster-response operations — the app explicitly warns users in the
   Create Task UI not to enter any person's name (`docs/05_features_tasks.md`: *"Do not enter
   any person's name in the task"* PII reminder), which is a sensible, low-cost mitigation
   given there's no encryption-at-rest beyond what Firestore provides by default, and no
   field-level encryption anywhere in the code. The `CHANGELOG.md` also notes an inaccurate
   "end-to-end encrypted" claim was found and removed from the About page — i.e., the team
   caught and corrected their own over-claim, which is worth mentioning if asked about data
   privacy honesty.

---

## 8. My Contribution (Dia Sutaria / `athena.parthenos10621@gmail.com`)

`git log --author` shows **2 commits** out of 148 total in the repo's history (vs. 103 by the
project lead and 14–11 by two other core contributors) — a small, targeted contribution, both
from the same session on 2025-11-15:

1. **`4dde485` — "Created TOS pop-up"** (`app/lib/features/auth/pages/signup_page.dart`, +126/-1).
   Added a Terms-of-Service acceptance gate to the sign-up flow: a `_tosAgreed` boolean that
   disables the Sign Up button until accepted; a "View Terms of Service" link that opens a
   `StatefulBuilder`-driven `AlertDialog` with a checkbox ("I have read and agree..."); the
   dialog only lets the user confirm once the checkbox is checked, after which it shows a
   confirmation SnackBar and unlocks the Sign Up button; `_handleSignUp` also bails out with
   its own SnackBar if someone manages to submit without agreeing. At the time of this commit
   the dialog's terms text was a placeholder ("Need to add terms and conditions"); the full
   legal Terms of Service/Privacy Policy text was added later (by other contributors, per
   `CHANGELOG.md`) in `lib/core/constants/terms_of_service.dart`, surfaced today via
   `LegalDocumentPage` from Settings. **This flow is still live in the current codebase** —
   `signup_page.dart` today still contains `_tosAgreed`, `_showTermsOfServiceDialog`, and the
   gated button exactly as added in this commit.
2. **`4a8f95e` — "Update about page"** (`app/lib/app/about_page.dart`, +4/-4). A copy/branding
   fix: replaced three mentions of "National Center for Technology and Dispute Resolution"
   with "A Fair Resolution, LLC" in the About page's organization, contact, and legal sections
   — correcting the credited sponsoring organization shown to end users.

**Honest framing for the interview**: this was a small, scoped UI contribution (consent-gating
pattern + content correction) on a large team project — good to be able to speak to clearly and
not oversell, while being ready to speak knowledgeably about the rest of the system since you
did the deep read for this briefing.

---

## 9. Weaknesses & Improvements

1. **Self-assignable admin role (§4, §7 finding #1).** The single biggest weakness. Fix:
   server-side role assignment via a Cloud Function + Firebase custom claims, with an
   allow-list or invite-code gate for who can become `admin`/`teamLeader`; Firestore rules
   should then check `request.auth.token.role` (a custom claim) instead of a client-writable
   document field.
2. **Last-write-wins sync with no conflict detection (§5).** At even moderate concurrent usage
   (two medics editing the same task from two phones with spotty signal — a very plausible
   disaster-response scenario), edits silently overwrite each other. Fix: add an `updatedAt`
   version check before overwrite (optimistic concurrency), or move to field-level merges
   where only the changed field is written to Firestore (`update()` instead of full-document
   `set()`/`copyWith()`+`update()`), reducing the blast radius of a lost write.
3. **No automated tests for Firestore security rules.** The rules are the actual authorization
   boundary (§4), yet CI (`.github/workflows/ci.yml`) only runs `flutter analyze` + `flutter
   test` — no `firebase emulators:exec` rules-unit-test step. `docs/12_development_notes.md`
   even documents a manual, error-prone "diff the live console rules against the repo file
   before every deploy" process. Fix: add the Firebase Rules Unit Testing library (`@firebase/rules-unit-testing`)
   with a small Node test suite run in CI against the emulator, covering at minimum "can a
   `teamMember` write their own `userRole`" and "can a non-member read/write someone else's task."
4. **Scalability of the admin "load everything" path.** `TaskRepository._getAllTasks()` /
   `TeamRepository._getAllTeams()` pull the *entire* `tasks`/`teams` collections for any admin
   user (with only a hard `limit(1000)` on `getAllTasks`), with no pagination. At 10x current
   usage (more teams, more admins), this becomes a real cost/latency/memory problem on both the
   client (building huge in-memory lists) and Firestore billing (full collection scans on every
   admin session). Fix: paginate with `startAfter()`/`limit()`, or better, give admins a
   dashboard with server-aggregated counts instead of raw full-collection fetches, and consider
   a Cloud Function to maintain denormalized summary documents.
5. **No backend beyond Firebase + fully client-driven business logic** means every rule change,
   every new validation, and every migration must ship as a client app update (App
   Store/Play review latency) rather than an instant server deploy — the `accountType` →
   `userRole` migration debt visible throughout the models and rules (§7 finding #3) is a
   direct symptom of this. Fix: introduce a thin Cloud Functions layer for anything
   security-sensitive or that needs instant rollout (role changes, server-validated writes,
   scheduled cleanup of orphaned data from the partial-failure cases in §5).

(Additional, lower-priority items an interviewer might probe: no push notifications despite
being listed as a deferred feature; `MapboxSource` is dead code left in the repo; `EditTaskPage`
and `/map-test` and `/analytics` routes exist but are unreachable from the UI — all confirmed
directly in `docs/11_project_structure.md` and `docs/12_development_notes.md`'s "Feature
Limitations" table.)

---

## 10. 15 Likely Interview Questions (easy → very hard)

1. **Q: What problem does Kapok solve, and for whom?**
   A: It coordinates volunteer disaster-response teams — creating/joining teams via a join
   code, and creating/assigning location-based tasks on a map — built for A Fair Resolution,
   LLC for eventual handoff to the RN Response Network, a nurse volunteer network. It's
   designed offline-first since disaster zones often have poor connectivity.

2. **Q: Why BLoC over something simpler like `setState` or plain `Provider`?**
   A: BLoC gives a strict separation between UI (widgets), business logic (event-in/state-out),
   and data (repositories), which scales better across a multi-semester student team with
   rotating contributors; it also makes testing easier (events/states are plain objects). The
   repo backs this with `bloc_test`/`mocktail` dev dependencies and dedicated BLoC test files.

3. **Q: Walk me through what happens when a user creates a task while offline.**
   A: `TaskRepository.createTask` saves to Hive immediately, checks `NetworkChecker.isConnected()`
   (false), and queues a `create_task` entry in the Hive `sync` box instead of touching
   Firestore. The task is returned and shown locally right away. When connectivity returns,
   `SyncService`, which listens to `connectivity_plus`, dequeues it and writes it to Firestore
   via `FirebaseSource.createTask` plus a manual update of the team's `taskIds` array.

4. **Q: What's the difference between closing a team and deleting a team?**
   A: Closing sets `isActive: false` (a soft delete) — the team, its members, and its tasks all
   stay in Firestore, just marked inactive and un-joinable/un-editable per the rules. Deleting
   is a hard delete: the `teams/{id}` document is removed and each member's `teamId` is
   cleared (individually, not transactionally, so one permission failure doesn't block the
   rest) — but tasks that belonged to the team are deliberately **not** deleted.

5. **Q: How does offline map caching work?**
   A: `MapBloc` downloads a ~4.8km-radius region of tiles (zoom 13–18) centered on the user's
   location (or a searched point), refreshing automatically every 5 minutes or when the user
   moves more than ~0.5 miles. `OfflineMapCache` stores tiles in Hive; `FirebaseMapSnapshotSource`
   writes region metadata to `mapSnapshots/{uid}` for cross-device reference (though this write
   currently fails with `permission-denied` until the owner-only rule for that collection is
   deployed — the repo has the rule but notes it isn't live yet).

6. **Q: Who can edit a task, and where is that enforced?**
   A: The assigned user, the team's leader, or an admin. It's enforced in two places: the
   Firestore rule (`tasks.allow update`) checks `createdBy`/`assignedTo`/role via a `get()` on
   the acting user's own doc, and `TaskRepository.canEditTask`/`PermissionService.canEditTask`
   duplicate the same logic client-side purely to drive the UI (show/hide the edit pencil).
   The rule is the real boundary; the client check is UX only.

7. **Q: Can a regular team member make themselves an admin? Walk me through exactly how.**
   A: Yes, confirmed in code two ways. Simplest: the sign-up form's "Account type" dropdown
   offers Team Member/Team Leader/Admin with no gating — `createUserWithEmailAndPassword` just
   writes whatever was selected. Separately, even post-signup, `RoleSelectionPage` writes
   `userRole` straight to the user's own Firestore doc via `FirebaseSource.updateUser`, and the
   Firestore rule's owner-write branch (`request.auth.uid == userId`) imposes no field
   restriction, so this (or a raw SDK call) would succeed regardless. There's no server-side
   validation of who can hold the admin role at all.

8. **Q: What happens if two team members edit the same task offline at the same time?**
   A: It's last-write-wins with no conflict detection. Both devices queue their full updated
   `TaskModel` locally; when each comes back online, `SyncService` pushes it straight to
   Firestore with `update()`. Whichever sync runs second overwrites the first with no merge,
   no version check, and no warning to either user. This is a real, unaddressed gap — there's
   no optimistic-concurrency check (e.g., comparing `updatedAt`) before the overwrite.

9. **Q: Why does `TaskRepository.deleteTask` read the team document *before* deleting the
   task, instead of after?**
   A: Firestore transactions require all reads to happen before any writes — it's a hard SDK
   constraint, not a style choice. `CHANGELOG.md` documents that this was actually a real bug
   found during QA: an earlier version wrote first and then tried to read, which Firestore
   rejects, silently breaking task deletion until it was fixed to read-then-write.

10. **Q: The app declares `firebase_storage` as a dependency — what's it used for?**
    A: Nothing, currently. `firebase/storage.rules` denies all reads and writes
    unconditionally (`allow read, write: if false`), and there's no upload code path anywhere
    in the app (profile picture upload is explicitly listed as "not implemented" in the
    docs). It's a declared-but-unused dependency, likely scaffolding for a future feature.

11. **Q: If Kapok had to scale to 10x the teams/users, what specifically breaks first, and
    why?**
    A: The admin "load everything" paths — `TaskRepository._getAllTasks()` and
    `TeamRepository._getAllTeams()` — which pull full collections (capped at 1000 for tasks,
    uncapped for teams) with no pagination, for every admin session. At 10x scale this means
    more Firestore reads per admin login, larger in-memory lists on the client, and slower
    screens. The fix is server-side pagination or, better, precomputed summary documents via a
    Cloud Function so admins see aggregates instead of raw full scans.

12. **Q: Why no Cloud Functions at all? What's the trade-off of keeping 100% of logic
    client-side?**
    A: It's simpler to build and ship for a small rotating student team with no dedicated
    backend engineer, and Firebase's client SDKs + Security Rules can genuinely cover a lot of
    CRUD apps. The trade-off, visible directly in this codebase, is that anything that truly
    needs trusted server-side logic — role assignment, server-validated writes, atomic
    cross-document consistency beyond what a single Firestore transaction can express — either
    doesn't get enforced at all (the admin self-escalation issue) or gets worked around with
    comment-documented compromises (e.g. `removeMember` clearing a field outside its
    transaction because current rules don't allow doing it inside).

13. **Q: Walk me through exactly what happens, step by step, if the app crashes halfway
    through account deletion — after the Firestore batch commits but before
    `authUser.delete()` runs.**
    A: `FirebaseSource.deleteAccount` first checks the sign-in is <5 minutes old and the user
    doesn't lead an active team — before touching any data, specifically to avoid this
    scenario. It then commits one Firestore `batch()` (anonymize tasks, remove from
    `memberIds`, delete the `users/{uid}` doc) and only afterward calls `authUser.delete()` as
    a **separate, non-atomic** call. If the app dies between those two steps, the user is left
    with a working Firebase Auth login but no Firestore profile — `AuthRepository.getUserCurrent`
    would hit "user not found" on next sign-in and route them back into onboarding, effectively
    forcing them to recreate a profile; their old data is already anonymized/detached, so
    nothing is silently lost, but the account itself isn't cleanly gone. This exact gap is not
    called out or handled anywhere in the code.

14. **Q: The Firestore rules check `userRole == "admin" || userRole == "Admin" ||
    accountType == "team_leader"` in many places — why, and what's the risk?**
    A: It's leftover backward-compatibility from a migration off an older `accountType` field
    onto the newer `userRole` enum field (confirmed in `UserModel.fromFirestore`'s explicit
    "Firestore Migration" handling, and in `docs/12_development_notes.md`'s QA notes about
    rules drift). The risk is that every one of these OR-chains is a spot where a rule author
    could introduce an inconsistency — e.g. forgetting one casing variant somewhere — and the
    repo's own notes confirm the live console rules have actually drifted from the committed
    file in the past, requiring a manual diff-and-merge process before every deploy, with no
    automated rules tests in CI to catch a regression.

15. **Q: If you were advising the client-handoff organization (RN Response Network) on the
    single highest-priority fix before go-live, what would it be and why?**
    A: Close the admin self-escalation path (§4/§7 #1) before anything else — it's a complete
    bypass of the entire role system, reachable by anyone who can sign up, with no exploit
    sophistication required (pick "Admin" from a dropdown, or edit one Firestore field).
    Everything else in the app — offline sync, task/team CRUD, the map — functions as
    designed; this one gap undermines the "Role-Based Access" feature the README advertises as
    a core capability. The fix (Cloud Function + custom claims + an invite/allow-list gate for
    privileged roles) is also a contained, well-understood change relative to the rest of the
    app's architecture.

---

## 11. Key Terms

- **BLoC (Business Logic Component)**: a state-management pattern where a class consumes a
  stream of input *events* and emits a stream of output *states*, keeping UI widgets free of
  business logic.
- **GetIt**: a service-locator package used here for manual dependency injection — classes are
  registered once and resolved by type anywhere in the app (`sl<TaskRepository>()`).
- **Firestore transaction**: an atomic read-then-write operation across multiple documents;
  Firestore requires every read in a transaction to happen before any write.
- **Firestore batch write**: a set of writes committed atomically together, but **without**
  reads inside it (unlike a transaction) — used for account deletion's multi-document update.
- **Firestore Security Rules**: a declarative, server-evaluated permission language that is
  Firestore's actual authorization boundary — independent of and not trusting any client-side
  check.
- **Custom claims**: key-value pairs attached to a Firebase Auth user's ID token by trusted
  server code (e.g. a Cloud Function), readable (but not writable) by the client and by
  security rules via `request.auth.token.*` — not used in Kapok today, but the standard fix for
  finding §7.1.
- **Offline-first**: an architecture where every write hits local storage first and is queued
  for the remote backend, so the app is fully usable without connectivity.
- **Last-write-wins**: a conflict-resolution strategy where the most recent write simply
  overwrites whatever was there, with no detection or merge of conflicting concurrent edits —
  what Kapok's sync currently does (see §5, §9).
- **Idempotent operation**: an operation that produces the same end result no matter how many
  times it's retried — Kapok's task/team creates are idempotent because they write to a fixed,
  client-generated document ID rather than appending.
- **Hive**: a lightweight, pure-Dart key-value NoSQL local database used for Kapok's offline
  cache and sync queue.
- **GeoPoint**: Firestore's native latitude/longitude field type, used for `TaskModel.geoLocation`.
- **Reverse/forward geocoding**: converting coordinates → human-readable address (reverse) or
  address → coordinates (forward); both done here via the Mapbox Geocoding API.
- **Soft delete**: marking a record inactive (`isActive: false`) instead of physically removing
  it, so data/history is preserved — used for "Close Team" as opposed to "Delete Team."
