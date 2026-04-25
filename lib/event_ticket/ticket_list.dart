import 'dart:ui';

import 'package:clubship/colors.dart';
import 'package:clubship/data/providers/auth_repository_provider.dart';
import 'package:clubship/data/providers/ticket_repository_provider.dart';
import 'package:clubship/event/event_view_model.dart';
import 'package:clubship/event/providers/get_events_provider.dart';
import 'package:clubship/event_ticket/buy_ticket_state.dart';
import 'package:clubship/event_ticket/buy_ticket_view_model.dart';
import 'package:clubship/router.dart';
import 'package:clubship/utils/extensions.dart';
import 'package:clubship/utils/helpers.dart';
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
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(children: [
              Image.asset('assets/images/banner/summary.png'),
              Positioned(
                top: 50,
                left: 12,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ]),
            Skeletonizer(
              enabled: state.loading,
              effect: ShimmerEffect(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[700]!,
                duration: const Duration(milliseconds: 1000),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
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
                    if (state.femaleTicketCount > 0) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          'Female Attendee Names',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Use the + button above to add more tickets',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                          ),
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
                        )
                    ],
                    const SizedBox(height: 20),
                    buildTicketCard(
                      title: 'Male Tickets',
                      count: state.maleTicketCount,
                      price: state.menTicketPrice,
                      onIncrement: incrementNumberOfMaleTickets,
                      onDecrement: decrementNumberOfMaleTickets,
                    ),
                    const SizedBox(height: 20),
                    if (state.maleTicketCount > 0) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 4),
                        child: Text(
                          'Male Attendee Names',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Use the + button above to add more tickets',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      for (int i = 0; i < state.maleTicketCount; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ClubTextField(
                            hintText: 'Enter name ${i + 1}',
                            isNameField: true,
                            autofocus: i == 0 && state.femaleTicketCount == 0,
                            onChanged: (val) =>
                                viewModel.updateMaleAttendeeName(i, val.trim()),
                          ),
                        )
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
            ),
          ),
          // Button at the bottom that moves with keyboard
          if (!state.loading)
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                8 + MediaQuery.of(context).padding.bottom,
              ),
              child: state.femaleTicketCount <= 0 && state.maleTicketCount <= 0
                  ? AppButton.secondary(
                      onPressed: () {
                        validateAndContinue(
                            context,
                            state.copyWith(
                              ticketState: TicketState.payAtTheDoor,
                            ));
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: ColorPallete.cardColor.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          price == 0 ? 'FREE' : '¥$price',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: price == 0 ? Colors.green : Colors.white),
                        ),
                        const SizedBox(height: 4),
                        if (title.contains('Female')) ...[
                          if (availableGuestlist > 0) ...[
                            Text(
                              '$availableGuestlist guestlist spots left',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ]
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: onDecrement,
                          color: Colors.white.withValues(alpha: 0.5),
                          iconSize: 32,
                        ),
                        Text(
                          count.toString(),
                          style: const TextStyle(
                              fontSize: 24, color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: onIncrement,
                          color: Colors.white.withValues(alpha: 0.5),
                          iconSize: 32,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
