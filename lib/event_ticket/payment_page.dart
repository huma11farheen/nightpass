import 'dart:ui';
import 'dart:io';

import 'package:clubship/colors.dart';
import 'package:clubship/data/providers/ticket_repository_provider.dart';
import 'package:clubship/data/providers/user_wallet_repository_provider.dart';
import 'package:clubship/domain/bottom_navigator_provider.dart';
import 'package:clubship/event/providers/get_events_provider.dart';
import 'package:clubship/event_ticket/buy_ticket_state.dart';
import 'package:clubship/payment/stripe_payment_handler.dart';
import 'package:clubship/repository/ticket_repository.dart';
import 'package:clubship/router.dart';
import 'package:clubship/utils/extensions.dart';
import 'package:clubship/wallet/models/saved_card_model.dart';
import 'package:clubship/wallet/saved_cards.dart';
import 'package:clubship/widgets/app_button.dart';
import 'package:clubship/widgets/failure_pop_up.dart';
import 'package:clubship/widgets/line.dart';
import 'package:clubship/widgets/pop_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OrderSummaryPage extends ConsumerStatefulWidget {
  const OrderSummaryPage({super.key, required this.summary});

  final BuyTicketState summary;

  @override
  ConsumerState<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends ConsumerState<OrderSummaryPage> {
  bool loading = false;
  List<StripeCard> cards = [];
  int selectedCardIndex = 0;
  PaymentMethod? selectedPaymentMethod;

  Future<void> _loadSavedPaymentPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPaymentMethod = prefs.getString('last_payment_method');
      final savedCardIndex = prefs.getInt('last_card_index') ?? 0;

      if (savedPaymentMethod != null) {
        if (savedPaymentMethod == 'card') {
          selectedPaymentMethod = PaymentMethod.card;
          selectedCardIndex = savedCardIndex;
        } else if (savedPaymentMethod == 'applePay') {
          selectedPaymentMethod = PaymentMethod.applePay;
        } else if (savedPaymentMethod == 'googlePay') {
          selectedPaymentMethod = PaymentMethod.googlePay;
        } else if (savedPaymentMethod == 'payAtDoor' &&
                   widget.summary.event?.payAtTheDoor == true) {
          // Only restore pay-at-door preference if the event allows it
          selectedPaymentMethod = PaymentMethod.payAtDoor;
        }
      }
    } catch (e) {
      debugPrint('Error loading payment preferences: $e');
    }
  }

  Future<void> _savePaymentPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (selectedPaymentMethod == PaymentMethod.card) {
        await prefs.setString('last_payment_method', 'card');
        await prefs.setInt('last_card_index', selectedCardIndex);
      } else if (selectedPaymentMethod == PaymentMethod.applePay) {
        await prefs.setString('last_payment_method', 'applePay');
      } else if (selectedPaymentMethod == PaymentMethod.googlePay) {
        await prefs.setString('last_payment_method', 'googlePay');
      } else if (selectedPaymentMethod == PaymentMethod.payAtDoor) {
        await prefs.setString('last_payment_method', 'payAtDoor');
      }
    } catch (e) {
      debugPrint('Error saving payment preferences: $e');
    }
  }

  Future<void> _fetchSavedCards() async {
    try {
      // Load saved payment preferences first (instant, no loading)
      await _loadSavedPaymentPreferences();

      // Fetch cards in background without showing loading state
      final response =
          await ref.read(userWalletRepositoryProvider).fetchSavedCards();

      if (!mounted) return;

      setState(() {
        cards = response;
        // ALWAYS set first card as default if cards are available
        // This ensures user doesn't have to select payment method every time
        if (cards.isNotEmpty) {
          // If no saved preference or invalid preference, use first card
          if (selectedPaymentMethod == null ||
              (selectedPaymentMethod == PaymentMethod.card && selectedCardIndex >= cards.length)) {
            selectedPaymentMethod = PaymentMethod.card;
            selectedCardIndex = 0;
          }
          // If saved preference was for digital wallet but user has cards, prefer the saved card
          if (selectedPaymentMethod == PaymentMethod.card) {
            // Validate that saved card index is still valid
            if (selectedCardIndex >= cards.length) {
              selectedCardIndex = 0;
            }
          }
        }
      });
    } catch (e) {
      debugPrint('Error fetching cards: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load saved cards')),
      );
    }
  }

  void _showPaymentMethodSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ColorPallete.black25,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payment Method',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Saved Cards
                  if (cards.isNotEmpty) ...[
                    Text(
                      'Saved Cards',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...cards.asMap().entries.map((entry) {
                      final index = entry.key;
                      final card = entry.value;
                      final isSelected =
                          selectedPaymentMethod == PaymentMethod.card &&
                              selectedCardIndex == index;

                      return _PaymentMethodTile(
                        icon: Icons.credit_card,
                        title: '${card.brand}',
                        subtitle: '•••• ${card.last4}',
                        isSelected: isSelected,
                        isCard: true,
                        onTap: () {
                          setModalState(() {
                            selectedPaymentMethod = PaymentMethod.card;
                            selectedCardIndex = index;
                          });
                          setState(() {
                            selectedPaymentMethod = PaymentMethod.card;
                            selectedCardIndex = index;
                          });
                          _savePaymentPreferences();
                        },
                      );
                    }),
                    const SizedBox(height: 8),
                    _PaymentMethodTile(
                      icon: Icons.add_card,
                      title: 'Add new card',
                      subtitle: '',
                      isSelected: false,
                      isCard: true,
                      onTap: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SavedCardsPage(
                              isSelectionMode: true,
                              selectedCardId: cards.isNotEmpty ? cards[selectedCardIndex].id : null,
                            ),
                          ),
                        );

                        // Handle the selected card result
                        if (result != null && result is int) {
                          setState(() {
                            selectedPaymentMethod = PaymentMethod.card;
                            selectedCardIndex = result;
                          });
                          _savePaymentPreferences();
                          // Refresh cards list to get any newly added cards
                          await _fetchSavedCards();
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Digital Wallets
                  Text(
                    'Digital Wallets',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Apple Pay (iOS only)
                  if (Platform.isIOS)
                    _PaymentMethodTile(
                      icon: CupertinoIcons.creditcard,
                      title: 'Apple Pay',
                      subtitle: 'Pay with Touch ID, Face ID, or Passcode',
                      isSelected: selectedPaymentMethod == PaymentMethod.applePay,
                      onTap: () {
                        setModalState(() {
                          selectedPaymentMethod = PaymentMethod.applePay;
                        });
                        setState(() {
                          selectedPaymentMethod = PaymentMethod.applePay;
                        });
                        _savePaymentPreferences();
                      },
                    ),

                  // Google Pay (Android only)
                  if (Platform.isAndroid)
                    _PaymentMethodTile(
                      icon: Icons.payment,
                      title: 'Google Pay',
                      subtitle: 'Pay with your Google account',
                      isSelected: selectedPaymentMethod == PaymentMethod.googlePay,
                      onTap: () {
                        setModalState(() {
                          selectedPaymentMethod = PaymentMethod.googlePay;
                        });
                        setState(() {
                          selectedPaymentMethod = PaymentMethod.googlePay;
                        });
                        _savePaymentPreferences();
                      },
                    ),

                  const SizedBox(height: 20),

                  // Other payment methods - only show if there are options to display
                  if (cards.isEmpty || widget.summary.event?.payAtTheDoor == true) ...[
                    Text(
                      'Other Options',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Show "Add Card" option if no cards are saved
                    if (cards.isEmpty)
                      _PaymentMethodTile(
                        icon: Icons.add_card,
                        title: 'Add Card',
                        subtitle: 'Add a new payment card',
                        isSelected: false,
                        isCard: true,
                        onTap: () async {
                          Navigator.pop(context);
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SavedCardsPage(
                                isSelectionMode: true,
                              ),
                            ),
                          );

                          // Handle the selected card result
                          if (result != null && result is int) {
                            setState(() {
                              selectedPaymentMethod = PaymentMethod.card;
                              selectedCardIndex = result;
                            });
                            _savePaymentPreferences();
                            // Refresh cards list to get any newly added cards
                            await _fetchSavedCards();
                          }
                        },
                      ),

                    // Only show Pay at Door option if the event allows it
                    if (widget.summary.event?.payAtTheDoor == true)
                      _PaymentMethodTile(
                        icon: Icons.payments_outlined,
                        title: 'Pay at Door',
                        subtitle: 'Cash or card at venue',
                        isSelected:
                            selectedPaymentMethod == PaymentMethod.payAtDoor,
                        onTap: () {
                          setModalState(() {
                            selectedPaymentMethod = PaymentMethod.payAtDoor;
                          });
                          setState(() {
                            selectedPaymentMethod = PaymentMethod.payAtDoor;
                          });
                          _savePaymentPreferences();
                        },
                      ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton.primary(
                        onPressed: () => Navigator.pop(context),
                        text: 'Confirm'),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> buyNow() async {
    // Calculate which female attendees are guestlist vs paid
    final totalGuestlistCapacity = widget.summary.event?.gustlist ?? 0;
    final registeredGuestlist = widget.summary.event?.registeredGuestlist ?? 0;
    final initialAvailableGuestlist = totalGuestlistCapacity - registeredGuestlist;
    final currentAvailableGuestlist = widget.summary.availableGuestlist;
    final guestlistSpotsUsedByThisUser = initialAvailableGuestlist - currentAvailableGuestlist;

    // Split female attendees into guestlist and paid
    final guestlistFemaleCount = guestlistSpotsUsedByThisUser;
    final paidFemaleCount = widget.summary.femaleTicketCount - guestlistSpotsUsedByThisUser;

    final guestlistFemaleAttendees = guestlistFemaleCount > 0
        ? widget.summary.femaleAttendee.take(guestlistFemaleCount).toList()
        : <String>[];

    final paidFemaleAttendees = paidFemaleCount > 0
        ? widget.summary.femaleAttendee.skip(guestlistFemaleCount).toList()
        : <String>[];

    debugPrint('=== TICKET PURCHASE DEBUG ===');
    debugPrint('Total guestlist capacity: $totalGuestlistCapacity');
    debugPrint('Registered guestlist: $registeredGuestlist');
    debugPrint('Initial available guestlist: $initialAvailableGuestlist');
    debugPrint('Current available guestlist: $currentAvailableGuestlist');
    debugPrint('Guestlist spots used by this user: $guestlistSpotsUsedByThisUser');
    debugPrint('Guestlist female count: $guestlistFemaleCount');
    debugPrint('Guestlist female attendees: $guestlistFemaleAttendees');
    debugPrint('Paid female count: $paidFemaleCount');
    debugPrint('Paid female attendees: $paidFemaleAttendees');
    debugPrint('Male tickets: ${widget.summary.maleTicketCount}');
    debugPrint('Male attendees: ${widget.summary.maleAttendee}');
    debugPrint('Total price: ${widget.summary.totalPrice}');
    debugPrint('============================');

    // Call add-to-guestlist for guestlist females
    ApiResult? guestlistResult;
    if (guestlistFemaleCount > 0) {
      guestlistResult = await ref.read(ticketRepositoryProvider).addToGuestlist(
            eventId: widget.summary.eventId ?? '',
            femaleCount: guestlistFemaleCount,
            maleCount: 0,
            isGuestlist: true,
            femaleList: guestlistFemaleAttendees,
            maleList: [],
          );

      if (guestlistResult != ApiResult.success) {
        if (!mounted) return;
        await showFailureAlertDialog(
          context: context,
          title: "Failed to add to guestlist",
          message: "We couldn't process your guestlist request. Please try again.",
          confirmText: "OK",
          onConfirm: () {
            context.pop();
          },
        );
        return;
      }
    }

    // Call buy-ticket for paid females + all males
    ApiResult? buyResult;
    if (paidFemaleCount > 0 || widget.summary.maleTicketCount > 0) {
      buyResult = await ref.read(ticketRepositoryProvider).buyTicket(
            eventId: widget.summary.eventId ?? '',
            femaleCount: paidFemaleCount,
            maleCount: widget.summary.maleTicketCount,
            payLater: false,
            femaleList: paidFemaleAttendees,
            maleList: widget.summary.maleAttendee,
            skipGuestlist: guestlistFemaleCount > 0, // Skip guestlist if we already handled guestlist tickets
          );

      if (buyResult != ApiResult.success) {
        if (!mounted) return;
        await showFailureAlertDialog(
          context: context,
          title: "Failed to purchase",
          message: "We couldn't process your request. Please try again.",
          confirmText: "OK",
          onConfirm: () {
            context.pop();
          },
        );
        return;
      }
    }

    if (!mounted) return;

    final result = (guestlistResult == ApiResult.success || guestlistFemaleCount == 0) &&
                   (buyResult == ApiResult.success || (paidFemaleCount == 0 && widget.summary.maleTicketCount == 0));

    if (result) {
      // Keep loading while backend processes
      // Force refresh events cache to update guestlist counts
      // Wait for the backend to complete the database update
      await Future.delayed(const Duration(milliseconds: 1500));

      // Invalidate the provider completely to force a fresh fetch
      if (mounted) {
        ref.invalidate(getEventsProvider);
      }

      if (!mounted) return;

      // Stop loading just before showing dialog
      setState(() {
        loading = false;
      });

      // Show success dialog
      await showCustomAlertDialog(
          context: context,
          title: "Ticket Purchased",
          message: "Your ticket has been sucessfully"
              " purchased for the event ${widget.summary.event?.name}",
          onConfirm: () {
            // Close the dialog
            Navigator.of(context).pop();
          });

      if (!mounted) return;

      // After dialog is closed, clear navigation stack and go to tickets
      // Pop all screens: order summary, ticket buying, event detail
      while (context.canPop()) {
        context.pop();
      }

      // Now navigate to tickets from home
      if (!mounted) return;
      context.push(Routes.tickets);
    } else {
      await showFailureAlertDialog(
        context: context,
        title: "Failed to purchase",
        message: "We couldn't process your request. Please try again.",
        confirmText: "OK",
        onConfirm: () {
          context.pop();
        },
      );
    }
  }

  Future<void> payAtTheDoor() async {
    // Calculate which female attendees are guestlist vs paid
    final totalGuestlistCapacity = widget.summary.event?.gustlist ?? 0;
    final registeredGuestlist = widget.summary.event?.registeredGuestlist ?? 0;
    final initialAvailableGuestlist = totalGuestlistCapacity - registeredGuestlist;
    final currentAvailableGuestlist = widget.summary.availableGuestlist;
    final guestlistSpotsUsedByThisUser = initialAvailableGuestlist - currentAvailableGuestlist;

    // Split female attendees into guestlist and paid
    final guestlistFemaleCount = guestlistSpotsUsedByThisUser;
    final paidFemaleCount = widget.summary.femaleTicketCount - guestlistSpotsUsedByThisUser;

    final guestlistFemaleAttendees = guestlistFemaleCount > 0
        ? widget.summary.femaleAttendee.take(guestlistFemaleCount).toList()
        : <String>[];

    final paidFemaleAttendees = paidFemaleCount > 0
        ? widget.summary.femaleAttendee.skip(guestlistFemaleCount).toList()
        : <String>[];

    debugPrint('=== PAY AT DOOR DEBUG ===');
    debugPrint('Total guestlist capacity: $totalGuestlistCapacity');
    debugPrint('Registered guestlist: $registeredGuestlist');
    debugPrint('Initial available guestlist: $initialAvailableGuestlist');
    debugPrint('Current available guestlist: $currentAvailableGuestlist');
    debugPrint('Guestlist spots used by this user: $guestlistSpotsUsedByThisUser');
    debugPrint('Guestlist female count: $guestlistFemaleCount');
    debugPrint('Guestlist female attendees: $guestlistFemaleAttendees');
    debugPrint('Paid female count: $paidFemaleCount');
    debugPrint('Paid female attendees: $paidFemaleAttendees');
    debugPrint('Male tickets: ${widget.summary.maleTicketCount}');
    debugPrint('Male attendees: ${widget.summary.maleAttendee}');
    debugPrint('Total price: ${widget.summary.totalPrice}');
    debugPrint('========================');

    // Call add-to-guestlist for guestlist females
    ApiResult? guestlistResult;
    if (guestlistFemaleCount > 0) {
      guestlistResult = await ref.read(ticketRepositoryProvider).addToGuestlist(
            eventId: widget.summary.eventId ?? '',
            femaleCount: guestlistFemaleCount,
            maleCount: 0,
            isGuestlist: true,
            femaleList: guestlistFemaleAttendees,
            maleList: [],
          );

      if (guestlistResult != ApiResult.success) {
        if (!mounted) return;
        await showFailureAlertDialog(
          context: context,
          title: "Failed to add to guestlist",
          message: "We couldn't process your guestlist request. Please try again.",
          confirmText: "OK",
          onConfirm: () {
            context.pop();
          },
        );
        return;
      }
    }

    // Call buy-ticket for paid females + all males (with payLater: true)
    ApiResult? buyResult;
    if (paidFemaleCount > 0 || widget.summary.maleTicketCount > 0) {
      buyResult = await ref.read(ticketRepositoryProvider).buyTicket(
            eventId: widget.summary.eventId ?? '',
            femaleCount: paidFemaleCount,
            maleCount: widget.summary.maleTicketCount,
            payLater: true,
            femaleList: paidFemaleAttendees,
            maleList: widget.summary.maleAttendee,
            skipGuestlist: guestlistFemaleCount > 0, // Skip guestlist if we already handled guestlist tickets
          );

      if (buyResult != ApiResult.success) {
        if (!mounted) return;
        await showFailureAlertDialog(
          context: context,
          title: "Failed to purchase",
          message: "We couldn't process your request. Please try again.",
          confirmText: "OK",
          onConfirm: () {
            context.pop();
          },
        );
        return;
      }
    }

    if (!mounted) return;

    final result = (guestlistResult == ApiResult.success || guestlistFemaleCount == 0) &&
                   (buyResult == ApiResult.success || (paidFemaleCount == 0 && widget.summary.maleTicketCount == 0));

    if (result) {
      // Keep loading while backend processes
      // Force refresh events cache to update guestlist counts
      // Wait for the backend to complete the database update
      await Future.delayed(const Duration(milliseconds: 1500));

      // Invalidate the provider completely to force a fresh fetch
      if (mounted) {
        ref.invalidate(getEventsProvider);
      }

      if (!mounted) return;

      // Stop loading just before showing dialog
      setState(() {
        loading = false;
      });

      // Show success dialog
      await showCustomAlertDialog(
          context: context,
          title: "Ticket Purchased",
          message: "Your ticket has been sucessfully"
              " purchased for the event ${widget.summary.event?.name}",
          onConfirm: () {
            // Close the dialog
            Navigator.of(context).pop();
          });

      if (!mounted) return;

      // After dialog is closed, clear navigation stack and go to tickets
      // Pop all screens: order summary, ticket buying, event detail
      while (context.canPop()) {
        context.pop();
      }

      // Now navigate to tickets from home
      if (!mounted) return;
      context.push(Routes.tickets);
    } else {
      await showFailureAlertDialog(
        context: context,
        title: "Failed to purchase",
        message: "We couldn't process your request. Please try again.",
        confirmText: "OK",
        onConfirm: () {
          context.pop();
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // For free tickets, set a dummy payment method to skip selection
    if (widget.summary.totalPrice == 0) {
      selectedPaymentMethod = PaymentMethod.card; // Dummy value, will use buyNow() with payLater: false
      // Don't fetch cards for free tickets - no payment needed
    } else {
      // Only fetch saved cards for paid tickets
      if (widget.summary.ticketState == TicketState.payAtTheDoor &&
          widget.summary.event?.payAtTheDoor == true) {
        selectedPaymentMethod = PaymentMethod.payAtDoor;
      }
      _fetchSavedCards();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
            child: Column(
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
                        color: Colors.white.withValues(alpha:0.9),
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

              Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
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
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextRow(
                              leading: 'Female tickets',
                              trailing: '${widget.summary.femaleTicketCount}',
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            TextRow(
                              leading: 'Male tickets',
                              trailing: '${widget.summary.maleTicketCount}',
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            const DashedLine(
                                gapWidth: 0,
                                strokeWidth: 0.2,
                                color: Colors.white30),
                            const SizedBox(
                              height: 16,
                            ),
                            // Show tax breakdown if tax is present
                            Builder(
                              builder: (context) {
                                final isServiceTaxIncluded = widget.summary.event?.isServiceTaxIncluded ?? false;

                                if (widget.summary.totalPrice == 0) {
                                  // Free ticket - show only total price
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total price',
                                        style: TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                      Text(
                                        'FREE',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                // Fixed 10% tax rate
                                const taxPercentage = 10;
                                const taxRate = 0.10;

                                final double subtotal;
                                final double taxAmount;
                                final double total;

                                if (isServiceTaxIncluded) {
                                  // INCLUSIVE TAX: total already includes tax
                                  // Example: ¥1000 total (includes ¥91 tax)
                                  total = widget.summary.totalPrice;
                                  subtotal = total / (1 + taxRate);
                                  taxAmount = total - subtotal;
                                } else {
                                  // EXCLUSIVE TAX: ticket price + tax = total
                                  // Example: ¥1000 + 10% = ¥1100
                                  subtotal = widget.summary.totalPrice;
                                  taxAmount = subtotal * taxRate;
                                  total = subtotal + taxAmount;
                                }

                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Subtotal',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '¥${subtotal.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Tax ($taxPercentage%)',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '¥${taxAmount.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const DashedLine(
                                        gapWidth: 0,
                                        strokeWidth: 0.2,
                                        color: Colors.white30),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Total price',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '¥${total.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Attendee Names Section
              if (widget.summary.femaleAttendee.isNotEmpty || widget.summary.maleAttendee.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
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
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: ColorPallete.brightPink.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.people_outline,
                                      color: ColorPallete.brightPink,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Attendee Information',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Female Attendees
                              if (widget.summary.femaleAttendee.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.pink.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Female (${widget.summary.femaleAttendee.length})',
                                        style: TextStyle(
                                          color: Colors.pink.shade300,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...widget.summary.femaleAttendee.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final name = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Colors.white54,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            name.trim().isEmpty ? 'Attendee ${index + 1}' : name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                if (widget.summary.maleAttendee.isNotEmpty) const SizedBox(height: 16),
                              ],

                              // Male Attendees
                              if (widget.summary.maleAttendee.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Male (${widget.summary.maleAttendee.length})',
                                        style: TextStyle(
                                          color: Colors.blue.shade300,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...widget.summary.maleAttendee.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final name = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Colors.white54,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            name.trim().isEmpty ? 'Attendee ${index + 1}' : name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Spacing between attendee names and payment section
              if (widget.summary.femaleAttendee.isNotEmpty || widget.summary.maleAttendee.isNotEmpty)
                const SizedBox(height: 16),

              // Only show payment method selector for paid tickets
              if (widget.summary.totalPrice > 0) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Payment Method',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (widget.summary.totalPrice > 0)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: loading ? null : _showPaymentMethodSelector,
                    child: ClipRRect(
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
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: ColorPallete.brightPink.withValues(alpha:0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    selectedPaymentMethod == PaymentMethod.card && cards.isNotEmpty
                                        ? Icons.credit_card
                                        : selectedPaymentMethod == PaymentMethod.applePay
                                            ? CupertinoIcons.creditcard
                                            : selectedPaymentMethod == PaymentMethod.googlePay
                                                ? Icons.payment
                                                : selectedPaymentMethod == PaymentMethod.payAtDoor
                                                    ? Icons.payments_outlined
                                                    : Icons.account_balance_wallet_outlined,
                                    color: ColorPallete.brightPink,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedPaymentMethod == PaymentMethod.card &&
                                                cards.isNotEmpty
                                            ? '${cards[selectedCardIndex].brand}'
                                            : selectedPaymentMethod == PaymentMethod.applePay
                                                ? 'Apple Pay'
                                                : selectedPaymentMethod == PaymentMethod.googlePay
                                                    ? 'Google Pay'
                                                    : selectedPaymentMethod == PaymentMethod.payAtDoor
                                                        ? 'Pay at Door'
                                                        : 'Select Payment',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,

                                          fontWeight: FontWeight.w600,
                                        ),

                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        selectedPaymentMethod == PaymentMethod.card &&
                                                cards.isNotEmpty
                                            ? '•••• ${cards[selectedCardIndex].last4}'
                                            : selectedPaymentMethod == PaymentMethod.applePay
                                                ? 'Pay with Touch ID, Face ID, or Passcode'
                                                : selectedPaymentMethod == PaymentMethod.googlePay
                                                    ? 'Pay with your Google account'
                                                    : selectedPaymentMethod == PaymentMethod.payAtDoor
                                                        ? 'Cash or card at venue'
                                                        : 'Choose your payment method',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha:0.6),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white.withValues(alpha:0.6),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // Add some bottom padding to ensure content is not cut off
              const SizedBox(height: 16),
              ],
            ),
                ),
              ),
              // Button at the bottom that moves with keyboard
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  8 + MediaQuery.of(context).padding.bottom,
                ),
                child: AppButton.primary(
                  text: selectedPaymentMethod == PaymentMethod.payAtDoor
                      ? 'Pay at the door'
                      : widget.summary.totalPrice == 0
                          ? 'Get Free Ticket'
                          : 'Buy now ¥${widget.summary.totalPriceWithTax.toStringAsFixed(0)}',
                  onPressed: () async {
                    if (selectedPaymentMethod == null) {
                      _showPaymentMethodSelector();
                      return;
                    }
                    setState(() {
                      loading = true;
                    });

                    // IMPORTANT: If tickets are free, always use buyNow() with payLater: false
                    // This ensures guestlist logic works correctly on the backend
                    if (widget.summary.totalPrice == 0) {
                      await buyNow();
                      return;
                    }

                    // For paid tickets, check payment method
                    if (selectedPaymentMethod == PaymentMethod.payAtDoor &&
                        widget.summary.event?.payAtTheDoor == true) {
                      await payAtTheDoor();
                    } else if (selectedPaymentMethod == PaymentMethod.card ||
                               selectedPaymentMethod == PaymentMethod.applePay ||
                               selectedPaymentMethod == PaymentMethod.googlePay) {
                      setState(() {
                        loading = true;
                      });
                      try {
                        final res = await StripePaymentHandler().stripeMakePayment(
                          widget.summary.totalPriceWithTax,
                        );
                        if (res == PurchaseStatus.success) {
                          await buyNow();
                        }
                      } catch (exception) {
                        if (context.mounted) {
                          context.showSnackbar(message: exception.toString());
                        }
                      } finally {
                        setState(() {
                          loading = false;
                        });
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        if (loading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}

class TextRow extends StatelessWidget {
  const TextRow({super.key, required this.leading, required this.trailing});

  final String leading;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Colors.white, fontSize: 16);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          leading,
          style: textStyle,
        ),
        Text(
          trailing,
          style: textStyle,
        )
      ],
    );
  }
}

enum PaymentMethod { card, applePay, googlePay, payAtDoor }

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCard;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.isCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    ColorPallete.brightPink.withValues(alpha:0.2),
                    ColorPallete.backgroundcolor2.withValues(alpha:0.2),
                  ],
                )
              : null,
          color: isSelected ? null : ColorPallete.black25,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ColorPallete.brightPink : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCard
                    ? Colors.white.withValues(alpha:0.1)
                    : ColorPallete.brightPink.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isCard ? Colors.white : ColorPallete.brightPink,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha:0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: ColorPallete.brightPink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
