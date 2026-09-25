import 'package:clubship/widgets/back_button.dart';
import 'package:clubship/design/brutal.dart';
import 'dart:ui';

import 'package:clubship/colors.dart';
import 'package:clubship/search/providers/search_query_provider.dart';
import 'package:clubship/search/search_parameters_row.dart';
import 'package:clubship/search/search_result_list.dart';
import 'package:clubship/utils/preference/preference_keys.dart';
import 'package:clubship/utils/preference/preference_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchInputScreen extends ConsumerStatefulWidget {
  const SearchInputScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SearchInputScreenState();
}

class _SearchInputScreenState extends ConsumerState<SearchInputScreen> {
  late Set<String> _lastSearchQueries = {};

  @override
  void initState() {
    super.initState();
    _loadLastSearchQueries();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const AppBackButton(forAppBar: true),
        title: Text(
          'Search',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          if (query.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(searchQueryProvider.notifier).update('');
              },
              child: Text(
                'Clear',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ColorPallete.brightPink,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const SearchParametersRow(),
          const SizedBox(height: 20),
          if (query.isEmpty) ...[
            Expanded(
              child: SearchHistoryList(
                lastSearchQueries: _lastSearchQueries,
                onItemTap: (query) {
                  ref.read(searchQueryProvider.notifier).update(query);
                },
                onRemoveItemTap: (query) {
                  setState(() {
                    _lastSearchQueries.remove(query);
                    _saveSearchesToPrefs();
                  });
                },
                onClearAll: () {
                  setState(() {
                    _lastSearchQueries.clear();
                    _saveSearchesToPrefs();
                  });
                },
              ),
            ),
          ] else ...[
            Expanded(child: SearchResultsList(query: query))
          ]
        ],
      ),
    );
  }

  Future<void> _loadLastSearchQueries() async {
    final prefs = ref.read(preferencesProvider);
    setState(() {
      final savedSearchList = prefs.getJson(PreferenceKeys.searchHistory) ?? [];
      _lastSearchQueries = Set.from(savedSearchList);
    });
  }

  Future<void> _saveSearchesToPrefs() async {
    final prefs = ref.read(preferencesProvider);
    prefs.setJson(PreferenceKeys.searchHistory, _lastSearchQueries.toList());
  }
}

class SearchHistoryList extends ConsumerWidget {
  const SearchHistoryList({
    super.key,
    required this.lastSearchQueries,
    required this.onItemTap,
    required this.onRemoveItemTap,
    required this.onClearAll,
  });

  final Set<String> lastSearchQueries;
  final Function(String) onItemTap;
  final Function(String) onRemoveItemTap;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (lastSearchQueries.isEmpty) {
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
                Icons.search,
                size: 64,
                color: ColorPallete.brightPink,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Start Searching',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search for events, clubs, and more',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Clear All button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                        Icons.history,
                        color: ColorPallete.brightPink,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Recent Searches',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onClearAll,
                  child: Text(
                    'Clear All',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ColorPallete.brightPink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search history items
            ...lastSearchQueries.map((query) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => onItemTap(query),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorPallete.cardColor.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 20,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  query,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => onRemoveItemTap(query),
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.white.withValues(alpha: 0.5),
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
