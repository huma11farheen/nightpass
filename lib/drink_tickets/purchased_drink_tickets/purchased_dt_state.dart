import 'package:clubship/event_ticket/providers/drink_ticket_view_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchased_dt_state.freezed.dart';

@JsonSerializable()
@freezed
class PurchasedDrinkTicketModel with _$PurchasedDrinkTicketModel {
  const factory PurchasedDrinkTicketModel({
    @Default(true) bool loading,
    @Default([]) List<DrinkTicketViewModel> drinkTickets,
  }) = _PurchasedDrinkTicketModel;
}
