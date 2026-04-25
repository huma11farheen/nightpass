import 'package:clubship/data/supabase_models/event_category.dart';
import 'package:clubship/event/event_list/event_list_state.dart';
import 'package:clubship/repository/events_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventListViewModel extends StateNotifier<EventListState> {
  final EventsRepository eventsRepository;

  EventListViewModel(this.eventsRepository) : super(const EventListState()) {
    getUpcomingEvents();
  }

  void getUpcomingEvents({EventCategory? category}) async {
    final events = await eventsRepository.fetchUpcomingEvents(category:category);
    state = state.copyWith(events: events, loading: false);
  }
}
