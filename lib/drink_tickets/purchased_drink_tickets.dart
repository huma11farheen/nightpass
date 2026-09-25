import 'package:clubship/data/providers/auth_repository_provider.dart';
import 'package:clubship/data/providers/ticket_repository_provider.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/drink_tickets/purchased_drink_tickets/puchased_dt_view_model.dart';
import 'package:clubship/drink_tickets/purchased_drink_tickets/purchased_dt_state.dart';
import 'package:clubship/event_ticket/drink_ticket/drink_ticket_card.dart';
import 'package:clubship/event_ticket/providers/drink_ticket_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final purchasedDrinkTicket = StateNotifierProvider<
    PurchasedDrinkTicketViewModel, PurchasedDrinkTicketModel>(
  (ref) => PurchasedDrinkTicketViewModel(
    ticketRepository: ref.read(ticketRepositoryProvider),
    userRepository: ref.read(authRepositoryProvider),
  ),
);

class PurchasedDrinkTickets extends ConsumerWidget {
  const PurchasedDrinkTickets({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(purchasedDrinkTicket);
    final tickets = state.drinkTickets;
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
                Icons.local_bar_outlined,
                size: 36,
                color: Brutal.mute,
              ),
            ),
            const SizedBox(height: 20),
            Text('No Drink Tickets Yet',
                style: Brutal.display(size: 20, color: Brutal.paper)),
            const SizedBox(height: 8),
            Text('Drink tickets from events will appear here',
                style: Brutal.body(size: 14, color: Brutal.mute)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      itemCount: tickets.length,
      itemBuilder: (context, i) => DrinkTicketCard(drinkTicket: tickets[i]),
    );
  }
}
