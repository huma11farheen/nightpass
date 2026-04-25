import 'package:clubship/notifications/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the NotificationService singleton
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for FCM token
final fcmTokenProvider = Provider<String?>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return notificationService.fcmToken;
});
