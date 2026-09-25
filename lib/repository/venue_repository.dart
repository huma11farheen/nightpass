import 'package:clubship/data/supabase_models/venue.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VenueRepository {
  final SupabaseClient supabase;

  VenueRepository(this.supabase);

  Future<List<Venue>> getVenues({String? type}) async {
    var query = supabase
        .from(Venue.modelName)
        .select('*')
        .eq('is_active', true);

    if (type != null) {
      query = query.eq('venue_type', type);
    }

    final data = await query.order('name');
    return data.map<Venue>((e) => Venue.fromJson(e)).toList();
  }

  Future<List<Venue>> getBars() => getVenues(type: 'bar');
  Future<List<Venue>> getClubVenues() => getVenues(type: 'club');
}
