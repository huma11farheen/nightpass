class Venue {
  static const modelName = "venue";

  final String id;
  final String createdAt;
  final String name;
  final String venueType; // 'bar' | 'club'
  final String? category;
  final String? area;
  final double lat;
  final double lng;
  final String? googleMapsUrl;
  final bool isPartner;
  final bool isVerified;
  final bool isActive;
  final List<String>? tags;
  final List<String>? musicGenres;
  final String? crowdType;
  final String? dressCode;
  final String? ageLimit;
  final double rating;
  final String? notes;
  final String? image;

  const Venue({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.venueType,
    this.category,
    this.area,
    required this.lat,
    required this.lng,
    this.googleMapsUrl,
    required this.isPartner,
    required this.isVerified,
    required this.isActive,
    this.tags,
    this.musicGenres,
    this.crowdType,
    this.dressCode,
    this.ageLimit,
    required this.rating,
    this.notes,
    this.image,
  });

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
        id: json['id'] as String,
        createdAt: json['created_at'] as String,
        name: json['name'] as String,
        venueType: json['venue_type'] as String,
        category: json['category'] as String?,
        area: json['area'] as String?,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        googleMapsUrl: json['google_maps_url'] as String?,
        isPartner: json['is_partner'] as bool? ?? false,
        isVerified: json['is_verified'] as bool? ?? true,
        isActive: json['is_active'] as bool? ?? true,
        tags: (json['tags'] as List?)?.cast<String>(),
        musicGenres: (json['music_genres'] as List?)?.cast<String>(),
        crowdType: json['crowd_type'] as String?,
        dressCode: json['dress_code'] as String?,
        ageLimit: json['age_limit'] as String?,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        notes: json['notes'] as String?,
        image: json['image'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt,
        'name': name,
        'venue_type': venueType,
        'category': category,
        'area': area,
        'lat': lat,
        'lng': lng,
        'google_maps_url': googleMapsUrl,
        'is_partner': isPartner,
        'is_verified': isVerified,
        'is_active': isActive,
        'tags': tags,
        'music_genres': musicGenres,
        'crowd_type': crowdType,
        'dress_code': dressCode,
        'age_limit': ageLimit,
        'rating': rating,
        'notes': notes,
        'image': image,
      };
}
