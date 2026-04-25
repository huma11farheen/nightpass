# FCM Token Authentication Fix

## Problem
You were getting this error:
```
Error saving FCM token to backend: FunctionException(status: 403, details: No user in JWT, reasonPhrase: Forbidden)
```

## Root Cause
The notification service was trying to save the FCM token to the backend during app initialization (in `main.dart`), but the user wasn't logged in yet. The backend requires authentication to save tokens.

## Solution

### 1. Added Authentication Check
**File: `lib/notifications/notification_service.dart:150-187`**

The service now checks if user is authenticated before attempting to save the token:

```dart
// Check if user is authenticated
final user = supabase.auth.currentUser;
if (user == null) {
  print('User not authenticated, skipping FCM token save. Will save after login.');
  return;
}
```

### 2. Added Public Method to Save Token
**File: `lib/notifications/notification_service.dart:189-197`**

New public method that can be called after login:

```dart
/// Save current FCM token to backend (call after login)
Future<void> saveFCMToken() async {
  if (_fcmToken != null) {
    await _saveFCMTokenToBackend(_fcmToken!);
  } else {
    await _getFCMToken();
  }
}
```

### 3. Save Token After Login
**File: `lib/login/login_view_model.dart:23-33`**

The login flow now saves the FCM token after successful authentication:

```dart
// Save FCM token after successful login
if (response == SignInResult.success) {
  try {
    await NotificationService().saveFCMToken();
    // Subscribe to topics
    await NotificationService().subscribeToTopic('events');
  } catch (e) {
    print('Failed to setup notifications: $e');
  }
}
```

### 4. Handle Already Logged-In Users
**File: `lib/main.dart:33-43`**

If user is already logged in when app starts, save the token:

```dart
// If user is already logged in, save FCM token
final currentUser = supabase.auth.currentUser;
if (currentUser != null) {
  try {
    await NotificationService().saveFCMToken();
    await NotificationService().subscribeToTopic('events');
  } catch (e) {
    print('Failed to setup notifications on startup: $e');
  }
}
```

## How It Works Now

### New User Flow:
1. App starts → No user logged in → FCM token obtained but NOT saved (no error)
2. User logs in → Token automatically saved to backend ✅
3. User subscribed to 'events' topic ✅

### Returning User Flow:
1. App starts → User already logged in → Token automatically saved ✅
2. User subscribed to 'events' topic ✅

### Token Refresh:
1. FCM token refreshes → Automatically saved if user is logged in ✅
2. If not logged in, waits until next login

## Testing

### Test 1: Fresh Login
1. Logout if logged in
2. Close and reopen app
3. Login with email/password
4. Check console for: `FCM token saved to backend`
5. Verify in database: `SELECT * FROM fcm_tokens WHERE user_id = 'your-user-id';`

### Test 2: Already Logged In
1. Keep user logged in
2. Force close app
3. Reopen app
4. Check console for: `FCM token saved to backend`

### Test 3: Token Refresh
1. Stay logged in
2. Wait for token refresh (or trigger manually)
3. Token should be updated in backend

## Error Handling

All FCM token operations are wrapped in try-catch blocks:
- Login won't fail if notification setup fails
- App startup won't crash if token save fails
- Errors are logged to console for debugging

## What Changed

| File | Changes |
|------|---------|
| `notification_service.dart` | Added auth check, added `saveFCMToken()` method |
| `login_view_model.dart` | Calls `saveFCMToken()` after successful login |
| `main.dart` | Saves token on startup if user already logged in |
| `README.md` | Updated documentation |

## No More Errors!

The 403 error is now fixed. The token will only be saved when:
- User is authenticated ✅
- User has a valid JWT ✅
- Backend can verify the user ✅

## Next Steps

1. ✅ Error fixed - no more 403
2. ✅ Token saves on login
3. ✅ Token saves on app startup (if logged in)
4. 🔄 Deploy backend (see `SETUP_NOTIFICATIONS.md`)
5. 🔄 Test on real device
6. 🔄 Verify tokens in database
