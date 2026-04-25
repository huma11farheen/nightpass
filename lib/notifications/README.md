# Background Notification Setup

This document explains how the background notification system works in the Clubship app.

## Overview

The app now supports Firebase Cloud Messaging (FCM) for push notifications that work when the app is in the foreground, background, or terminated state.

## Components

### 1. NotificationService (`notification_service.dart`)

The main service that handles all notification-related functionality:

- **Initialization**: Sets up FCM and local notifications
- **Permission requests**: Asks users for notification permissions
- **FCM token management**: Gets and refreshes device tokens
- **Message handling**: Processes foreground, background, and terminated state messages
- **Local notifications**: Shows notifications when app is in foreground
- **Topic subscription**: Subscribe/unsubscribe to notification topics

### 2. Background Message Handler

Defined in `notification_service.dart` and registered in `main.dart`:

```dart
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handles notifications when app is in background or terminated
}
```

### 3. Provider (`notification_service_provider.dart`)

Provides easy access to the notification service throughout the app:

```dart
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final fcmTokenProvider = Provider<String?>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.fcmToken;
});
```

## How It Works

### Notification States

1. **Foreground**: App is open and visible
   - Handled by `FirebaseMessaging.onMessage`
   - Shows a local notification using `flutter_local_notifications`

2. **Background**: App is minimized but still running
   - Handled by `firebaseMessagingBackgroundHandler`
   - System shows notification automatically

3. **Terminated**: App is completely closed
   - Handled by `firebaseMessagingBackgroundHandler`
   - System shows notification automatically

### Notification Taps

- When user taps a notification while app is in background: `FirebaseMessaging.onMessageOpenedApp`
- When user taps a notification while app is terminated: `getInitialMessage()` in `initialize()`

## Platform Configuration

### Android

**AndroidManifest.xml** (`android/app/src/main/AndroidManifest.xml`):
- POST_NOTIFICATIONS permission (Android 13+)
- VIBRATE and WAKE_LOCK permissions
- Default notification channel configuration
- Default notification icon

### iOS

**Info.plist** (`ios/Runner/Info.plist`):
- UIBackgroundModes with `remote-notification` and `fetch`
- FirebaseAppDelegateProxyEnabled set to false

## Usage Examples

### Get FCM Token

The FCM token is automatically retrieved on initialization. Access it using:

```dart
// In a ConsumerWidget
@override
Widget build(BuildContext context, WidgetRef ref) {
  final token = ref.watch(fcmTokenProvider);
  print('FCM Token: $token');
  // Send this token to your backend server
}
```

Or directly:

```dart
final notificationService = NotificationService();
final token = notificationService.fcmToken;
```

### Subscribe to Topics

```dart
final notificationService = ref.read(notificationServiceProvider);

// Subscribe to a topic (e.g., all users get event notifications)
await notificationService.subscribeToTopic('events');

// Subscribe to user-specific notifications
await notificationService.subscribeToTopic('user_${userId}');

// Unsubscribe
await notificationService.unsubscribeFromTopic('events');
```

### Handle Notification Navigation

Update the TODO sections in `notification_service.dart`:

```dart
void _handleMessageOpenedApp(RemoteMessage message) {
  print('Notification opened app: ${message.messageId}');

  // Example: Navigate based on notification type
  final type = message.data['type'];
  final id = message.data['id'];

  if (type == 'event') {
    // Navigate to event details
    // context.push('/event/$id');
  } else if (type == 'ticket') {
    // Navigate to ticket details
    // context.push('/ticket/$id');
  }
}
```

## Sending Notifications from Backend

### Using FCM REST API

Send a POST request to:
```
https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send
```

Example payload:

```json
{
  "message": {
    "token": "DEVICE_FCM_TOKEN",
    "notification": {
      "title": "New Event Available!",
      "body": "Check out the latest nightclub event"
    },
    "data": {
      "type": "event",
      "id": "event_123",
      "click_action": "FLUTTER_NOTIFICATION_CLICK"
    },
    "android": {
      "priority": "high",
      "notification": {
        "channel_id": "high_importance_channel"
      }
    },
    "apns": {
      "payload": {
        "aps": {
          "sound": "default",
          "badge": 1
        }
      }
    }
  }
}
```

### Topic-based Notifications

Send to all users subscribed to a topic:

```json
{
  "message": {
    "topic": "events",
    "notification": {
      "title": "New Event!",
      "body": "Tonight at Club XYZ"
    }
  }
}
```

## Testing

### Test Foreground Notifications

1. Run the app
2. Send a test notification from Firebase Console
3. Notification should appear as a local notification

### Test Background Notifications

1. Minimize the app
2. Send a test notification
3. Notification should appear in system tray

### Test Terminated State

1. Force close the app
2. Send a test notification
3. Notification should appear
4. Tap notification - app should open

## Backend Integration (Already Implemented ✅)

The notification system automatically:

1. **Saves FCM tokens**:
   - On app startup if user is already logged in (`main.dart:34-43`)
   - After successful login (`login_view_model.dart:24-33`)
   - On token refresh (automatic)

2. **Subscribes to topics**:
   - Automatically subscribes to 'events' topic after login
   - Add more topics as needed in `login_view_model.dart`

3. **Authentication Check**:
   - The service checks if user is authenticated before saving token
   - Skips save if user is not logged in (prevents 403 errors)
   - Automatically saves when user logs in

## Usage After Login

The FCM token is automatically saved to Supabase backend via the `save-fcm-token` edge function. No additional code needed!

## Handle Navigation (TODO)

Implement the navigation logic in `notification_service.dart:_handleMessageOpenedApp`:

```dart
void _handleMessageOpenedApp(RemoteMessage message) {
  final type = message.data['type'];
  final id = message.data['eventId'] ?? message.data['ticketId'];

  if (type == 'ticket_purchase' || type == 'event_reminder') {
    router.push('/event/$id');
  } else if (type == 'guestlist') {
    router.push('/guestlist');
  }
}
```

## Clean up on Logout (TODO)

Add this to your logout handler:

```dart
await NotificationService().deleteToken();
await NotificationService().unsubscribeFromTopic('events');
```

## Debugging

Enable debug logs by running in debug mode. The service logs:
- Permission status
- FCM token
- Message reception
- Topic subscriptions

Check console output for messages starting with "FCM" or "Notification".

## Common Issues

### Notifications not received on iOS
- Ensure you have APNs configured in Firebase Console
- Check that you have the correct provisioning profile with push notification capability
- Verify Info.plist has correct background modes

### Notifications not received on Android
- Check that Google Services JSON file is in `android/app/`
- Verify notification channel is created
- Ensure app has notification permissions (Android 13+)

### Background handler not working
- Ensure the handler function is top-level (not inside a class)
- Has `@pragma('vm:entry-point')` annotation
- Is registered before `runApp()` in main.dart
