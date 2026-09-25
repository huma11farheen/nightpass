import 'package:clubship/design/brutal.dart';
import 'package:clubship/whats_happening/ra_events_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

const _accentColors = [Brutal.magenta, Brutal.cyan, Brutal.yellow];
const _icons = [
  Icons.graphic_eq,
  Icons.bolt,
  Icons.nightlife,
  Icons.speaker,
  Icons.radio,
  Icons.album,
];

class WhatsHappeningPage extends ConsumerWidget {
  const WhatsHappeningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(todaysRaEventsProvider);

    return Scaffold(
      backgroundColor: Brutal.bg,
      body: RefreshIndicator(
        color: Brutal.magenta,
        backgroundColor: Brutal.card,
        onRefresh: () => ref.refresh(todaysRaEventsProvider.future),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _Header(),
            ),
            eventsAsync.when(
              data: (events) => _EventsSliver(events: events),
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: Brutal.magenta),
                ),
              ),
              error: (error, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorState(
                  onRetry: () => ref.invalidate(todaysRaEventsProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventsSliver extends StatelessWidget {
  final List<RaEvent> events;

  const _EventsSliver({required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'NOTHING ON TONIGHT',
            style: Brutal.label(size: 12, color: Brutal.mute),
          ),
        ),
      );
    }

    final liveCount = events.where((event) => event.isLiveNow).length;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return _LiveTickerBanner(
                total: events.length,
                liveCount: liveCount,
              );
            }
            final eventIndex = index - 1;
            return _EventCard(
              event: events[eventIndex],
              accentColor: _accentColors[eventIndex % _accentColors.length],
              icon: _icons[eventIndex % _icons.length],
            );
          },
          childCount: events.length + 1,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Brutal.bg,
      padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Brutal.magenta,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text('LIVE NOW',
                  style: Brutal.label(size: 11, color: Brutal.magenta)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "WHAT'S\nHAPPENING NOW",
            style: Brutal.display(size: 34, color: Brutal.paper),
          ),
          const SizedBox(height: 6),
          Text(
            'Real events live & starting soon in Tokyo',
            style: Brutal.body(size: 15, color: Brutal.mute),
          ),
        ],
      ),
    );
  }
}

class _LiveTickerBanner extends StatelessWidget {
  final int total;
  final int liveCount;

  const _LiveTickerBanner({required this.total, required this.liveCount});

  @override
  Widget build(BuildContext context) {
    final summary = liveCount > 0
        ? '$liveCount live now · $total events today'
        : '$total events happening today';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Brutal.card,
        border: Border.all(color: Brutal.hairlineColor, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department,
              color: Brutal.magenta, size: 16),
          const SizedBox(width: 8),
          Text(summary, style: Brutal.label(size: 11, color: Brutal.dim)),
          const Spacer(),
          Text('RA · TOKYO', style: Brutal.label(size: 10, color: Brutal.mute)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "COULDN'T LOAD EVENTS",
            style: Brutal.label(size: 12, color: Brutal.mute),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Brutal.magenta, width: 1.5),
              ),
              child: Text('RETRY',
                  style: Brutal.label(size: 12, color: Brutal.magenta)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final RaEvent event;
  final Color accentColor;
  final IconData icon;

  const _EventCard({
    required this.event,
    required this.accentColor,
    required this.icon,
  });

  String get _status {
    if (event.isLiveNow) return 'LIVE';
    if (event.isStartingSoon) return 'STARTING SOON';
    return 'TONIGHT';
  }

  String get _timeText {
    final format = DateFormat.Hm();
    final start =
        event.startTime != null ? format.format(event.startTime!) : '--:--';
    final end = event.endTime != null ? format.format(event.endTime!) : '';
    if (event.isLiveNow && end.isNotEmpty) return 'NOW · until $end';
    return end.isNotEmpty ? '$start – $end' : start;
  }

  String get _lineup {
    if (event.artists.isEmpty) return event.areaName.toUpperCase();
    return event.artists.take(3).join(' · ').toUpperCase();
  }

  Future<void> _openEventPage() async {
    final uri = Uri.parse(event.eventUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final isLive = event.isLiveNow;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Brutal.card,
        border: Border.all(color: Brutal.hairlineColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top accent strip
          Container(
            height: 3,
            color: accentColor,
          ),

          if (event.imageUrl != null)
            Image.network(
              event.imageUrl!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status + lineup row
                Row(
                  children: [
                    _StatusChip(
                        label: _status, isLive: isLive, color: accentColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _lineup,
                        style: Brutal.label(size: 10, color: Brutal.mute),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(icon, color: accentColor, size: 16),
                  ],
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  event.title.toUpperCase(),
                  style: Brutal.display(size: 24, color: Brutal.paper),
                ),

                const SizedBox(height: 6),

                // Venue
                Text(event.venueName,
                    style: Brutal.body(size: 15, color: Brutal.dim)),

                const SizedBox(height: 14),

                // Time row
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: Brutal.mute),
                    const SizedBox(width: 4),
                    Text(_timeText,
                        style: Brutal.label(size: 11, color: Brutal.dim)),
                    const Spacer(),
                    Text(event.areaName.toUpperCase(),
                        style: Brutal.label(size: 10, color: Brutal.mute)),
                  ],
                ),

                const SizedBox(height: 12),

                // CTA button
                GestureDetector(
                  onTap: _openEventPage,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: accentColor, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        'TICKETS & INFO',
                        style: Brutal.label(size: 12, color: accentColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isLive;
  final Color color;

  const _StatusChip(
      {required this.label, required this.isLive, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLive ? color.withValues(alpha: 0.15) : Brutal.elevated,
        border:
            Border.all(color: isLive ? color : Brutal.hairlineColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: Brutal.label(size: 10, color: isLive ? color : Brutal.mute)),
        ],
      ),
    );
  }
}
