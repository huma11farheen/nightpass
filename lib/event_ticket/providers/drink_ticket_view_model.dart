import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/data/supabase_models/drink_ticket.dart';
import 'package:clubship/data/supabase_models/event.dart';
import 'package:clubship/data/supabase_models/user_profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'drink_ticket_view_model.freezed.dart';

part 'drink_ticket_view_model.g.dart';

@freezed
class DrinkTicketViewModel with _$DrinkTicketViewModel {
  const factory DrinkTicketViewModel({
    required DrinkTicket drinkTicket,
    required Club? club,
    UserProfile? sender,
    Event? event
  }) = _DrinkTicketViewModel;

  factory DrinkTicketViewModel.fromJson(Map<String, dynamic> json) =>
      _$DrinkTicketViewModelFromJson(json);

  factory DrinkTicketViewModel.fromResponseData(
    Map<String, dynamic> item,
  ) {
    var eventTicket = DrinkTicket.fromJson(item);
    Club? club = item['club'] != null ? Club.fromJson(item['club']) : null;
    var user =
        item['sender'] != null ? UserProfile.fromJson(item['sender']) : null;
    var event =
    item['event'] != null ? Event.fromJson(item['event']) : null;

    return DrinkTicketViewModel(
      drinkTicket: eventTicket,
      club: club,
      sender: user,
      event: event
    );
  }
}
