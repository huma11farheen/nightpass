import 'dart:io';
import 'dart:ui';

import 'package:clubship/colors.dart';
import 'package:clubship/data/providers/event_repository_provider.dart';
import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/domain/bottom_navigator_provider.dart';
import 'package:clubship/event/event_card.dart';
import 'package:clubship/event/event_list/event_list_page.dart';
import 'package:clubship/event/event_view_model.dart';
import 'package:clubship/event/providers/get_events_provider.dart';
import 'package:clubship/home_page/category_selector/category_selector.dart';
import 'package:clubship/home_page/featured_event/featured_row.dart';
import 'package:clubship/home_page/main_page_state.dart';
import 'package:clubship/home_page/main_page_view_model.dart';
import 'package:clubship/home_page/premium_widgets.dart';
import 'package:clubship/my_page/providers/get_user_detail_provider.dart';
import 'package:clubship/router.dart';
import 'package:clubship/send_tickets/app_search_bar.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/utils/typography.dart';
import 'package:clubship/widgets/cached_image.dart';
import 'package:clubship/widgets/simple_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'home_page/event_category_selector.dart';

final homePageListProvider =
    StateNotifierProvider<MainPageViewModel, MainPageState>(
  (ref) => MainPageViewModel(
    eventsRepository: ref.read(eventRepositoryProvider),
  ),
);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _eventsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Reduce overscroll glow for better performance
    _scrollController.addListener(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEvents() {
    // Give a small delay for the content to load
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final context = _eventsKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.0, // Scroll to top of the events section
        );
      }
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final eventsProvider = ref.watch(eventListProvider);
    final events = eventsProvider.events;
    final user = ref.watch(getUserDetailProvider);
    final allEvents = ref.watch(getEventsProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) async {
        final shouldExit = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return EVJSimpleDialog(
              title: 'Exit Confirmation',
              content: 'Are you sure you want to exit?',
              onPositivePressed: () {
                Navigator.of(dialogContext).pop(true); // returns true
              },
              onNegativePressed: () {
                Navigator.of(dialogContext).pop(false); // returns false
              },
              onPositiveButtonText: 'Exit',
              onNegativeButtonText: 'Cancel',
            );
          },
        );

        if (shouldExit == true) {
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else if (Platform.isIOS) {
            exit(0);
          }
        }
      },
      child: Scaffold(

        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(getEventsProvider);
            ref.invalidate(eventListProvider);
            await Future.delayed(const Duration(milliseconds: 1500));
          },
          child: CustomScrollView(
            controller: _scrollController,
            cacheExtent: 500,
            slivers: [
              // Premium Header
              SliverToBoxAdapter(
                child: _PremiumHeader(
                  user: user.value,
                  greeting: _getGreeting(),
                  onProfileTap: () {
                    ref.read(bottomTabIndex.notifier).setSelectedIndex(3);
                  },
                  onSearchTap: () => context.push(Routes.search),
                  onNotificationTap: () => context.push(Routes.notifications),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              SliverToBoxAdapter(
                child: allEvents.when(
                  data: (data) {
                    print('[FeaturedEvents] fetched ${data.length} events');
                    final featuredEvents = data.take(5).toList();
                    if (featuredEvents.isNotEmpty) {
                      return Column(
                        children: [
                          PremiumFeaturedCarousel(events: featuredEvents),
                          const SizedBox(height: 24),
                        ],
                      );
                    }
                    print('[FeaturedEvents] list is empty, hiding carousel');
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (err, stack) {
                    print('[FeaturedEvents] ERROR: $err\n$stack');
                    return const SizedBox.shrink();
                  },
                ),
              ),

              // Nearby Clubs
              SliverToBoxAdapter(
                child: PremiumSectionHeader(
                  icon: Icons.location_on,
                  title: 'Nearby Clubs',
                  subtitle: 'Explore venues around you',
                  onViewAllTap: () {
                    ref.read(bottomTabIndex.notifier).setSelectedIndex(2);
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              const SliverToBoxAdapter(child: EnhancedNearbyClubs()),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              SliverToBoxAdapter(
                child: PremiumSectionHeader(
                  icon: Icons.map_outlined,
                  title: 'Clubs on Map',
                  subtitle: 'Find venues near you',
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              const SliverToBoxAdapter(child: ClubMapSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              /// CATEGORY SELECTOR (which updates the event list and scrolls to it)
              SliverToBoxAdapter(
                child: CategorySelector(
                  onTap: (category) {
                    ref
                        .read(eventListProvider.notifier)
                        .getUpcomingEvents(category: category);
                  },
                  onCategorySelected: _scrollToEvents,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 18)),

              SliverToBoxAdapter(
                child: Container(
                  key: _eventsKey,
                  child: const SizedBox.shrink(),
                ),
              ),

              // Events Section
              SliverToBoxAdapter(
                child: PremiumSectionHeader(
                  icon: Icons.event,
                  title: 'Upcoming Events',
                  subtitle: '${events.length} events available',
                  onViewAllTap: () {
                    ref.read(bottomTabIndex.notifier).setSelectedIndex(1);
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Events Grid
              if (eventsProvider.loading)
                SliverToBoxAdapter(child: EventsGridSkeleton())
              else if (events.isEmpty)
                SliverToBoxAdapter(child: EmptyEventsState())
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final e = events[index];
                        return RepaintBoundary(
                          child: EventCard(
                            eventItem: e,
                            onTap: () {
                              context.push(Routes.eventDetail, extra: e);
                            },
                          ),
                        );
                      },
                      childCount: events.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

// Premium Header Component
class _PremiumHeader extends ConsumerWidget {
  final dynamic user;
  final String greeting;
  final VoidCallback onProfileTap;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;

  const _PremiumHeader({
    required this.user,
    required this.greeting,
    required this.onProfileTap,
    required this.onSearchTap,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ColorPallete.cardColor.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Avatar with Gradient Border
                    GestureDetector(
                      onTap: onProfileTap,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              ColorPallete.brightPink,
                              Colors.purple,
                            ],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: ColorPallete.black25,
                          backgroundImage:
                          user?.image != null ? NetworkImage(user.image) : null,
                          child: user?.image == null
                              ? Icon(
                            Icons.person,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 28,
                          )
                              : null,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Greeting and Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.name ?? 'Guest',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Notification Bell
                    GestureDetector(
                      onTap: onNotificationTap,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Full-width Search Bar
                GestureDetector(
                  onTap: onSearchTap,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.white.withValues(alpha: 0.6),
                          size: 18,

                        ),


                        const SizedBox(width: 8),
                        Text(
                          'Search Venue/Event',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ),
        ),
    );
  }
}

// Quick Action Cards Component
class _QuickActionCards extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _QuickActionCard(
            icon: Icons.calendar_today,
            title: 'My Events',
            subtitle: 'View tickets',
            gradient: LinearGradient(
              colors: [
                Colors.purple.withValues(alpha: 0.3),
                Colors.blue.withValues(alpha: 0.3),
              ],
            ),
            onTap: () {
              ref.read(bottomTabIndex.notifier).setSelectedIndex(2);
            },
          ),
          _QuickActionCard(
            icon: Icons.confirmation_number,
            title: 'My Tickets',
            subtitle: 'View all',
            gradient: LinearGradient(
              colors: [
                ColorPallete.brightPink.withValues(alpha: 0.3),
                Colors.orange.withValues(alpha: 0.3),
              ],
            ),
            onTap: () {
              context.push(Routes.tickets);
            },
          ),
          _QuickActionCard(
            icon: Icons.account_balance_wallet,
            title: 'Wallet',
            subtitle: 'Add funds',
            gradient: LinearGradient(
              colors: [
                Colors.green.withValues(alpha: 0.3),
                Colors.teal.withValues(alpha: 0.3),
              ],
            ),
            onTap: () {
              context.push(Routes.wallet);
            },
          ),
          _QuickActionCard(
            icon: Icons.local_offer,
            title: 'Offers',
            subtitle: 'Exclusive deals',
            gradient: LinearGradient(
              colors: [
                Colors.amber.withValues(alpha: 0.3),
                Colors.orange.withValues(alpha: 0.3),
              ],
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.7),
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
