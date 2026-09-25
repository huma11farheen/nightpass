import 'package:clubship/widgets/back_button.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/event/event_view_model.dart';
import 'package:clubship/event/providers/get_category_provider.dart';
import 'package:clubship/router.dart';
import 'package:clubship/widgets/app_button.dart';
import 'package:clubship/widgets/dots_indicator.dart';
import 'package:clubship/widgets/map_view_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EventDetailPage extends ConsumerStatefulWidget {
  const EventDetailPage({super.key, required this.eventItem});

  final EventViewModel eventItem;

  @override
  ConsumerState<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends ConsumerState<EventDetailPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<String> images = List.from(widget.eventItem.subImages);
    images.insert(0, widget.eventItem.image);

    return Scaffold(
      backgroundColor: Brutal.bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AppBackButton(forAppBar: true),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Brutal.magenta,
            ),
            child: IconButton(
              icon: const Icon(Icons.table_restaurant_rounded, color: Brutal.paper),
              onPressed: () => context.push(Routes.vip, extra: widget.eventItem),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Brutal.magenta,
        backgroundColor: Brutal.card,
        strokeWidth: 3.0,
        displacement: 60,
        edgeOffset: 20,
        onRefresh: () async {
          setState(() {});
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Hero Image Carousel
              Stack(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      height: 500,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                    items: images
                        .map(
                          (e) => Container(
                            width: double.infinity,
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
                  // Gradient overlay — fade into Brutal.bg
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Brutal.bg.withValues(alpha: 0.55),
                            Brutal.bg.withValues(alpha: 0.85),
                            Brutal.bg,
                          ],
                          stops: const [0.0, 0.4, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Event name + flat chips overlay
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Builder(builder: (context) {
                          final hasGuestlist = widget.eventItem.gustlist > 0 &&
                              widget.eventItem.registeredGuestlist < widget.eventItem.gustlist;
                          final spotsLeft = widget.eventItem.gustlist - widget.eventItem.registeredGuestlist;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Guestlist tag — above the title so it's the first thing seen
                              if (hasGuestlist)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  color: Brutal.yellow,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.female, size: 13, color: Brutal.bg),
                                      const SizedBox(width: 5),
                                      Text(
                                        'FREE GUESTLIST FOR LADIES · $spotsLeft SPOTS LEFT',
                                        style: Brutal.label(size: 10, color: Brutal.bg),
                                      ),
                                    ],
                                  ),
                                ),
                              Text(
                                widget.eventItem.name,
                                style: Brutal.display(size: 30, color: Brutal.paper),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            // Club/location chip — magenta flat
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              color: Brutal.magenta,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on, size: 13, color: Brutal.paper),
                                  const SizedBox(width: 5),
                                  Text(
                                    widget.eventItem.club.name,
                                    style: Brutal.label(size: 12, color: Brutal.paper),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Genre chips — flat card style
                            if (widget.eventItem.category.isNotEmpty)
                              Consumer(
                                builder: (context, ref, child) {
                                  final categoriesAsync = ref.watch(getCategoryProvider);
                                  return categoriesAsync.when(
                                    data: (categories) {
                                      final categoryMap = {
                                        for (var cat in categories) cat.id: cat.category ?? cat.id
                                      };
                                      return Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: widget.eventItem.category.map((categoryId) {
                                          final categoryName = categoryMap[categoryId] ?? categoryId;
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Brutal.card,
                                              border: Border.all(color: Brutal.hairlineColor),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.music_note, size: 12, color: Brutal.yellow),
                                                const SizedBox(width: 4),
                                                Text(
                                                  categoryName,
                                                  style: Brutal.label(size: 12, color: Brutal.dim),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                    loading: () => const SizedBox(
                                      width: 40,
                                      height: 12,
                                      child: Center(
                                        child: SizedBox(
                                          width: 10,
                                          height: 10,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Brutal.yellow),
                                          ),
                                        ),
                                      ),
                                    ),
                                    error: (_, __) => Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: widget.eventItem.category.map((categoryId) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Brutal.card,
                                            border: Border.all(color: Brutal.hairlineColor),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.music_note, size: 12, color: Brutal.yellow),
                                              const SizedBox(width: 4),
                                              Text(
                                                categoryId,
                                                style: Brutal.label(size: 12, color: Brutal.dim),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (images.length > 1)
                    Positioned(
                      top: 100,
                      right: 16,
                      child: DotsIndicator(
                        dotCount: images.length,
                        currentIndex: _currentIndex,
                      ),
                    ),
                ],
              ),
              eventDetails(event: widget.eventItem),
            ],
          ),
        ),
      ),
      persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: AppButton.primary(
            text: 'Buy Ticket',
            onPressed: () => context.push(
              Routes.ticketBuyingScreen,
              extra: widget.eventItem,
            ),
            isPersistentFooterButton: false,
          ),
        ),
      ],
    );
  }

  Widget eventDetails({required EventViewModel event}) {
    final startDateTime = DateTime.parse(event.startDate);
    final endDateTime = DateTime.parse(event.endDate);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Description ───────────────────────────────────────────────────
          if (event.description != null && event.description!.isNotEmpty) ...[
            _SectionCard(
              header: const _SectionHeader(label: 'About This Event', icon: Icons.info_outline),
              child: Text(
                event.description!,
                style: Brutal.body(size: 17, color: Brutal.dim),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Date & Time ───────────────────────────────────────────────────
          _SectionCard(
            header: const _SectionHeader(label: 'When', icon: Icons.access_time),
            child: Column(
              children: [
                _buildDateTimeRow(
                  icon: Icons.calendar_today,
                  label: 'Start',
                  date: DateFormat('EEEE, MMM dd, yyyy').format(startDateTime),
                  time: DateFormat('hh:mm a').format(startDateTime),
                ),
                const SizedBox(height: 12),
                const Divider(color: Brutal.hairlineColor, height: 1),
                const SizedBox(height: 12),
                _buildDateTimeRow(
                  icon: Icons.calendar_today,
                  label: 'End',
                  date: DateFormat('EEEE, MMM dd, yyyy').format(endDateTime),
                  time: DateFormat('hh:mm a').format(endDateTime),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Pricing ───────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _buildPriceCard(
                  label: 'Women',
                  price: event.femalePrice,
                  icon: Icons.female,
                  color: Brutal.magenta,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPriceCard(
                  label: 'Men',
                  price: event.malePrice,
                  icon: Icons.male,
                  color: Brutal.cyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Stats & Features ──────────────────────────────────────────────
          if (event.freeFemaleDrinkTicket > 0 ||
              event.freeMaleDrinkTicket > 0 ||
              event.isRecurring ||
              event.payAtTheDoor) ...[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (event.freeFemaleDrinkTicket > 0)
                  _buildStatChip(
                    icon: Icons.local_bar,
                    label: 'Free Drinks (Women)',
                    value: event.freeFemaleDrinkTicket.toString(),
                    color: Brutal.yellow,
                  ),
                if (event.freeMaleDrinkTicket > 0)
                  _buildStatChip(
                    icon: Icons.local_bar,
                    label: 'Free Drinks (Men)',
                    value: event.freeMaleDrinkTicket.toString(),
                    color: Brutal.yellow,
                  ),
                if (event.isRecurring)
                  _buildStatChip(
                    icon: Icons.repeat,
                    label: 'Recurring Event',
                    value: '',
                    color: Brutal.cyan,
                  ),
                if (event.payAtTheDoor)
                  _buildStatChip(
                    icon: Icons.payments,
                    label: 'Pay at Door',
                    value: '',
                    color: Brutal.magenta,
                  ),
              ],
            ),

            // Drink ticket note
            if (event.freeFemaleDrinkTicket > 0 || event.freeMaleDrinkTicket > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Brutal.yellow.withValues(alpha: 0.08),
                  border: Border.all(color: Brutal.yellow.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Brutal.yellow, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Drink tickets will be generated once your event ticket is scanned at the venue.',
                        style: Brutal.body(size: 15, color: Brutal.yellow),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],

          // ── Location ──────────────────────────────────────────────────────
          _SectionCard(
            header: const _SectionHeader(label: 'Location', icon: Icons.location_on),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.club.locationAddress ?? event.locationAddress,
                  style: Brutal.body(size: 15, color: Brutal.mute),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                MapViewWidget(
                  lat: event.club.lat,
                  lon: event.club.lng,
                  locationName: event.club.name,
                  locationAddress: event.club.locationAddress,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDateTimeRow({
    required IconData icon,
    required String label,
    required String date,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Brutal.mute, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Brutal.label(size: 11, color: Brutal.mute),
              ),
              const SizedBox(height: 3),
              Text(
                date,
                style: Brutal.body(size: 16, color: Brutal.paper),
              ),
              Text(
                time,
                style: Brutal.body(size: 15, color: Brutal.dim),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard({
    required String label,
    required double price,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Brutal.elevated,
        border: Border.all(color: Brutal.hairlineColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: Brutal.display(size: 18, color: Brutal.paper),
          ),
          const SizedBox(height: 6),
          Text(
            price == 0
                ? 'Free'
                : '¥${price.toStringAsFixed(price == price.toInt() ? 0 : 2)}',
            style: Brutal.display(size: 30, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 7),
          Text(
            value.isEmpty ? label : '$label: $value',
            style: Brutal.label(size: 12, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Section layout helpers ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 2, height: 18, color: Brutal.magenta),
        const SizedBox(width: 10),
        Icon(icon, size: 16, color: Brutal.magenta),
        const SizedBox(width: 8),
        Text(label, style: Brutal.display(size: 18, color: Brutal.paper)),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.header, required this.child});

  final Widget header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Brutal.elevated,
        border: Border.all(color: Brutal.hairlineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// Simple image card widgets for other screens (vip, guestlist)
class SingleImageCard extends StatelessWidget {
  const SingleImageCard({super.key, required this.event});

  final EventViewModel event;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(event.image),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class ImageCard extends StatelessWidget {
  const ImageCard({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
