import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/event/event_view_model.dart';

enum SearchResultType { club, event }

class SearchResult {
  final SearchResultType type;
  final Club? club;
  final EventViewModel? event;

  SearchResult.club(this.club)
      : type = SearchResultType.club,
        event = null;

  SearchResult.event(this.event)
      : type = SearchResultType.event,
        club = null;

  String get name {
    switch (type) {
      case SearchResultType.club:
        return club?.name ?? '';
      case SearchResultType.event:
        return event?.name ?? '';
    }
  }

  String get id {
    switch (type) {
      case SearchResultType.club:
        return club?.id ?? '';
      case SearchResultType.event:
        return event?.id ?? '';
    }
  }
}
