import 'package:clubship/data/providers/auth_repository_provider.dart';
import 'package:clubship/data/providers/ticket_repository_provider.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/event_ticket/event_ticket_card.dart';
import 'package:clubship/event_ticket/event_ticket_state.dart';
import 'package:clubship/event_ticket/event_ticket_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventTicketsProvider =
    StateNotifierProvider<PurchasedEventTicketViewModel, EventTicketState>(
  (ref) => PurchasedEventTicketViewModel(
    ticketRepository: ref.read(ticketRepositoryProvider),
    userRepository: ref.read(authRepositoryProvider),
  ),
);

class EventTicketsPage extends ConsumerWidget {
  const EventTicketsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(eventTicketsProvider);
    final tickets = state.eventTickets;
    final isLoading = state.loading;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Brutal.magenta, strokeWidth: 2),
      );
    }

    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              color: Brutal.elevated,
              child: const Icon(
                Icons.confirmation_number_outlined,
                size: 36,
                color: Brutal.mute,
              ),
            ),
            const SizedBox(height: 20),
            Text('No Event Tickets Yet',
                style: Brutal.display(size: 20, color: Brutal.paper)),
            const SizedBox(height: 8),
            Text('Purchase tickets to your favourite events',
                style: Brutal.body(size: 14, color: Brutal.mute)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      itemCount: tickets.length,
      itemBuilder: (context, i) => EventTicketCard(eventTicketModel: tickets[i]),
    );
  }
}
