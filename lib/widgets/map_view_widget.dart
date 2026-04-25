import 'package:clubship/utils/map_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapViewWidget extends StatefulWidget {
  const MapViewWidget({
    super.key,
    required this.lat,
    required this.lon,
    this.locationName,
  });
  final double lat;
  final double lon;
  final String? locationName;

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  GoogleMapController? _controller;
  bool _isMapReady = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
      const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16))),
      height: 150,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
            setState(() {
              _isMapReady = true;
            });
            // Small delay to ensure map is fully initialized
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted && _controller != null) {
                _controller!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(widget.lat, widget.lon),
                      zoom: 16.0,
                    ),
                  ),
                );
              }
            });
          },

          initialCameraPosition: CameraPosition(
            target: LatLng(widget.lat, widget.lon),
            // Set the initial map position
            zoom: 16.0, // Set the initial zoom level - street level view
          ),
          markers: {
            Marker(
              onTap: (){
                MapUtils.openMap(widget.lat, widget.lon, locationName: widget.locationName);
              },
              markerId: const MarkerId('kkk'),
              position: LatLng(widget.lat, widget.lon),
            )
          },
          gestureRecognizers: {
            Factory(() => PanGestureRecognizer()),
          },
          zoomGesturesEnabled: false,
          zoomControlsEnabled: false,
          scrollGesturesEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }
}