import 'package:clubship/data/supabase_models/venue.dart';
import 'package:clubship/supabase/supabase_client.dart';
import 'package:flutter/foundation.dart';

/// Thin result type kept so all existing call sites compile unchanged.
class PlacesResult {
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String? photoUrl;
  final bool? openNow;
  /// 'bar' | 'club' — sourced from the venue table's venue_type column.
  final String venueType;

  const PlacesResult({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.photoUrl,
    this.openNow,
    this.venueType = 'bar',
  });

  PlacesResult withPhoto(String? url) => PlacesResult(
        name: name,
        address: address,
        lat: lat,
        lng: lng,
        photoUrl: url,
        openNow: openNow,
        venueType: venueType,
      );

  static PlacesResult fromVenue(Venue v) => PlacesResult(
        name: v.name,
        address: v.area ?? 'Tokyo',
        lat: v.lat,
        lng: v.lng,
        photoUrl: v.image,
        openNow: null,
        venueType: v.venueType, // 'bar' or 'club'
      );
}

/// Fetches venues from the Supabase `venue` table.
class PlacesPhotoService {
  static List<PlacesResult>? _cache;

  static Future<List<PlacesResult>> searchBarsInTokyo() async {
    if (_cache != null) return _cache!;

    try {
      final data = await supabase
          .from(Venue.modelName)
          .select('*')
          .eq('is_active', true)
          .order('name');

      final venues = data.map<Venue>((e) => Venue.fromJson(e)).toList();
      _cache = venues.map(PlacesResult.fromVenue).toList();
      return _cache!;
    } catch (e) {
      debugPrint('PlacesPhotoService (Supabase) error: $e');
      return [];
    }
  }

  static void clearCache() => _cache = null;

  static Future<String?> getPhotoUrl(String clubName) async {
    try {
      final data = await supabase
          .from(Venue.modelName)
          .select('image')
          .eq('name', clubName)
          .maybeSingle();
      return data?['image'] as String?;
    } catch (e) {
      debugPrint('PlacesPhotoService.getPhotoUrl error: $e');
      return null;
    }
  }

  static Future<bool?> getOpenNow(String venueName) async => null;
}
