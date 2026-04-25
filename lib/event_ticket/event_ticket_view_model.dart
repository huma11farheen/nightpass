import 'dart:async';

import 'package:clubship/data/supabase_models/event_ticket.dart';
import 'package:clubship/event_ticket/event_ticket_state.dart';
import 'package:clubship/repository/ticket_repository.dart';
import 'package:clubship/repository/users_repository.dart';
import 'package:clubship/supabase/supabase_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PurchasedEventTicketViewModel extends StateNotifier<EventTicketState> {
  PurchasedEventTicketViewModel(
      {required this.userRepository, required this.ticketRepository})
      : super(const EventTicketState()) {
    initialize();
  }

  final TicketRepository ticketRepository;
  final UserRepository userRepository;
  StreamSubscription<List<EventTicket>>? _ticketStreamSub;

  void initialize() {
    listenToPurchasedEventTickets();
  }

  void listenToPurchasedEventTickets() {
    _ticketStreamSub?.cancel();
    final userId = supabase.auth.currentUser?.id;

    _ticketStreamSub =
        ticketRepository.streamEventTicketsForUser().listen((tickets) {
      print(tickets.length);

      final nowUtc = DateTime.now().toUtc();

      final filtered = tickets.where((ticket) {
        // Use expiryDate (ticket expiry time) to check if ticket is still valid
        final expiryDateUtc = DateTime.tryParse(ticket.expiryDate)?.toUtc();
        if (expiryDateUtc == null) return false;

        print('Ticket expiry: $expiryDateUtc, Current time: $nowUtc');
        final isStillValid =
            expiryDateUtc.isAfter(nowUtc) || expiryDateUtc.isAtSameMomentAs(nowUtc);

        return isStillValid;
      }).toList();

      state = state.copyWith(eventTickets: filtered, loading: false);
    });
  }

  void refreshTickets() {
    // Cancel any existing subscription before starting a new one
    _ticketStreamSub?.cancel();

    _ticketStreamSub =
        ticketRepository.streamEventTicketsForUser().listen((tickets) {
      final nowUtc = DateTime.now().toUtc();

      final filteredTickets = tickets.where((ticket) {
        // Use expiryDate (ticket expiry time) to check if ticket is still valid
        final expiryDateUtc = DateTime.tryParse(ticket.expiryDate)?.toUtc();
        if (expiryDateUtc == null) return false;

        return expiryDateUtc.isAfter(nowUtc) || expiryDateUtc.isAtSameMomentAs(nowUtc);
      }).toList();

      state = state.copyWith(eventTickets: filteredTickets, loading: false);
    });
  }
}
