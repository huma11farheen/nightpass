import 'dart:convert';

import 'package:clubship/supabase/config.dart';
import 'package:clubship/supabase/supabase_client.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Searches Google Places Nearby Search for bars and clubs in Tokyo,
/// upserts results into the `club` table (partner_club = false),
/// and marks permanently-closed venues as is_active = false.
class PlacesService {
  static const _baseUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

  // Tokyo station — centre of the search
  static const _tokyoLat = 35.6762;
  static const _tokyoLng = 139.6503;
  // 15 km radius covers most of central Tokyo nightlife
  static const _radiusMeters = 15000;

  // Only sync if last sync was more than 24 hours ago.
  static const _cacheTtl = Duration(hours: 24);

  static String get _apiKey => Config.get('PLACES_REST_API');

  /// Fetches venues from Google Places and upserts them into Supabase.
  /// Returns the number of venues synced, or -1 if sync was skipped (still fresh).
  static Future<int> syncVenues() async {
    // Check when we last synced — skip if within TTL
    try {
      final lastSync = await supabase
          .from('club')
          .select('last_synced_at')
          .eq('partner_club', false)
          .not('last_synced_at', 'is', null)
          .order('last_synced_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (lastSync != null) {
        final ts = DateTime.tryParse(lastSync['last_synced_at'] as String? ?? '');
        if (ts != null && DateTime.now().difference(ts) < _cacheTtl) {
          debugPrint('PlacesService: cache still fresh, skipping sync');
          return -1;
        }
      }
    } catch (e) {
      debugPrint('PlacesService: cache check error — $e');
    }

    final seen = <String>{};
    final venues = <Map<String, dynamic>>[];

    // Fetch both bars and night clubs — deduplicate by place_id
    for (final type in ['bar', 'night_club']) {
      final results = await _fetchNearby(type);
      for (final v in results) {
        final pid = v['place_id'] as String?;
        if (pid != null && seen.add(pid)) {
          venues.add(v);
        }
      }
    }

    if (venues.isEmpty) {
      debugPrint('PlacesService: no results from Places API');
      return 0;
    }

    debugPrint('PlacesService: upserting ${venues.length} unique venues');
    await _upsertVenues(venues);
    return venues.length;
  }

  static Future<List<Map<String, dynamic>>> _fetchNearby(String type) async {
    final results = <Map<String, dynamic>>[];
    String? pageToken;

    // Places returns max 60 results over 3 pages
    do {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'location': '$_tokyoLat,$_tokyoLng',
        'radius': '$_radiusMeters',
        'type': type,
        'key': _apiKey,
        'language': 'en',
        if (pageToken != null) 'pagetoken': pageToken,
      });

      final response = await http.get(uri);
      if (response.statusCode != 200) {
        debugPrint('PlacesService: HTTP ${response.statusCode} for type=$type');
        break;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final status = body['status'] as String?;

      if (status == 'REQUEST_DENIED' || status == 'INVALID_REQUEST') {
        debugPrint('PlacesService: Places API error — $status: ${body['error_message']}');
        break;
      }

      final places = (body['results'] as List? ?? []).cast<Map<String, dynamic>>();
      for (final place in places) {
        final businessStatus = place['business_status'] as String?;
        final location = (place['geometry']?['location']) as Map<String, dynamic>?;
        if (location == null) continue;

        final venueType = type == 'night_club' ? 'club' : 'bar';

        results.add({
          'place_id': place['place_id'] as String?,
          'name': place['name'] as String? ?? 'Unknown',
          'lat': (location['lat'] as num).toDouble(),
          'lng': (location['lng'] as num).toDouble(),
          'area': _extractArea(place),
          'rating': (place['rating'] as num?)?.toDouble(),
          'image': _photoUrl(place),
          'venue_type': venueType,
          'is_active': businessStatus != 'CLOSED_PERMANENTLY' && businessStatus != 'CLOSED_TEMPORARILY',
          'business_status': businessStatus ?? 'OPERATIONAL',
          'google_maps_url':
              'https://www.google.com/maps/place/?q=place_id:${place['place_id']}',
        });
      }

      pageToken = body['next_page_token'] as String?;
      // Google requires a short delay before using next_page_token
      if (pageToken != null) await Future.delayed(const Duration(seconds: 2));
    } while (pageToken != null);

    return results;
  }

  static String? _photoUrl(Map<String, dynamic> place) {
    final photos = place['photos'] as List?;
    if (photos == null || photos.isEmpty) return null;
    final ref = (photos.first as Map<String, dynamic>)['photo_reference'] as String?;
    if (ref == null) return null;
    return 'https://maps.googleapis.com/maps/api/place/photo'
        '?maxwidth=800&photo_reference=$ref&key=$_apiKey';
  }

  static String? _extractArea(Map<String, dynamic> place) {
    final terms = place['vicinity'] as String?;
    if (terms == null) return null;
    // vicinity is like "2 Chome-14-5, Roppongi, Minato City" — take last comma segment
    final parts = terms.split(',');
    return parts.length > 1 ? parts.last.trim() : terms;
  }

  static Future<void> _upsertVenues(List<Map<String, dynamic>> venues) async {
    final now = DateTime.now().toUtc().toIso8601String();

    // Build upsert rows — only set fields that Places provides.
    // Required Club fields get sensible defaults so fromJson doesn't crash.
    final rows = venues.map((v) => {
      'place_id': v['place_id'],
      'name': v['name'],
      'lat': v['lat'],
      'lng': v['lng'],
      'area': v['area'],
      'rating': v['rating'],
      'image': v['image'],
      'venue_type': v['venue_type'],
      'is_active': v['is_active'],
      'google_maps_url': v['google_maps_url'],
      'partner_club': false,
      'last_synced_at': now,
      // Required fields with defaults
      'opening_time': '',
      'closing_time': '',
      'description': '',
      'female_price': 0.0,
      'men_price': 0.0,
      'female_drink_ticket': 0,
      'male_drink_ticket': 0,
      'guestlist': 0,
      'guestlist_discount': 0.0,
    }).toList();

    // Upsert on place_id — updates existing rows, inserts new ones.
    // Rows without a place_id (shouldn't happen) are skipped.
    final withPlaceId = rows.where((r) => r['place_id'] != null).toList();
    if (withPlaceId.isEmpty) return;

    try {
      // Delete existing Places-synced rows then re-insert fresh
      await supabase.from('club').delete().eq('partner_club', false);

      // Insert in batches of 20
      const batchSize = 20;
      for (var i = 0; i < withPlaceId.length; i += batchSize) {
        final batch = withPlaceId.sublist(i, (i + batchSize).clamp(0, withPlaceId.length));
        await supabase.from('club').insert(batch);
      }
      debugPrint('PlacesService: inserted ${withPlaceId.length} venues');
    } catch (e) {
      debugPrint('PlacesService: insert FAILED — $e');
    }
  }
}
