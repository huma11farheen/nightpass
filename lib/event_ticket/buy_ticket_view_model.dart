import 'dart:math';

import 'package:clubship/event/event_view_model.dart';
import 'package:clubship/event_ticket/buy_ticket_state.dart';
import 'package:clubship/repository/ticket_repository.dart';
import 'package:clubship/repository/users_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TicketType { entry, drink }

class ButTicketViewModel extends StateNotifier<BuyTicketState> {
  ButTicketViewModel({
    required this.userRepository,
    required this.ticketRepository,
  }) : super(const BuyTicketState());

  final TicketRepository ticketRepository;
  final UserRepository userRepository;

  void setEvent(EventViewModel eevnt) {
    state = state.copyWith(
      eventId: eevnt.id,
      event: eevnt,
      maleTicketCount: 0,
      femaleTicketCount: 0,
      femaleAttendee: [],
      maleAttendee: [],
      totalPrice: 0,
      availableGuestlist: eevnt.gustlist - eevnt.registeredGuestlist,
      loading: false,
    );
  }

  /*
   * GUESTLIST LOGIC EXPLANATION:
   *
   * Expected Behavior:
   * - Female tickets use guestlist spots first (free tickets)
   * - Once guestlist is exhausted, female tickets become paid
   * - Male tickets are ALWAYS paid (never use guestlist)
   *
   * Example scenario (3 guestlist spots available):
   * 1. Add 1 female ticket → guestlist: 2, total: ¥0 (female uses guestlist)
   * 2. Add 1 male ticket → guestlist: 2, total: ¥1000 (male is paid)
   * 3. Add 1 female ticket → guestlist: 1, total: ¥1000 (female uses guestlist)
   * 4. Add 1 female ticket → guestlist: 0, total: ¥1000 (female uses last guestlist)
   * 5. Add 1 female ticket → guestlist: 0, total: ¥1500 (female becomes paid)
   *
   * Backend should create tickets with:
   * - First 3 female tickets: isGuestlist = true, price = 0
   * - 4th female ticket: isGuestlist = false, price = 500
   * - All male tickets: isGuestlist = false, price = 1000
   */

  void setPrice({required double menPrice, required double womenPrice}) {
    state =
        state.copyWith(womenTicketPrice: womenPrice, menTicketPrice: menPrice, loading: false);
  }

  void incrementFemaleTickets() {
    // If female ticket is free (price == 0), cap at available guestlist spots
    if (state.womenTicketPrice == 0 && state.availableGuestlist <= 0) return;

    final newCount = state.femaleTicketCount + 1;

    // Only decrement guestlist if spots are available
    final willUseGuestlistSpot = state.availableGuestlist > 0;
    final newGuestlistAvailable = willUseGuestlistSpot
        ? state.availableGuestlist - 1
        : state.availableGuestlist;

    // Calculate how many female tickets are paid vs free (guestlist)
    // Use spots used by THIS USER, not total spots used globally
    final totalGuestlistCapacity = state.event?.gustlist ?? 0;
    final initialAvailableGuestlist = totalGuestlistCapacity - (state.event?.registeredGuestlist ?? 0);
    final guestlistSpotsUsedByThisUser = initialAvailableGuestlist - newGuestlistAvailable;
    final paidFemaleTickets = max(0, newCount - guestlistSpotsUsedByThisUser);

    final newTotalPrice = (paidFemaleTickets * state.womenTicketPrice) +
                         (state.maleTicketCount * state.menTicketPrice);

    state = state.copyWith(
        availableGuestlist: newGuestlistAvailable,
        femaleTicketCount: newCount,
        totalPrice: newTotalPrice);
  }

  void decrementFemaleTickets() {
    if (state.femaleTicketCount <= 0) return; // Prevent going below 0

    final newCount = state.femaleTicketCount - 1;
    final updatedAttendees = state.femaleAttendee.length > newCount
        ? state.femaleAttendee.sublist(0, newCount)
        : state.femaleAttendee;

    // Determine if we should restore a guestlist spot
    // We restore a spot if the ticket being removed was using a guestlist spot from THIS USER's session
    final totalGuestlistCapacity = state.event?.gustlist ?? 0;
    final initialAvailableGuestlist = totalGuestlistCapacity - (state.event?.registeredGuestlist ?? 0);
    final guestlistSpotsUsedByThisUser = initialAvailableGuestlist - state.availableGuestlist;
    final wasUsingGuestlistSpot = state.femaleTicketCount <= guestlistSpotsUsedByThisUser;

    final newGuestlistAvailable = wasUsingGuestlistSpot
        ? min(totalGuestlistCapacity, state.availableGuestlist + 1)
        : state.availableGuestlist;

    // Calculate how many female tickets are paid vs free (guestlist)
    // Use spots used by THIS USER, not total spots used globally
    final guestlistSpotsUsedByThisUserAfter = initialAvailableGuestlist - newGuestlistAvailable;
    final paidFemaleTickets = max(0, newCount - guestlistSpotsUsedByThisUserAfter);

    final newTotalPrice = (paidFemaleTickets * state.womenTicketPrice) +
                         (state.maleTicketCount * state.menTicketPrice);

    state = state.copyWith(
        availableGuestlist: newGuestlistAvailable,
        femaleTicketCount: newCount,
        femaleAttendee: updatedAttendees,
        totalPrice: newTotalPrice);
  }

  void incrementMaleTickets() {
    state = state.copyWith(
        maleTicketCount: state.maleTicketCount + 1,
        totalPrice: state.totalPrice + state.menTicketPrice);
  }

  void decrementMaleTickets() {
    final newCount = state.maleTicketCount - 1;
    final updatedAttendees = state.maleAttendee.length > newCount
        ? state.maleAttendee.sublist(0, newCount)
        : state.maleAttendee;

    state = state.copyWith(
        maleTicketCount: newCount,
        maleAttendee: updatedAttendees,
        totalPrice: state.totalPrice - state.menTicketPrice);
  }

  bool areAllFieldsFilled() {
    final femaleValid =
        state.femaleAttendee.length == state.femaleTicketCount &&
            state.femaleAttendee.every((name) => name.trim().isNotEmpty);

    final maleValid = state.maleAttendee.length == state.maleTicketCount &&
        state.maleAttendee.every((name) => name.trim().isNotEmpty);

    return femaleValid && maleValid;
  }

  void updateFemaleAttendeeName(int index, String name) {
    final list = [...state.femaleAttendee];

    // Safely grow the list and fill missing elements with empty strings
    while (list.length <= index) {
      list.add('');
    }

    list[index] = name;
    state = state.copyWith(femaleAttendee: list);
  }

  void updateMaleAttendeeName(int index, String name) {
    final list = [...state.maleAttendee];

    while (list.length <= index) {
      list.add('');
    }

    list[index] = name;
    state = state.copyWith(maleAttendee: list);
  }
}
