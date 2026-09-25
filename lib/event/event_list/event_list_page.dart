import 'package:clubship/data/providers/event_repository_provider.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/event/event_list/event_list_state.dart';
import 'package:clubship/event/event_list/event_list_view_model.dart';
import 'package:clubship/event/event_view_model.dart';
import 'package:clubship/event/providers/get_category_provider.dart';
import 'package:clubship/event/providers/get_events_provider.dart';
import 'package:clubship/router.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/widgets/cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class EventList extends ConsumerStatefulWidget {
  const EventList({super.key});

  @override
  ConsumerState<EventList> createState() => _EventListState();
}

class _EventListState extends ConsumerState<EventList> {
  String? _selectedCategoryId; // null = ALL
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(getCategoryProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    // Build id→name lookup once categories are available
    final categoryNames = <String, String>{};
    categories.whenData((cats) {
      for (final c in cats) {
        if (c.category != null) categoryNames[c.id] = c.category!;
      }
    });

    return ref.watch(getEventsProvider).when(
      data: (allEvents) {
        // Filter by selected category
        final events = _selectedCategoryId == null
            ? allEvents
            : allEvents
                .where((e) => e.category.contains(_selectedCategoryId))
                .toList();

        return Scaffold(
          backgroundColor: Brutal.bg,
          body: RefreshIndicator(
            color: Brutal.magenta,
            backgroundColor: Brutal.card,
            onRefresh: () async {
              ref.invalidate(getEventsProvider);
              await Future.delayed(const Duration(milliseconds: 1200));
            },
            child: CustomScrollView(
              slivers: [
                // ── Header ───────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UPCOMING EVENTS',
                          style: Brutal.label(size: 10, color: Brutal.mute),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Events',
                              style: TextStyle(
                                fontFamily: 'Fraunces',
                                fontSize: 44,
                                fontWeight: FontWeight.w700,
                                color: Brutal.paper,
                                height: 1.0,
                              ),
                            ),
                            const Spacer(),
                            // filter icon
                            GestureDetector(
                              onTap: () => _showFilterSheet(
                                context,
                                categories.value ?? [],
                              ),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: _selectedCategoryId != null
                                      ? Brutal.magenta.withValues(alpha: 0.15)
                                      : Brutal.card,
                                  border: Border.all(
                                    color: _selectedCategoryId != null
                                        ? Brutal.magenta
                                        : Brutal.hairlineColor,
                                  ),
                                ),
                                child: Icon(
                                  Icons.tune,
                                  color: _selectedCategoryId != null
                                      ? Brutal.magenta
                                      : Brutal.dim,
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setState(() => _isGridView = !_isGridView),
                              child: Container(
                                width: 36,
                                height: 36,
                                color: Brutal.magenta,
                                child: Icon(
                                  _isGridView ? Icons.view_list : Icons.grid_view,
                                  color: Brutal.bg,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Divider ───────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(height: 1, color: Brutal.hairlineColor),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // ── Category filter chips (below Upcoming Events header) ──
                SliverToBoxAdapter(
                  child: categories.when(
                    data: (cats) => _CategoryChips(
                      categories: cats,
                      selectedId: _selectedCategoryId,
                      onSelected: (id) =>
                          setState(() => _selectedCategoryId = id),
                    ),
                    loading: () => const SizedBox(height: 52),
                    error: (_, __) => const SizedBox(height: 52),
                  ),
                ),

                // ── Poster grid / list ────────────────────────────────────
                if (events.isEmpty)
                  const SliverFillRemaining(child: _EmptyState())
                else if (_isGridView)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 120),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.68,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final event = events[index];
                          return _PosterCard(
                            event: event,
                            categoryNames: categoryNames,
                            onTap: () =>
                                context.push(Routes.eventDetail, extra: event),
                          );
                        },
                        childCount: events.length,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final event = events[index];
                          return _ListCard(
                            event: event,
                            categoryNames: categoryNames,
                            onTap: () =>
                                context.push(Routes.eventDetail, extra: event),
                          );
                        },
                        childCount: events.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: Brutal.bg,
        body: _buildSkeleton(topPadding),
      ),
      error: (_, __) => Scaffold(
        backgroundColor: Brutal.bg,
        body: const _EmptyState(),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, List<dynamic> cats) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FilterSheet(
        categories: cats,
        selectedId: _selectedCategoryId,
        onSelected: (id) {
          setState(() => _selectedCategoryId = id);
          Navigator.pop(context);
        },
        onClear: () {
          setState(() => _selectedCategoryId = null);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildSkeleton(double topPadding) {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: Brutal.elevated,
        highlightColor: Brutal.hover,
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 80, height: 10, color: Brutal.elevated),
                  const SizedBox(height: 6),
                  Container(width: 160, height: 42, color: Brutal.elevated),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                itemCount: 6,
                itemBuilder: (_, __) => Container(
                  width: 64,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(color: Brutal.elevated),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.68,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, __) => Container(color: Brutal.card),
                childCount: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category filter chips ────────────────────────────────────────────────────
class _CategoryChips extends StatelessWidget {
  final List<dynamic> categories;
  final String? selectedId;
  final void Function(String? id) onSelected;

  const _CategoryChips({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isAll = selectedId == null;
            return _Chip(
              label: 'ALL',
              isSelected: isAll,
              onTap: () => onSelected(null),
            );
          }
          final cat = categories[index - 1];
          final isSelected = selectedId == cat.id;
          return _Chip(
            label: (cat.category ?? '').toUpperCase(),
            isSelected: isSelected,
            onTap: () => onSelected(isSelected ? null : cat.id),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Brutal.magenta : Brutal.card,
          border: Border.all(
            color: isSelected ? Brutal.magenta : Brutal.hairlineColor,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: Brutal.label(
              size: 9,
              color: isSelected ? Brutal.bg : Brutal.dim,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Poster card ──────────────────────────────────────────────────────────────
class _PosterCard extends StatelessWidget {
  final EventViewModel event;
  final Map<String, String> categoryNames;
  final VoidCallback onTap;

  const _PosterCard({required this.event, required this.categoryNames, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(event.startDate);
    final dayStr = date != null ? DateFormat('EEE, MMM dd').format(date).toUpperCase() : '';
    final timeStr = event.startDate.toTimeString();
    final price = event.femalePrice == 0
        ? 'FREE'
        : '¥${event.femalePrice.toInt()}';
    final isLive = isClubOpen(event.club.openingTime, event.club.closingTime, event.club.workingDay);

    // Resolve first category ID to human-readable name
    final genreLabel = event.category.isNotEmpty
        ? (categoryNames[event.category.first] ?? '').toUpperCase()
        : null;
    final hasGenre = genreLabel != null && genreLabel.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Brutal.card,
          border: Border.all(
            color: isLive
                ? Brutal.magenta.withValues(alpha: 0.6)
                : Brutal.hairlineColor,
            width: isLive ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Full bleed image
            Positioned.fill(
              child: NomuCachedNetworkImage(
                imageUrl: event.image,
                fit: BoxFit.cover,
              ),
            ),

            // Bottom gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: const [
                      Colors.transparent,
                      Color(0x55000000),
                      Color(0xDD000000),
                      Color(0xF5050505),
                    ],
                    stops: const [0.2, 0.5, 0.75, 1.0],
                  ),
                ),
              ),
            ),

            // Genre tag — top left
            if (hasGenre)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  color: Brutal.magenta,
                  child: Text(
                    genreLabel,
                    style: Brutal.label(size: 9, color: Brutal.bg),
                  ),
                ),
              ),

            // LIVE dot — top right
            if (isLive)
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Brutal.magenta,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text('LIVE', style: Brutal.label(size: 8, color: Brutal.magenta)),
                  ],
                ),
              ),

            // Bottom content
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Event name
                  Text(
                    event.name.toUpperCase(),
                    style: Brutal.display(size: 17, color: Brutal.paper),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Date + time + price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (dayStr.isNotEmpty)
                              Text(
                                dayStr,
                                style: Brutal.label(size: 9, color: Brutal.dim),
                              ),
                            Text(
                              timeStr,
                              style: Brutal.label(size: 9, color: Brutal.mute),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              event.club.name,
                              style: Brutal.body(size: 11, color: Brutal.mute),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        price,
                        style: Brutal.label(size: 14, color: Brutal.paper),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── List card (single-column view) ──────────────────────────────────────────
class _ListCard extends StatelessWidget {
  final EventViewModel event;
  final Map<String, String> categoryNames;
  final VoidCallback onTap;

  const _ListCard({required this.event, required this.categoryNames, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(event.startDate);
    final dayStr = date != null ? DateFormat('EEE, MMM dd').format(date).toUpperCase() : '';
    final timeStr = event.startDate.toTimeString();
    final price = event.femalePrice == 0 ? 'FREE' : '¥${event.femalePrice.toInt()}';
    final genreLabel = event.category.isNotEmpty
        ? (categoryNames[event.category.first] ?? '').toUpperCase()
        : null;
    final hasGenre = genreLabel != null && genreLabel.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        height: 100,
        decoration: BoxDecoration(
          color: Brutal.card,
          border: Border.all(color: Brutal.hairlineColor),
        ),
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 100,
              height: 100,
              child: NomuCachedNetworkImage(
                imageUrl: event.image,
                fit: BoxFit.cover,
              ),
            ),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Genre + name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasGenre)
                          Text(genreLabel, style: Brutal.label(size: 9, color: Brutal.magenta)),
                        const SizedBox(height: 3),
                        Text(
                          event.name,
                          style: Brutal.display(size: 16, color: Brutal.paper),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // Date + price
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dayStr, style: Brutal.label(size: 9, color: Brutal.dim)),
                              Text('$timeStr · ${event.club.name}',
                                  style: Brutal.body(size: 11, color: Brutal.mute),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Text(price, style: Brutal.label(size: 13, color: Brutal.paper)),
                      ],
                    ),
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

// ─── Filter bottom sheet ──────────────────────────────────────────────────────
class _FilterSheet extends StatelessWidget {
  final List<dynamic> categories;
  final String? selectedId;
  final void Function(String id) onSelected;
  final VoidCallback onClear;

  const _FilterSheet({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Text('FILTER BY GENRE', style: Brutal.display(size: 18, color: Brutal.paper)),
                const Spacer(),
                if (selectedId != null)
                  GestureDetector(
                    onTap: onClear,
                    child: Text('CLEAR', style: Brutal.label(size: 10, color: Brutal.magenta)),
                  ),
              ],
            ),
          ),

          // Category grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final id = cat.id;
                final label = (cat.category ?? '').toUpperCase();
                final isSelected = selectedId == id;
                return GestureDetector(
                  onTap: () => onSelected(id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Brutal.magenta : Brutal.card,
                      border: Border.all(
                        color: isSelected ? Brutal.magenta : Brutal.hairlineColor,
                      ),
                    ),
                    child: Text(
                      label,
                      style: Brutal.label(
                        size: 10,
                        color: isSelected ? Brutal.bg : Brutal.dim,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
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
          Text('NO EVENTS FOUND', style: Brutal.display(size: 20, color: Brutal.dim)),
          const SizedBox(height: 6),
          Text('Check back later', style: Brutal.body(size: 14, color: Brutal.mute)),
        ],
      ),
    );
  }
}
