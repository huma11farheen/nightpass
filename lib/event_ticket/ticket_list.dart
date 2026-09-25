import 'package:clubship/data/providers/auth_repository_provider.dart';
import 'package:clubship/data/providers/ticket_repository_provider.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/event/event_view_model.dart';
import 'package:clubship/event/providers/get_events_provider.dart';
import 'package:clubship/event_ticket/buy_ticket_state.dart';
import 'package:clubship/event_ticket/buy_ticket_view_model.dart';
import 'package:clubship/router.dart';
import 'package:clubship/utils/extensions.dart';
import 'package:clubship/widgets/app_button.dart';
import 'package:clubship/widgets/clubship_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

final buyTicketProvider =
    StateNotifierProvider.autoDispose<ButTicketViewModel, BuyTicketState>(
  (ref) => ButTicketViewModel(
    ticketRepository: ref.read(ticketRepositoryProvider),
    userRepository: ref.read(authRepositoryProvider),
  ),
);

class TicketBuyingScreen extends ConsumerStatefulWidget {
  final EventViewModel eventItem;

  const TicketBuyingScreen({
    required this.eventItem,
    super.key,
  });

  @override
  ConsumerState<TicketBuyingScreen> createState() => _TicketBuyingScreenState();
}

class _TicketBuyingScreenState extends ConsumerState<TicketBuyingScreen> {
  List<String> femaleAttendees = [];
  List<String> maleAttendees = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize with navigation param immediately to show UI
      ref.read(buyTicketProvider.notifier)
        ..setPrice(
            menPrice: widget.eventItem.malePrice,
            womenPrice: widget.eventItem.femalePrice)
        ..setEvent(widget.eventItem);

      // Then fetch the latest event data from the provider to update with current guestlist
      _loadLatestEventData();
    });
  }

  void _loadLatestEventData() {
    // Get the latest event data asynchronously
    ref.read(getEventsProvider).whenData((events) {
      // Find the event by ID to get the latest data with updated registeredGuestlist
      final latestEvent = events.firstWhere(
        (e) => e.id == widget.eventItem.id,
        orElse: () => widget.eventItem, // Fallback to passed event if not found
      );

      // Update with fresh data if different
      if (latestEvent.registeredGuestlist !=
          widget.eventItem.registeredGuestlist) {
        ref.read(buyTicketProvider.notifier).setEvent(latestEvent);
      }
    });
  }

  void syncControllersToTicketCount({
    required int count,
    required List<TextEditingController> controllerList,
  }) {
    if (controllerList.length < count) {
      for (int i = controllerList.length; i < count; i++) {
        controllerList.add(TextEditingController());
      }
    } else if (controllerList.length > count) {
      controllerList.removeRange(count, controllerList.length);
    }
  }

  void validateAndContinue(BuildContext context, BuyTicketState state) {
    if (!ref.read(buyTicketProvider.notifier).areAllFieldsFilled()) {
      context.showSnackbar(message: 'Please enter all attendee names');
      return;
    }

    context.push(
      Routes.orderSummary,
      extra: state,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(buyTicketProvider);
    final viewModel = ref.read(buyTicketProvider.notifier);
    final totalPrice = state.totalPrice;

    void incrementNumberOfFemaleTickets() {
      viewModel.incrementFemaleTickets();
    }

    void decrementNumberOfFemaleTickets() {
      if (state.femaleTicketCount > 0) {
        viewModel.decrementFemaleTickets();
      }
    }

    void incrementNumberOfMaleTickets() {
      viewModel.incrementMaleTickets();
    }

    void decrementNumberOfMaleTickets() {
      if (state.maleTicketCount > 0) {
        viewModel.decrementMaleTickets();
      }
    }

    return Scaffold(
      backgroundColor: Brutal.bg,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // ── Flat brutalist header ─────────────────────────────────────────
          Container(
            color: Brutal.bg,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Close button — flat 36×36 square
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Brutal.elevated,
                      border: Border.all(color: Brutal.hairlineColor),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Brutal.dim,
                      size: 18,
                    ),
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'BUY TICKETS',
                      style: Brutal.display(size: 20, color: Brutal.paper),
                    ),
                    if (state.event?.name case final String eventName)
                      Text(
                        eventName,
                        style: Brutal.body(size: 13, color: Brutal.mute),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Hairline divider
          Container(height: 1, color: Brutal.hairlineColor),

          // ── Scrollable content ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Skeletonizer(
                enabled: state.loading,
                effect: const ShimmerEffect(
                  baseColor: Brutal.elevated,
                  highlightColor: Brutal.hover,
                  duration: Duration(milliseconds: 1000),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Female ticket card
                      buildTicketCard(
                        title: 'Female Tickets',
                        count: state.femaleTicketCount,
                        price: state.availableGuestlist > 0
                            ? 0
                            : state.womenTicketPrice,
                        onIncrement: incrementNumberOfFemaleTickets,
                        onDecrement: decrementNumberOfFemaleTickets,
                        showGuestlistFinished: state.availableGuestlist == 0,
                        availableGuestlist: state.availableGuestlist,
                      ),

                      // Female attendee name inputs
                      if (state.femaleTicketCount > 0) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 4),
                          child: Text(
                            'Female Attendee Names',
                            style: Brutal.display(
                                size: 14, color: Brutal.paper),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Use the + button above to add more tickets',
                            style: Brutal.body(size: 13, color: Brutal.mute),
                          ),
                        ),
                        for (int i = 0; i < state.femaleTicketCount; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: ClubTextField(
                              hintText: 'Enter name ${i + 1}',
                              isNameField: true,
                              autofocus: i == 0,
                              onChanged: (val) => viewModel
                                  .updateFemaleAttendeeName(i, val.trim()),
                            ),
                          ),
                      ],

                      const SizedBox(height: 20),

                      // Male ticket card
                      buildTicketCard(
                        title: 'Male Tickets',
                        count: state.maleTicketCount,
                        price: state.menTicketPrice,
                        onIncrement: incrementNumberOfMaleTickets,
                        onDecrement: decrementNumberOfMaleTickets,
                      ),

                      // Male attendee name inputs
                      if (state.maleTicketCount > 0) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 4),
                          child: Text(
                            'Male Attendee Names',
                            style: Brutal.display(
                                size: 14, color: Brutal.paper),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Use the + button above to add more tickets',
                            style: Brutal.body(size: 13, color: Brutal.mute),
                          ),
                        ),
                        for (int i = 0; i < state.maleTicketCount; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: ClubTextField(
                              hintText: 'Enter name ${i + 1}',
                              isNameField: true,
                              autofocus:
                                  i == 0 && state.femaleTicketCount == 0,
                              onChanged: (val) =>
                                  viewModel.updateMaleAttendeeName(
                                      i, val.trim()),
                            ),
                          ),
                      ],

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom action button ──────────────────────────────────────────
          if (!state.loading)
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                8 + MediaQuery.of(context).padding.bottom,
              ),
              child:
                  state.femaleTicketCount <= 0 && state.maleTicketCount <= 0
                      ? AppButton.secondary(
                          onPressed: () {
                            validateAndContinue(
                              context,
                              state.copyWith(
                                ticketState: TicketState.payAtTheDoor,
                              ),
                            );
                          },
                          text: 'Proceed to Payment',
                        )
                      : AppButton.primary(
                          onPressed: () {
                            validateAndContinue(
                              context,
                              state.copyWith(
                                ticketState: TicketState.buyNow,
                              ),
                            );
                          },
                          text: totalPrice == 0
                              ? (state.availableGuestlist > 0
                                  ? 'Get Free Tickets'
                                  : 'Proceed')
                              : 'Proceed to Payment ¥$totalPrice',
                        ),
            ),
        ],
      ),
    );
  }

  Widget buildTicketCard({
    required String title,
    required int count,
    required double price,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    bool showGuestlistFinished = false,
    int availableGuestlist = 0,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Brutal.elevated,
        border: Border.all(color: Brutal.hairlineColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row + price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: Brutal.label(size: 13, color: Brutal.mute),
              ),
              Text(
                price == 0 ? 'FREE' : '¥${price.toStringAsFixed(0)}',
                style: Brutal.display(
                  size: 20,
                  color: price == 0 ? Brutal.cyan : Brutal.paper,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Guestlist availability (female tickets only)
          if (title.contains('Female') && availableGuestlist > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                '$availableGuestlist SPOTS AVAILABLE',
                style: Brutal.label(size: 10, color: Brutal.cyan),
              ),
            ),

          // Counter row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Decrement button
              GestureDetector(
                onTap: onDecrement,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Brutal.card,
                    border: Border.all(color: Brutal.hairlineColor),
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: Brutal.dim,
                    size: 18,
                  ),
                ),
              ),

              // Count display
              Text(
                count.toString(),
                style: Brutal.display(size: 26, color: Brutal.paper),
              ),

              // Increment button
              GestureDetector(
                onTap: onIncrement,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Brutal.card,
                    border: Border.all(color: Brutal.hairlineColor),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Brutal.dim,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
