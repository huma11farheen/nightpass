import 'package:clubship/data/providers/auth_repository_provider.dart';
import 'package:clubship/data/providers/ticket_repository_provider.dart';
import 'package:clubship/data/supabase_models/drink_ticket.dart';
import 'package:clubship/drink_tickets/purchased_drink_tickets/puchased_dt_view_model.dart';
import 'package:clubship/drink_tickets/purchased_drink_tickets/purchased_dt_state.dart';
import 'package:clubship/event_ticket/drink_ticket/drink_ticket_card.dart';
import 'package:clubship/event_ticket/providers/drink_ticket_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

final purchasedDrinkTicket = StateNotifierProvider<
    PurchasedDrinkTicketViewModel, PurchasedDrinkTicketModel>(
  (ref) => PurchasedDrinkTicketViewModel(
    ticketRepository: ref.read(ticketRepositoryProvider),
    userRepository: ref.read(authRepositoryProvider),
  ),
);

class PurchasedDrinkTickets extends ConsumerStatefulWidget {
  const PurchasedDrinkTickets({super.key});

  @override
  ConsumerState<PurchasedDrinkTickets> createState() =>
      _PurchasedDrinkTicketsState();
}

class _PurchasedDrinkTicketsState extends ConsumerState<PurchasedDrinkTickets> {
  bool _showSkeleton = false;

  @override
  void initState() {
    super.initState();
    // Only show skeleton if loading takes longer than 200ms
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _showSkeleton = true;
        });
      }
    });
  }

  // Mock data for skeleton loading
  List<DrinkTicketViewModel> _getMockTickets() {
    return List.generate(
      3,
      (index) => DrinkTicketViewModel(
        drinkTicket: DrinkTicket(
          id: 'skeleton-$index',
          createdAt: DateTime.now().toIso8601String(),
          userId: 'mock-user-id',
          qrCode: 'MOCK-QR-CODE-$index',
          expiryDate: DateTime.now().toIso8601String(),
          eventId: 'mock-event-id',
          isAssigned: true,
          eventName: 'Loading Event Name',
          image: 'https://via.placeholder.com/150',
          promoterTicket: false
        ),
        club: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(purchasedDrinkTicket);
    final tickets = state.drinkTickets;
    final isLoading = state.loading;
    final shouldShowSkeleton = isLoading && _showSkeleton;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 8),
        child: shouldShowSkeleton
            ? Skeletonizer(
                enabled: true,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: _getMockTickets().length,
                  itemBuilder: (context, index) {
                    return DrinkTicketCard(
                      drinkTicket: _getMockTickets()[index],
                    );
                  },
                ),
              )
            : tickets.isEmpty && !isLoading
                ? const Center(
                    child: Text(
                      'No Drink tickets yet',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  )
                : tickets.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: tickets.length,
                        itemBuilder: (context, index) {
                          return DrinkTicketCard(
                            drinkTicket: tickets[index],
                          );
                        },
                      )
                    : const SizedBox.shrink(),
      ),
    );
  }
}
