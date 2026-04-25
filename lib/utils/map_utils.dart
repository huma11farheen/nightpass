import 'package:url_launcher/url_launcher.dart';

class MapUtils {

  MapUtils._();

  static Future<void> openMap(double latitude, double longitude, {String? locationName}) async {
    // If location name is provided, use it in the query for better display
    // Otherwise fall back to coordinates
    final query = locationName != null && locationName.isNotEmpty
        ? Uri.encodeComponent(locationName)
        : '$latitude,$longitude';
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
    await _launchInBrowser(Uri.parse(googleUrl));
  }

  static Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
    )) {
      throw Exception('Could not launch $url');
    }
  }
}