import 'package:clubship/data/providers/event_repository_provider.dart';
import 'package:clubship/event/event_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_events_by_category.g.dart';

@Riverpod(keepAlive: true)
Future<List<EventViewModel>> getEventsByCategory(Ref ref, String categoryId) {
  final eventsRepository = ref.watch(eventRepositoryProvider);
  return eventsRepository.getEventsByCategory(categoryId);
}
