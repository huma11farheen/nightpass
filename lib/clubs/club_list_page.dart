import 'dart:ui';
import 'dart:ui' as ui;

import 'package:clubship/clubs/club_list_state.dart';
import 'package:clubship/clubs/club_list_view_model.dart';
import 'package:clubship/colors.dart';
import 'package:clubship/data/providers/club_repository_provider.dart';
import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/home_page/premium_widgets.dart';
import 'package:clubship/router.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/utils/map_utils.dart';
import 'package:clubship/widgets/cached_image.dart';
import 'package:flutter/foundation.dart' as flutter show Factory;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

final clubListProvider = StateNotifierProvider<ClubsViewModel, ClubListState>(
  (ref) => ClubsViewModel(
    ref.read(clubRepositoryProvider),
  ),
);

class ClubList extends ConsumerStatefulWidget {
  const ClubList({super.key});

  @override
  ConsumerState<ClubList> createState() => _ClubListState();
}

enum _VenueTab { clubs, bars }

// Filter state
enum _VenueFilter { openNow, freeEntry, guestlist, openToday }

class _ClubListState extends ConsumerState<ClubList> {
  Set<Marker> _markers = {};
  bool _markersBuilt = false;
  List<Club> _venueList = [];
  bool _googleClubsLoaded = false;

  _VenueTab _activeTab = _VenueTab.clubs;
  List<Club> _bars = [];
  bool _barsLoading = false;
  bool _barsLoaded = false;

  final Set<_VenueFilter> _activeFilters = {};
  final Set<String> _activeGenres = {};

  bool _locationPermitted = false;

  @override
  void initState() {
    super.initState();
    _loadGoogleClubs();
    _checkExistingPermission();
  }

  // Silent check only — no dialog, just reads current state
  Future<void> _checkExistingPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled || !mounted) return;
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        setState(() => _locationPermitted = true);
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

  List<Club> _applyFilters(List<Club> clubs) {
    var result = clubs;
    for (final f in _activeFilters) {
      switch (f) {
        case _VenueFilter.openNow:
          result = result.where((c) => isClubOpen(c.openingTime, c.closingTime, c.workingDay)).toList();
        case _VenueFilter.freeEntry:
          result = result.where((c) => c.femalePrice == 0).toList();
        case _VenueFilter.guestlist:
          result = result.where((c) => c.guestlist > 0).toList();
        case _VenueFilter.openToday:
          final today = _todayName();
          result = result.where((c) => c.workingDay?.any((d) => d.toLowerCase() == today) ?? false).toList();
      }
    }
    if (_activeGenres.isNotEmpty) {
      result = result.where((c) => c.genre?.any((g) => _activeGenres.contains(g)) ?? false).toList();
    }
    return result;
  }

  String _todayName() {
    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return days[DateTime.now().weekday - 1];
  }

  Future<void> _loadBars() async {
    if (_barsLoaded || _barsLoading) return;
    setState(() => _barsLoading = true);
    try {
      final bars = await ref.read(clubRepositoryProvider).getAllVenuesForMap(venueType: 'bar');
      if (!mounted) return;
      setState(() {
        _bars = bars;
        _barsLoaded = true;
        _barsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _barsLoading = false);
      debugPrint('_loadBars error: $e');
    }
  }

  Future<void> _loadGoogleClubs() async {
    try {
      final venues = await ref.read(clubRepositoryProvider).getAllVenuesForMap();
      if (!mounted) return;
      setState(() {
        _venueList = venues;
        _googleClubsLoaded = true;
      });
    } catch (e) {
      debugPrint('_loadVenues error: $e');
      if (mounted) setState(() => _googleClubsLoaded = true);
    }
  }

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

  Future<void> _buildMarkers(List<Club> clubs) async {
    if (clubs.isEmpty) return;
    _markersBuilt = true;

    // Build each icon only once and reuse across all markers
    final realIcon = await _buildPinMarker(isReal: true);
    final googIcon = await _buildPinMarker(isReal: false);

    final markers = <Marker>{};

    // Real DB clubs — pink markers
    for (final club in clubs) {
      if (club.lat == 0.0 && club.lng == 0.0) continue;
      markers.add(Marker(
        markerId: MarkerId(club.id),
        position: LatLng(club.lat, club.lng),
        icon: realIcon,
        onTap: () => _openFullMap(initialClub: club),
      ));
    }

    // Add venue markers from venue table
    for (final v in _venueList) {
      markers.add(Marker(
        markerId: MarkerId('venue_${v.id}'),
        position: LatLng(v.lat, v.lng),
        icon: googIcon,
        onTap: () => _openFullMap(initialVenue: v),
      ));
    }

    if (mounted) setState(() => _markers = markers);
  }

  Future<BitmapDescriptor> _buildPinMarker({required bool isReal}) =>
      _ClubListState._buildPinIconStatic(isReal: isReal, selected: false);

  static Future<BitmapDescriptor> _buildPinIconStatic({required bool isReal, bool selected = false}) async {
    final size = selected ? 76.0 : 60.0;
    final cx = size / 2;
    final cy = size * 0.42;
    final r = selected ? 24.0 : 18.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final color = isReal ? Brutal.magentaAlt : Brutal.magenta;
    final colorDark = isReal ? Brutal.magentaDark : Brutal.magenta;
    const selectedColor = Color(0xFFFFE000);
    const selectedColorDark = Color(0xFFFFA500);
    final fillColor = selected ? selectedColor : color;
    final fillColorDark = selected ? selectedColorDark : colorDark;
    final strokeColor = selected ? Colors.black : Colors.white.withValues(alpha: 0.85);
    final strokeWidth = selected ? 3.0 : 2.0;

    // Shadow
    canvas.drawCircle(
      Offset(cx, cy + 2),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: selected ? 0.55 : 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, selected ? 8 : 5),
    );
    // Fill
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [fillColor, fillColorDark],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
    );
    // Ring
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
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
      Paint()..color = selected ? selectedColorDark : colorDark,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  Future<void> _openFullMap({Club? initialClub, Club? initialVenue}) async {
    final clubs = ref.read(clubListProvider).clubs;
    if (!_markersBuilt) {
      await _buildMarkers(clubs);
      if (!mounted) return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullMapSheet(
          markers: _markers,
          clubs: clubs,
          venues: _venueList,
          initialClub: initialClub,
          initialVenue: initialVenue,
          locationPermitted: _locationPermitted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clubsState = ref.watch(clubListProvider);
    final clubs = clubsState.clubs;
    final isLoading = clubsState.loading;
    final liveCount = clubs.where((c) => isClubOpen(c.openingTime, c.closingTime, c.workingDay)).length;

    // Trigger marker build once clubs are loaded (covers both first mount and updates)
    if (clubs.isNotEmpty && !_markersBuilt) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _buildMarkers(clubs);
      });
    }

    final totalClubs = clubs.length + _venueList.length;
    final filteredClubs = _applyFilters(clubs);
    final filteredGoogleClubs = _venueList;

    // Collect all unique genres from loaded clubs
    final allGenres = <String>{};
    for (final c in clubs) {
      if (c.genre != null) allGenres.addAll(c.genre!);
    }
    final sortedGenres = allGenres.toList()..sort();
    final hasActiveFilters = _activeFilters.isNotEmpty || _activeGenres.isNotEmpty;

    return Scaffold(
      backgroundColor: Brutal.bg,
      body: CustomScrollView(
        slivers: [
          // ── Map Section ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _AtlasMapSection(
              markers: _markers,
              liveCount: liveCount,
              totalClubs: totalClubs,
              onMapCreated: (_) {},
              onExploreTap: () => _openFullMap(),
            ),
          ),

          // ── Header row ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    'venues',
                    style: TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: Brutal.paper,
                      height: 1.1,
                    ),
                  ),
                  const Spacer(),
                  if (liveCount > 0)
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Brutal.magenta,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$liveCount LIVE',
                          style: Brutal.label(size: 11, color: Brutal.magenta),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),

          // ── Tab bar ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _VenueTabBar(
                activeTab: _activeTab,
                onTabChanged: (tab) {
                  setState(() => _activeTab = tab);
                  if (tab == _VenueTab.bars) _loadBars();
                },
              ),
            ),
          ),

          // ── Filter chips (clubs tab only) ──────────────────────────────────
          if (_activeTab == _VenueTab.clubs && !isLoading)
            SliverToBoxAdapter(
              child: _FilterBar(
                activeFilters: _activeFilters,
                activeGenres: _activeGenres,
                allGenres: sortedGenres,
                onFilterTap: (f) => setState(() {
                  if (_activeFilters.contains(f)) {
                    _activeFilters.remove(f);
                  } else {
                    _activeFilters.add(f);
                  }
                }),
                onGenreTap: (g) => setState(() {
                  if (_activeGenres.contains(g)) {
                    _activeGenres.remove(g);
                  } else {
                    _activeGenres.add(g);
                  }
                }),
                onClearAll: () => setState(() {
                  _activeFilters.clear();
                  _activeGenres.clear();
                }),
              ),
            ),

          // ── Divider ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: Brutal.hairlineColor,
            ),
          ),

          // ── Clubs tab content ──────────────────────────────────────────────
          if (_activeTab == _VenueTab.clubs) ...[
            // ── "Our Official Partner Clubs in Tokyo" header ──────────────────
            if (!isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 2,
                        height: 14,
                        color: Brutal.magenta,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'OUR OFFICIAL PARTNER CLUBS IN TOKYO',
                        style: Brutal.label(size: 11, color: Brutal.magenta),
                      ),
                    ],
                  ),
                ),
              ),

            if (isLoading)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _ClubRowSkeleton(),
                  childCount: 8,
                ),
              )
            else if (filteredClubs.isEmpty && hasActiveFilters)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Text('◇', style: Brutal.display(size: 34, color: Brutal.mute)),
                        const SizedBox(height: 12),
                        Text('NO VENUES MATCH', style: Brutal.display(size: 17, color: Brutal.dim)),
                        const SizedBox(height: 4),
                        Text('Try removing some filters', style: Brutal.body(size: 13, color: Brutal.mute)),
                      ],
                    ),
                  ),
                ),
              )
            else if (clubs.isEmpty)
              const SliverToBoxAdapter(child: _EmptyState())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final club = filteredClubs[index];
                    final isLive = isClubOpen(club.openingTime, club.closingTime, club.workingDay);
                    return _AtlasClubRow(
                      club: club,
                      isLive: isLive,
                      onTap: () => context.push(Routes.clubDetailScreen, extra: club),
                    );
                  },
                  childCount: filteredClubs.length,
                ),
              ),

            // ── "More venues in Tokyo" section header ────────────────────────
            if (!isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 2,
                        height: 14,
                        color: Brutal.dim,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MORE VENUES IN TOKYO',
                        style: Brutal.label(size: 11, color: Brutal.dim),
                      ),
                    ],
                  ),
                ),
              ),

            if (!isLoading)
              SliverToBoxAdapter(
                child: Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Brutal.hairlineColor,
                ),
              ),

            // ── Google Places club rows ──────────────────────────────────────
            if (!isLoading && !_googleClubsLoaded)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _ClubRowSkeleton(),
                  childCount: 6,
                ),
              )
            else if (_googleClubsLoaded)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final v = filteredGoogleClubs[index];
                    return _VenueRow(
                      venue: v,
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => _VenueDetailSheet(venue: v),
                      ),
                    );
                  },
                  childCount: filteredGoogleClubs.length,
                ),
              ),
          ],

          // ── Bars tab content ───────────────────────────────────────────────
          if (_activeTab == _VenueTab.bars) ...[
            if (_barsLoading)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _ClubRowSkeleton(),
                  childCount: 8,
                ),
              )
            else if (_barsLoaded && _bars.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Text('◇', style: Brutal.display(size: 34, color: Brutal.mute)),
                        const SizedBox(height: 12),
                        Text('NO BARS FOUND', style: Brutal.display(size: 17, color: Brutal.dim)),
                        const SizedBox(height: 4),
                        Text('Check back later', style: Brutal.body(size: 13, color: Brutal.mute)),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final bar = _bars[index];
                    return _VenueRow(
                      venue: bar,
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => _VenueDetailSheet(venue: bar),
                      ),
                    );
                  },
                  childCount: _bars.length,
                ),
              ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─── Venue tab bar ────────────────────────────────────────────────────────────
class _VenueTabBar extends StatelessWidget {
  final _VenueTab activeTab;
  final void Function(_VenueTab) onTabChanged;

  const _VenueTabBar({required this.activeTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _VenueTab.values.map((tab) {
        final isActive = tab == activeTab;
        final label = switch (tab) {
          _VenueTab.clubs => 'CLUBS',
          _VenueTab.bars => 'BARS IN TOKYO',
        };
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onTabChanged(tab),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isActive ? Brutal.magenta : Brutal.elevated,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: isActive ? Brutal.magenta : Brutal.hairlineColor,
                ),
              ),
              child: Text(
                label,
                style: Brutal.label(
                  size: 10,
                  color: isActive ? Brutal.bg : Brutal.dim,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Filter bar ───────────────────────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  final Set<_VenueFilter> activeFilters;
  final Set<String> activeGenres;
  final List<String> allGenres;
  final void Function(_VenueFilter) onFilterTap;
  final void Function(String) onGenreTap;
  final VoidCallback onClearAll;

  const _FilterBar({
    required this.activeFilters,
    required this.activeGenres,
    required this.allGenres,
    required this.onFilterTap,
    required this.onGenreTap,
    required this.onClearAll,
  });

  static const _labels = {
    _VenueFilter.openNow: 'OPEN NOW',
    _VenueFilter.freeEntry: 'FREE ENTRY',
    _VenueFilter.guestlist: 'GUESTLIST',
    _VenueFilter.openToday: 'OPEN TODAY',
  };

  @override
  Widget build(BuildContext context) {
    final hasActive = activeFilters.isNotEmpty || activeGenres.isNotEmpty;
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Clear all — only when something is active
          if (hasActive) ...[
            _Chip(
              label: '✕ CLEAR',
              active: false,
              isClear: true,
              onTap: onClearAll,
            ),
            const SizedBox(width: 6),
          ],
          // Fixed filters
          ..._VenueFilter.values.map((f) {
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _Chip(
                label: _labels[f]!,
                active: activeFilters.contains(f),
                onTap: () => onFilterTap(f),
              ),
            );
          }),
          // Genre chips
          ...allGenres.map((g) {
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _Chip(
                label: g.toUpperCase(),
                active: activeGenres.contains(g),
                isGenre: true,
                onTap: () => onGenreTap(g),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final bool isClear;
  final bool isGenre;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
    this.isClear = false,
    this.isGenre = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeBg = isGenre ? Brutal.magenta : Brutal.magenta;
    final Color activeBorder = isGenre ? Brutal.magenta : Brutal.magenta;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        decoration: BoxDecoration(
          color: isClear
              ? Colors.transparent
              : active
                  ? activeBg
                  : Brutal.elevated,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: isClear
                ? Brutal.mute
                : active
                    ? activeBorder
                    : Brutal.hairlineColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: Brutal.label(
            size: 9,
            color: isClear
                ? Brutal.mute
                : active
                    ? Brutal.bg
                    : Brutal.dim,
          ),
        ),
      ),
    );
  }
}

// ─── Atlas Map Section ────────────────────────────────────────────────────────
class _AtlasMapSection extends StatelessWidget {
  final Set<Marker> markers;
  final int liveCount;
  final int totalClubs;
  final void Function(GoogleMapController) onMapCreated;
  final VoidCallback onExploreTap;

  const _AtlasMapSection({
    required this.markers,
    required this.liveCount,
    required this.totalClubs,
    required this.onMapCreated,
    required this.onExploreTap,
  });

  static const _darkMapStyle = _ClubListState._darkMapStyle;
  static const _tokyo = LatLng(35.6762, 139.6503);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // Map — onTap fires when the user taps anywhere on the native map view
        SizedBox(
          height: 260 + topPadding,
          child: GoogleMap(
            onMapCreated: onMapCreated,
            onTap: (_) => onExploreTap(),
            style: _darkMapStyle,
            initialCameraPosition: const CameraPosition(target: _tokyo, zoom: 11.5),
            markers: markers,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            myLocationButtonEnabled: false,
            zoomGesturesEnabled: false,
            scrollGesturesEnabled: false,
          ),
        ),

        // Top gradient fade (status bar area)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: topPadding + 40,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Brutal.bg, Brutal.bg.withValues(alpha: 0)],
              ),
            ),
          ),
        ),

        // Bottom fade into background
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 60,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Brutal.bg, Brutal.bg.withValues(alpha: 0)],
              ),
            ),
          ),
        ),

        // Bottom pill: live count + explore button
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Row(
            children: [
              // Live pill
              if (liveCount > 0)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Brutal.magenta,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$liveCount LIVE · TOKYO',
                            style: Brutal.label(size: 10, color: Brutal.paper),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const Spacer(),

              // EXPLORE button
              GestureDetector(
                onTap: onExploreTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Brutal.magenta,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'EXPLORE',
                        style: Brutal.label(size: 11, color: Brutal.bg),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 11, color: Brutal.bg),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }
}

// ─── Atlas Club Row ───────────────────────────────────────────────────────────
class _AtlasClubRow extends StatelessWidget {
  final Club club;
  final bool isLive;
  final VoidCallback onTap;

  const _AtlasClubRow({
    required this.club,
    required this.isLive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final genre = (club.genre != null && club.genre!.isNotEmpty)
        ? club.genre!.map((g) => g.trim().toUpperCase()).take(2).toList()
        : <String>[];
    final area = _extractArea(club.locationAddress);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Brutal.hairlineColor, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.zero,
              child: SizedBox(
                width: 56,
                height: 56,
                child: NomuCachedNetworkImage(
                  imageUrl: club.image ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Name + area + tags
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: Brutal.display(size: 17, color: Brutal.paper),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (area.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      area,
                      style: Brutal.body(size: 13, color: Brutal.mute),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (genre.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: genre
                          .map(
                            (g) => Container(
                              margin: const EdgeInsets.only(right: 5),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Brutal.elevated,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                g,
                                style: Brutal.label(size: 9, color: Brutal.dim),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Live status + capacity
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isLive ? Brutal.magenta : Brutal.mute,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isLive ? 'LIVE' : 'CLOSED',
                      style: Brutal.label(
                        size: 9,
                        color: isLive ? Brutal.magenta : Brutal.mute,
                      ),
                    ),
                  ],
                ),
                if (isLive && club.guestlist > 0) ...[
                  const SizedBox(height: 3),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${(club.guestlist * 0.6).toInt()}',
                          style: Brutal.label(size: 14, color: Brutal.paper),
                        ),
                        TextSpan(
                          text: '/${club.guestlist}',
                          style: Brutal.label(size: 10, color: Brutal.mute),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _extractArea(String? address) {
    if (address == null || address.trim().isEmpty) return '';
    final parts = address.trim().split(RegExp(r'[,、]'));
    return parts.last.trim();
  }
}

// ─── Skeleton row ─────────────────────────────────────────────────────────────
class _ClubRowSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Brutal.hairlineColor, width: 1)),
        ),
        child: Row(
          children: [
            Container(width: 56, height: 56, color: Brutal.elevated),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 120, height: 14, color: Brutal.elevated),
                  const SizedBox(height: 5),
                  Container(width: 80, height: 10, color: Brutal.elevated),
                ],
              ),
            ),
            Container(width: 40, height: 14, color: Brutal.elevated),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('◇', style: Brutal.display(size: 42, color: Brutal.mute)),
          const SizedBox(height: 16),
          Text('NO VENUES FOUND', style: Brutal.display(size: 20, color: Brutal.dim)),
          const SizedBox(height: 6),
          Text('Check back later', style: Brutal.body(size: 14, color: Brutal.mute)),
        ],
      ),
    );
  }
}

// ─── Full map bottom sheet ─────────────────────────────────────────────────────
class _FullMapSheet extends StatefulWidget {
  final Set<Marker> markers;
  final List<Club> clubs;
  final List<Club> venues;
  final Club? initialClub;
  final Club? initialVenue;
  final bool locationPermitted;

  const _FullMapSheet({
    required this.markers,
    required this.clubs,
    required this.venues,
    this.initialClub,
    this.initialVenue,
    this.locationPermitted = false,
  });

  @override
  State<_FullMapSheet> createState() => _FullMapSheetState();
}

// ─── Lightweight grid-based clustering ───────────────────────────────────────
// Groups markers into grid cells sized by zoom level. No external packages.
class MapClusterer {
  final List<({LatLng pos, int index})> _items;
  MapClusterer(this._items);

  // Returns grid-cell size in degrees for a given zoom level
  static double _cellSize(double zoom) {
    if (zoom >= 14) return 0.0; // no clustering at street level
    if (zoom >= 12) return 0.02;
    if (zoom >= 10) return 0.08;
    if (zoom >= 8)  return 0.3;
    return 1.0;
  }

  // Returns clusters: each is a list of original indices that belong together
  List<({LatLng center, List<int> indices})> cluster(double zoom) {
    final cellSize = _cellSize(zoom);
    if (cellSize == 0.0) {
      // No clustering — every item is its own cluster
      return _items.map((e) => (center: e.pos, indices: [e.index])).toList();
    }

    final Map<String, List<int>> cells = {};
    final Map<String, LatLng> cellFirstPos = {};

    for (final item in _items) {
      final gridX = (item.pos.longitude / cellSize).floor();
      final gridY = (item.pos.latitude  / cellSize).floor();
      final key = '$gridX,$gridY';
      cells.putIfAbsent(key, () => []);
      cellFirstPos.putIfAbsent(key, () => item.pos);
      cells[key]!.add(item.index);
    }

    return cells.entries.map((e) {
      final positions = e.value.map((i) => _items.firstWhere((x) => x.index == i).pos);
      final avgLat = positions.map((p) => p.latitude).reduce((a, b) => a + b) / e.value.length;
      final avgLng = positions.map((p) => p.longitude).reduce((a, b) => a + b) / e.value.length;
      return (center: LatLng(avgLat, avgLng), indices: e.value);
    }).toList();
  }







}

enum _MapFilter { all, clubs, bars }

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

  BitmapDescriptor? _realIcon;
  BitmapDescriptor? _googIcon;
  BitmapDescriptor? _realIconSelected;
  BitmapDescriptor? _googIconSelected;
  int? _selectedAllEntriesIndex;
  final Map<int, BitmapDescriptor> _clusterIconCache = {};

  static const _defaultCenter = LatLng(35.6762, 139.6503);
  static const _darkMapStyle = _ClubListState._darkMapStyle;

  @override
  void initState() {
    super.initState();
    // Initialise from parent — permission was resolved before sheet opened
    _locationPermitted = widget.locationPermitted;

    _allEntries = [
      ...widget.clubs.map((c) => (real: c, venue: null as Club?)),
      ...widget.venues.map((v) => (real: null as Club?, venue: v)),
    ];

    _clusterer = MapClusterer([
      for (var i = 0; i < _allEntries.length; i++)
        (pos: _latLngForEntry(_allEntries[i]), index: i),
    ]);

    int startIndex = 0;
    if (widget.initialClub != null) {
      final idx = _allEntries.indexWhere((e) => e.real?.id == widget.initialClub!.id);
      if (idx >= 0) startIndex = idx;
    } else if (widget.initialVenue != null) {
      final idx = _allEntries.indexWhere((e) => e.venue?.id == widget.initialVenue!.id);
      if (idx >= 0) startIndex = idx;
    }
    _cardVisible = widget.initialClub != null || widget.initialVenue != null;
    _currentIndex = startIndex;
    _currentZoom = _cardVisible ? 14.0 : 13.0;
    _pageController = PageController(initialPage: startIndex, viewportFraction: 0.88);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _prebuildIcons();
      _rebuildMarkers(_currentZoom);
      await _fetchUserLocation();
    });
  }

  List<({Club? real, Club? venue})> get _filteredEntries {
    final entries = switch (_mapFilter) {
      _MapFilter.all   => _allEntries.toList(),
      _MapFilter.clubs => _allEntries.where((e) => e.real != null || e.venue?.venueType == 'club').toList(),
      _MapFilter.bars  => _allEntries.where((e) => e.venue?.venueType == 'bar').toList(),
    };
    // Sort by distance from user location so swiping goes to nearest venue
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

  void _setMapFilter(_MapFilter filter) {
    if (_mapFilter == filter) return;
    setState(() {
      _mapFilter = filter;
      _cardVisible = false;
      _clusterer = MapClusterer([
        for (var i = 0; i < _allEntries.length; i++)
          if (_matchesFilter(_allEntries[i], filter))
            (pos: _latLngForEntry(_allEntries[i]), index: i),
      ]);
    });
    _rebuildMarkers(_currentZoom);
  }

  bool _matchesFilter(({Club? real, Club? venue}) e, _MapFilter f) => switch (f) {
    _MapFilter.all   => true,
    _MapFilter.clubs => e.real != null || e.venue?.venueType == 'club',
    _MapFilter.bars  => e.venue?.venueType == 'bar',
  };

  Future<void> _prebuildIcons() async {
    _realIcon         = await _ClubListState._buildPinIconStatic(isReal: true,  selected: false);
    _googIcon         = await _ClubListState._buildPinIconStatic(isReal: false, selected: false);
    _realIconSelected = await _ClubListState._buildPinIconStatic(isReal: true,  selected: true);
    _googIconSelected = await _ClubListState._buildPinIconStatic(isReal: false, selected: true);
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

  Future<void> _rebuildMarkers(double zoom) async {
    if (_realIcon == null || _googIcon == null) return;
    // When a card is selected, never cluster — show every pin individually
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
        final centerLat = cluster.center.latitude;
        final centerLng = cluster.center.longitude;
        markers.add(Marker(
          markerId: MarkerId('c_${centerLat.toStringAsFixed(3)}_${centerLng.toStringAsFixed(3)}'),
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
      final latLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _userLocation = latLng;
        _locationPermitted = true;
      });
      if (!_cardVisible) {
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 13));
      }
    } catch (e) {
      debugPrint('Location fetch error: $e');
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

  LatLng _latLngForIndex(int index) => _latLngForEntry(_allEntries[index]);

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
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Column(
        children: [
          // ── Header bar ───────────────────────────────────────────────────────
          Container(
            color: const Color(0xFF0A0A0F),
            padding: EdgeInsets.fromLTRB(12, topPad + 8, 16, 8),
            child: Row(
              children: [
                // Back button
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
                // Filter buttons — highlighted tabs
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

          // ── Map (fills remaining space) ───────────────────────────────────
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
                    _currentZoom = zoom;
                    _rebuildMarkers(zoom);
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                        ),
                        child: Text('TAP A PIN', style: Brutal.label(size: 10, color: Brutal.dim)),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Venue card carousel ───────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            height: _cardVisible ? 136 : 0,
            child: _cardVisible
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: _filteredEntries.length,
                    onPageChanged: (index) {
                      final entry = _filteredEntries[index];
                      final allEntriesIndex = _allEntries.indexOf(entry);
                      _selectedAllEntriesIndex = allEntriesIndex;
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
                            ? _MapClubCard(club: entry.real!)
                            : _MapVenueCard(venue: entry.venue!),
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

class _MapClubCard extends StatelessWidget {
  final Club club;
  const _MapClubCard({required this.club});

  @override
  Widget build(BuildContext context) {
    final isLive = isClubOpen(club.openingTime, club.closingTime, club.workingDay);

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        context.push(Routes.clubDetailScreen, extra: club);
      },
      child: Container(
        height: 112,
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF14141F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isLive ? Brutal.magenta : Brutal.elevated).withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: SizedBox(
                width: 90,
                height: 112,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isLive ? Brutal.magenta : Brutal.mute,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isLive ? 'LIVE' : 'CLOSED',
                          style: Brutal.label(size: 9, color: isLive ? Brutal.magenta : Brutal.mute),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      club.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Brutal.display(size: 16, color: Brutal.paper),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      club.locationAddress ?? 'Tokyo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Brutal.body(size: 12, color: Brutal.mute),
                    ),
                    if (club.femalePrice > 0) ...[
                      const SizedBox(height: 5),
                      Text(
                        'FROM ¥${club.femalePrice.toInt()}',
                        style: Brutal.label(size: 10, color: Brutal.yellow),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_forward_ios, size: 12, color: ColorPallete.brightPink),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Non-partner venue row ────────────────────────────────────────────────────
class _VenueRow extends StatelessWidget {
  final Club venue;
  final VoidCallback onTap;

  const _VenueRow({required this.venue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Brutal.hairlineColor, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.zero,
              child: SizedBox(
                width: 56,
                height: 56,
                child: NomuCachedNetworkImage(
                  imageUrl: venue.image ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    style: Brutal.display(size: 17, color: Brutal.paper),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (venue.area != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      venue.area!,
                      style: Brutal.body(size: 13, color: Brutal.mute),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (venue.rating != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 10, color: Brutal.yellow),
                      const SizedBox(width: 3),
                      Text(
                        venue.rating!.toStringAsFixed(1),
                        style: Brutal.label(size: 10, color: Brutal.yellow),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Brutal.magenta.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: Brutal.magenta.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'NOT LISTED',
                    style: Brutal.label(size: 9, color: Brutal.magenta),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Map card for non-partner venue ──────────────────────────────────────────
class _MapVenueCard extends StatelessWidget {
  final Club venue;
  const _MapVenueCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _VenueDetailSheet(venue: venue),
      ),
      child: Container(
        height: 112,
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF14141F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Brutal.magenta.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: SizedBox(
                width: 90,
                height: 112,
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
                      Text(
                        venue.venueType!.toUpperCase(),
                        style: Brutal.label(size: 9, color: Brutal.cyan),
                      ),
                    const SizedBox(height: 3),
                    Text(
                      venue.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Brutal.display(size: 16, color: Brutal.paper),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 10, color: Brutal.cyan),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            venue.area ?? 'Tokyo',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Brutal.body(size: 12, color: Brutal.mute),
                          ),
                        ),
                      ],
                    ),
                    if (venue.rating != null) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 10, color: Brutal.yellow),
                          const SizedBox(width: 3),
                          Text(
                            venue.rating!.toStringAsFixed(1),
                            style: Brutal.label(size: 9, color: Brutal.yellow),
                          ),
                        ],
                      ),
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

// ─── Venue detail bottom sheet ────────────────────────────────────────────────
class _VenueDetailSheet extends StatelessWidget {
  final Club venue;
  const _VenueDetailSheet({required this.venue});

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
                        child: Text(venue.venueType!.toUpperCase(), style: Brutal.label(size: 9, color: Brutal.paper)),
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
                          Text(venue.area ?? 'Tokyo', style: Brutal.body(size: 15, color: Brutal.paper)),
                          Text('Tokyo, Japan', style: Brutal.body(size: 13, color: Brutal.mute)),
                        ],
                      ),
                    ),
                    if (venue.rating != null)
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Brutal.yellow),
                          const SizedBox(width: 4),
                          Text(venue.rating!.toStringAsFixed(1), style: Brutal.label(size: 13, color: Brutal.yellow)),
                        ],
                      ),
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

// ─── Map filter pill button ───────────────────────────────────────────────────
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

// ─── Kept for other imports that may reference it ─────────────────────────────
class SearchClubInputField extends StatelessWidget {
  const SearchClubInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 59, bottom: 20),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
            hintText: 'Search Venue',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
