import 'package:clubship/colors.dart';
import 'package:clubship/data/providers/auth_repository_provider.dart';
import 'package:clubship/data/providers/ticket_repository_provider.dart';
import 'package:clubship/data/supabase_models/event_ticket.dart';
import 'package:clubship/event_ticket/event_ticket_card.dart';
import 'package:clubship/event_ticket/event_ticket_state.dart';
import 'package:clubship/event_ticket/event_ticket_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

final eventTicketsProvider =
    StateNotifierProvider<PurchasedEventTicketViewModel, EventTicketState>(
  (ref) => PurchasedEventTicketViewModel(
    ticketRepository: ref.read(ticketRepositoryProvider),
    userRepository: ref.read(authRepositoryProvider),
  ),
);

class EventTicketsPage extends ConsumerStatefulWidget {
  const EventTicketsPage({super.key});

  @override
  ConsumerState<EventTicketsPage> createState() =>
      _PurchasedDrinkTicketsState();
}

class _PurchasedDrinkTicketsState extends ConsumerState<EventTicketsPage> {
  // Mock data for skeleton loading
  List<EventTicket> _getMockTickets() {
    return List.generate(
      3,
      (index) => EventTicket(
        id: 'skeleton-$index',
        createdAt: DateTime.now().toIso8601String(),
        qrCode: 'MOCK-QR-CODE-$index',
        expiryDate: DateTime.now().toIso8601String(),
        eventId: 'mock-event-id',
        userId: 'mock-user-id',
        eventName: 'Loading Event Name',
        price: 25.0,
        checkedIn: false,
        isGuestlist: false,
        isPayAtDoor: false,
        clubName: 'Loading Club',
        attendeeName: 'Loading Attendee',
        eventDate: DateTime.now().toIso8601String(),
        image: 'https://via.placeholder.com/150',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventTicketsProvider);
    final tickets = state.eventTickets;
    final isLoading = state.loading;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Skeletonizer(
        enabled: isLoading,
        child: tickets.isEmpty && !isLoading
            ? Center(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF2A2D3A).withOpacity(0.4),
                        ColorPallete.backgroundcolor2.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.confirmation_number_outlined,
                        size: 64,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Event Tickets Yet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Purchase tickets to your favorite events',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                itemCount: isLoading ? _getMockTickets().length : tickets.length,
                itemBuilder: (context, index) {
                  final ticket = isLoading
                      ? _getMockTickets()[index]
                      : tickets[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: EventTicketCard(
                      eventTicketModel: ticket,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
