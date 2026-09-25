import 'dart:ui';

import 'package:clubship/colors.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/widgets/common_web_view.dart';
import 'package:clubship/data/providers/event_repository_provider.dart';
import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/domain/bottom_navigator_provider.dart';
import 'package:clubship/my_page/my_page.dart';
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
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Brutal.bg,
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
              // ── Brutalist Header (search bar + avatar) ───────────────
              SliverToBoxAdapter(
                child: _PremiumHeader(
                  user: user.value,
                  greeting: _getGreeting(),
                  onProfileTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPage()));
                  },
                  onSearchTap: () => context.push(Routes.search),
                  onNotificationTap: () => context.push(Routes.notifications),
                ),
              ),





              // ── Hero section: "Where to tonight?" + ticker + club list ─
              SliverToBoxAdapter(
                child: BrutalHeroSection(
                  onSearchTap: () => context.push(Routes.search),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── Featured events carousel ─────────────────────────────
              SliverToBoxAdapter(
                child: allEvents.when(
                  data: (data) {
                    final featuredEvents = data.take(5).toList();
                    if (featuredEvents.isNotEmpty) {
                      return Column(
                        children: [
                          PremiumFeaturedCarousel(events: featuredEvents),
                          const SizedBox(height: 24),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
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

              /// CATEGORY SELECTOR — below Upcoming Events header
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

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Events Grid
              if (eventsProvider.loading)
                SliverToBoxAdapter(child: EventsGridSkeleton())
              else if (events.isEmpty)
                SliverToBoxAdapter(child: EmptyEventsState())
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
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

              SliverToBoxAdapter(
                child: SizedBox(
                  height: 100 + MediaQuery.of(context).padding.bottom,
                ),
              ),
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
        color: Brutal.bg,
        padding: const EdgeInsets.only(top: 54, left: 16, right: 16, bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Square avatar with neon border
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Brutal.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Brutal.neon(),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: user?.image != null
                      ? Image.network(
                          user.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person,
                            color: Brutal.dim,
                            size: 24,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: Brutal.dim,
                          size: 24,
                        ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Greeting + Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting.toUpperCase(),
                    style: Brutal.label(size: 10, color: Brutal.mute),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user?.name ?? 'Guest',
                    style: Brutal.display(size: 22, color: Brutal.paper),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Notification button — sharp square
            GestureDetector(
              onTap: onNotificationTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Brutal.card,
                  border: Border.all(color: Brutal.hairlineColor, width: 1),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Brutal.dim,
                  size: 20,
                ),
              ),
            ),
          ],
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
                Brutal.magenta.withValues(alpha: 0.3),
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
