import 'package:clubship/router.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/widgets/cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../clubs/club_list_page.dart';

class NearbyClubs extends ConsumerWidget {
  const NearbyClubs({
    super.key,
  });

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

    return Center(
      child: SizedBox(
        height: 170,
        child: isLoading
            ? Skeletonizer(
                enabled: true,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 150,
                          height: 170,
                          color: Colors.grey[900],
                          child: Stack(
                            children: [
                              // Background placeholder
                              Positioned.fill(
                                child: Container(
                                  color: Colors.grey[800],
                                ),
                              ),

                              // Gradient at bottom
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.85),
                                        Colors.black.withValues(alpha: 0.80),
                                        Colors.black.withValues(alpha: 0.75),
                                        Colors.black.withValues(alpha: 0.65),
                                        Colors.black.withValues(alpha: 0.5),
                                        Colors.black.withValues(alpha: 0.3),
                                        Colors.transparent,
                                      ],
                                      stops: const [
                                        0.0,
                                        0.2,
                                        0.4,
                                        0.5,
                                        0.6,
                                        0.8,
                                        1.0,
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Loading Club Name',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(0.5, 0.5),
                                              blurRadius: 2.0,
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Loading Address',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(0.5, 0.5),
                                              blurRadius: 2.0,
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Loading',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                          fontSize: 11,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(0.5, 0.5),
                                              blurRadius: 2.0,
                                              color: Colors.black54,
                                            ),
                                          ],
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
                    );
                  },
                ),
              )
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: clubs.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final club = clubs[index];
                  final isOpen = isClubOpen(club.openingTime, club.closingTime);
                  final shortAddress =
                      getFirstThreeWords(clubs[index].locationAddress);
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        context.push(
                          Routes.clubDetailScreen,
                          extra: clubs[index],
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 150,
                          height: 170,
                          color: Colors.grey[900],
                          child: Stack(
                            children: [
                              // Background image
                              Positioned.fill(
                                child: NomuCachedNetworkImage(
                                  imageUrl: clubs[index].image ?? '',
                                  fit: BoxFit.cover,
                                ),
                              ),

                              // Gradient at bottom
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.85),
                                        Colors.black.withValues(alpha: 0.80),
                                        Colors.black.withValues(alpha: 0.75),
                                        Colors.black.withValues(alpha: 0.65),
                                        Colors.black.withValues(alpha: 0.5),
                                        Colors.black.withValues(alpha: 0.3),
                                        Colors.transparent,
                                      ],
                                      stops: const [
                                        0.0,
                                        0.2,
                                        0.4,
                                        0.5,
                                        0.6,
                                        0.8,
                                        1.0,
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        clubs[index].name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(0.5, 0.5),
                                              blurRadius: 2.0,
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        shortAddress,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(0.5, 0.5),
                                              blurRadius: 2.0,
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isOpen ? 'Open now' : 'Closed',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isOpen ? Colors.green : Colors.grey,
                                          fontSize: 11,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(0.5, 0.5),
                                              blurRadius: 2.0,
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // GestureDetector(
                                      //   onTap: () {},
                                      //   child: Align(
                                      //     alignment: Alignment.centerLeft,
                                      //     child: Container(
                                      //       height: 32,
                                      //       decoration: BoxDecoration(
                                      //         color: Colors.pink,
                                      //         borderRadius: BorderRadius.circular(8),
                                      //       ),
                                      //       child: const Center(
                                      //         child: Text('Guestlist'),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // )
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
                },
              ),
      ),
    );
  }
}
