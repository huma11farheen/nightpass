
import 'package:clubship/data/supabase_models/event_ticket.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_ticket_state.freezed.dart';

@JsonSerializable()
@freezed
class EventTicketState with _$EventTicketState {
  const factory EventTicketState({
    @Default(true) bool loading,
    @Default([]) List<EventTicket> eventTickets,
  }) = _EventTicketState;
}
