import 'package:clubship/widgets/back_button.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/event/event_card.dart';
import 'package:clubship/event/event_view_model.dart';
import 'package:clubship/router.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/widgets/app_button.dart';
import 'package:clubship/widgets/club_genre_selector.dart';
import 'package:clubship/widgets/dots_indicator.dart';
import 'package:clubship/widgets/map_view_widget.dart';
import 'package:clubship/widgets/working_days_container.dart';
import 'package:dart_openapi_model_gen/string_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../event/event_list/event_list_page.dart';

class ClubDetailPage extends ConsumerStatefulWidget {
  const ClubDetailPage({
    super.key,
    required this.club,
  });

  final Club club;

  @override
  ConsumerState<ClubDetailPage> createState() => _ClubDetailPageState();
}

class _ClubDetailPageState extends ConsumerState<ClubDetailPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clubModel = widget.club;
    final List<String> images = List.from([clubModel.image]);
    final eventsProvider = ref.watch(eventListProvider);
    final events = eventsProvider.events;
    final isOpen = isClubOpen(
        clubModel.openingTime, clubModel.closingTime, clubModel.workingDay);
    final clubEvents = events.where((event) {
      return event.clubId == widget.club.id;
    }).toList();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: Scaffold(
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  AppButton.primary(
                    text: 'Reserve Table',
                    onPressed: () {
                      context.push(
                        Routes.reserveClub,
                        extra: clubModel,
                      );
                    },
                  ),
                ],
              ),
            ),
            backgroundColor: Brutal.bg,
            body: RefreshIndicator(
              color: Brutal.magenta,
              backgroundColor: Brutal.elevated,
              strokeWidth: 3.0,
              displacement: 60,
              edgeOffset: 20,
              onRefresh: () async {
                setState(() {});
                await Future.delayed(const Duration(milliseconds: 800));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Stack(children: [
                  Column(
                    children: [
                      // ── Hero image section ──────────────────────────────
                      SizedBox(
                        height: 300,
                        child: images.length == 1
                            ? Container(
                                height: 300,
                                width: double.infinity,
                                color: Colors.black,
                                child: Stack(
                                  children: [
                                    // Background image — no ClipRRect
                                    Positioned.fill(
                                      child: Image.network(
                                        images.first,
                                        fit: BoxFit.cover,
                                      ),
                                    ),

                                    // Flat fade-to-bg gradient overlay
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Brutal.bg.withValues(alpha: 0.85),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Club name + status
                                    Positioned(
                                      left: 16,
                                      right: 16,
                                      bottom: 16,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            clubModel.name.capitalize(),
                                            style: Brutal.display(
                                                size: 28,
                                                color: Brutal.paper),
                                          ),
                                          const SizedBox(height: 10),
                                          // Flat square status chip
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            color: isOpen
                                                ? Colors.green
                                                : Colors.red,
                                            child: Text(
                                              isOpen ? 'OPEN NOW' : 'CLOSED',
                                              style: Brutal.label(
                                                  size: 10,
                                                  color: Brutal.paper),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Back button — flat square
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: const AppBackButton(forAppBar: true),
                                    ),
                                  ],
                                ),
                              )
                            : Stack(
                                children: [
                                  CarouselSlider(
                                    options: CarouselOptions(
                                      autoPlay: false,
                                      aspectRatio: 17 / 12,
                                      viewportFraction: 2,
                                      enlargeCenterPage: true,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          _currentIndex = index;
                                        });
                                      },
                                    ),
                                    items: images
                                        .map(
                                          (e) => Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(e),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  Positioned(
                                    bottom: 2.0,
                                    right: 0.0,
                                    left: 0.0,
                                    child: DotsIndicator(
                                      dotCount: images.length,
                                      currentIndex: _currentIndex,
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      _buildCard(
                        image: NetworkImage(clubModel.image ?? ''),
                        title: clubModel.name,
                        description: clubModel.description,
                        clubModel: clubModel,
                        events: clubEvents,
                        isLoadingEvents: eventsProvider.loading,
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required NetworkImage image,
    required String title,
    required String description,
    required List<EventViewModel> events,
    Club? clubModel,
    required bool isLoadingEvents,
  }) {
    final openingTime =
        getHourAndMinute(clubModel?.openingTime ?? '00:00');
    final closingTime =
        getHourAndMinute(clubModel?.closingTime ?? '00:00');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Description card ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Brutal.elevated,
              border: Border.all(color: Brutal.hairlineColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('ABOUT'),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: Brutal.body(size: 16, color: Brutal.dim),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Operating Hours card ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Brutal.elevated,
              border: Border.all(color: Brutal.hairlineColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('OPERATING HOURS'),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTimeInfo(
                      'OPENS',
                      '${openingTime['hour'].toString().padLeft(2, '0')}:${openingTime['minute'].toString().padLeft(2, '0')}',
                      Icons.wb_sunny_outlined,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Brutal.hairlineColor,
                    ),
                    _buildTimeInfo(
                      'CLOSES',
                      '${closingTime['hour'].toString().padLeft(2, '0')}:${closingTime['minute'].toString().padLeft(2, '0')}',
                      Icons.nightlight_round,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Working Days card ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Brutal.elevated,
              border: Border.all(color: Brutal.hairlineColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('WORKING DAYS'),
                const SizedBox(height: 10),
                WorkingDaysContainer(
                  canEdit: false,
                  color: Brutal.magenta,
                  onTagsChanged: (v) {},
                  selectedTags: clubModel?.workingDay ?? [],
                  title: '',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Event Genres card ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Brutal.elevated,
              border: Border.all(color: Brutal.hairlineColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('EVENT GENRES'),
                const SizedBox(height: 10),
                ClubGenreSelector(
                  isEditable: false,
                  selectedGenres: clubModel?.genre ?? [],
                  onSelectionChanged: (tags) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Location card ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Brutal.elevated,
              border: Border.all(color: Brutal.hairlineColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('LOCATION'),
                const SizedBox(height: 4),
                Text(
                  clubModel?.locationAddress ?? '',
                  style: Brutal.body(size: 15, color: Brutal.dim),
                ),
                const SizedBox(height: 12),
                // No ClipRRect — map is flat
                MapViewWidget(
                  lat: clubModel?.lat ?? 0.0,
                  lon: clubModel?.lng ?? 0.0,
                  locationName: clubModel?.name,
                  locationAddress: clubModel?.locationAddress,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Rules & Regulations card ──────────────────────────────────────
          if (clubModel?.rulesAndRegulation != null &&
              clubModel!.rulesAndRegulation!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Brutal.elevated,
                border: Border.all(
                    color: Brutal.yellow.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('RULES & REGULATIONS'),
                  const SizedBox(height: 10),
                  Text(
                    clubModel.rulesAndRegulation ?? '',
                    style: Brutal.body(size: 16, color: Brutal.dim),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Upcoming Events section header ────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: 2, height: 14, color: Brutal.magenta),
              const SizedBox(width: 8),
              Text('UPCOMING EVENTS', style: Brutal.display(size: 17)),
              const Spacer(),
              if (events.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  color: Brutal.magenta,
                  child: Text(
                    '${events.length}',
                    style: Brutal.label(size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Events grid ───────────────────────────────────────────────────
          if (isLoadingEvents)
            _buildEventsSkeleton()
          else if (events.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Brutal.elevated,
                border: Border.all(color: Brutal.hairlineColor),
              ),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(
                    Icons.event_busy,
                    size: 40,
                    color: Brutal.mute,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No upcoming events',
                    style: Brutal.body(size: 16, color: Brutal.mute),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final e = events[index];
                return Hero(
                  tag: 'event-${e.id}',
                  child: EventCard(
                    eventItem: e,
                    onTap: () {
                      context.push(Routes.eventDetail, extra: e);
                    },
                  ),
                );
              },
            ),
          const SizedBox(height: 96),
        ],
      ),
    );
  }

  /// Magenta accent bar + uppercase display title — used for every card header.
  Widget _buildSectionHeader(String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(width: 2, height: 14, color: Brutal.magenta),
        const SizedBox(width: 8),
        Text(title, style: Brutal.display(size: 17)),
      ],
    );
  }

  /// Icon + label/time column — no circular container.
  Widget _buildTimeInfo(String label, String time, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Brutal.magenta, size: 22),
        const SizedBox(height: 8),
        Text(label, style: Brutal.label(size: 10, color: Brutal.mute)),
        const SizedBox(height: 4),
        Text(time, style: Brutal.display(size: 26, color: Brutal.paper)),
      ],
    );
  }

  Widget _buildEventsSkeleton() {
    return Skeletonizer.zone(
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
              name: 'Electronic Music Night',
              image: 'https://via.placeholder.com/400x230',
              description:
                  'Join us for an amazing night of electronic music with top DJs',
              femalePrice: 0,
              startDate: DateTime.now()
                  .add(Duration(days: index + 1))
                  .toString(),
              endDate: DateTime.now()
                  .add(Duration(days: index + 1, hours: 6))
                  .toString(),
              subImages: [],
              category: ['Electronic', 'Dance'],
              clubId: widget.club.id,
              malePrice: 3000,
              registeredGuestlist: 45,
              gustlist: 100,
              locationAddress:
                  widget.club.locationAddress ?? 'Tokyo, Japan',
              club: widget.club,
            ),
            onTap: () {},
          );
        },
      ),
    );
  }
}
