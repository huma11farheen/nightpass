import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/data/supabase_models/event_ticket.dart';
import 'package:clubship/data/supabase_models/user_profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_ticket_view_model.freezed.dart';

part 'event_ticket_view_model.g.dart';

@freezed
class EventTicketViewModel with _$EventTicketViewModel {
  const factory EventTicketViewModel(
      {required EventTicket eventTicket,
      required Club club,
      UserProfile? sender}) = _EventTicketViewModel;

  factory EventTicketViewModel.fromJson(Map<String, dynamic> json) =>
      _$EventTicketViewModelFromJson(json);

  factory EventTicketViewModel.fromResponseData(
    Map<String, dynamic> item,
  ) {
    var eventTicket = EventTicket.fromJson(item);
    var club = Club.fromJson(item['club']);
    var user =
        item['sender'] != null ? UserProfile.fromJson(item['sender']) : null;

    return EventTicketViewModel(
      eventTicket: eventTicket,
      club: club,
      sender: user,
    );
  }
}
