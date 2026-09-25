import 'dart:async';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:clubship/design/brutal.dart';
import 'package:clubship/data/providers/club_repository_provider.dart';
import 'package:clubship/utils/map_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:clubship/clubs/club_list_page.dart';
import 'package:clubship/colors.dart';
import 'package:clubship/event/providers/get_events_provider.dart';
import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/event/event_card.dart';
import 'package:clubship/event/event_view_model.dart';
import 'package:clubship/router.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/widgets/cached_image.dart';
import 'package:flutter/foundation.dart' as flutter show Factory;
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

// ─── Brutal Hero Section ─────────────────────────────────────────────────────
// "Where to tonight?" title + tight club list + animated ticker
class PoppingTonight extends StatelessWidget {
  const PoppingTonight({super.key});

  static const _paper   = Color(0xFFF4F1EA);
  static const _magenta = Brutal.magenta;

  TextStyle _fraunces({
    required double size,
    required double weight,
    bool italic = false,
    required Color color,
    double letterSpacingEm = -0.04,
  }) {
    return TextStyle(
      fontFamily: 'Fraunces',
      fontSize: size,
      color: color,
      height: 0.82,
      letterSpacing: size * letterSpacingEm,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      fontVariations: [
        const FontVariation('opsz', 144),   // display cut — KEY
        FontVariation('wght', weight),
        const FontVariation('SOFT', 50),    // softer terminals
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("what's",
          style: _fraunces(
            size: 88, weight: 500, italic: true,
            color: _paper, letterSpacingEm: -0.02,
          ),
        ),
        Text('POPPING',
          style: _fraunces(size: 132, weight: 900, color: _magenta),
        ),
        Text('TONIGHT',
          style: _fraunces(size: 132, weight: 900, color: _paper),
        ),
      ],
    );
  }
}
class BrutalHeroSection extends ConsumerWidget {
  final VoidCallback? onSearchTap;
  const BrutalHeroSection({super.key, this.onSearchTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsProvider = ref.watch(clubListProvider);
    final clubs = clubsProvider.clubs;
    final allEvents = ref.watch(getEventsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Hero title block ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Editorial hero banner image
              Image.asset(
                'assets/images/whats_popping_banner.png',
                fit: BoxFit.fitWidth,
                width: double.infinity,
              ),

              const SizedBox(height: 14),

              // ── Search bar ───────────────────────────────────────────────
              _CyclingSearchBar(onTap: onSearchTap),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Ticker below search bar ────────────────────────────────────────
        allEvents.when(
          data: (events) => BrutalTickerBanner(events: events),
          loading: () => BrutalTickerBanner(events: const []),
          error: (_, __) => BrutalTickerBanner(events: const []),
        ),
      ],
    );
  }
}

// ─── Cycling search bar placeholder ──────────────────────────────────────────
class _CyclingSearchBar extends StatefulWidget {
  final VoidCallback? onTap;
  const _CyclingSearchBar({this.onTap});

  @override
  State<_CyclingSearchBar> createState() => _CyclingSearchBarState();
}

class _CyclingSearchBarState extends State<_CyclingSearchBar>
    with SingleTickerProviderStateMixin {
  static const _hints = [
    'Search club...',
    'Search venue...',
    'Search event...',
    'Search artist...',
    'Search night...',
  ];

  int _index = 0;
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _cycle());
  }

  void _cycle() async {
    await _ctrl.forward();
    if (!mounted) return;
    setState(() => _index = (_index + 1) % _hints.length);
    await _ctrl.reverse();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(
          color: Brutal.paper,
          borderRadius: BorderRadius.zero,
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Brutal.bg, size: 16),
            const SizedBox(width: 10),
            FadeTransition(
              opacity: _fade,
              child: Text(
                _hints[_index],
                style: Brutal.body(size: 15, color: Brutal.elevated),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Animated ticker ──────────────────────────────────────────────────────────
class BrutalTickerBanner extends StatefulWidget {
  final List<EventViewModel> events;
  const BrutalTickerBanner({super.key, required this.events});

  @override
  State<BrutalTickerBanner> createState() => _BrutalTickerBannerState();
}

class _BrutalTickerBannerState extends State<BrutalTickerBanner>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _offset = 0;
  Duration _last = Duration.zero;
  // pixels per second — fast enough to feel alive
  static const double _speed = 80;

  String get _tickerText {
    if (widget.events.isEmpty) {
      return '  SOLD OUT · CONTACT 80% · TICKETS MOVING · DOORS 22:00 · ';
    }
    final parts = <String>[];
    for (final e in widget.events.take(6)) {
      final price = e.femalePrice == 0 ? 'FREE' : '¥${e.femalePrice.toInt()}';
      final isOpen = isClubOpen(e.club.openingTime, e.club.closingTime, e.club.workingDay);
      parts.add('  ${e.name.toUpperCase()} · ${e.club.name.toUpperCase()} · $price · ${isOpen ? 'OPEN NOW' : 'DOORS TONIGHT'} · ');
    }
    return parts.join('★');
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (_last == Duration.zero) {
        _last = elapsed;
        return;
      }
      final dt = (elapsed - _last).inMicroseconds / 1e6;
      _last = elapsed;
      setState(() => _offset += _speed * dt);
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _tickerText;
    return Container(
      width: double.infinity,
      color: Brutal.magenta,
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: ClipRect(
        child: CustomPaint(
          painter: _TickerPainter(
            text: text,
            offset: _offset,
            style: Brutal.label(size: 11, color: Brutal.bg),
          ),
          size: const Size(double.infinity, 18),
        ),
      ),
    );
  }
}

class _TickerPainter extends CustomPainter {
  final String text;
  final double offset;
  final TextStyle style;

  _TickerPainter({required this.text, required this.offset, required this.style});

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final w = tp.width;
    // wrap offset so it cycles over one copy width
    final x = -(offset % w);
    final cy = (size.height - tp.height) / 2;
    tp.paint(canvas, Offset(x, cy));
    // second copy for seamless wrap
    tp.paint(canvas, Offset(x + w, cy));
  }

  @override
  bool shouldRepaint(_TickerPainter old) =>
      old.offset != offset || old.text != text;
}

// ─── Hero club list ────────────────────────────────────────────────────────────
class _HeroClubList extends StatelessWidget {
  final List<dynamic> clubs;
  const _HeroClubList({required this.clubs});

  @override
  Widget build(BuildContext context) {
    final display = clubs.take(6).toList();
    return Column(
      children: [
        // Full-width hairline at top
        Container(height: 1, color: Brutal.hairlineColor),
        ...List.generate(display.length, (i) {
          final club = display[i];
          final isOpen = isClubOpen(club.openingTime, club.closingTime, club.workingDay);
          return _HeroClubRow(club: club, isOpen: isOpen, isLast: i == display.length - 1);
        }),
      ],
    );
  }
}

class _HeroClubRow extends StatelessWidget {
  final dynamic club;
  final bool isOpen;
  final bool isLast;
  const _HeroClubRow({required this.club, required this.isOpen, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(Routes.clubDetailScreen, extra: club),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Brutal.hairlineColor, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Open/closed dot
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: isOpen ? Brutal.cyan : Brutal.mute,
                shape: BoxShape.rectangle,
              ),
            ),
            const SizedBox(width: 12),
            // Club name — display font
            Expanded(
              child: Text(
                club.name,
                style: Brutal.display(size: 19, color: Brutal.paper),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Status label
            Text(
              isOpen ? 'OPEN' : 'LATER',
              style: Brutal.label(size: 10, color: isOpen ? Brutal.cyan : Brutal.mute),
            ),
            const SizedBox(width: 12),
            // Arrow
            Text('▸', style: Brutal.label(size: 11, color: Brutal.magenta)),
          ],
        ),
      ),
    );
  }
}

class _HeroClubListSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 1, color: Brutal.hairlineColor),
        ...List.generate(5, (i) => Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Brutal.hairlineColor, width: 1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(width: 7, height: 7, color: Brutal.elevated),
              const SizedBox(width: 12),
              Container(width: 140, height: 14, color: Brutal.elevated),
            ],
          ),
        )),
      ],
    );
  }
}

// Allows map gestures to win over the parent bottom-sheet drag recognizer
class AllowMultipleGestureRecognizer extends OneSequenceGestureRecognizer {
  @override
  void addPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer);
    resolve(GestureDisposition.rejected);
  }
  @override
  String get debugDescription => 'allowMultiple';
  @override
  void didStopTrackingLastPointer(int pointer) {}
  @override
  void handleEvent(PointerEvent event) {}
}

// Premium Section Header
class PremiumSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onViewAllTap;

  const PremiumSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Brutal.bg,
              borderRadius: BorderRadius.circular(8),
              border: Brutal.neon(),
            ),
            child: Icon(
              icon,
              color: Brutal.magenta,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: Brutal.display(size: 18, color: Brutal.paper),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Brutal.body(size: 13, color: Brutal.mute),
                ),
              ],
            ),
          ),
          if (onViewAllTap != null)
            GestureDetector(
              onTap: onViewAllTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Brutal.bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Brutal.magenta, width: 1),
                ),
                child: Text(
                  'VIEW ALL',
                  style: Brutal.label(size: 10, color: Brutal.magenta),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Premium Featured Carousel
class PremiumFeaturedCarousel extends StatefulWidget {
  final List<EventViewModel> events;

  const PremiumFeaturedCarousel({super.key, required this.events});

  @override
  State<PremiumFeaturedCarousel> createState() => _PremiumFeaturedCarouselState();
}

class _PremiumFeaturedCarouselState extends State<PremiumFeaturedCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: 0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Brutal.yellow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Brutal.yellow, width: 1),
                ),
                child: const Icon(
                  Icons.star,
                  color: Color(0xFF050505),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FEATURED EVENTS',
                      style: Brutal.display(size: 18, color: Brutal.paper),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Hand-picked events for you',
                      style: Brutal.body(size: 13, color: Brutal.mute),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Carousel — height drives the square cards (≈ 85% viewport width)
        RepaintBoundary(
          child: SizedBox(
            height: MediaQuery.of(context).size.width * 0.85,
            child: PageView.builder(
              controller: _pageController,
              physics: const PageScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.events.length,
              itemBuilder: (context, index) {
                final event = widget.events[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: RepaintBoundary(
                    child: _PremiumFeaturedCard(event: event),
                  ),
                );
              },
            ),
          ),
        ),

        // Page Indicators
        const SizedBox(height: 16),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.events.length,
              (index) {
                final isActive = _currentPage == index;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 20 : 6,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? Brutal.magenta : Brutal.mute,
                    borderRadius: BorderRadius.zero,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Premium Featured Card
class _PremiumFeaturedCard extends ConsumerWidget {
  final EventViewModel event;

  const _PremiumFeaturedCard({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.parse(event.startDate);
    final formattedDate = DateFormat('EEE, MMM dd').format(date);
    final time = event.startDate.toTimeString();

    return GestureDetector(
      onTap: () {
        context.push(Routes.eventDetail, extra: event);
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRect(
          child: Stack(
            children: [
                // Background Image
                Positioned.fill(
                  child: NomuCachedNetworkImage(
                    imageUrl: event.image,
                    fit: BoxFit.cover,
                  ),
                ),

                // Gradient Overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: const [
                          Colors.transparent,
                          Color(0x80000000),
                          Color(0xF2000000),
                        ],
                        stops: const [0.3, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),

                // Content
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.club.name.toUpperCase(),
                        style: Brutal.label(size: 10, color: Brutal.magenta),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.name,
                        style: Brutal.display(size: 20, color: Brutal.paper),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedDate.toUpperCase(),
                                  style: Brutal.label(size: 10, color: Brutal.dim),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'DOORS $time',
                                  style: Brutal.label(size: 9, color: Brutal.mute),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: Brutal.magenta,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              event.femalePrice == 0
                                  ? 'FREE'
                                  : '¥${event.femalePrice.toInt()}',
                              style: Brutal.label(size: 12, color: Brutal.bg),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),


              ],
            ),
          ),
        ),
    );
  }

}

class EnhancedNearbyClubs extends ConsumerWidget {
  const EnhancedNearbyClubs({super.key});

  String getFirstThreeWords(String? address) {
    if (address == null || address.trim().isEmpty) return "";
    final words = address.trim().split(RegExp(r'\s+'));
    return words.take(2).join(' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsProvider = ref.watch(clubListProvider);
    final clubs = clubsProvider.clubs;
    final isLoading = clubsProvider.loading;

    return SizedBox(
      height: 200,
      child: isLoading
          ? ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Skeletonizer(
                  enabled: true,
                  child: Container(
                    width: 170,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: const BoxDecoration(
                      color: Brutal.card,
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                );
              },
            )
          : clubs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                      'NO CLUBS FOUND',
                      style: Brutal.label(size: 11, color: Brutal.mute),
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: clubs.length,
                  itemBuilder: (context, index) {
                    final club = clubs[index];
                    final isOpen = isClubOpen(club.openingTime, club.closingTime, club.workingDay);
                    final shortAddress = getFirstThreeWords(club.locationAddress);

                    return RepaintBoundary(
                      child: _EnhancedClubCard(
                        club: club,
                        isOpen: isOpen,
                        shortAddress: shortAddress,
                      ),
                    );
                  },
                ),
    );
  }
}


class _EnhancedClubCard extends StatelessWidget {
  final dynamic club;
  final bool isOpen;
  final String shortAddress;

  const _EnhancedClubCard({
    required this.club,
    required this.isOpen,
    required this.shortAddress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(Routes.clubDetailScreen, extra: club);
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 12),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.zero,
        ),
        child: ClipRect(
          child: Stack(
            children: [
                  // Background Image
                  Positioned.fill(
                    child: NomuCachedNetworkImage(
                      imageUrl: club.image ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Gradient Overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: const [
                            Colors.transparent,
                            Color(0x99000000),
                            Color(0xF5050505),
                          ],
                          stops: const [0.25, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Brutal.display(size: 16, color: Brutal.paper),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          shortAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Brutal.body(size: 12, color: Brutal.dim),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isOpen ? Brutal.cyan : Brutal.elevated,
                            border: Border.all(
                              color: isOpen ? Brutal.cyan : Brutal.mute,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            isOpen ? 'OPEN' : 'CLOSED',
                            style: Brutal.label(
                              size: 9,
                              color: isOpen ? Brutal.bg : Brutal.mute,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}

// Events Grid Skeleton
class EventsGridSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      effect: ShimmerEffect(
        baseColor: Colors.grey[800]!,
        highlightColor: Colors.grey[700]!,
        duration: const Duration(milliseconds: 1000),
      ),
      enabled: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.78,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return EventCard(
              eventItem: EventViewModel(
                id: 'skeleton-$index',
                createdAt: DateTime.now().toString(),
                name: 'Loading Event',
                image: 'https://via.placeholder.com/400x230',
                femalePrice: 0.0,
                startDate: DateTime.now().toString(),
                endDate: DateTime.now().toString(),
                locationAddress: 'Loading',
                club: Club(
                  id: 'skeleton',
                  createdAt: DateTime.now().toString(),
                  openingTime: '22:00',
                  closingTime: '04:00',
                  name: 'Loading Club',
                  description: 'Loading',
                  femalePrice: 0,
                  menPrice: 0,
                  femaleDrinkTicket: 0,
                  maleDrinkTicket: 0,
                  lng: 0.0,
                  lat: 0.0,
                  guestlist: 0,
                  guestlistDiscount: 0.0,
                ),
              ),
              onTap: () {},
            );
          },
        ),
      ),
    );
  }
}

// Empty Events State
class EmptyEventsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 240,
        decoration: const BoxDecoration(
          color: Brutal.card,
          borderRadius: BorderRadius.zero,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '◇',
              style: Brutal.display(size: 42, color: Brutal.mute),
            ),
            const SizedBox(height: 16),
            Text(
              'NO EVENTS FOUND',
              style: Brutal.display(size: 20, color: Brutal.dim),
            ),
            const SizedBox(height: 6),
            Text(
              'Check back later',
              style: Brutal.body(size: 14, color: Brutal.mute),
            ),
          ],
        ),
      ),
    );
  }
}

// Genre filter + map wrapper
class ClubMapSection extends ConsumerStatefulWidget {
  const ClubMapSection({super.key});

  @override
  ConsumerState<ClubMapSection> createState() => _ClubMapSectionState();
}

class _ClubMapSectionState extends ConsumerState<ClubMapSection> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _markersReady = false;
  bool _markersBuilding = false;
  LatLng? _userLocation;
  String? _selectedGenre;
  bool _locationPermitted = false;

  // All clubs in order for the PageView (partner first, then venue-table)
  final List<Club> _realClubs = [];
  final List<Club> _venueClubsList = [];

  static const _tokyo = LatLng(35.6762, 139.6503);


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

  @override
  void initState() {
    super.initState();
    _checkExistingPermission();
  }

  // Silent check only — no dialog
  Future<void> _checkExistingPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled || !mounted) return;
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        setState(() => _locationPermitted = true);
        Position? pos = await Geolocator.getLastKnownPosition();
        pos ??= await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
        );
        if (!mounted) return;
        final latLng = LatLng(pos.latitude, pos.longitude);
        setState(() => _userLocation = latLng);
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 13));
      }
    } catch (_) {}
  }

  // Full request — triggers system dialog, called on user action
  Future<void> _requestLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!mounted) return;
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enable Location in device settings to see your position on the map'),
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (!mounted) return;
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission blocked. Enable it in App Settings → Permissions → Location'),
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        setState(() => _locationPermitted = true);
      }
    } catch (_) {}
  }

  Future<void> _buildMarkers() async {
    if (_markersBuilding || _markersReady) return;
    _markersBuilding = true;
    final allClubs = ref.read(clubListProvider).clubs;
    final clubs = _selectedGenre == null
        ? allClubs
        : allClubs.where((c) => c.genre?.contains(_selectedGenre) == true).toList();
    final markers = <Marker>{};

    _realClubs.clear();
    _venueClubsList.clear();

    final realIcon = await _buildCustomMarker(isReal: true);
    final venueIcon = await _buildCustomMarker(isReal: false);

    for (final club in clubs) {
      if (club.lat == 0.0 && club.lng == 0.0) continue;
      _realClubs.add(club);
      markers.add(Marker(
        markerId: MarkerId('db_${club.id}'),
        position: LatLng(club.lat, club.lng),
        icon: realIcon,
        onTap: () => _openFullMap(initialRealClub: club),
      ));
    }

    final venueResults = await ref.read(clubRepositoryProvider).getAllVenuesForMap();
    for (final v in venueResults) {
      _venueClubsList.add(v);
      markers.add(Marker(
        markerId: MarkerId('venue_${v.id}'),
        position: LatLng(v.lat, v.lng),
        icon: venueIcon,
        onTap: () => _openFullMap(initialVenueClub: v),
      ));
    }

    if (mounted) {
      setState(() {
        _markers = markers;
        _markersReady = true;
        _markersBuilding = false;
      });
    }
  }

  Future<void> _openFullMap({Club? initialRealClub, Club? initialVenueClub}) async {
    if (!_locationPermitted) await _requestLocationPermission();
    if (!mounted) return;
    if (!_markersReady) {
      await _buildMarkers();
      if (!mounted) return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullMapSheet(
          markers: _markers,
          realClubs: _realClubs,
          venueClubs: _venueClubsList,
          initialRealClub: initialRealClub,
          initialVenueClub: initialVenueClub,
          locationPermitted: _locationPermitted,
        ),
      ),
    );
  }

  Future<BitmapDescriptor> _buildCustomMarker({bool isReal = true}) =>
      _ClubMapSectionState._buildPinIconStatic(isReal: isReal, selected: false);

  static Future<BitmapDescriptor> _buildPinIconStatic({required bool isReal, bool selected = false}) async {
    final size = selected ? 76.0 : 60.0;
    final cx = size / 2;
    final cy = size * 0.42;
    final r = selected ? 24.0 : 18.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const selectedFill = Color(0xFFFFE000);
    const selectedTail = Color(0xFFFFA500);
    final color = isReal ? Brutal.magentaAlt : Brutal.magenta;
    final colorDark = isReal ? Brutal.magentaDark : Brutal.magenta;

    // Shadow
    canvas.drawCircle(
      Offset(cx, cy + 2),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: selected ? 0.55 : 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, selected ? 8 : 5),
    );
    // Fill
    if (selected) {
      canvas.drawCircle(Offset(cx, cy), r, Paint()..color = selectedFill);
    } else {
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.4),
            colors: [color, colorDark],
          ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
      );
    }
    // Ring
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = selected ? Colors.black : Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 3.0 : 2.0,
    );
    // Centre dot
    canvas.drawCircle(Offset(cx, cy), selected ? 6 : 5,
        Paint()..color = selected ? Colors.black : Colors.white);
    // Tail
    final tip = Offset(cx, size - 2);
    canvas.drawPath(
      Path()
        ..moveTo(cx - 5, cy + r - 1)
        ..lineTo(cx + 5, cy + r - 1)
        ..lineTo(tip.dx, tip.dy)
        ..close(),
      Paint()..color = selected ? selectedTail : colorDark,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    final clubState = ref.watch(clubListProvider);
    final allClubs = clubState.clubs;

    // Collect unique genres from real clubs
    final genres = <String>{};
    for (final club in allClubs) {
      if (club.genre != null) genres.addAll(club.genre!);
    }
    final sortedGenres = genres.toList()..sort();

    final filteredRealCount = _selectedGenre == null
        ? allClubs.length
        : allClubs.where((c) => c.genre?.contains(_selectedGenre) == true).length;
    final totalClubs = filteredRealCount + _venueClubsList.length;

    // Trigger marker build once clubs have loaded (build re-runs when provider updates)
    if (allClubs.isNotEmpty && !_markersReady && !_markersBuilding) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _buildMarkers());
    }





    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Genre filter chips
        // if (sortedGenres.isNotEmpty) ...[
        //   SizedBox(
        //     height: 28,
        //     child: ListView(
        //       scrollDirection: Axis.horizontal,
        //       padding: const EdgeInsets.symmetric(horizontal: 16),
        //       children: [
        //         _GenreChip(
        //           label: 'ALL',
        //           isSelected: _selectedGenre == null,
        //           onTap: () => setState(() {
        //             _selectedGenre = null;
        //             _markersReady = false;
        //             _markersBuilding = false;
        //             _buildMarkers();
        //           }),
        //         ),
        //         ...sortedGenres.map((g) => _GenreChip(
        //           label: g.toUpperCase(),
        //           isSelected: _selectedGenre == g,
        //           onTap: () => setState(() {
        //             _selectedGenre = g;
        //             _markersReady = false;
        //             _markersBuilding = false;
        //             _buildMarkers();
        //           }),
        //         )),
        //       ],
        //     ),
        //   ),
        //   const SizedBox(height: 10),
        // ],

    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
          borderRadius: BorderRadius.zero,
          child: SizedBox(
            height: 200,
            child: Stack(
              children: [
                // Non-interactive preview map — onTap opens the full map
                GoogleMap(
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _buildMarkers();
                      if (_userLocation != null) {
                        controller.animateCamera(
                          CameraUpdate.newLatLngZoom(_userLocation!, 13),
                        );
                      }
                    },
                    onTap: (_) => _openFullMap(),
                    style: _darkMapStyle,
                    initialCameraPosition: CameraPosition(
                      target: _userLocation ?? _tokyo,
                      zoom: 11.5,
                    ),
                    markers: _markers,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomGesturesEnabled: false,
                    scrollGesturesEnabled: false,
                  ),

                // Tap-to-expand overlay hint
                Positioned(
                  top: 12,
                  left: 12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, color: ColorPallete.brightPink, size: 13),
                            const SizedBox(width: 5),
                            Text(
                              '$totalClubs CLUBS IN TOKYO',
                              style: Brutal.label(size: 11, color: Brutal.paper),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    color: Brutal.magenta,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.open_in_full_rounded, color: Brutal.paper, size: 11),
                        const SizedBox(width: 5),
                        Text(
                          'EXPLORE MAP',
                          style: Brutal.label(size: 10, color: Brutal.paper),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ], // Column children
    ); // Column
  }
}

// Genre filter chip for map section
class _GenreChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenreChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Brutal.magenta : Brutal.elevated,
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: isSelected ? Brutal.magenta : Brutal.hairlineColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: Brutal.label(size: 10, color: isSelected ? Brutal.bg : Brutal.dim),
        ),
      ),
    );
  }
}

// Full-screen map bottom sheet with scrollable club cards
class _FullMapSheet extends StatefulWidget {
  final Set<Marker> markers;
  final List<Club> realClubs;
  final List<Club> venueClubs;
  final Club? initialRealClub;
  final Club? initialVenueClub;
  final bool locationPermitted;

  const _FullMapSheet({
    required this.markers,
    required this.realClubs,
    required this.venueClubs,
    this.initialRealClub,
    this.initialVenueClub,
    this.locationPermitted = false,
  });

  @override
  State<_FullMapSheet> createState() => _FullMapSheetState();
}

class _FullMapSheetState extends State<_FullMapSheet> {
  GoogleMapController? _mapController;
  late final PageController _pageController;
  late final List<({Club? real, Club? venue})> _allEntries;
  late MapClusterer _clusterer;

  Set<Marker> _displayMarkers = {};
  double _currentZoom = 13.0;
  int _currentIndex = 0;
  bool _cardVisible = false;
  LatLng? _userLocation;
  late bool _locationPermitted;
  _MapFilter _mapFilter = _MapFilter.all;
  int? _selectedAllEntriesIndex;

  BitmapDescriptor? _realIcon;
  BitmapDescriptor? _googIcon;
  BitmapDescriptor? _realIconSelected;
  BitmapDescriptor? _googIconSelected;
  final Map<int, BitmapDescriptor> _clusterIconCache = {};

  static const _defaultCenter = LatLng(35.6762, 139.6503);
  static const _darkMapStyle = _ClubMapSectionState._darkMapStyle;

  @override
  void initState() {
    super.initState();
    // Initialise from parent — permission was resolved before sheet opened
    _locationPermitted = widget.locationPermitted;

    _allEntries = [
      ...widget.realClubs.map((c) => (real: c, venue: null as Club?)),
      ...widget.venueClubs.map((v) => (real: null as Club?, venue: v)),
    ];

    _clusterer = MapClusterer([
      for (var i = 0; i < _allEntries.length; i++)
        (pos: _latLngForEntry(_allEntries[i]), index: i),
    ]);

    int startIndex = 0;
    if (widget.initialRealClub != null) {
      startIndex = _allEntries.indexWhere((e) => e.real?.id == widget.initialRealClub!.id);
      if (startIndex < 0) startIndex = 0;
    } else if (widget.initialVenueClub != null) {
      startIndex = _allEntries.indexWhere((e) => e.venue?.id == widget.initialVenueClub!.id);
      if (startIndex < 0) startIndex = 0;
    }

    _cardVisible = widget.initialRealClub != null || widget.initialVenueClub != null;
    _currentIndex = startIndex;
    _currentZoom = _cardVisible ? 14.0 : 13.0;
    _pageController = PageController(initialPage: startIndex, viewportFraction: 0.88);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _prebuildIcons();
      _rebuildMarkers(_currentZoom);
      await _fetchUserLocation();
    });
  }

  Future<void> _prebuildIcons() async {
    _realIcon         = await _ClubMapSectionState._buildPinIconStatic(isReal: true,  selected: false);
    _googIcon         = await _ClubMapSectionState._buildPinIconStatic(isReal: false, selected: false);
    _realIconSelected = await _ClubMapSectionState._buildPinIconStatic(isReal: true,  selected: true);
    _googIconSelected = await _ClubMapSectionState._buildPinIconStatic(isReal: false, selected: true);
  }

  Future<BitmapDescriptor> _clusterIcon(int count) async {
    if (_clusterIconCache.containsKey(count)) return _clusterIconCache[count]!;
    const size = 56.0;
    const cx = size / 2, cy = size / 2, r = 22.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawCircle(const Offset(cx, cy + 2), r,
        Paint()..color = Colors.black.withValues(alpha: 0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawCircle(const Offset(cx, cy), r,
        Paint()..shader = const RadialGradient(center: Alignment(-0.3, -0.4), colors: [Brutal.magentaAlt, Brutal.magentaDark])
            .createShader(Rect.fromCircle(center: const Offset(cx, cy), radius: r)));
    canvas.drawCircle(const Offset(cx, cy), r,
        Paint()..color = Colors.white.withValues(alpha: 0.9)..style = PaintingStyle.stroke..strokeWidth = 2.5);
    final tp = TextPainter(
      text: TextSpan(text: '$count', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
    final img = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    final icon = BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
    _clusterIconCache[count] = icon;
    return icon;
  }

  List<({Club? real, Club? venue})> get _filteredEntries {
    final entries = switch (_mapFilter) {
      _MapFilter.all   => _allEntries.toList(),
      _MapFilter.clubs => _allEntries
          .where((e) => e.real != null || e.venue?.venueType == 'club')
          .toList(),
      _MapFilter.bars  => _allEntries
          .where((e) => e.venue?.venueType == 'bar')
          .toList(),
    };
    if (_userLocation != null) {
      entries.sort((a, b) {
        final la = _latLngForEntry(a);
        final lb = _latLngForEntry(b);
        final da = Geolocator.distanceBetween(_userLocation!.latitude, _userLocation!.longitude, la.latitude, la.longitude);
        final db = Geolocator.distanceBetween(_userLocation!.latitude, _userLocation!.longitude, lb.latitude, lb.longitude);
        return da.compareTo(db);
      });
    }
    return entries;
  }

  bool _matchesFilter(({Club? real, Club? venue}) e, _MapFilter f) => switch (f) {
    _MapFilter.all   => true,
    _MapFilter.clubs => e.real != null || e.venue?.venueType == 'club',
    _MapFilter.bars  => e.venue?.venueType == 'bar',
  };

  void _setMapFilter(_MapFilter filter) {
    if (_mapFilter == filter) return;
    setState(() {
      _mapFilter = filter;
      _cardVisible = false;
      _selectedAllEntriesIndex = null;
      _clusterer = MapClusterer([
        for (var i = 0; i < _allEntries.length; i++)
          if (_matchesFilter(_allEntries[i], filter))
            (pos: _latLngForEntry(_allEntries[i]), index: i),
      ]);
    });
    _rebuildMarkers(_currentZoom);
  }

  Future<void> _rebuildMarkers(double zoom) async {
    if (_realIcon == null || _googIcon == null) return;
    final effectiveZoom = _selectedAllEntriesIndex != null ? 99.0 : zoom;
    final clusters = _clusterer.cluster(effectiveZoom);
    final markers = <Marker>{};
    for (final cluster in clusters) {
      if (cluster.indices.length == 1) {
        final idx = cluster.indices.first;
        final isReal = _allEntries[idx].real != null;
        final isSelected = idx == _selectedAllEntriesIndex;
        final icon = isReal
            ? (isSelected ? (_realIconSelected ?? _realIcon!) : _realIcon!)
            : (isSelected ? (_googIconSelected ?? _googIcon!) : _googIcon!);
        markers.add(Marker(
          markerId: MarkerId('v_$idx'),
          position: cluster.center,
          icon: icon,
          onTap: () => _onMarkerTapped(idx),
        ));
      } else {
        final count = cluster.indices.length;
        final icon = await _clusterIcon(count);
        final key = '${cluster.center.latitude.toStringAsFixed(3)}_${cluster.center.longitude.toStringAsFixed(3)}';
        markers.add(Marker(
          markerId: MarkerId('c_$key'),
          position: cluster.center,
          icon: icon,
          onTap: () => _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(cluster.center, zoom + 2),
          ),
        ));
      }
    }
    if (mounted) setState(() => _displayMarkers = markers);
  }

  Future<void> _fetchUserLocation() async {
    if (!mounted) return;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;
      Position? pos = await Geolocator.getLastKnownPosition();
      pos ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
      if (!mounted) return;
      final userLatLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _userLocation = userLatLng;
        _locationPermitted = true;
      });
      if (!_cardVisible) {
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 13));
      }
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  LatLng _latLngForEntry(({Club? real, Club? venue}) e) {
    if (e.real != null) return LatLng(e.real!.lat, e.real!.lng);
    return LatLng(e.venue!.lat, e.venue!.lng);
  }

  void _onMarkerTapped(int allEntriesIndex) {
    final entry = _allEntries[allEntriesIndex];
    final filteredIndex = _filteredEntries.indexOf(entry);
    if (filteredIndex < 0) return;

    final wasVisible = _cardVisible;
    _selectedAllEntriesIndex = allEntriesIndex;
    setState(() {
      _currentIndex = filteredIndex;
      _cardVisible = true;
    });
    _currentZoom = 19;
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_latLngForEntry(entry), 19),
    );
    _rebuildMarkers(19);

    if (wasVisible) {
      _pageController.animateToPage(filteredIndex, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(filteredIndex);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad    = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: Column(
        children: [
          // ── Header bar ─────────────────────────────────────────────────────
          Container(
            color: const Color(0xFF0A0A14),
            padding: EdgeInsets.fromLTRB(12, topPad + 8, 16, 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Brutal.elevated,
                      border: Border.all(color: Brutal.hairlineColor),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: ColorPallete.brightPink, size: 13),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${_filteredEntries.length} VENUES',
                          style: Brutal.label(size: 13, color: Brutal.paper),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _MapFilterButton(
                  label: 'CLUBS',
                  active: _mapFilter == _MapFilter.clubs,
                  onTap: () => _setMapFilter(
                    _mapFilter == _MapFilter.clubs ? _MapFilter.all : _MapFilter.clubs,
                  ),
                ),
                const SizedBox(width: 8),
                _MapFilterButton(
                  label: 'BARS',
                  active: _mapFilter == _MapFilter.bars,
                  onTap: () => _setMapFilter(
                    _mapFilter == _MapFilter.bars ? _MapFilter.all : _MapFilter.bars,
                  ),
                ),
              ],
            ),
          ),

          // ── Map ────────────────────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (c) {
                    _mapController = c;
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (!mounted) return;
                      if (_cardVisible && _filteredEntries.isNotEmpty) {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(_latLngForEntry(_filteredEntries[_currentIndex]), 14),
                        );
                      } else if (_userLocation != null) {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(_userLocation!, 13),
                        );
                      }
                    });
                  },
                  onCameraIdle: () async {
                    if (_mapController == null) return;
                    final zoom = await _mapController!.getZoomLevel();
                    if ((zoom - _currentZoom).abs() > 0.5) {
                      _currentZoom = zoom;
                      _rebuildMarkers(zoom);
                    }
                  },
                  style: _darkMapStyle,
                  initialCameraPosition: CameraPosition(
                    target: _cardVisible && _filteredEntries.isNotEmpty
                        ? _latLngForEntry(_filteredEntries[_currentIndex])
                        : (_userLocation ?? _defaultCenter),
                    zoom: _cardVisible ? 14 : 13,
                  ),
                  markers: _displayMarkers,
                  onTap: (_) {
                    _selectedAllEntriesIndex = null;
                    setState(() => _cardVisible = false);
                    _rebuildMarkers(_currentZoom);
                  },
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                  compassEnabled: true,
                  myLocationEnabled: _locationPermitted,
                  myLocationButtonEnabled: _locationPermitted,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  gestureRecognizers: {
                    flutter.Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
                    flutter.Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
                  },
                ),

                if (!_cardVisible)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Text(
                          'TAP A PIN',
                          style: Brutal.label(size: 10, color: Brutal.dim),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Venue cards ────────────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            height: _cardVisible ? 140 : 0,
            child: _cardVisible
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: _filteredEntries.length,
                    onPageChanged: (index) {
                      final entry = _filteredEntries[index];
                      final allIdx = _allEntries.indexOf(entry);
                      _selectedAllEntriesIndex = allIdx >= 0 ? allIdx : null;
                      _currentIndex = index;
                      final zoom = _currentZoom.clamp(14.0, 16.0);
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(_latLngForEntry(entry), zoom),
                      );
                      _rebuildMarkers(zoom);
                    },
                    itemBuilder: (context, index) {
                      final entry = _filteredEntries[index];
                      final isSelected = index == _currentIndex;
                      return AnimatedScale(
                        scale: isSelected ? 1.0 : 0.93,
                        duration: const Duration(milliseconds: 200),
                        child: entry.real != null
                            ? _RealClubCard(club: entry.real!)
                            : _VenueClubCard(venue: entry.venue!),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),

          SizedBox(height: bottomPad + 8),
        ],
      ),
    );
  }
}

class _RealClubCard extends StatelessWidget {
  final Club club;
  const _RealClubCard({required this.club});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        context.push(Routes.clubDetailScreen, extra: club);
      },
      child: Container(
        height: 116,
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF16162A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorPallete.brightPink.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: ColorPallete.brightPink.withValues(alpha: 0.1), blurRadius: 12)],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              child: SizedBox(
                width: 100,
                height: 116,
                child: NomuCachedNetworkImage(
                  imageUrl: club.image ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: ColorPallete.brightPink.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: ColorPallete.brightPink.withValues(alpha: 0.4)),
                      ),
                      child: Text('ON NIGHTPASS', style: Brutal.label(size: 9, color: Brutal.magenta)),
                    ),
                    const SizedBox(height: 5),
                    Text(club.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: Brutal.display(size: 15, color: Brutal.paper)),
                    const SizedBox(height: 3),
                    Text(club.locationAddress ?? 'Tokyo', maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: Brutal.body(size: 12, color: Brutal.mute)),
                    const SizedBox(height: 3),
                    Text('FROM ¥${club.femalePrice.toInt()}',
                        style: Brutal.label(size: 10, color: Brutal.yellow)),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_forward_ios, size: 13, color: ColorPallete.brightPink),
            ),
          ],
        ),
      ),
    );
  }
}

class _VenueClubCard extends StatelessWidget {
  final Club venue;
  const _VenueClubCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _VenueClubDetailSheet(venue: venue),
      ),
      child: Container(
        height: 116,
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF16162A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Brutal.magenta.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: Brutal.magenta.withValues(alpha: 0.1), blurRadius: 12)],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              child: SizedBox(
                width: 100,
                height: 116,
                child: NomuCachedNetworkImage(
                  imageUrl: venue.image ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (venue.venueType != null)
                      Text(venue.venueType!.toUpperCase(),
                          style: Brutal.label(size: 9, color: Brutal.cyan)),
                    const SizedBox(height: 3),
                    Text(venue.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: Brutal.display(size: 15, color: Brutal.paper)),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.location_on, size: 11, color: Brutal.cyan),
                      const SizedBox(width: 3),
                      Expanded(child: Text(venue.area ?? 'Tokyo', maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: Brutal.body(size: 12, color: Brutal.mute))),
                    ]),
                    if (venue.rating != null) ...[
                      const SizedBox(height: 3),
                      Row(children: [
                        const Icon(Icons.star, size: 10, color: Brutal.yellow),
                        const SizedBox(width: 3),
                        Text(venue.rating!.toStringAsFixed(1),
                            style: Brutal.label(size: 10, color: Brutal.yellow)),
                      ]),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VenueClubDetailSheet extends StatelessWidget {
  final Club venue;
  const _VenueClubDetailSheet({required this.venue});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A14),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 0),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: SizedBox(
                  width: double.infinity,
                  height: 220,
                  child: NomuCachedNetworkImage(
                    imageUrl: venue.image ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (venue.venueType != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        color: Brutal.magenta,
                        child: Text(venue.venueType!.toUpperCase(),
                            style: Brutal.label(size: 9, color: Brutal.paper)),
                      ),
                    const SizedBox(height: 6),
                    Text(venue.name, style: Brutal.display(size: 26, color: Brutal.paper)),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Brutal.magenta.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.location_on, color: Color(0xFF7C3AED), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(venue.area ?? 'Tokyo',
                              style: Brutal.body(size: 15, color: Brutal.paper)),
                          Text('Tokyo, Japan',
                              style: Brutal.body(size: 13, color: Brutal.mute)),
                        ],
                      ),
                    ),
                    if (venue.rating != null)
                      Row(children: [
                        const Icon(Icons.star, size: 14, color: Brutal.yellow),
                        const SizedBox(width: 4),
                        Text(venue.rating!.toStringAsFixed(1),
                            style: Brutal.label(size: 13, color: Brutal.yellow)),
                      ]),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => MapUtils.openMap(venue.lat, venue.lng, locationName: venue.name),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.map_outlined, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text('OPEN IN MAPS', style: Brutal.label(size: 12, color: Brutal.bg)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _MapFilter { all, clubs, bars }

class _MapFilterButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _MapFilterButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: active ? Brutal.magenta : Brutal.elevated,
          border: Border.all(
            color: active ? Brutal.magenta : Brutal.magenta.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: Brutal.label(
            size: 12,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
