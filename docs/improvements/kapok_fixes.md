# Kapok App — Fix & Enhancement Spec

> **App:** Kapok — a disaster response coordination mobile app built with Flutter + Firebase + Mapbox
> **Platform:** Android (primary), iOS
> **Total Items:** 31 fixes/enhancements across 6 phases

---

## Phase 1: Global UI Consistency

These changes affect every screen in the app. Complete them first so subsequent phase work inherits the fixes.

### 1.1 — Equal Spacing for Back Arrow & Kapok Logo (All Pages)

**What:** On every page that has a back arrow (←) on the left and the Kapok tree logo on the right of the app bar, the horizontal spacing is uneven. The logo sits too close to the right edge compared to the arrow's distance from the left edge.

**Required behavior:**
- Measure the left padding/margin of the back arrow from the left screen edge.
- Set the right padding/margin of the Kapok logo to match that exact value.
- Apply this consistently on **every page** that has both elements (e.g., Create Account, Join Team, Task Details, Settings, About, etc.).
- Verify on multiple screen sizes.

**Reference:** The Create Account page screenshot shows the problem clearly — the logo is flush with the edge while the arrow has visible padding.

---

### 1.2 — Blue Header Block with Curved Bottom on All Pages

**What:** Some pages (e.g., Join Team, Settings) have a blue block/banner behind the page title at the top. Other pages (e.g., Create Account) do not. Make this consistent.

**Required behavior:**
- Every page in the app (except the Sign In page and the loading/splash page) must have a blue header block at the top spanning the full width.
- The page title text (e.g., "Create Account", "Join Team", "Tasks", "Settings", etc.) should appear inside this blue block.
- The bottom edge of the blue block must have a **curved/rounded shape** — specifically, the bottom-left and bottom-right corners should be rounded, similar to how the "Join Team" page currently looks. The top edge remains straight/flush with the top of the screen.
- The blue color should match the existing blue used on pages like Join Team and Settings.

---

### 1.3 — Consistent Font Across the Entire App

**What:** The font used across different pages is inconsistent.

**Required behavior:**
- Audit every screen and widget in the app.
- Ensure a single font family is used throughout (headings, body text, buttons, labels, input fields, dialogs, etc.).
- If the app currently uses a primary font (check the Flutter theme), enforce it globally and remove any one-off overrides.

---

### 1.4 — Dark Mode Filter Chips Visibility (Tasks Page)

**What:** On the Tasks page, when dark mode is enabled, the filter chips/boxes (e.g., "All Statuses", "All Priorities", "All Categories", "All Dates", "Overdue only") have dark backgrounds with dark text, making the labels invisible.

**Required behavior:**
- Ensure all filter chips on the Tasks page use a color scheme that is legible in both light and dark mode.
- Match the styling of these chips to other UI elements on the same page that already work in dark mode.
- Test in both light and dark themes.

---

## Phase 2: Text & Content Changes

These are straightforward string/content replacements. No layout or logic changes.

### 2.1 — Replace "relief" with "response" (Global)

**What:** The word "relief" appears in multiple places throughout the app and must be replaced with "response".

**Known locations (search the entire codebase for all occurrences):**
- Join Team page: info box text mentions "disaster relief coordination" → change to "disaster response coordination"
- About page → Our Mission section: "disaster relief efforts" → "disaster response efforts"
- About page → Kapok Icon section: "disaster relief coordination" → "disaster response coordination"
- Any other occurrence of "relief" in user-facing strings should be changed to "response".

---

### 2.2 — Replace "Kapok Icon" Section Text on About Page

**What:** Replace the entire paragraph under the "Kapok Icon" heading on the About page.

**Current text:**
> Kapok's icon is a stylized representation of the kapok tree, known for its resilience and ability to thrive in challenging environments. The design reflects the app's mission to support disaster relief coordination in even the most difficult conditions.

**New text:**
> **Inspiration: The Living Tree**
>
> At the heart of the design is a majestic kapok tree, its sprawling canopy symbolizing the robust network of individuals united in a mission of disaster response. Every leaf and branch represents the vital links between team members, emphasizing collaboration, rapid response, and the collective strength that drives Kapok's initiative forward.

Note: Keep the "Kapok Icon" heading itself. Add "Inspiration: The Living Tree" as a subtitle/subheading beneath it, followed by the paragraph.

---

### 2.3 — Replace "Digging Deeper: Tech Roots" Section Text on About Page

**What:** Replace the entire paragraph under the "Digging Deeper: Tech Roots" heading on the About page.

**Current text:**
> Kapok's technology roots run deep, combining mobile development with cloud-based services to create a robust and reliable platform. The app leverages Flutter for cross-platform compatibility, Firebase for real-time data...

**New text:**
> Beneath the tree, an intricate network of roots unfolds like a circuit board, illustrating that the foundation of Kapok's operation is deeply embedded in advanced technology. This creative fusion of natural form and technical precision speaks to the modern, adaptive strategies the team employs in the face of adversity. The Kapok app was made for you.

---

### 2.4 — Rename "Offline Map Cache" Page Title

**What:** Change the title of the Offline Map Cache page.

**Current title:** `Offline Map Cache`

**New title:** `Maps Stored Offline Temporarily`

---

### 2.5 — Technology Section Text Edits on About Page

**What:** Two small changes in the Technology section of the About page:

1. Remove the word "reliably" — change "designed to work reliably even in areas" to "designed to work in areas".
2. Capitalize "Internet" — change "limited internet connectivity" to "limited Internet connectivity".

**Final sentence should read:**
> The app is designed to work even in areas with limited Internet connectivity.

---

### 2.6 — Replace Legal Section Text on About Page

**What:** Replace the entire text under the "Legal" heading on the About page.

**Current text:**
> Kapok is owned by A Fair Resolution, LLC. All rights reserved. Kapok is designed to assist in...

**New text:**
> © 2006 A Fair Resolution, LLC. All rights reserved. Kapok is owned by A Fair Resolution, LLC. Kapok is designed to assist in disaster response coordination. Users are responsible for their data and usage of the app and should comply with all applicable laws.

---

### 2.7 — Change "cached" to "saved" in Clear Cache Dialog

**What:** In the Clear Cache confirmation popup, update the description text.

**Current text:**
> This will clear approximately 50 KB of locally cached data (tasks, teams, settings). You will need to sync again after clearing.

**New text:**
> This will clear approximately 50 KB of locally saved data (tasks, teams, settings). You will need to sync again after clearing.

Note: The dialog title "Clear Cache" should remain unchanged.

---

### 2.8 — Change Theme Option "System" to "Default"

**What:** On the Settings page, in the "Select Theme" dialog, change the label for the "System" option.

**Current label:** `System`

**New label:** `Default`

This applies both in the dialog and anywhere the current theme value is displayed (e.g., the subtitle under "Theme" that shows the current selection).

---

### 2.9 — Remove "App" from App Icon Label

**What:** On the phone's home screen, the app icon label currently says something like "Kapok App" or similar.

**Required behavior:** The label beneath the app icon should simply say **"Kapok"** — remove the word "App".

Update the `android:label` in `AndroidManifest.xml` and equivalent iOS setting.

---

## Phase 3: About Page & Settings Page Structural Changes

These involve adding, removing, or reordering sections.

### 3.1 — Delete "A Fair Resolution, LLC" Description Section on About Page

**What:** On the About page, there is a section with the heading "A Fair Resolution, LLC" that contains a description paragraph starting with "A Fair Resolution, LLC is an organization dedicated to dispute prevention and resolution..."

**Required behavior:** Delete this entire section (heading + description paragraph). The Legal section (which has its own updated text per Fix 2.6) should remain.

---

### 3.2 — Fix Bullet Point Indentation Under "Key Features" on About Page

**What:** Under the "Key Features" section, the bullet point "Secure authentication (end-to-end encrypted) and data protection" wraps to a second line. The second line ("and data protection") currently starts at the left margin instead of aligning with the text of the bullet.

**Required behavior:**
- Ensure that when any bullet point wraps to a second line, the continuation text aligns with the start of the text on the first line (i.e., standard hanging indent), not with the bullet character.
- This is a general fix — apply it to all bullet lists in the app, not just this one instance.

---

### 3.3 — Add App Version + Tagline Between Technology and Legal on About Page

**What:** Add a new section between the "Technology" section and the "Legal" section on the About page.

**Content to add:**
```
App Version 1.0.0
Built with ❤️ for disaster response coordination.
```

Use a heart symbol/emoji (❤️) where indicated. This should be styled as centered or left-aligned text, visually distinct as a small informational footer-like element.

---

### 3.4 — Delete Notifications Section on Settings Page

**What:** On the Settings page, remove the entire "Notifications" section, which currently contains:
- Header: "Notifications"
- Item: "Notifications" with subtitle "Push notifications will be enabled in a future update"

Delete the header and all items under it.

---

### 3.5 — Delete Privacy Section on Settings Page

**What:** On the Settings page, remove the entire "Privacy" section, which currently contains:
- Header: "Privacy"
- Toggle: "Analytics" — "Analytics will be enabled in a future update"
- Toggle: "Crash Reporting" — "Crash reporting will be enabled in a future update"

Delete the header and all items under it.

---

### 3.6 — Delete Feedback & Support Section on Settings Page

**What:** On the Settings page, remove the entire "Feedback & Support" section, which currently contains:
- Header: "Feedback & Support"
- Item: "Email Support"
- Item: "Report an Issue"
- Item: "Send Feedback"

Delete the header and all items under it.

---

### 3.7 — Add App Version + Tagline to Settings Page

**What:** In the Settings page, add the app version and tagline in the "About" subsection area (near "Privacy Policy" and "Terms of Service" links).

**Content to add:**
```
App Version 1.0.0
Built with ❤️ for disaster response coordination.
```

This should appear in the About subsection, likely above the "Privacy Policy" and "Terms of Service" links.

---

### 3.8 — About Page as Post-Login Landing Page

**What:** Currently, after a user logs in, they land on a page other than the About page (likely the Map or Tasks page). The About page is currently accessible from within the navigation but not shown first.

**Required behavior:**
- After the loading/splash screen → login → the **first page the user sees is the About page**.
- The About page should still be accessible from the normal navigation (e.g., the drawer or profile section) at any time.
- This is a navigation flow reorder — it does NOT make the About page accessible before authentication.
- The user can then navigate away from the About page to the main app (Map, Tasks, etc.) via the bottom navigation or a continue/proceed action.

---

## Phase 4: Feature Removals & Map Changes

### 4.1 — Remove Due Date and Overdue Functionality

**What:** The due date and overdue features are no longer needed. Remove them entirely.

**Scope of removal:**
- **Tasks page filters:** Remove the "All Dates" filter chip and the "Overdue only" toggle/chip.
- **Task creation form:** Remove any due date picker/field.
- **Task detail view:** Remove due date display.
- **Task edit form:** Remove due date field.
- **Task model/data:** The due date field can remain in the database schema to avoid migration issues, but it should not be exposed in the UI anywhere.
- **Overdue logic:** Remove any background logic, notifications, or visual indicators related to overdue tasks (e.g., red highlighting, overdue badges).
- **Filter logic:** Remove date-based filtering and overdue filtering from the task query/filter system.

---

### 4.2 — Change Map Pin Color from Red to Blue

**What:** The map pin/marker used to indicate task locations on the map is currently red (the Mapbox default).

**Required behavior:**
- Change the marker color to blue, matching the app's primary blue color.
- If Mapbox allows custom marker colors via the SDK, use that approach.
- If the default Mapbox marker is not customizable, use a custom marker asset (SVG or PNG) in blue.
- Apply this to all map views in the app (main map, task detail map, edit task map, etc.).

---

### 4.3 — Fix Question Mark Icon Help Overlay Per Page

**What:** The question mark (?) icon at the top of certain pages (e.g., Task Details) opens a help overlay that explains what each icon does. However, the help content does not match the actual icons on the page — some icons present on the page are not explained, and some explanations reference icons that don't exist on that page.

**Required behavior:**
- For each page that has a question mark help button, audit the icons actually present in the app bar/toolbar of that page.
- Update the help overlay to list **only** the icons that exist on that specific page, with accurate descriptions for each.
- Remove any help entries for icons not present on the page.
- The question mark icon itself should remain on all pages where it currently exists.
- Example: The Task Details page currently shows help for "Editing", "Completing", "Sharing", and "Swipe Actions". Verify that these match the actual icons on the Task Details app bar (which shows: ?, share, edit/pencil, delete/trash, and the Kapok logo). Update accordingly — e.g., add "Delete" if the trash icon exists but isn't explained.

---

## Phase 5: Feature Implementations & Bug Fixes

### 5.1 — Implement Share Team Code Functionality

**What:** On a team's detail page, there is a "Share" button next to the "Copy Code" button. Tapping "Share" should allow the user to share the team code via the device's native share sheet.

**Required behavior:**
- When the user taps "Share", invoke the platform's native share dialog (e.g., `Share.share()` in Flutter).
- The shared content should include the team code and a brief message, e.g.: `"Join my team on Kapok! Team code: MMMT92"`
- The "Copy Code" button should continue to work as-is (copies to clipboard).

---

### 5.2 — Implement Edit Team Functionality

**What:** On a team's detail page, tapping the three-dot menu → "Edit Team" currently shows a placeholder dialog that says "Edit team functionality will be implemented here" with Save/Cancel buttons. It does not actually navigate to an edit form.

**Required behavior:**
- Tapping "Edit Team" should navigate to an **edit screen** (not a dialog) where the team leader can modify team details (team name, description, and any other editable team fields).
- The edit screen should pre-populate with the current team data.
- Provide "Save" and "Cancel" buttons/actions.
- "Save" should persist changes to Firebase and navigate back to the team detail page with updated data.
- "Cancel" should discard changes and navigate back.
- Only team leaders and admins should have access to this functionality (the menu option should be hidden for regular members).

---

### 5.3 — Fix Remove Member from Team

**What:** When a team leader tries to remove a member from the team, it fails with the error: `TeamException: Failed to remove member`.

**Required behavior:**
- Debug and fix the member removal flow.
- The team leader should be able to remove any member (except themselves) from the team.
- After successful removal, the member list should refresh and show the updated list.
- Appropriate error handling should be in place — show a user-friendly message if removal fails, with the actual reason if possible.
- Check Firebase security rules and the Dart/Flutter service layer for the root cause.

---

### 5.4 — Debug Edit Task Issues

**What:** Editing tasks has multiple bugs:

1. **Assigned-to change not reflected:** When editing a task and selecting a different team member in the "Assigned To" field, the UI does not visually update to show the new selection.
2. **Page freeze on re-edit:** After editing and saving a task, attempting to edit the same task again causes the page to freeze or render incorrectly (some input fields/boxes don't appear).
3. **General instability:** The edit task flow needs a thorough review for state management issues.

**Required behavior:**
- Fix the "Assigned To" dropdown/selector so that selecting a new member immediately reflects in the UI.
- Fix the state management so that re-entering the edit screen after saving works correctly every time.
- Ensure all form fields (task name, description, category, priority, assigned to, location/map, status) render correctly on every edit attempt.
- Test the full cycle: open task → edit → change fields → save → view updated task → edit again → verify all fields render.

---

### 5.5 — Fix Spanish Language Loading Failure

**What:** When the user changes the app language from English to Spanish in Settings, the app fails to load and gets stuck on a loading spinner indefinitely.

**Required behavior:**
- Debug and fix the locale/language switching logic.
- Switching to Spanish should reload the app with all Spanish translations applied.
- Switching back to English should also work.
- Ensure all translated string files (ARB files or equivalent) are complete and valid — missing keys can cause crashes.
- Test the full cycle: English → Spanish → use app → Spanish → English → use app.

---

### 5.6 — Fix Team Join Confirmation Feedback

**What:** When a user enters a team code on the Join Team page and successfully joins, there should be clear visual feedback.

**Required behavior:**
- After successfully joining a team, show a small blue snackbar/toast at the bottom of the screen confirming the action, e.g.: `"Successfully joined team [team name]!"`
- The snackbar should auto-dismiss after a few seconds.
- If there's already a snackbar in place that doesn't match this description, update it to be a blue-colored snackbar.

---

## Phase 6: Permissions & New Admin Page

### 6.1 — Task Edit Permissions: Members Can Only Edit Their Own Tasks

**What:** Currently, team members can edit any task, including tasks assigned to other people.

**Required behavior:**
- A team member should only be able to edit tasks that are **assigned to them**.
- If a member views a task assigned to someone else, the edit button/pencil icon should either be hidden or disabled.
- Team leaders and admins should retain the ability to edit all tasks.
- This permission check should be enforced both in the UI (hide/disable edit controls) and in the backend/Firebase security rules.

---

### 6.2 — Create Administrator Functionalities Page

**What:** Create a new page in the app that documents/lists administrator-level permissions and capabilities.

**Page title:** `Administrator Permissions` (or similar)

**Content — display as a table or structured list:**

| Action | Who Can Perform |
|---|---|
| Create Team | Team Leaders, Admins |
| Join Team | Team Members, Team Leaders (as member) |
| View Team | Any team member |
| Edit Team | Team Leader, Admin |
| Close Team | Team Leader, Admin |
| Delete Team | Team Leader, Admin |
| Remove Member | Team Leader only |
| Leave Team | Any member (except leader) |
| View All Teams | Admin only |

**Required behavior:**
- This page should be accessible from the app's navigation (e.g., from Settings or from a drawer menu).
- It should be visible to all authenticated users so they understand the permission model.
- Style it consistently with the rest of the app (blue header, same font, etc.).
- If admin-specific actions (like "View All Teams" or "Delete Team") are not yet implemented in the backend, note that they are planned but not yet functional. Implement the page as a reference/documentation screen.

---

## Summary Checklist

| Phase | Items | Description |
|-------|-------|-------------|
| 1 | 1.1–1.4 | Global UI: spacing, blue headers, fonts, dark mode |
| 2 | 2.1–2.9 | Text/content replacements across the app |
| 3 | 3.1–3.8 | About page & Settings page structural changes |
| 4 | 4.1–4.3 | Feature removals (due date, overdue) + map pin + help icons |
| 5 | 5.1–5.6 | Feature implementations + bug fixes |
| 6 | 6.1–6.2 | Permissions enforcement + new admin page |
