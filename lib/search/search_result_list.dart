import 'package:clubship/design/brutal.dart';
import 'package:clubship/colors.dart';
import 'package:clubship/clubs/club_card.dart';
import 'package:clubship/router.dart';
import 'package:clubship/search/providers/search_sugession_provider.dart';
import 'package:clubship/search/search_result_model.dart';
import 'package:clubship/utils/preference/preference_keys.dart';
import 'package:clubship/utils/preference/preference_provider.dart';
import 'package:clubship/widgets/async_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../event/event_card.dart';

class SearchResultsList extends ConsumerWidget {
  const SearchResultsList({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Expanded(
        child: query.length < 2
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Type at least 2 characters',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              )
            : AsyncValueWidget(
                value: ref.watch(searchSugessionProvider(query)),
                data: (searchResults) {
                  if (searchResults.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: ColorPallete.brightPink.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.search_off,
                              size: 64,
                              color: ColorPallete.brightPink,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No Results Found',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'Try searching with different keywords',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Group results by type
                  final events = searchResults
                      .where((r) => r.type == SearchResultType.event)
                      .toList();
                  final clubs = searchResults
                      .where((r) => r.type == SearchResultType.club)
                      .toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Results summary
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ColorPallete.brightPink.withValues(alpha: 0.15),
                                Brutal.magenta.withValues(alpha: 0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: ColorPallete.brightPink.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: ColorPallete.brightPink,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Found ${searchResults.length} result${searchResults.length > 1 ? 's' : ''}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Events Section
                        if (events.isNotEmpty) ...[
                          _SectionHeader(
                            icon: Icons.event,
                            title: 'Events',
                            count: events.length,
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final result = events[index];
                              return Hero(
                                tag: 'search-event-${result.event!.id}',
                                child: EventCard(
                                  onTap: () {
                                    _saveQueryToHistory(query, ref);
                                    context.push(Routes.eventDetail, extra: result.event);
                                  },
                                  eventItem: result.event!,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Clubs Section
                        if (clubs.isNotEmpty) ...[
                          _SectionHeader(
                            icon: Icons.location_on,
                            title: 'Clubs',
                            count: clubs.length,
                          ),
                          const SizedBox(height: 12),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: clubs.length,
                            itemBuilder: (context, index) {
                              final result = clubs[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ClubCard(
                                  onTap: () {
                                    _saveQueryToHistory(query, ref);
                                    context.push(Routes.clubDetailScreen, extra: result.club);
                                  },
                                  club: result.club!,
                                ),
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
      );

  Future<void> _saveQueryToHistory(String query, WidgetRef ref) async {
    if (query.isEmpty) return;
    final prefs = ref.read(preferencesProvider);
    final List<String> savedSearches = prefs.getJson(
          PreferenceKeys.searchHistory,
        ) ??
        [];
    final Set<String> searchSet = Set.from(savedSearches);
    searchSet.add(query);
    prefs.setJson(PreferenceKeys.searchHistory, searchSet.toList());
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorPallete.brightPink.withValues(alpha: 0.2),
                Brutal.magenta.withValues(alpha: 0.2),
              ],
            ),
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
        Column(
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
              '$count ${count > 1 ? title.toLowerCase() : title.toLowerCase().replaceAll('s', '')} found',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
