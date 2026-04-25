import 'package:clubship/data/supabase_models/in_app_notification.dart';
import 'package:clubship/supabase/supabase_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getNotificationsProvider =
    StreamProvider<List<InAppNotification>>((ref) {
  try {
    return supabase
        .from(InAppNotification.modelName)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(50)
        .map((data) => data.map((json) => InAppNotification.fromJson(json)).toList());
  } catch (e) {
    print('Error fetching notifications: $e');
    return Stream.value([]);
  }
});
