import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/utils/places_service.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClubRepository {
  final SupabaseClient supabase;

  ClubRepository(this.supabase);

  Future<List<Club>> getClubs() async {
    final clubs = await supabase
        .from(Club.modelName)
        .select('*')
        .eq('partner_club', true)
        .withConverter(
            (data) => data.map((e) => Club.fromJson(e)).toList());
    return clubs;
  }

  /// Syncs venues from Google Places (respects 24h cache), then reads from DB.
  /// Filters out is_active = false (permanently/temporarily closed venues).
  Future<List<Club>> getAllVenuesForMap({String? venueType}) async {
    // Sync first — this is fast if cache is fresh (returns -1 immediately)
    try {
      final count = await PlacesService.syncVenues();
      if (count > 0) debugPrint('PlacesService: synced $count venues');
    } catch (e) {
      debugPrint('PlacesService: sync error — $e');
    }

    var query = supabase
        .from(Club.modelName)
        .select('*')
        .eq('partner_club', false)
        .eq('is_active', true);
    if (venueType != null) {
      query = query.eq('venue_type', venueType);
    }
    final data = await query.order('name');
    return data.map<Club>((e) => Club.fromJson(e)).toList();
  }
}
