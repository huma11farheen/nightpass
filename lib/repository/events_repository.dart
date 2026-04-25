import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/data/supabase_models/event.dart';
import 'package:clubship/data/supabase_models/event_category.dart';
import 'package:clubship/data/supabase_models/event_ticket.dart';
import 'package:clubship/event/event_view_model.dart';
import 'package:clubship/my_page/order_history/order_history_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventsRepository {
  final SupabaseClient supabase;

  EventsRepository(this.supabase);

  Future<List<EventViewModel>> fetchUpcomingEvents(
      {EventCategory? category}) async {
    // Use device's local time
    final now = DateTime.now();
    final today = now.toIso8601String();

    if (category?.id == 'all') {
      final events = await supabase
          .from(Event.modelName)
          .select('*, ${Club.modelName}(*)')
          .gte(
            'end_date',  // Check end_date to show ongoing events
            today,
          )
          .order('start_date', ascending: true);

      final allEvents = events.map((item) => _convertToViewModel(item)).toList();

      // Filter out events that have already ended (using local device time)
      final openEvents = allEvents.where((event) {
        final endDate = DateTime.parse(event.endDate);
        return endDate.isAfter(now);
      }).toList();

      return openEvents;
    }
    if (category != null) {
      return getEventsByCategory(category.id);
    }
    final events = await supabase
        .from(Event.modelName)
        .select('*, ${Club.modelName}(*)')
        .gte(
          'end_date',  // Check end_date to show ongoing events
          today,
        )
        .order('start_date', ascending: true);

    final allEvents = events.map((item) => _convertToViewModel(item)).toList();

    // Filter out events that have already ended (using local device time)
    final List<EventViewModel> openEvents = allEvents.where((event) {
      final endDate = DateTime.parse(event.endDate);
      return endDate.isAfter(now);
    }).toList();

    return openEvents;
  }

  Future<List<EventViewModel>> getEventsByCategory(String categoryId) async {
    try {
      // Use device's local time
      final now = DateTime.now();
      final today = now.toIso8601String();

      final events = await supabase
          .from(Event.modelName)
          .select('*,${Club.modelName}(*)')
          .contains('category', [categoryId])
          .gte(
            'end_date',  // Check end_date to show ongoing events
            today,
          )
          .order('start_date', ascending: true);

      final allEvents = events.map((item) => _convertToViewModel(item)).toList();

      // Filter out events that have already ended (using local device time)
      final openEvents = allEvents.where((event) {
        final endDate = DateTime.parse(event.endDate);
        return endDate.isAfter(now);
      }).toList();

      return openEvents;
    } catch (e) {
      return [];
    }
  }

  Future<List<EventCategory>> getCategories() async {
    final categories = await supabase.from(EventCategory.modelName).select('*');
    return categories.map((item) => EventCategory.fromJson(item)).toList();
  }

  EventViewModel _convertToViewModel(
    Map<String, dynamic> item,
  ) {
    final club = Club.fromJson(item['club']);

    EventViewModel viewModel = EventViewModel(
        id: item['id'],
        createdAt: item['created_at'],
        name: item['name'],
        image: item['image'],

        description: item['description'],
        femalePrice: (item['female_price'] as num).toDouble(),
        startDate: item['start_date'],
        endDate: item['end_date'],
        subImages: (item['sub_images'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        category: (item['category'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        pending: item['pending'],
        checkedIn: item['checked_in'],
        clubId: item['club_id'],
        malePrice: (item['male_price'] as num).toDouble(),
        isRecurring: item['is_recurring'],
        // Handles nested category name
        locationAddress: club.locationAddress ?? '',
        freeFemaleDrinkTicket: item['free_female_drink_ticket'],
        freeMaleDrinkTicket: item['free_male_drink_ticket'],
        gustlist: item['guestlist'],
        registeredGuestlist: item['registered_guestlist'],
        payAtTheDoor: item['pay_at_the_door_available'],
        isServiceTaxIncluded: item['is_service_tax_included'] as bool? ?? false,
        club: club);

    return viewModel;
  }

  Future<List<OrderHistoryViewModel>> fetchOrderHistory() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final list = await supabase
          .from(EventTicket.modelName)
          .select('*, ${Club.modelName}(*), ${Event.modelName}(*)')
          .eq('user_id', userId)  // Only show tickets you currently own
          .order('created_at', ascending: false)
          .withConverter(
            (data) =>
                data.map((e) => _convertToOrderHistoryViewModel(e)).toList(),
          );

      return list;
    } catch (e) {
      throw Exception('Failed to fetch order history');
    }
  }

  OrderHistoryViewModel _convertToOrderHistoryViewModel(
    Map<String, dynamic> item,
  ) {
    final club = Club.fromJson(item['club']);
    final event = Event.fromJson(item['event']);
    final eventTicket = EventTicket.fromJson(item);

    OrderHistoryViewModel viewModel = OrderHistoryViewModel(
        club: club, event: event, eventTicket: eventTicket);

    return viewModel;
  }
}
