import 'dart:ui';
import 'package:clubship/colors.dart';
import 'package:clubship/data/providers/event_repository_provider.dart';
import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/event/event_card.dart';
import 'package:clubship/event/event_list/event_list_state.dart';
import 'package:clubship/event/event_list/event_list_view_model.dart';
import 'package:clubship/event/event_view_model.dart';
import 'package:clubship/event/providers/get_category_provider.dart';
import 'package:clubship/event/providers/get_events_provider.dart';
import 'package:clubship/router.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/utils/typography.dart';
import 'package:clubship/widgets/cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

final eventListProvider =
    StateNotifierProvider<EventListViewModel, EventListState>(
  (ref) => EventListViewModel(
    ref.read(eventRepositoryProvider),
  ),
);

Map<String, List<EventViewModel>> groupEventsByCategory(
    List<EventViewModel> events) {
  final Map<String, List<EventViewModel>> grouped = {};

  for (final event in events) {
    for (final category in event.category) {
      grouped.putIfAbsent(category, () => []);
      grouped[category]!.add(event);
    }
  }

  return grouped;
}

class EventList extends ConsumerWidget {
  const EventList({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(getCategoryProvider);

    return ref.watch(getEventsProvider).when(
      data: (data) {
        // Check if events list is empty
        if (data.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F0F0F),
            appBar: AppBar(
              title: const Text('Events'),
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xFF0F0F0F),
            ),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF0F0F0F),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_busy_rounded,
                      size: 64,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Upcoming Events',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final groupedDrink = groupEventsByCategory(data);
        // Get featured events (first 5 events)
        final featuredEvents = data.take(5).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Events'),
            automaticallyImplyLeading: false,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(getEventsProvider);
              // Wait for the new data to be fetched
              await Future.delayed(const Duration(milliseconds: 1500));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured Carousel Section
                  // if (featuredEvents.isNotEmpty) ...[
                  //   const SizedBox(height: 16),
                  //   _FeaturedCarousel(events: featuredEvents),
                  //   const SizedBox(height: 24),
                  // ],

                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, bottom: 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...groupedDrink.entries.map(
                          (entry) {
                      final category = entry.key;
                      final events = entry.value;

                      final categoryName = categories.value
                              ?.firstWhere(
                                (c) => c.id == category,
                              )
                              .category ??
                          'Unknown Category';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category Header
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.yellow,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    categoryName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Events horizontal list
                            SizedBox(
                              height: 250,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                itemCount: events.length,
                                itemBuilder: (context, index) {
                                  final event = events[index];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: index < events.length - 1 ? 12 : 0,
                                    ),
                                    child: SizedBox(


                                      width: 160,
                                      child: EventCard(
                                        eventItem: event,
                                        onTap: () {
                                          context.push(
                                            Routes.eventDetail,
                                            extra: event,
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
            ),
          ),
        );
      },
      error: (s, v) {
        return const SizedBox();
      },
      loading: () {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Events'),
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            child: Skeletonizer(
              enabled: true,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 140),
                child: Column(
                  children: List.generate(3, (categoryIndex) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Header Skeleton
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  height: 24,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: ColorPallete.black50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Events horizontal list skeleton
                          SizedBox(
                            height: 250,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: index < 3 ? 12 : 0,
                                  ),
                                  child: SizedBox(
                                    width: 160,
                                    child: EventCard(
                                      eventItem: EventViewModel(
                                        id: 'skeleton-$index',
                                        createdAt: DateTime.now().toString(),
                                        name: 'Loading Event Name',
                                        image: 'https://picsum.photos/250?image=9',
                                        femalePrice: 5000,
                                        startDate: DateTime.now().toString(),
                                        endDate: DateTime.now().toString(),
                                        locationAddress: 'Loading Address',
                                        club: Club(
                                          id: 'skeleton-club',
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
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'music':
        return Icons.music_note;
      case 'sports':
        return Icons.sports_soccer;
      case 'food':
        return Icons.restaurant;
      case 'art':
        return Icons.palette;
      case 'nightlife':
        return Icons.nightlife;
      case 'party':
        return Icons.celebration;
      case 'conference':
        return Icons.business_center;
      default:
        return Icons.event;
    }
  }
}

// Featured Carousel Widget with Peek Effect
class _FeaturedCarousel extends StatefulWidget {
  final List<EventViewModel> events;

  const _FeaturedCarousel({required this.events});

  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85, // Show 85% of card, allowing sides to peek
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
                  gradient: LinearGradient(
                    colors: [
                      ColorPallete.brightPink.withValues(alpha: 0.2),
                      Colors.purple.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ColorPallete.brightPink.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
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
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.events.length,
            itemBuilder: (context, index) {
              final event = widget.events[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = (_pageController.page ?? 0) - index;
                    value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
                  }
                  return Center(
                    child: SizedBox(
                      height: Curves.easeInOut.transform(value) * 320,
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _FeaturedEventCard(event: event),
                ),
              );
            },
          ),
        ),

        // Page Indicator
        const SizedBox(height: 16),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.events.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: _currentPage == index
                      ? LinearGradient(
                          colors: [
                            ColorPallete.brightPink,
                            Colors.purple,
                          ],
                        )
                      : null,
                  color: _currentPage == index ? null : Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Featured Event Card
class _FeaturedEventCard extends ConsumerWidget {
  final EventViewModel event;

  const _FeaturedEventCard({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.parse(event.startDate);
    final formattedDate = DateFormat('EEE, MMM dd').format(date);
    final time = event.startDate.toTimeString();

    return GestureDetector(
      onTap: () {
        context.push(Routes.eventDetail, extra: event);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: ColorPallete.brightPink.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
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
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                          Colors.black.withValues(alpha: 0.95),
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
                      // Event Name
                      Text(
                        event.name,
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Club Name
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: ColorPallete.brightPink,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.club.name,
                              style: GoogleFonts.inter(
                                fontSize: 14,
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

                      // Date, Time, and Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Date & Time
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedDate,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  time,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Price Button
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ColorPallete.brightPink,
                                  Colors.purple,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: ColorPallete.brightPink.withValues(alpha: 0.5),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              event.femalePrice == 0
                                  ? 'Free Entry'
                                  : '¥${event.femalePrice.toInt()}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
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


                // Drink Tickets Badge
                if (event.freeFemaleDrinkTicket > 0 || event.freeMaleDrinkTicket > 0)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00BCD4).withValues(alpha: 0.95),
                            const Color(0xFF0097A7).withValues(alpha: 0.95),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00BCD4).withValues(alpha: 0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_bar,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'FREE DRINKS',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
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
    );
  }
}

//
//
// class EventList extends ConsumerWidget {
//   const EventList({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final eventsProvider = ref.watch(eventListProvider);
//     final events = eventsProvider.events;
//
//     return Scaffold(
//       appBar: const ClubshipAppBar(
//         child: Padding(
//           padding: EdgeInsets.only(left: 20, right: 16, top: 70, bottom: 20),
//           child: Text(
//             'Events',
//             style: TextStyle(fontSize: 24),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: eventsProvider.loading
//             ? _buildSkeletonLoader()
//             : events.isEmpty
//                 ? const Center(
//                     child: Text('No upcoming events'),
//                   )
//                 : ListView.builder(
//                     itemCount: events.length,
//                     itemBuilder: (context, index) {
//                       final event = events[index];
//                       return EventCard(
//                         eventItem: event,
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => EventDetailPage(
//                                 eventItem: event,
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//       ),
//     );
//   }
//
//   Widget _buildSkeletonLoader() {
//     return Skeletonizer(
//       child: ListView.builder(
//         itemCount: 5, // Display 5 skeletons
//         itemBuilder: (context, index) {
//           return EventCard(
//             eventItem: Event(
//               id: '',
//               createdAt: '',
//               name: '',
//               image: '',
//               description: '',
//               startDate: '',
//               endDate: '',
//               pending: 0,
//               checkedIn: 0,
//               clubId: '',
//               malePrice: 0,
//               openingTime: '',
//               closingTime: '',
//               isRecurring: false,
//             ),
//             onTap: () {},
//           );
//         },
//       ),
//     );
//   }
// }
