import 'package:clubship/event/event_view_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'buy_ticket_state.freezed.dart';

@freezed
class BuyTicketState with _$BuyTicketState {
  const factory BuyTicketState({
    @Default(true) bool loading,
    String? eventId,
    @Default(0) int maleTicketCount,
    @Default(0) int availableGuestlist,
    @Default(0) int femaleTicketCount,
    @Default(0) double totalPrice,
    @Default(0) double womenTicketPrice,
    @Default(0) double menTicketPrice,
    @Default([]) List<String> femaleAttendee,
    @Default([]) List<String> maleAttendee,
    @Default(TicketState.none) TicketState ticketState,
    EventViewModel? event,
  }) = _BuyTicketState;

  const BuyTicketState._();

  bool get guestlistAvailable => availableGuestlist > 0;

  double get totalPriceWithTax {
    if (totalPrice == 0) return 0;

    final isServiceTaxIncluded = event?.isServiceTaxIncluded ?? false;
    const taxRate = 0.10; // Fixed 10% tax rate

    if (isServiceTaxIncluded) {
      // If service tax is included (inclusive), total already includes tax
      return totalPrice;
    } else {
      // If service tax is not included (exclusive), add 10% to the total
      return totalPrice + (totalPrice * taxRate);
    }
  }
}

enum TicketState {
  none,
  buyNow,
  payAtTheDoor,
}
