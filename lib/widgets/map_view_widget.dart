import 'dart:convert';
import 'package:clubship/supabase/config.dart';
import 'package:clubship/utils/map_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MapViewWidget extends StatefulWidget {
  const MapViewWidget({
    super.key,
    required this.lat,
    required this.lon,
    this.locationName,
    this.locationAddress,
  });
  final double lat;
  final double lon;
  final String? locationName;
  final String? locationAddress;

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  GoogleMapController? _controller;
  late double _lat;
  late double _lon;
  bool _resolved = false;

  static const _darkMapStyle = '''[
    {"elementType":"geometry","stylers":[{"color":"#2c2c3e"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#c0c0d0"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#1e1e2e"}]},
    {"featureType":"road","elementType":"geometry","stylers":[{"color":"#3d3d58"}]},
    {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#252538"}]},
    {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#4a4a6a"}]},
    {"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#9090a8"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#1a2a4a"}]},
    {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#4a6080"}]},
    {"featureType":"landscape","elementType":"geometry","stylers":[{"color":"#262638"}]},
    {"featureType":"poi","stylers":[{"visibility":"off"}]},
    {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#1e3a2e"},{"visibility":"on"}]},
    {"featureType":"transit","stylers":[{"visibility":"simplified"}]},
    {"featureType":"transit.station","elementType":"labels.text.fill","stylers":[{"color":"#a0a0c0"}]}
  ]''';

  bool get _hasCoords => _lat != 0.0 || _lon != 0.0;

  @override
  void initState() {
    super.initState();
    _lat = widget.lat;
    _lon = widget.lon;
    if (!_hasCoords) {
      // Prefer full address for accuracy, fall back to name
      final query = widget.locationAddress?.isNotEmpty == true
          ? widget.locationAddress!
          : (widget.locationName?.isNotEmpty == true ? widget.locationName! : null);
      if (query != null) {
        _geocode(query);
      } else {
        _resolved = true;
      }
    } else {
      _resolved = true;
    }
  }

  Future<void> _geocode(String query) async {
    try {
      final encoded = Uri.encodeComponent(
          query.contains('Japan') ? query : '$query Tokyo Japan');
      final apiKey = Config.get('PLACE_API');
      final uri = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=$encoded&key=$apiKey');
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final results = json['results'] as List?;
        if (results != null && results.isNotEmpty) {
          final location = results.first['geometry']['location'];
          if (mounted) {
            setState(() {
              _lat = (location['lat'] as num).toDouble();
              _lon = (location['lng'] as num).toDouble();
              _resolved = true;
            });
            _controller?.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(target: LatLng(_lat, _lon), zoom: 16.0),
            ));
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('MapViewWidget geocode error: $e');
    }
    if (mounted) setState(() => _resolved = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show map until geocoding is done (avoids flash at 0,0)
    if (!_resolved) {
      return const SizedBox(
        height: 150,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF1FA3)),
        ),
      );
    }

    // Still no coords after geocode — show placeholder
    if (!_hasCoords) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 150,
      child: GoogleMap(
        onMapCreated: (controller) {
          _controller = controller;
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _controller?.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(target: LatLng(_lat, _lon), zoom: 16.0),
              ));
            }
          });
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(_lat, _lon),
          zoom: 16.0,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('venue'),
            position: LatLng(_lat, _lon),
            onTap: () => MapUtils.openMap(_lat, _lon,
                locationName: widget.locationName),
          ),
        },
        gestureRecognizers: {
          Factory(() => PanGestureRecognizer()),
        },
        zoomGesturesEnabled: false,
        zoomControlsEnabled: false,
        scrollGesturesEnabled: false,
        compassEnabled: false,
        mapToolbarEnabled: false,
        style: _darkMapStyle,
      ),
    );
  }
}
