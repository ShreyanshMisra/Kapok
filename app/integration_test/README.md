# Integration tests

End-to-end tests that drive the real Kapok app on a device or emulator.

Unlike `app/test/`, these tests:

- Boot Flutter on a real Android/iOS device or emulator (not the host VM).
- Can talk to native plugins (Mapbox, geolocation, biometrics).
- Should hit the **Firebase emulator suite**, never production Firestore.

## Running locally

```bash
cd app

# All integration tests on the first connected device
flutter test integration_test/

# One file, on a specific device
flutter devices                     # find the id
flutter test integration_test/app_smoke_test.dart -d <device-id>
```

## With the Firebase emulator suite

```bash
# Terminal 1 — from repo root
firebase emulators:start --only auth,firestore

# Terminal 2 — point the app at the emulator and run tests
cd app
flutter test \
  integration_test/ \
  --dart-define=USE_FIREBASE_EMULATOR=true
```

`USE_FIREBASE_EMULATOR` is read by `lib/core/services/firebase_service.dart`
to call `FirebaseFirestore.instance.useFirestoreEmulator(...)` and
`FirebaseAuth.instance.useAuthEmulator(...)` when set.

(Implementation note: the wiring for that env var is **not yet in place** —
see `docs/15_store_readiness_evaluation.md` §7 for the gap list.)

## What to add next

In rough priority order:

1. **Auth flow** — sign up, sign in, sign out against the auth emulator.
2. **Team lifecycle** — create team, invite member, leave team.
3. **Task lifecycle** — create task with location, assign, mark in-progress, complete.
4. **Offline → online** — turn off connectivity, create task, restore, verify Firestore sync.
5. **Permissions** — verify role-gated UI is actually hidden, not just visually muted.

Each test should:

- Be hermetic. Create the data it needs; tear down after.
- Use `find.bySemanticsLabel(...)` so screen-reader regressions get caught.
- Run on both the lowest supported iOS and Android API levels in CI.
