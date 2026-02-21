# Final Touches: Implementation Completed

> Companion to `sprint-1-2-completed.md` and `sprint-3-4-progress.md`. Documents the final polish pass addressing dark mode, branded imagery, and first-login routing.

---

## Task 1: Dark Mode Fixes

### 1.1 Map Search Bar (Primary Fix)

**Problem:** In dark mode, the map's location search dropdown had a white background with grey text, making results unreadable.

**Root cause:** `_buildSearchBar()` in `map_page.dart` used hardcoded `AppColors.surface` (always `#FEFEFF`) for the Card backgrounds and provided no explicit text color, so the ListTile text defaulted to dark grey on a white card regardless of theme.

**Fix (map_page.dart):**
- Replaced `AppColors.surface.withValues(alpha: 0.95)` → `Theme.of(context).colorScheme.surface.withOpacity(0.95)` for the search input Card.
- Replaced `AppColors.surface` → `Theme.of(context).colorScheme.surface` for the results dropdown Card.
- Added explicit `color: onSurfaceColor` to the result `Text` style, leading `Icon`, search `Icon`, and clear `IconButton`.
- Added `style: TextStyle(color: onSurfaceColor)` to the `TextField` itself and a themed `hintStyle`.

### 1.2 App-Wide Dark Mode Audit

**Problem:** Multiple pages used static `AppColors` constants (`surface`, `background`, `textPrimary`, `textSecondary`, `divider`, `card`) that don't adapt to the dark theme.

**Replacement mapping applied across 14 files:**

| Hardcoded Constant | Replaced With |
|---|---|
| `AppColors.surface` | `theme.colorScheme.surface` |
| `AppColors.background` | `theme.scaffoldBackgroundColor` |
| `AppColors.card` | `theme.cardTheme.color ?? theme.colorScheme.surface` |
| `AppColors.textPrimary` | `theme.colorScheme.onSurface` |
| `AppColors.textSecondary` | `theme.colorScheme.onSurface.withOpacity(0.6)` |
| `AppColors.divider` | `theme.dividerTheme.color ?? theme.colorScheme.onSurface.withOpacity(0.12)` |

**Files modified:**

| File | Changes |
|------|---------|
| `map_page.dart` | Scaffold bg, debug text, map card/FAB surface, task preview due date |
| `settings_page.dart` | Notifications, sync, cache, privacy, feedback sections |
| `enhanced_task_card.dart` | Title, category, description, location, team, time, assignee colors |
| `team_detail_page.dart` | Member count, description, code card, member section, info rows, tasks, dropdown bg |
| `task_detail_page.dart` | Coordinates, due date, dropdown icon, status timeline line |
| `teams_page.dart` | Error state text, member count, chevron icon |
| `tasks_page.dart` | Filter chip text, error state title/message, section headers |
| `role_selection_page.dart` | Scaffold bg, subtitle, role card title/subtitle/arrow |
| `map_cache_page.dart` | Empty state icon/text, region titles, tile count, info rows, preview overlay |
| `forgot_password_page.dart` | Description text, help text |
| `router.dart` | 404 page title and description |
| `join_team_page.dart` | Instruction text |
| `create_team_page.dart` | Share code text in dialog |
| `help_overlay.dart` | Tip description text |
| `map_test_page.dart` | Status card surface color |

**Intentionally left alone:**
- `AppColors.primary`, `primaryLight`, `primaryDark`, `secondary`, `error`, `success`, `warning`, severity/role colors (these are brand/semantic colors, not theme-dependent neutrals).
- `foregroundColor: AppColors.surface` on primary-colored buttons (intentional white-on-primary).
- `app_theme.dart`, `app_colors.dart`, `app_styles.dart` (theme definitions).

---

## Task 2: Kapok Icon Tagline (Light/Dark Mode)

### Assets

Two tagline wordmark images in `app/assets/images/icon_tagline/`:

| File | Designed For |
|------|-------------|
| `KapokIcon_Dark_Tagline_Wordmark.png` | Dark backgrounds (light-colored text/graphic) |
| `Kapok_Icon_Light_Tagline_Wordmark.png` | Light backgrounds (dark-colored text/graphic) |

### Asset Registration

Added `assets/images/icon_tagline/` to the `flutter.assets` list in `pubspec.yaml`. Without this, Flutter could not bundle or load the images at runtime.

### Splash Screen (`splash_screen.dart`)

- Detects system brightness via `MediaQuery.of(context).platformBrightness` (the splash runs outside the theme provider).
- **Dark mode:** `primaryDark` background + `KapokIcon_Dark_Tagline_Wordmark.png`.
- **Light mode:** `surface` (white) background + `Kapok_Icon_Light_Tagline_Wordmark.png`.
- Loading spinner color adapts: white in dark mode, primary blue in light mode.
- Error fallback icon adapts similarly.

### Login Page (`login_page.dart`)

- Replaced the plain `kapok_icon.png` (120×120) with the tagline wordmark images (220 wide).
- Switches via `theme.brightness == Brightness.dark`.
- Falls back to the old `kapok_icon.png` if tagline images fail to load.
- Removed the separate "Kapok" title `Text` and "Disaster Relief Coordination" subtitle since the tagline image includes them.

### About Page (`about_page.dart`)

- Already used the correct pattern (`theme.brightness == Brightness.dark` toggle). Updated to reference the renamed filenames.

---

## Task 3: First Login → About Page

### Problem

Every login went directly to the Home page (map tab). First-time users had no introduction to the app.

### Solution

First-time logins now route to the About page. Subsequent logins go straight to the Map/Home page.

### New File: `lib/core/services/first_login_service.dart`

Follows the same singleton + Hive pattern as `OnboardingService`:

- **Per-user flag** stored in Hive settings box with key `has_logged_in_before_{uid}`.
- `hasLoggedInBefore(String uid)` — returns `true` if the user has logged in at least once.
- `markLoggedIn(String uid)` — sets the flag to `true`.

### Navigation Changes (`kapok_app.dart`)

**BlocListener (login event handling):**
- In the "fully set up user" branch, added a first-login check before navigating.
- If `FirstLoginService.instance.hasLoggedInBefore(uid)` is `false`: marks the user as logged in, then navigates to `/about`.
- Otherwise: navigates to `/home` as before.
- Added `/about` to the list of routes that skip re-navigation.

**Home BlocBuilder (initial widget on app start):**
- If `AuthAuthenticated` and user has not logged in before: renders `AboutPage`.
- Otherwise: renders `HomePage` as before.

### About Page Changes (`about_page.dart`)

- When the About page is the root route (no back navigation available — the first-login case), a **"Continue" button** appears at the bottom of the scrollable content.
- The button calls `FirstLoginService.instance.markLoggedIn(uid)` and navigates to `/home`.
- When the About page is accessed normally (from drawer/navigation), no button appears and the back arrow works as usual.
- `automaticallyImplyLeading` set based on `Navigator.of(context).canPop()` to hide the back arrow when there's nowhere to go back.

### Localization

Added `continueText` to `app_localizations.dart`:
- English: `"Continue"`
- Spanish: `"Continuar"`

---

## Files Created

| File | Purpose |
|------|---------|
| `lib/core/services/first_login_service.dart` | Per-user first-login tracking via Hive |

## Files Modified

| File | Tasks |
|------|-------|
| `pubspec.yaml` | Added `icon_tagline/` asset folder |
| `app_localizations.dart` | Added `continueText` (EN + ES) |
| `splash_screen.dart` | Theme-aware tagline image + background |
| `login_page.dart` | Theme-aware tagline image replacing plain icon |
| `about_page.dart` | Updated image filenames, added Continue button for first login |
| `kapok_app.dart` | First-login routing logic in listener + home builder |
| `map_page.dart` | Dark-mode-aware search bar + remaining hardcoded colors |
| `settings_page.dart` | Hardcoded colors → theme-aware |
| `enhanced_task_card.dart` | Hardcoded colors → theme-aware |
| `team_detail_page.dart` | Hardcoded colors → theme-aware |
| `task_detail_page.dart` | Hardcoded colors → theme-aware |
| `teams_page.dart` | Hardcoded colors → theme-aware |
| `tasks_page.dart` | Hardcoded colors → theme-aware |
| `role_selection_page.dart` | Hardcoded colors → theme-aware |
| `map_cache_page.dart` | Hardcoded colors → theme-aware |
| `forgot_password_page.dart` | Hardcoded colors → theme-aware |
| `router.dart` | Hardcoded colors → theme-aware |
| `join_team_page.dart` | Hardcoded colors → theme-aware |
| `create_team_page.dart` | Hardcoded colors → theme-aware |
| `help_overlay.dart` | Hardcoded colors → theme-aware |
| `map_test_page.dart` | Hardcoded colors → theme-aware |

---

## Verification

```bash
cd app
flutter pub get
flutter run -d emulator-5554   # or -d chrome, -d windows
```

Test checklist:
- [ ] Toggle system dark mode — search bar dropdown, all pages readable
- [ ] Splash screen shows correct tagline image for light/dark
- [ ] Login page shows correct tagline image for light/dark
- [ ] About page shows correct tagline image for light/dark
- [ ] First login → About page with Continue button
- [ ] Second login → straight to Map/Home
- [ ] About page from drawer → no Continue button, back arrow works
