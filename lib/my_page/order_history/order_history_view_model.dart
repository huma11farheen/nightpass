import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/data/supabase_models/event.dart';
import 'package:clubship/data/supabase_models/event_ticket.dart';

part 'order_history_view_model.freezed.dart';

@freezed
class OrderHistoryViewModel with _$OrderHistoryViewModel {
  const factory OrderHistoryViewModel({
    required EventTicket eventTicket,
    required Club club,
    required Event event,
  }) = _OrderHistoryViewModel;
}
