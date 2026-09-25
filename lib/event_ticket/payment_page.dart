import 'package:clubship/widgets/back_button.dart';
import 'dart:io';

import 'package:clubship/data/providers/ticket_repository_provider.dart';
import 'package:clubship/data/providers/user_wallet_repository_provider.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/drink_tickets/purchased_drink_tickets.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      await _loadSavedPaymentPreferences();
      final response = await ref.read(userWalletRepositoryProvider).fetchSavedCards();
      if (!mounted) return;
      setState(() {
        cards = response;
        if (cards.isNotEmpty) {
          if (selectedPaymentMethod == null ||
              (selectedPaymentMethod == PaymentMethod.card &&
                  selectedCardIndex >= cards.length)) {
            selectedPaymentMethod = PaymentMethod.card;
            selectedCardIndex = 0;
          }
          if (selectedPaymentMethod == PaymentMethod.card) {
            if (selectedCardIndex >= cards.length) selectedCardIndex = 0;
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
      backgroundColor: Brutal.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(width: 2, height: 18, color: Brutal.magenta),
                          const SizedBox(width: 10),
                          Text('Payment Method',
                              style: Brutal.display(size: 20, color: Brutal.paper)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Brutal.elevated,
                            border: Border.all(color: Brutal.hairlineColor),
                          ),
                          child: const Icon(Icons.close, color: Brutal.dim, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Saved Cards
                  if (cards.isNotEmpty) ...[
                    Text('Saved Cards',
                        style: Brutal.label(size: 11, color: Brutal.mute)),
                    const SizedBox(height: 10),
                    ...cards.asMap().entries.map((entry) {
                      final index = entry.key;
                      final card = entry.value;
                      final isSelected = selectedPaymentMethod == PaymentMethod.card &&
                          selectedCardIndex == index;
                      return _BrutalPaymentTile(
                        icon: Icons.credit_card,
                        title: card.brand,
                        subtitle: '•••• ${card.last4}',
                        isSelected: isSelected,
                        accentColor: Brutal.cyan,
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
                    _BrutalPaymentTile(
                      icon: Icons.add_card,
                      title: 'Add New Card',
                      subtitle: '',
                      isSelected: false,
                      accentColor: Brutal.mute,
                      onTap: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SavedCardsPage(
                              isSelectionMode: true,
                              selectedCardId: cards.isNotEmpty
                                  ? cards[selectedCardIndex].id
                                  : null,
                            ),
                          ),
                        );
                        if (result != null && result is int) {
                          setState(() {
                            selectedPaymentMethod = PaymentMethod.card;
                            selectedCardIndex = result;
                          });
                          _savePaymentPreferences();
                          await _fetchSavedCards();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Digital Wallets
                  Text('Digital Wallets',
                      style: Brutal.label(size: 11, color: Brutal.mute)),
                  const SizedBox(height: 10),

                  if (Platform.isIOS)
                    _BrutalPaymentTile(
                      icon: CupertinoIcons.creditcard,
                      title: 'Apple Pay',
                      subtitle: 'Touch ID / Face ID',
                      isSelected: selectedPaymentMethod == PaymentMethod.applePay,
                      accentColor: Brutal.paper,
                      onTap: () {
                        setModalState(
                            () => selectedPaymentMethod = PaymentMethod.applePay);
                        setState(
                            () => selectedPaymentMethod = PaymentMethod.applePay);
                        _savePaymentPreferences();
                      },
                    ),

                  if (Platform.isAndroid)
                    _BrutalPaymentTile(
                      icon: Icons.payment,
                      title: 'Google Pay',
                      subtitle: 'Pay with your Google account',
                      isSelected: selectedPaymentMethod == PaymentMethod.googlePay,
                      accentColor: Brutal.yellow,
                      onTap: () {
                        setModalState(
                            () => selectedPaymentMethod = PaymentMethod.googlePay);
                        setState(
                            () => selectedPaymentMethod = PaymentMethod.googlePay);
                        _savePaymentPreferences();
                      },
                    ),

                  // Other Options
                  if (cards.isEmpty || widget.summary.event?.payAtTheDoor == true) ...[
                    const SizedBox(height: 16),
                    Text('Other Options',
                        style: Brutal.label(size: 11, color: Brutal.mute)),
                    const SizedBox(height: 10),

                    if (cards.isEmpty)
                      _BrutalPaymentTile(
                        icon: Icons.add_card,
                        title: 'Add Card',
                        subtitle: 'Add a new payment card',
                        isSelected: false,
                        accentColor: Brutal.mute,
                        onTap: () async {
                          Navigator.pop(context);
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SavedCardsPage(isSelectionMode: true),
                            ),
                          );
                          if (result != null && result is int) {
                            setState(() {
                              selectedPaymentMethod = PaymentMethod.card;
                              selectedCardIndex = result;
                            });
                            _savePaymentPreferences();
                            await _fetchSavedCards();
                          }
                        },
                      ),

                    if (widget.summary.event?.payAtTheDoor == true)
                      _BrutalPaymentTile(
                        icon: Icons.payments_outlined,
                        title: 'Pay at Door',
                        subtitle: 'Cash or card at venue',
                        isSelected: selectedPaymentMethod == PaymentMethod.payAtDoor,
                        accentColor: Brutal.yellow,
                        onTap: () {
                          setModalState(
                              () => selectedPaymentMethod = PaymentMethod.payAtDoor);
                          setState(
                              () => selectedPaymentMethod = PaymentMethod.payAtDoor);
                          _savePaymentPreferences();
                        },
                      ),
                  ],

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton.primary(
                        onPressed: () => Navigator.pop(context), text: 'Confirm'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> buyNow() async {
    final totalGuestlistCapacity = widget.summary.event?.gustlist ?? 0;
    final registeredGuestlist = widget.summary.event?.registeredGuestlist ?? 0;
    final initialAvailableGuestlist = totalGuestlistCapacity - registeredGuestlist;
    final currentAvailableGuestlist = widget.summary.availableGuestlist;
    final guestlistSpotsUsedByThisUser =
        initialAvailableGuestlist - currentAvailableGuestlist;

    final guestlistFemaleCount = guestlistSpotsUsedByThisUser;
    final paidFemaleCount =
        widget.summary.femaleTicketCount - guestlistSpotsUsedByThisUser;

    final guestlistFemaleAttendees = guestlistFemaleCount > 0
        ? widget.summary.femaleAttendee.take(guestlistFemaleCount).toList()
        : <String>[];
    final paidFemaleAttendees = paidFemaleCount > 0
        ? widget.summary.femaleAttendee.skip(guestlistFemaleCount).toList()
        : <String>[];

    debugPrint('=== TICKET PURCHASE DEBUG ===');
    debugPrint('Guestlist female count: $guestlistFemaleCount');
    debugPrint('Paid female count: $paidFemaleCount');
    debugPrint('Male tickets: ${widget.summary.maleTicketCount}');
    debugPrint('============================');

    ApiResult? guestlistResult;
    if (guestlistFemaleCount > 0) {
      guestlistResult =
          await ref.read(ticketRepositoryProvider).addToGuestlist(
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
          onConfirm: () => context.pop(),
        );
        return;
      }
    }

    ApiResult? buyResult;
    if (paidFemaleCount > 0 || widget.summary.maleTicketCount > 0) {
      buyResult = await ref.read(ticketRepositoryProvider).buyTicket(
            eventId: widget.summary.eventId ?? '',
            femaleCount: paidFemaleCount,
            maleCount: widget.summary.maleTicketCount,
            payLater: false,
            femaleList: paidFemaleAttendees,
            maleList: widget.summary.maleAttendee,
            skipGuestlist: guestlistFemaleCount == 0,
            freeFemaleDrinkTickets: widget.summary.event?.freeFemaleDrinkTicket ?? 0,
            freeMaleDrinkTickets: widget.summary.event?.freeMaleDrinkTicket ?? 0,
          );

      if (buyResult != ApiResult.success) {
        if (!mounted) return;
        await showFailureAlertDialog(
          context: context,
          title: "Failed to purchase",
          message: "We couldn't process your request. Please try again.",
          confirmText: "OK",
          onConfirm: () => context.pop(),
        );
        return;
      }
    }

    if (!mounted) return;

    final result =
        (guestlistResult == ApiResult.success || guestlistFemaleCount == 0) &&
            (buyResult == ApiResult.success ||
                (paidFemaleCount == 0 && widget.summary.maleTicketCount == 0));

    if (result) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        ref.invalidate(getEventsProvider);
        // Refresh drink tickets — they may have been generated by the backend
        ref.read(purchasedDrinkTicket.notifier).refreshTickets();
      }
      if (!mounted) return;

      setState(() => loading = false);

      await _showBrutalSuccessDialog(
        context: context,
        eventName: widget.summary.event?.name ?? '',
      );

      if (!mounted) return;
      while (context.canPop()) {
        context.pop();
      }
      if (!mounted) return;
      context.push(Routes.tickets);
    } else {
      await showFailureAlertDialog(
        context: context,
        title: "Failed to purchase",
        message: "We couldn't process your request. Please try again.",
        confirmText: "OK",
        onConfirm: () => context.pop(),
      );
    }
  }

  Future<void> payAtTheDoor() async {
    final totalGuestlistCapacity = widget.summary.event?.gustlist ?? 0;
    final registeredGuestlist = widget.summary.event?.registeredGuestlist ?? 0;
    final initialAvailableGuestlist = totalGuestlistCapacity - registeredGuestlist;
    final currentAvailableGuestlist = widget.summary.availableGuestlist;
    final guestlistSpotsUsedByThisUser =
        initialAvailableGuestlist - currentAvailableGuestlist;

    final guestlistFemaleCount = guestlistSpotsUsedByThisUser;
    final paidFemaleCount =
        widget.summary.femaleTicketCount - guestlistSpotsUsedByThisUser;

    final guestlistFemaleAttendees = guestlistFemaleCount > 0
        ? widget.summary.femaleAttendee.take(guestlistFemaleCount).toList()
        : <String>[];
    final paidFemaleAttendees = paidFemaleCount > 0
        ? widget.summary.femaleAttendee.skip(guestlistFemaleCount).toList()
        : <String>[];

    debugPrint('=== PAY AT DOOR DEBUG ===');
    debugPrint('Guestlist female count: $guestlistFemaleCount');
    debugPrint('Paid female count: $paidFemaleCount');
    debugPrint('========================');

    ApiResult? guestlistResult;
    if (guestlistFemaleCount > 0) {
      guestlistResult =
          await ref.read(ticketRepositoryProvider).addToGuestlist(
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
          onConfirm: () => context.pop(),
        );
        return;
      }
    }

    ApiResult? buyResult;
    if (paidFemaleCount > 0 || widget.summary.maleTicketCount > 0) {
      buyResult = await ref.read(ticketRepositoryProvider).buyTicket(
            eventId: widget.summary.eventId ?? '',
            femaleCount: paidFemaleCount,
            maleCount: widget.summary.maleTicketCount,
            payLater: true,
            femaleList: paidFemaleAttendees,
            maleList: widget.summary.maleAttendee,
            skipGuestlist: guestlistFemaleCount == 0,
            freeFemaleDrinkTickets: widget.summary.event?.freeFemaleDrinkTicket ?? 0,
            freeMaleDrinkTickets: widget.summary.event?.freeMaleDrinkTicket ?? 0,
          );

      if (buyResult != ApiResult.success) {
        if (!mounted) return;
        await showFailureAlertDialog(
          context: context,
          title: "Failed to purchase",
          message: "We couldn't process your request. Please try again.",
          confirmText: "OK",
          onConfirm: () => context.pop(),
        );
        return;
      }
    }

    if (!mounted) return;

    final result =
        (guestlistResult == ApiResult.success || guestlistFemaleCount == 0) &&
            (buyResult == ApiResult.success ||
                (paidFemaleCount == 0 && widget.summary.maleTicketCount == 0));

    if (result) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        ref.invalidate(getEventsProvider);
        ref.read(purchasedDrinkTicket.notifier).refreshTickets();
      }
      if (!mounted) return;

      setState(() => loading = false);

      await _showBrutalSuccessDialog(
        context: context,
        eventName: widget.summary.event?.name ?? '',
      );

      if (!mounted) return;
      while (context.canPop()) {
        context.pop();
      }
      if (!mounted) return;
      context.push(Routes.tickets);
    } else {
      await showFailureAlertDialog(
        context: context,
        title: "Failed to purchase",
        message: "We couldn't process your request. Please try again.",
        confirmText: "OK",
        onConfirm: () => context.pop(),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.summary.totalPrice == 0) {
      selectedPaymentMethod = PaymentMethod.card;
    } else {
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
          backgroundColor: Brutal.bg,
          appBar: AppBar(
            backgroundColor: Brutal.bg,
            elevation: 0,
            leading: const AppBackButton(forAppBar: true),
            title: Text('Order Summary',
                style: Brutal.display(size: 20, color: Brutal.paper)),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Ticket Count Section ───────────────────────────────
                      _BrutalSectionCard(
                        label: 'Tickets',
                        icon: Icons.confirmation_number_outlined,
                        child: Column(
                          children: [
                            _BrutalRow(
                              leading: 'Female Tickets',
                              trailing: '${widget.summary.femaleTicketCount}',
                              trailingColor: Brutal.magenta,
                            ),
                            const SizedBox(height: 10),
                            Container(
                                height: 1, color: Brutal.hairlineColor),
                            const SizedBox(height: 10),
                            _BrutalRow(
                              leading: 'Male Tickets',
                              trailing: '${widget.summary.maleTicketCount}',
                              trailingColor: Brutal.cyan,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Price Breakdown ────────────────────────────────────
                      _BrutalSectionCard(
                        label: 'Price',
                        icon: Icons.receipt_long_outlined,
                        child: _buildPriceBreakdown(),
                      ),
                      const SizedBox(height: 16),

                      // ── Attendee Names ─────────────────────────────────────
                      if (widget.summary.femaleAttendee.isNotEmpty ||
                          widget.summary.maleAttendee.isNotEmpty) ...[
                        _BrutalSectionCard(
                          label: 'Attendees',
                          icon: Icons.people_outline,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.summary.femaleAttendee.isNotEmpty) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.female,
                                        size: 14, color: Brutal.magenta),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Female (${widget.summary.femaleAttendee.length})',
                                      style: Brutal.label(
                                          size: 10, color: Brutal.magenta),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...widget.summary.femaleAttendee
                                    .asMap()
                                    .entries
                                    .map((e) => _AttendeeRow(
                                          name: e.value,
                                          index: e.key,
                                          color: Brutal.magenta,
                                        )),
                                if (widget.summary.maleAttendee.isNotEmpty)
                                  const SizedBox(height: 14),
                              ],
                              if (widget.summary.maleAttendee.isNotEmpty) ...[
                                Row(
                                  children: [
                                    const Icon(Icons.male,
                                        size: 14, color: Brutal.cyan),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Male (${widget.summary.maleAttendee.length})',
                                      style: Brutal.label(
                                          size: 10, color: Brutal.cyan),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...widget.summary.maleAttendee
                                    .asMap()
                                    .entries
                                    .map((e) => _AttendeeRow(
                                          name: e.value,
                                          index: e.key,
                                          color: Brutal.cyan,
                                        )),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ── Payment Method ─────────────────────────────────────
                      if (widget.summary.totalPrice > 0) ...[
                        Text('Payment Method',
                            style: Brutal.label(size: 11, color: Brutal.mute)),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: loading ? null : _showPaymentMethodSelector,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Brutal.elevated,
                              border: Border.all(color: Brutal.magenta, width: 1),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  color: Brutal.magenta.withValues(alpha: 0.15),
                                  child: Icon(
                                    _paymentIcon(),
                                    color: Brutal.magenta,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _paymentTitle(),
                                        style: Brutal.body(
                                            size: 15, color: Brutal.paper),
                                      ),
                                      if (_paymentSubtitle().isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          _paymentSubtitle(),
                                          style: Brutal.body(
                                              size: 12, color: Brutal.mute),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: Brutal.mute, size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),

              // ── CTA Button ─────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                    20, 0, 20, 12 + MediaQuery.of(context).padding.bottom),
                child: AppButton.primary(
                  text: selectedPaymentMethod == PaymentMethod.payAtDoor
                      ? 'Pay at the Door'
                      : widget.summary.totalPrice == 0
                          ? 'Get Free Ticket'
                          : 'Buy Now  ¥${widget.summary.totalPriceWithTax.toStringAsFixed(0)}',
                  onPressed: () async {
                    if (selectedPaymentMethod == null) {
                      _showPaymentMethodSelector();
                      return;
                    }
                    setState(() => loading = true);

                    if (widget.summary.totalPrice == 0) {
                      await buyNow();
                      return;
                    }

                    if (selectedPaymentMethod == PaymentMethod.payAtDoor &&
                        widget.summary.event?.payAtTheDoor == true) {
                      await payAtTheDoor();
                    } else if (selectedPaymentMethod == PaymentMethod.card ||
                        selectedPaymentMethod == PaymentMethod.applePay ||
                        selectedPaymentMethod == PaymentMethod.googlePay) {
                      try {
                        final res = await StripePaymentHandler()
                            .stripeMakePayment(widget.summary.totalPriceWithTax);
                        if (res == PurchaseStatus.success) await buyNow();
                      } catch (exception) {
                        if (context.mounted) {
                          context.showSnackbar(message: exception.toString());
                        }
                      } finally {
                        setState(() => loading = false);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        if (loading)
          Container(
            color: Brutal.bg.withValues(alpha: 0.7),
            child: const Center(
              child: CircularProgressIndicator(color: Brutal.magenta),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    final isServiceTaxIncluded =
        widget.summary.event?.isServiceTaxIncluded ?? false;

    if (widget.summary.totalPrice == 0) {
      return const _BrutalRow(
        leading: 'Total Price',
        trailing: 'FREE',
        trailingColor: Brutal.yellow,
        trailingBold: true,
      );
    }

    const taxRate = 0.10;
    const taxPercentage = 10;
    final double subtotal;
    final double taxAmount;
    final double total;

    if (isServiceTaxIncluded) {
      total = widget.summary.totalPrice;
      subtotal = total / (1 + taxRate);
      taxAmount = total - subtotal;
    } else {
      subtotal = widget.summary.totalPrice;
      taxAmount = subtotal * taxRate;
      total = subtotal + taxAmount;
    }

    return Column(
      children: [
        _BrutalRow(
          leading: 'Subtotal',
          trailing: '¥${subtotal.toStringAsFixed(0)}',
        ),
        const SizedBox(height: 8),
        _BrutalRow(
          leading: 'Tax ($taxPercentage%)',
          trailing: '¥${taxAmount.toStringAsFixed(0)}',
        ),
        const SizedBox(height: 12),
        Container(height: 1, color: Brutal.hairlineColor),
        const SizedBox(height: 12),
        _BrutalRow(
          leading: 'Total Price',
          trailing: '¥${total.toStringAsFixed(0)}',
          trailingColor: Brutal.paper,
          trailingBold: true,
        ),
      ],
    );
  }

  IconData _paymentIcon() {
    if (selectedPaymentMethod == PaymentMethod.card && cards.isNotEmpty) {
      return Icons.credit_card;
    } else if (selectedPaymentMethod == PaymentMethod.applePay) {
      return CupertinoIcons.creditcard;
    } else if (selectedPaymentMethod == PaymentMethod.googlePay) {
      return Icons.payment;
    } else if (selectedPaymentMethod == PaymentMethod.payAtDoor) {
      return Icons.payments_outlined;
    }
    return Icons.account_balance_wallet_outlined;
  }

  String _paymentTitle() {
    if (selectedPaymentMethod == PaymentMethod.card && cards.isNotEmpty) {
      return cards[selectedCardIndex].brand;
    } else if (selectedPaymentMethod == PaymentMethod.applePay) {
      return 'Apple Pay';
    } else if (selectedPaymentMethod == PaymentMethod.googlePay) {
      return 'Google Pay';
    } else if (selectedPaymentMethod == PaymentMethod.payAtDoor) {
      return 'Pay at Door';
    }
    return 'Select Payment';
  }

  String _paymentSubtitle() {
    if (selectedPaymentMethod == PaymentMethod.card && cards.isNotEmpty) {
      return '•••• ${cards[selectedCardIndex].last4}';
    } else if (selectedPaymentMethod == PaymentMethod.applePay) {
      return 'Touch ID / Face ID / Passcode';
    } else if (selectedPaymentMethod == PaymentMethod.googlePay) {
      return 'Pay with your Google account';
    } else if (selectedPaymentMethod == PaymentMethod.payAtDoor) {
      return 'Cash or card at venue';
    }
    return 'Choose your payment method';
  }
}

// ── Success popup ─────────────────────────────────────────────────────────────

Future<void> _showBrutalSuccessDialog({
  required BuildContext context,
  required String eventName,
}) async {
  await showDialog(
    context: context,
    barrierColor: Brutal.bg.withValues(alpha: 0.85),
    builder: (ctx) => Dialog(
      backgroundColor: Brutal.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Brutal.yellow.withValues(alpha: 0.12),
              child: const Icon(Icons.check, color: Brutal.yellow, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              'Ticket Purchased',
              style: Brutal.display(size: 24, color: Brutal.paper),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'You\'re going to $eventName',
              style: Brutal.body(size: 16, color: Brutal.dim),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(ctx).pop();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  color: Brutal.magenta,
                  alignment: Alignment.center,
                  child: Text(
                    'View Tickets',
                    style: Brutal.label(size: 13, color: Brutal.paper),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Reusable Brutal UI components ─────────────────────────────────────────────

class _BrutalSectionCard extends StatelessWidget {
  const _BrutalSectionCard({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Brutal.elevated,
        border: Border.all(color: Brutal.hairlineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 2, height: 16, color: Brutal.magenta),
              const SizedBox(width: 8),
              Icon(icon, size: 14, color: Brutal.magenta),
              const SizedBox(width: 6),
              Text(label, style: Brutal.display(size: 16, color: Brutal.paper)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _BrutalRow extends StatelessWidget {
  const _BrutalRow({
    required this.leading,
    required this.trailing,
    this.trailingColor,
    this.trailingBold = false,
  });

  final String leading;
  final String trailing;
  final Color? trailingColor;
  final bool trailingBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(leading, style: Brutal.body(size: 16, color: Brutal.dim)),
        Text(
          trailing,
          style: trailingBold
              ? Brutal.display(size: 16, color: trailingColor ?? Brutal.paper)
              : Brutal.body(size: 16, color: trailingColor ?? Brutal.dim),
        ),
      ],
    );
  }
}

class _AttendeeRow extends StatelessWidget {
  const _AttendeeRow({
    required this.name,
    required this.index,
    required this.color,
  });

  final String name;
  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(width: 4, height: 4, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name.trim().isEmpty ? 'Attendee ${index + 1}' : name,
              style: Brutal.body(size: 16, color: Brutal.paper),
            ),
          ),
        ],
      ),
    );
  }
}

enum PaymentMethod { card, applePay, googlePay, payAtDoor }

class _BrutalPaymentTile extends StatelessWidget {
  const _BrutalPaymentTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.08) : Brutal.elevated,
          border: Border.all(
            color: isSelected ? accentColor : Brutal.hairlineColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              color: accentColor.withValues(alpha: 0.12),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Brutal.body(size: 16, color: Brutal.paper)),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: Brutal.body(size: 14, color: Brutal.mute)),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(3),
                color: accentColor,
                child: const Icon(Icons.check, color: Brutal.bg, size: 14),
              ),
          ],
        ),
      ),
    );
  }
}
