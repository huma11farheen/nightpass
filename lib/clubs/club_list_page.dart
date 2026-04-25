import 'package:clubship/clubs/club_card.dart';
import 'package:clubship/clubs/event_card.dart';
import 'package:clubship/clubs/club_list_state.dart';
import 'package:clubship/clubs/club_list_view_model.dart';
import 'package:clubship/data/providers/club_repository_provider.dart';
import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

final clubListProvider = StateNotifierProvider<ClubsViewModel, ClubListState>(
  (ref) => ClubsViewModel(
    ref.read(clubRepositoryProvider),
  ),
);

class ClubList extends ConsumerWidget {
// Assuming you have a list of Club objects

  const ClubList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsProvider = ref.watch(clubListProvider);
    final clubs = clubsProvider.clubs;

    print('ClubList - Loading: ${clubsProvider.loading}, Clubs count: ${clubs.length}');

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        title: const Text(
          'Clubs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: clubsProvider.loading
          ? _buildSkeletonLoader()

          : clubs.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: clubs.length,
                  itemBuilder: (context, index) {
                    final club = clubs[index];
                    return EventCard(
                      club: club,
                      onTap: () {
                        context.push(
                          Routes.clubDetailScreen,
                          extra: club,
                        );
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    print('Building empty state widget');
    return Container(
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
    );
  }

  Widget _buildSkeletonLoader() {
    return Skeletonizer.zone(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 10,
        itemBuilder: (context, index) {
          return EventCard(
            onTap: () {},
            club: Club(
              guestlist: 50,
              id: 'skeleton-id-$index',
              createdAt: DateTime.now().toString(),
              openingTime: '23:00',
              closingTime: '04:30',
              description: 'Experience the ultimate nightlife destination with premium drinks, top DJs.',
              femalePrice: 3000,
              menPrice: 5000,
              name: 'Event Skeleton Name ${index + 1}',
              femaleDrinkTicket: 2,
              maleDrinkTicket: 1,
              lng: 139.7671,
              lat: 35.6812,
              guestlistDiscount: 20.0,
            ),
          );
        },
      ),
    );
  }
}

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
