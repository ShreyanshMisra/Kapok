# Authentication Feature

## Overview

The authentication system handles user registration, login, password reset, and profile management. It uses Firebase Authentication for identity management and Firestore for user profile storage.

## User Flows

### Login Flow

1. User enters email and password on `LoginPage`
2. `SignInRequested` event dispatched to `AuthBloc`
3. `AuthRepository.signInWithEmailAndPassword()` called
4. Firebase authenticates credentials
5. User profile fetched from Firestore
6. Profile cached locally in Hive
7. `AuthAuthenticated` state emitted
8. App navigates to home or onboarding based on profile completeness

### Registration Flow

1. User fills form on `SignupPage`:
   - Full name
   - Email
   - Password (with confirmation)
   - Account type (Team Member, Team Leader, Admin)
   - Professional role (Medical, Engineering, etc.)
2. User must accept Terms of Service
3. `SignUpRequested` event dispatched
4. Firebase creates auth account
5. User profile saved to Firestore
6. `AuthAuthenticated` state emitted with `isNewSignup: true`
7. User redirected to role-appropriate setup:
   - Team Leader → Create Team page
   - Team Member → Join Team page
   - Admin → Home page

### Password Reset Flow

1. User enters email on `ForgotPasswordPage`
2. `PasswordResetRequested` event dispatched
3. Firebase sends reset email
4. `PasswordResetSent` state emitted
5. UI shows success message

## Pages

### LoginPage (`lib/features/auth/pages/login_page.dart`)

- Email and password fields with validation
- Password visibility toggle
- "Forgot Password" link
- "Sign Up" link for new users
- Shows loading indicator during authentication
- Displays errors via SnackBar

### SignupPage (`lib/features/auth/pages/signup_page.dart`)

- Form fields: name, email, password, confirm password
- Account type dropdown: Team Member, Team Leader, Admin
- Professional role dropdown:
  - Medical
  - Engineering
  - Carpentry
  - Plumbing
  - Construction
  - Electrical
  - Supplies
  - Transportation
  - Other
- Terms of Service dialog with acceptance checkbox
- Form validation using `Validators` class

### ForgotPasswordPage (`lib/features/auth/pages/forgot_password_page.dart`)

- Email input field
- Two-state UI:
  - Before sending: email form
  - After sending: success message with checkmark
- "Back to Login" navigation

### RoleSelectionPage (`lib/features/auth/pages/role_selection_page.dart`)

- Three role cards with icons and descriptions
- Updates user profile with selected role
- Navigates to appropriate team setup page

## BLoC Structure

### Events (`lib/features/auth/bloc/auth_event.dart`)

| Event | Parameters | Purpose |
|-------|------------|---------|
| `SignInRequested` | email, password | Login request |
| `SignUpRequested` | email, password, name, accountType, role | Registration |
| `SignOutRequested` | none | Logout |
| `PasswordResetRequested` | email | Password reset |
| `AuthCheckRequested` | none | Check current auth status |
| `ProfileUpdateRequested` | name?, role?, user? | Update profile |

### States (`lib/features/auth/bloc/auth_state.dart`)

| State | Properties | Meaning |
|-------|------------|---------|
| `AuthInitial` | none | Initial state |
| `AuthLoading` | none | Operation in progress |
| `AuthAuthenticated` | user, needsOnboarding, isNewSignup | User logged in |
| `AuthUnauthenticated` | none | No user logged in |
| `AuthError` | message | Operation failed |
| `PasswordResetSent` | none | Reset email sent |
| `ProfileUpdated` | user | Profile updated |

### Onboarding Check Logic

The `needsOnboarding` flag is set when:
- User is Team Leader or Team Member AND has no `teamId`
- User is not Admin AND has no `role` set

## Repository (`lib/data/repositories/auth_repository.dart`)

### Key Methods

```dart
// Sign in with email/password
Future<UserModel> signInWithEmailAndPassword(String email, String password)

// Create new user account
Future<UserModel> createUserWithEmailAndPassword(
  String email,
  String password,
  String name,
  String accountType,
  String role,
)

// Sign out
Future<void> signOut()

// Send password reset email
Future<void> sendPasswordResetEmail(String email)

// Get current user
Future<UserModel?> getCurrentUser()

// Update user profile
Future<UserModel> updateUserProfile(UserModel user)
```

### Offline Support

- User profile cached to Hive after authentication
- `getCurrentUser()` falls back to Hive if Firestore unavailable
- Profile updates queued for sync if offline

## Firebase Integration

### Authentication Methods

- Email/password sign-in
- Email/password registration
- Password reset via email

### User Document Structure

Users are stored in Firestore at `users/{userId}`:

```json
{
  "id": "user_123456789",
  "name": "John Doe",
  "email": "john@example.com",
  "userRole": "teamMember",
  "role": "Medical",
  "teamId": "team_987654321",
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

## Error Handling

Firebase error codes are mapped to user-friendly messages:

| Firebase Code | User Message |
|---------------|--------------|
| `user-not-found` | "This email is not registered. Please sign up first." |
| `wrong-password` | "Invalid password. Please try again." |
| `invalid-credential` | "Invalid email or password." |
| `email-already-in-use` | "An account already exists with this email." |
| `weak-password` | "Password is too weak." |
| `invalid-email` | "Please enter a valid email address." |

## Form Validation

The `Validators` class provides:

- `validateEmail()`: Valid email format required
- `validatePassword()`: Minimum 6 characters
- `validateName()`: 2-50 characters
- `confirmPassword()`: Must match password field
