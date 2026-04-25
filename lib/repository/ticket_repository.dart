import 'package:clubship/data/supabase_models/drink_ticket.dart';
import 'package:clubship/data/supabase_models/event_ticket.dart';
import 'package:clubship/event_ticket/providers/drink_ticket_view_model.dart';
import 'package:clubship/utils/supabase_functions.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

enum ApiResult { success, failure }

class TicketRepository {
  final SupabaseClient supabase;

  TicketRepository(this.supabase);

  Stream<List<DrinkTicketViewModel>> streamDrinkTicketsForUser() {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return const Stream.empty();

    // Stream with event join to get event end date
    final query = supabase
        .from(DrinkTicket.modelName)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('expiry_date');

    return query.asyncMap((rows) async {
      if (rows.isEmpty) return <DrinkTicketViewModel>[];

      // Get all unique event IDs
      final eventIds = rows
          .map((row) => row['event_id'])
          .where((id) => id != null)
          .toSet()
          .toList();

      // Batch fetch all events at once
      Map<String, dynamic> eventsMap = {};
      if (eventIds.isNotEmpty) {
        try {
          final eventsResponse = await supabase
              .from('events')
              .select()
              .inFilter('id', eventIds);

          for (final event in eventsResponse) {
            eventsMap[event['id']] = event;
          }
        } catch (e) {
          // Error fetching events, continue without event data
        }
      }

      // Map tickets with their corresponding event data
      return rows.map((row) {
        final ticketData = Map<String, dynamic>.from(row);
        final eventId = ticketData['event_id'];

        if (eventId != null && eventsMap.containsKey(eventId)) {
          ticketData['event'] = eventsMap[eventId];
        }

        return DrinkTicketViewModel.fromResponseData(ticketData);
      }).toList();
    });
  }

  Stream<List<EventTicket>> streamEventTicketsForUser() {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return const Stream.empty();

    final query = supabase
        .from(EventTicket.modelName)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return query.asyncMap((rows) async {
      if (rows.isEmpty) return <EventTicket>[];

      // Get all unique club IDs
      final clubIds = rows
          .map((row) => row['club_id'])
          .where((id) => id != null)
          .toSet()
          .toList();

      // Batch fetch all clubs at once
      Map<String, String> clubNamesMap = {};
      if (clubIds.isNotEmpty) {
        try {
          final clubsResponse = await supabase
              .from('club')
              .select('id, name')
              .inFilter('id', clubIds);

          for (final club in clubsResponse) {
            clubNamesMap[club['id']] = club['name'];
          }
        } catch (e) {
          // Error fetching clubs, continue without club data
        }
      }

      // Map tickets with their corresponding club name
      return rows.map((row) {
        final ticketData = Map<String, dynamic>.from(row);
        final clubId = ticketData['club_id'];

        if (clubId != null && clubNamesMap.containsKey(clubId)) {
          ticketData['club_name'] = clubNamesMap[clubId];
        }

        return EventTicket.fromJson(ticketData);
      }).toList();
    });
  }

  Future<ApiResult> buyTicket({
    required String eventId,
    required int femaleCount,
    required int maleCount,
    required bool payLater,
    required List<String> femaleList,
    required List<String> maleList,
    bool skipGuestlist = false,
  }) async {
    try {
      await SupabaseFunctions.of(supabase).invoke('buy-ticket', body: {
        'eventId': eventId,
        'femaleTicketCount': femaleCount,
        'maleTicketCount': maleCount,
        'payLater': payLater,
        'femaleAttendee': femaleList,
        'maleAttendee': maleList,
        'skipGuestlist': skipGuestlist,
      });
      return ApiResult.success;
    } catch (e) {
      print(e);
      print('Failed');
      return ApiResult.failure;
    }
  }

  Future<ApiResult> addToGuestlist({
    required String eventId,
    required int femaleCount,
    required int maleCount,
    required bool isGuestlist,
    required List<String> femaleList,
    required List<String> maleList,
  }) async {
    try {
      await SupabaseFunctions.of(supabase).invoke('add-to-guestlist', body: {
        'eventId': eventId,
        'femaleTicketCount': femaleCount,
        'maleTicketCount': maleCount,
        'femaleAttendee': femaleList,
        'maleAttendee': maleList,
      });

      return ApiResult.success;
    } catch (e) {
      return ApiResult.failure;
    }
  }

  Future<void> removeDrinkTicket(String userId, String ticketId) async {
    // try {
    //   // Get a reference to the user's document
    //   final userDocRef =
    //       FirebaseFirestore.instance.collection('users').doc(userId);
    //
    //   // Get a reference to the drink ticket document within the user's subcollection
    //   final ticketDocRef = userDocRef.collection('drink_tickets').doc(ticketId);
    //
    //   // Delete the drink ticket document
    //   await ticketDocRef.delete();
    //   print('Drink ticket removed successfully');
    // } catch (e) {
    //   print('Error removing drink ticket: $e');
    // }
  }
}
