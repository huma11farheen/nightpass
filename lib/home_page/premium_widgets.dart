import 'dart:async';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:clubship/utils/places_photo_service.dart';
import 'package:clubship/utils/map_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:clubship/clubs/club_list_page.dart';
import 'package:clubship/colors.dart';
import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/event/event_card.dart';
import 'package:clubship/event/event_view_model.dart';
import 'package:clubship/router.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/widgets/cached_image.dart';
import 'package:flutter/foundation.dart' as flutter show Factory;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorPallete.brightPink.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ColorPallete.brightPink.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: ColorPallete.brightPink,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (onViewAllTap != null)
            TextButton(
              onPressed: onViewAllTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ColorPallete.brightPink,
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorPallete.brightPink.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ColorPallete.brightPink.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.yellow,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Featured Events',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Hand-picked events for you',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Carousel
        RepaintBoundary(
          child: SizedBox(
            height: 320,
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
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? ColorPallete.brightPink
                        : Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: ColorPallete.brightPink,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.club.name,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedDate,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                                Text(
                                  time,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: ColorPallete.brightPink,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              event.femalePrice == 0
                                  ? 'Free'
                                  : '¥${event.femalePrice.toInt()}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
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

// Enhanced Nearby Clubs
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
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: clubs.length,
              itemBuilder: (context, index) {
                final club = clubs[index];
                final isOpen = isClubOpen(club.openingTime, club.closingTime);
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: ColorPallete.brightPink,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                shortAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isOpen
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isOpen
                                  ? Colors.green.withValues(alpha: 0.5)
                                  : Colors.grey.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isOpen ? Colors.green : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isOpen ? 'Open Now' : 'Closed',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isOpen ? Colors.green : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Favorite Icon
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
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
            childAspectRatio: 0.65,
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
        height: 300,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ColorPallete.cardColor.withValues(alpha: 0.3),
              ColorPallete.cardColor.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Events Found',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new events',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Club Map Section
class ClubMapSection extends ConsumerStatefulWidget {
  const ClubMapSection({super.key});

  @override
  ConsumerState<ClubMapSection> createState() => _ClubMapSectionState();
}

class _StaticClub {
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String? photoUrl;
  const _StaticClub(this.name, this.address, this.lat, this.lng, [this.photoUrl]);

  _StaticClub withPhoto(String? url) => _StaticClub(name, address, lat, lng, url);
}

class _ClubMapSectionState extends ConsumerState<ClubMapSection> {
  GoogleMapController? _mapController;
  Club? _selectedClub;
  _StaticClub? _selectedStaticClub;
  Set<Marker> _markers = {};
  bool _markersReady = false;

  // All clubs in order for the PageView (real first, then static)
  final List<Club> _realClubs = [];
  final List<_StaticClub> _staticClubsList = [];

  static const _tokyo = LatLng(35.6762, 139.6503);

  static const _staticClubs = [
    _StaticClub('ageHa', '2-2-10 Shinkiba, Koto', 35.6327, 139.8196),
    _StaticClub('Womb', '2-16 Maruyamacho, Shibuya', 35.6598, 139.6977),
    _StaticClub('ATOM Tokyo', '2-4 Maruyamacho, Shibuya', 35.6601, 139.6980),
    _StaticClub('Contact', '2-10-12 Dogenzaka, Shibuya', 35.6584, 139.6985),
    _StaticClub('Bonobo', '1-14-11 Jinnan, Shibuya', 35.6625, 139.6993),
    _StaticClub('Sound Museum Vision', '2-10-7 Dogenzaka, Shibuya', 35.6588, 139.6991),
    _StaticClub('HARLEM', '2-4 Maruyamacho, Shibuya', 35.6602, 139.6979),
    _StaticClub('Club Asia', '1-8 Maruyamacho, Shibuya', 35.6597, 139.6972),
    _StaticClub('Camelot', '1-4-4 Dogenzaka, Shibuya', 35.6592, 139.6995),
    _StaticClub('Oath', '1-6-3 Dogenzaka, Shibuya', 35.6590, 139.6990),
    _StaticClub('Ele Tokyo', '1-7-1 Nishishinjuku, Shinjuku', 35.6917, 139.6970),
    _StaticClub('AiSOTOPE LOUNGE', '2-12-16 Shinjuku', 35.6939, 139.7072),
    _StaticClub('Club Camelot Roppongi', '3-10-5 Roppongi, Minato', 35.6632, 139.7320),
    _StaticClub('V2 Tokyo', '7-14-22 Roppongi, Minato', 35.6626, 139.7306),
    _StaticClub('Muse', '4-1-1 Nishi-Azabu, Minato', 35.6601, 139.7270),
    _StaticClub('Esprit Tokyo', '3-13-14 Roppongi, Minato', 35.6638, 139.7315),
    _StaticClub('STUDIO COAST', '2-2-10 Shinkiba, Koto', 35.6331, 139.8200),
    _StaticClub('Feria', '1-1-12 Kabukicho, Shinjuku', 35.6951, 139.7040),
    _StaticClub('Maharaja', '2-3-18 Dogenzaka, Shibuya', 35.6596, 139.6988),
    _StaticClub('The Room', '1-5-8 Dogenzaka, Shibuya', 35.6594, 139.6986),
    _StaticClub('Bar Martha', '1-9-1 Jinnan, Shibuya', 35.6622, 139.6989),
    _StaticClub('Kitsune Tokyo', '6-8-10 Minami-Aoyama, Minato', 35.6671, 139.7183),
    _StaticClub('Salsa Sudada', '2-14-8 Kabukicho, Shinjuku', 35.6948, 139.7045),
    _StaticClub('Alife', '2-12-3 Nishi-Azabu, Minato', 35.6604, 139.7267),
    _StaticClub('Laforet Harajuku B1', '1-11-6 Jingumae, Shibuya', 35.6693, 139.7073),
    _StaticClub('Shinjuku Loft', '1-12-9 Kabukicho, Shinjuku', 35.6943, 139.7038),
    _StaticClub('Liquid Room', '3-16-6 Higashi, Shibuya', 35.6479, 139.7040),
    _StaticClub('Unit', '1-34-17 Daikanayama, Shibuya', 35.6485, 139.7023),
    _StaticClub('Daikanyama AIR', '1-3-14 Sarugakucho, Shibuya', 35.6481, 139.7027),
    _StaticClub('Circus Tokyo', '6-24-5 Jingumae, Shibuya', 35.6695, 139.7045),
    _StaticClub('Warehouse702', '2-1-3 Higashishinagawa, Shinagawa', 35.6175, 139.7435),
    _StaticClub('Roppongi Hills Club', '6-10-1 Roppongi, Minato', 35.6604, 139.7293),
    _StaticClub('MOGRA', '1-20-1 Sotokanda, Chiyoda', 35.7015, 139.7735),
    _StaticClub('SuperDeluxe', '3-1-25 Nishi-Azabu, Minato', 35.6608, 139.7262),
    _StaticClub('Bar Trench', '1-5-8 Ebisunishi, Shibuya', 35.6475, 139.7138),
    _StaticClub('Tableaux', '11-6 Sarugakucho, Shibuya', 35.6483, 139.7021),
    _StaticClub('Shibuya O-East', '2-14-8 Dogenzaka, Shibuya', 35.6602, 139.6983),
    _StaticClub('Shibuya O-West', '2-3 Maruyamacho, Shibuya', 35.6600, 139.6978),
    _StaticClub('The Lockup Shibuya', '1-6-1 Dogenzaka, Shibuya', 35.6591, 139.6989),
    _StaticClub('Trump Room', '1-8-1 Nishi-Shinjuku, Shinjuku', 35.6910, 139.6968),
    _StaticClub('Sky Bar Andaz', '1-2-1 Yuraku, Chiyoda', 35.6746, 139.7619),
    _StaticClub('Bauhaus', '3-13-2 Roppongi, Minato', 35.6640, 139.7316),
    _StaticClub('Vanilla', '7-9-4 Roppongi, Minato', 35.6629, 139.7311),
    _StaticClub('Bacchanalia', '3-11-5 Roppongi, Minato', 35.6635, 139.7317),
    _StaticClub('Agave', '7-15-10 Roppongi, Minato', 35.6628, 139.7308),
    _StaticClub('Propaganda', '2-21-7 Dogenzaka, Shibuya', 35.6589, 139.6979),
    _StaticClub('Club Quattro', '32-13 Udagawacho, Shibuya', 35.6630, 139.6991),
    _StaticClub('Gaspanic Bar', '3-15-24 Roppongi, Minato', 35.6637, 139.7313),
    _StaticClub('Dragon Men', '2-12-21 Shinjuku', 35.6940, 139.7070),
    _StaticClub('Nakameguro Solfa', '2-10-15 Kamimeguro, Meguro', 35.6440, 139.7001),
  ];

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _buildMarkers();
  }

  Future<void> _buildMarkers() async {
    final clubs = ref.read(clubListProvider).clubs;
    final markers = <Marker>{};

    _realClubs.clear();
    _staticClubsList.clear();

    // Real clubs from DB
    for (final club in clubs) {
      if (club.lat == 0.0 && club.lng == 0.0) continue;
      _realClubs.add(club);
      final icon = await _buildCustomMarker(club.name, isReal: true);
      markers.add(Marker(
        markerId: MarkerId('db_${club.id}'),
        position: LatLng(club.lat, club.lng),
        icon: icon,
        onTap: () => _openFullMap(initialRealClub: club),
      ));
    }

    // Static Tokyo clubs — fetch photos in parallel then build markers
    final photoFutures = _staticClubs.map((sc) => PlacesPhotoService.getPhotoUrl(sc.name));
    final photos = await Future.wait(photoFutures);

    for (var i = 0; i < _staticClubs.length; i++) {
      final sc = _staticClubs[i].withPhoto(photos[i]);
      _staticClubsList.add(sc);
      final icon = await _buildCustomMarker(sc.name, isReal: false);
      markers.add(Marker(
        markerId: MarkerId('static_${sc.name}'),
        position: LatLng(sc.lat, sc.lng),
        icon: icon,
        onTap: () => _openFullMap(initialStaticClub: sc),
      ));
    }

    if (mounted) {
      setState(() {
        _markers = markers;
        _markersReady = true;
      });
    }
  }

  void _openFullMap({Club? initialRealClub, _StaticClub? initialStaticClub}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FullMapSheet(
        markers: _markers,
        realClubs: _realClubs,
        staticClubs: _staticClubsList,
        initialRealClub: initialRealClub,
        initialStaticClub: initialStaticClub,
      ),
    );
  }

  Future<BitmapDescriptor> _buildCustomMarker(String clubName, {bool isReal = true}) async {
    const size = 60.0;
    const cx = size / 2;
    const cy = size * 0.42; // centre of the circle, leaves room for pointer below
    const r = 18.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final color = isReal ? const Color(0xFFFF2D78) : const Color(0xFF7C3AED);
    final colorDark = isReal ? const Color(0xFFBB0055) : const Color(0xFF5B21B6);

    // Drop shadow
    canvas.drawCircle(
      const Offset(cx, cy + 2),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Filled circle
    canvas.drawCircle(
      const Offset(cx, cy),
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [color, colorDark],
        ).createShader(Rect.fromCircle(center: const Offset(cx, cy), radius: r)),
    );

    // White ring
    canvas.drawCircle(
      const Offset(cx, cy),
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // White inner dot
    canvas.drawCircle(const Offset(cx, cy), 5, Paint()..color = Colors.white);

    // Pointer
    final tip = const Offset(cx, size - 2);
    canvas.drawPath(
      Path()
        ..moveTo(cx - 5, cy + r - 1)
        ..lineTo(cx + 5, cy + r - 1)
        ..lineTo(tip.dx, tip.dy)
        ..close(),
      Paint()..color = colorDark,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    final totalClubs = ref.watch(clubListProvider).clubs.length + _staticClubs.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _openFullMap(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 200,
            child: Stack(
              children: [
                // Non-interactive preview map
                IgnorePointer(
                  child: GoogleMap(
                    onMapCreated: (controller) {
                      _mapController = controller;
                      if (!_markersReady) _buildMarkers();
                    },
                    style: _darkMapStyle,
                    initialCameraPosition: const CameraPosition(
                      target: _tokyo,
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
                              '$totalClubs clubs in Tokyo',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ColorPallete.brightPink.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.open_in_full_rounded, color: Colors.white, size: 12),
                            const SizedBox(width: 5),
                            Text(
                              'Explore map',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Full-screen map bottom sheet with scrollable club cards
class _FullMapSheet extends StatefulWidget {
  final Set<Marker> markers;
  final List<Club> realClubs;
  final List<_StaticClub> staticClubs;
  final Club? initialRealClub;
  final _StaticClub? initialStaticClub;

  const _FullMapSheet({
    required this.markers,
    required this.realClubs,
    required this.staticClubs,
    this.initialRealClub,
    this.initialStaticClub,
  });

  @override
  State<_FullMapSheet> createState() => _FullMapSheetState();
}

class _FullMapSheetState extends State<_FullMapSheet> {
  GoogleMapController? _mapController;
  late final PageController _pageController;

  late final List<({Club? real, _StaticClub? stat})> _allEntries;
  // Markers cached once — never rebuilt during map movement
  late final Set<Marker> _sheetMarkers;

  int _currentIndex = 0;
  bool _cardVisible = false;
  LatLng? _userLocation;

  static const _defaultCenter = LatLng(35.6762, 139.6503);
  static const _darkMapStyle = _ClubMapSectionState._darkMapStyle;

  @override
  void initState() {
    super.initState();
    _allEntries = [
      ...widget.realClubs.map((c) => (real: c, stat: null as _StaticClub?)),
      ...widget.staticClubs.map((s) => (real: null as Club?, stat: s)),
    ];

    // Build markers once and cache — key fix for map lag
    _sheetMarkers = _buildSheetMarkersOnce();

    int startIndex = 0;
    if (widget.initialRealClub != null) {
      startIndex = _allEntries.indexWhere((e) => e.real?.id == widget.initialRealClub!.id);
      if (startIndex < 0) startIndex = 0;
    } else if (widget.initialStaticClub != null) {
      startIndex = _allEntries.indexWhere((e) => e.stat?.name == widget.initialStaticClub!.name);
      if (startIndex < 0) startIndex = 0;
    }

    _currentIndex = startIndex;
    _pageController = PageController(initialPage: startIndex, viewportFraction: 0.88);
    _cardVisible = widget.initialRealClub != null || widget.initialStaticClub != null;

    // Defer until after first frame so the dialog can show
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchUserLocation());
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

      // Try last known position first (instant), fall back to fresh position
      Position? pos = await Geolocator.getLastKnownPosition();
      pos ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );

      if (!mounted) return;
      final userLatLng = LatLng(pos.latitude, pos.longitude);
      setState(() => _userLocation = userLatLng);

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

  LatLng _latLngForIndex(int index) {
    final entry = _allEntries[index];
    if (entry.real != null) return LatLng(entry.real!.lat, entry.real!.lng);
    return LatLng(entry.stat!.lat, entry.stat!.lng);
  }

  void _onMarkerTapped(int index) {
    setState(() {
      _currentIndex = index;
      _cardVisible = true;
    });
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_latLngForIndex(index), 14));
  }

  // Called once in initState — never during build
  Set<Marker> _buildSheetMarkersOnce() {
    final markers = <Marker>{};
    for (var i = 0; i < _allEntries.length; i++) {
      final entry = _allEntries[i];
      final isReal = entry.real != null;
      final pos = _latLngForIndex(i);
      final idx = i;
      markers.add(Marker(
        markerId: MarkerId('sheet_$i'),
        position: pos,
        icon: widget.markers
            .firstWhere(
              (m) => m.markerId.value == (isReal ? 'db_${entry.real!.id}' : 'static_${entry.stat!.name}'),
              orElse: () => Marker(markerId: MarkerId('fallback_$i'), position: pos),
            )
            .icon,
        onTap: () => _onMarkerTapped(idx),
      ));
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      height: screenH * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A14),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: ColorPallete.brightPink, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${_allEntries.length} clubs in Tokyo',
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),

          // Map
          Expanded(
            child: Stack(
              children: [
                RawGestureDetector(
                  gestures: {
                    // Claim all pointer events so the bottom sheet drag doesn't
                    // compete with map pan/zoom gestures
                    AllowMultipleGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<AllowMultipleGestureRecognizer>(
                      () => AllowMultipleGestureRecognizer(),
                      (instance) {},
                    ),
                  },
                  child: GoogleMap(
                  onMapCreated: (c) {
                    _mapController = c;
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (!mounted) return;
                      if (_cardVisible) {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(_latLngForIndex(_currentIndex), 14),
                        );
                      } else if (_userLocation != null) {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(_userLocation!, 13),
                        );
                      }
                    });
                  },
                  style: _darkMapStyle,
                  initialCameraPosition: CameraPosition(
                    target: _cardVisible
                        ? _latLngForIndex(_currentIndex)
                        : (_userLocation ?? _defaultCenter),
                    zoom: _cardVisible ? 14 : 13,
                  ),
                  markers: _sheetMarkers,
                  onTap: (_) => setState(() => _cardVisible = false),
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                  compassEnabled: true,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  gestureRecognizers: {
                    flutter.Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
                  },
                  ), // GoogleMap
                ), // RawGestureDetector

                // Tap hint when no card shown
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
                          'Tap a pin to see club details',
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Scrollable club cards
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            height: _cardVisible ? 140 : 0,
            child: _cardVisible
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: _allEntries.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(_latLngForIndex(index), 14),
                      );
                    },
                    itemBuilder: (context, index) {
                      final entry = _allEntries[index];
                      final isSelected = index == _currentIndex;
                      return AnimatedScale(
                        scale: isSelected ? 1.0 : 0.93,
                        duration: const Duration(milliseconds: 200),
                        child: entry.real != null
                            ? _RealClubCard(club: entry.real!)
                            : _StaticClubCard(staticClub: entry.stat!),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
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
                child: club.image != null && club.image!.isNotEmpty
                    ? Image.network(
                        club.image!,
                        width: 100,
                        height: 116,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF2A1A3E),
                          child: const Icon(Icons.nightlife, color: Colors.white24, size: 32),
                        ),
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : Container(color: const Color(0xFF1E1E30)),
                      )
                    : Container(
                        color: const Color(0xFF2A1A3E),
                        child: const Icon(Icons.nightlife, color: Colors.white24, size: 32),
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
                      child: Text('On Clubship', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: ColorPallete.brightPink)),
                    ),
                    const SizedBox(height: 5),
                    Text(club.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.location_on, size: 11, color: ColorPallete.brightPink),
                      const SizedBox(width: 3),
                      Expanded(child: Text(club.locationAddress ?? 'Tokyo', maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 10, color: Colors.white54))),
                    ]),
                    const SizedBox(height: 3),
                    Text('From ¥${club.femalePrice.toInt()}',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber)),
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

class _StaticClubCard extends StatelessWidget {
  final _StaticClub staticClub;
  const _StaticClubCard({required this.staticClub});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _StaticClubDetailSheet(club: staticClub),
      ),
      child: Container(
      height: 116,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF16162A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withValues(alpha: 0.1), blurRadius: 12)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
            child: SizedBox(
              width: 100,
              height: 116,
              child: staticClub.photoUrl != null
                  ? Image.network(
                      staticClub.photoUrl!,
                      width: 100,
                      height: 116,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF2D1B6E),
                        child: const Center(child: Icon(Icons.nightlife, color: Colors.white38, size: 40)),
                      ),
                      loadingBuilder: (_, child, progress) =>
                          progress == null ? child : Container(color: const Color(0xFF2D1B6E)),
                    )
                  : Container(
                      color: const Color(0xFF2D1B6E),
                      child: const Center(child: Icon(Icons.nightlife, color: Colors.white38, size: 40)),
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
                  Text(staticClub.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on, size: 11, color: Color(0xFF7C3AED)),
                    const SizedBox(width: 3),
                    Expanded(child: Text(staticClub.address, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.white54))),
                  ]),
                  const SizedBox(height: 4),
                  Text('Tokyo, Japan', style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
                ],
              ),
            ),
          ),
        ],
      ),
      ), // Container
    ); // GestureDetector
  }
}

class _StaticClubDetailSheet extends StatelessWidget {
  final _StaticClub club;
  const _StaticClubDetailSheet({required this.club});

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
          // Handle
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

          // Hero image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: SizedBox(
                  width: double.infinity,
                  height: 220,
                  child: club.photoUrl != null
                      ? Image.network(
                          club.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF2D1B6E),
                            child: const Center(child: Icon(Icons.nightlife, color: Colors.white24, size: 60)),
                          ),
                          loadingBuilder: (_, child, progress) =>
                              progress == null ? child : Container(color: const Color(0xFF2D1B6E)),
                        )
                      : Container(
                          color: const Color(0xFF2D1B6E),
                          child: const Center(child: Icon(Icons.nightlife, color: Colors.white24, size: 60)),
                        ),
                ),
              ),
              // Gradient over image
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
              // Close button
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
              // Name on image
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Text(
                  club.name,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [const Shadow(blurRadius: 8, color: Colors.black)],
                  ),
                ),
              ),
            ],
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.location_on, color: Color(0xFF7C3AED), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(club.address,
                              style: GoogleFonts.inter(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                          Text('Tokyo, Japan',
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Not on Clubship badge
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white38, size: 16),
                      const SizedBox(width: 10),
                      Text(
                        'This club is not yet on Clubship',
                        style: GoogleFonts.inter(fontSize: 13, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Open in Maps button
                GestureDetector(
                  onTap: () => MapUtils.openMap(club.lat, club.lng, locationName: club.name),
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
                        Text(
                          'Open in Maps',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
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
