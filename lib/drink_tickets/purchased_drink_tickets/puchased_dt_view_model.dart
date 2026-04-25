import 'dart:async';

import 'package:clubship/drink_tickets/drink_ticket_model.dart';
import 'package:clubship/drink_tickets/purchased_drink_tickets/purchased_dt_state.dart';
import 'package:clubship/event_ticket/providers/drink_ticket_view_model.dart';
import 'package:clubship/repository/ticket_repository.dart';
import 'package:clubship/repository/users_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PurchasedDrinkTicketViewModel
    extends StateNotifier<PurchasedDrinkTicketModel> {
  PurchasedDrinkTicketViewModel(
      {required this.userRepository, required this.ticketRepository})
      : super(const PurchasedDrinkTicketModel()) {
    initialize();
  }

  final TicketRepository ticketRepository;
  final UserRepository userRepository;
  StreamSubscription<List<DrinkTicketViewModel>>? _ticketStreamSub;

  void initialize() {
    listenToPurchasedDrinkTickets();
  }

  void listenToPurchasedDrinkTickets() {
    _ticketStreamSub?.cancel();

    _ticketStreamSub =
        ticketRepository.streamDrinkTicketsForUser().listen((tickets) {
      final nowUtc = DateTime.now().toUtc();

      final filteredTickets = tickets.where((ticket) {
        // Use event end date instead of ticket expiry date
        final eventEndDateUtc = DateTime.tryParse(ticket.event?.endDate ?? '')?.toUtc();

        // Fallback to expiry date if event end date is not available
        final dateToCheck = eventEndDateUtc ?? DateTime.tryParse(ticket.drinkTicket.expiryDate)?.toUtc();

        if (dateToCheck == null) return false;

        // Keep ticket only if it's assigned AND event has not ended yet
        final isStillValid = ticket.drinkTicket.isAssigned &&
            (dateToCheck.isAfter(nowUtc) || dateToCheck.isAtSameMomentAs(nowUtc));

        return isStillValid;
      }).toList();

      state = state.copyWith(drinkTickets: filteredTickets, loading: false);
    });
  }

  void refreshTickets() {
    // Cancel any existing subscription before starting a new one
    _ticketStreamSub?.cancel();

    _ticketStreamSub =
        ticketRepository.streamDrinkTicketsForUser().listen((tickets) {
      final nowUtc = DateTime.now().toUtc();

      final filteredTickets = tickets.where((ticket) {
        // Use event end date instead of ticket expiry date
        final eventEndDateUtc = DateTime.tryParse(ticket.event?.endDate ?? '')?.toUtc();

        // Fallback to expiry date if event end date is not available
        final dateToCheck = eventEndDateUtc ?? DateTime.tryParse(ticket.drinkTicket.expiryDate)?.toUtc();

        if (dateToCheck == null) return false;

        // Keep ticket only if it's assigned AND event has not ended yet
        final isStillValid = ticket.drinkTicket.isAssigned &&
            (dateToCheck.isAfter(nowUtc) || dateToCheck.isAtSameMomentAs(nowUtc));

        return isStillValid;
      }).toList();

      state = state.copyWith(drinkTickets: filteredTickets, loading: false);
    });
  }

  sendTicket(DrinkTicketModel drinkTicketModel) async {
    // await ticketRepository.sendDrinkToUser("2wSW9kHmTLPFgDmC37RrhkhfFaS2", drinkTicketModel);
  }
}
