import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// A real event pulled from Resident Advisor's public GraphQL endpoint.
class RaEvent {
  final String id;
  final String title;
  final String venueName;
  final String areaName;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<String> artists;
  final String? imageUrl;
  final String eventUrl;

  const RaEvent({
    required this.id,
    required this.title,
    required this.venueName,
    required this.areaName,
    required this.startTime,
    required this.endTime,
    required this.artists,
    required this.imageUrl,
    required this.eventUrl,
  });

  factory RaEvent.fromJson(Map<String, dynamic> json) {
    final venue = json['venue'] as Map<String, dynamic>?;
    final images = json['images'] as List<dynamic>? ?? [];
    final artists = json['artists'] as List<dynamic>? ?? [];

    return RaEvent(
      id: json['id'].toString(),
      title: json['title'] as String? ?? 'Untitled',
      venueName: venue?['name'] as String? ?? 'TBA',
      areaName: (venue?['area'] as Map<String, dynamic>?)?['name'] as String? ??
          'Tokyo',
      startTime: DateTime.tryParse(json['startTime'] as String? ?? ''),
      endTime: DateTime.tryParse(json['endTime'] as String? ?? ''),
      artists: artists
          .map((a) => (a as Map<String, dynamic>)['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList(),
      imageUrl: images.isNotEmpty
          ? (images.first as Map<String, dynamic>)['filename'] as String?
          : null,
      eventUrl: 'https://ra.co${json['contentUrl'] ?? ''}',
    );
  }

  bool get isLiveNow {
    final now = DateTime.now();
    if (startTime == null || endTime == null) return false;
    return now.isAfter(startTime!) && now.isBefore(endTime!);
  }

  bool get isStartingSoon {
    final now = DateTime.now();
    if (startTime == null || isLiveNow) return false;
    final untilStart = startTime!.difference(now);
    return untilStart.inMinutes >= 0 && untilStart.inMinutes <= 90;
  }
}

/// Fetches events happening today in Tokyo from Resident Advisor.
///
/// Unofficial public endpoint (the same one ra.co's own site uses) — no API
/// key, but it can change without notice. Prototype-grade.
class RaEventsService {
  static const _endpoint = 'https://ra.co/graphql';
  static const _tokyoAreaId = 27;

  static const _query = r'''
query($filters: FilterInputDtoInput, $pageSize: Int, $page: Int) {
  eventListings(filters: $filters, pageSize: $pageSize, page: $page) {
    totalResults
    data {
      event {
        id
        title
        contentUrl
        startTime
        endTime
        images { filename }
        venue { name area { name } }
        artists { name }
      }
    }
  }
}
''';

  Future<List<RaEvent>> fetchTodaysTokyoEvents() async {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');
    // Include yesterday's listings so parties that started last night and are
    // still running (e.g. at 2am) show up as live.
    final yesterday = dateFormat.format(now.subtract(const Duration(days: 1)));
    final today = dateFormat.format(now);

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent':
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36',
        'Referer': 'https://ra.co/events/jp/tokyo',
      },
      body: jsonEncode({
        'query': _query,
        'variables': {
          'filters': {
            'areas': {'eq': _tokyoAreaId},
            'listingDate': {'gte': yesterday, 'lte': today},
          },
          'pageSize': 50,
          'page': 1,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Resident Advisor returned ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final listings = ((body['data']?['eventListings']?['data'])
            as List<dynamic>? ??
        []);

    final events = listings
        .map((item) =>
            RaEvent.fromJson((item as Map<String, dynamic>)['event']))
        .toList();

    // De-dup (an event can appear under both listing dates) and keep only
    // events that haven't ended yet.
    final seen = <String>{};
    final upcoming = events.where((event) {
      if (!seen.add(event.id)) return false;
      if (event.endTime == null) return true;
      return event.endTime!.isAfter(now);
    }).toList();

    // Live events first, then by start time.
    upcoming.sort((a, b) {
      if (a.isLiveNow != b.isLiveNow) return a.isLiveNow ? -1 : 1;
      final aStart = a.startTime ?? now;
      final bStart = b.startTime ?? now;
      return aStart.compareTo(bStart);
    });

    return upcoming;
  }
}

/// Today's Tokyo events, re-fetched every 2 minutes so statuses (LIVE /
/// STARTING SOON) and new listings stay current while the page is open.
final todaysRaEventsProvider =
    StreamProvider.autoDispose<List<RaEvent>>((ref) async* {
  final service = RaEventsService();
  yield await service.fetchTodaysTokyoEvents();
  yield* Stream.periodic(const Duration(minutes: 2))
      .asyncMap((_) => service.fetchTodaysTokyoEvents());
});
