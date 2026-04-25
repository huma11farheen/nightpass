
import 'package:clubship/utils/map_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  const MapView({super.key, required this.lat, required this.lon});
  final double lat;
  final double lon;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {

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
          },

          initialCameraPosition: CameraPosition(
            target: LatLng(widget.lat, widget.lon),
            // Set the initial map position
            zoom: 12.0, // Set the initial zoom level
          ),
          markers: {
            Marker(
              onTap: (){
                MapUtils.openMap(widget.lat, widget.lon);
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