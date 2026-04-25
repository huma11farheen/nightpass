import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clubship/supabase/config.dart';

class PlacesPhotoService {
  static const _cachePrefix = 'places_photo_';
  static const _photoWidth = 400;

  static String get _apiKey => Config.get('PLACE_API');

  // Returns a photo URL for the given club name, cached permanently.
  static Future<String?> getPhotoUrl(String clubName) async {
    final cacheKey = '$_cachePrefix${clubName.toLowerCase().replaceAll(' ', '_')}';

    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(cacheKey);
    if (cached != null) return cached.isEmpty ? null : cached;

    try {
      final photoRef = await _findPhotoReference(clubName);
      if (photoRef == null) {
        await prefs.setString(cacheKey, '');
        return null;
      }

      final photoUrl = _buildPhotoUrl(photoRef);
      await prefs.setString(cacheKey, photoUrl);
      return photoUrl;
    } catch (e) {
      debugPrint('PlacesPhotoService error for $clubName: $e');
      return null;
    }
  }

  static Future<String?> _findPhotoReference(String clubName) async {
    final uri = Uri.https('maps.googleapis.com', '/maps/api/place/findplacefromtext/json', {
      'input': '$clubName Tokyo nightclub',
      'inputtype': 'textquery',
      'fields': 'photos',
      'key': _apiKey,
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) return null;

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = json['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return null;

    final photos = candidates.first['photos'] as List?;
    if (photos == null || photos.isEmpty) return null;

    return photos.first['photo_reference'] as String?;
  }

  static String _buildPhotoUrl(String photoReference) {
    return 'https://maps.googleapis.com/maps/api/place/photo'
        '?maxwidth=$_photoWidth'
        '&photo_reference=$photoReference'
        '&key=$_apiKey';
  }
}
