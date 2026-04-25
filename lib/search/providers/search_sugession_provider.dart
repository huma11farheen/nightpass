import 'package:clubship/clubs/club_list_page.dart';
import 'package:clubship/event/providers/get_events_provider.dart';
import 'package:clubship/search/search_result_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_sugession_provider.g.dart';

@riverpod
Future<List<SearchResult>> searchSugession(
  Ref ref,
  String query,
) async {
  if (query.isEmpty || query.length < 2) {
    return [];
  }

  final queryLower = query.toLowerCase();
  final results = <SearchResult>[];

  // Search events
  final events = ref.watch(getEventsProvider);
  final searchedEvents = events.value
          ?.where((event) => event.name.toLowerCase().contains(queryLower))
          .toList() ??
      [];

  // Add events to results
  for (var event in searchedEvents) {
    results.add(SearchResult.event(event));
  }

  // Search clubs
  final clubs = ref.watch(clubListProvider);
  final searchedClubs = clubs.clubs
      .where((club) =>
          club.name.toLowerCase().contains(queryLower) ||
          club.description?.toLowerCase().contains(queryLower) == true)
      .toList();

  // Add clubs to results
  for (var club in searchedClubs) {
    results.add(SearchResult.club(club));
  }

  return results;
}
