import 'package:clubship/data/providers/event_repository_provider.dart';
import 'package:clubship/event/event_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_events_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<EventViewModel>> getEvents(Ref ref) {
  final eventsRepository = ref.watch(eventRepositoryProvider);
  return eventsRepository.fetchUpcomingEvents();
}