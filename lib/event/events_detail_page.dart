import 'package:clubship/colors.dart';
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
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.pink,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.table_restaurant_rounded, color: Colors.white),
              onPressed: () => context.push(Routes.vip, extra: widget.eventItem),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: ColorPallete.brightPink,
        backgroundColor: ColorPallete.cardColor,
        strokeWidth: 3.0,
        displacement: 60,
        edgeOffset: 20,
        onRefresh: () async {
          setState(() {
            // Rebuild to refresh data
          });
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
                // Gradient overlay - merged effect
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.95),
                          Colors.black,
                        ],
                        stops: const [0.0, 0.3, 0.6, 0.85, 1.0],
                      ),
                    ),
                  ),
                ),
                // Side gradients for merged effect
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Event Name & Club Name - Clean Title
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.eventItem.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 32,
                          color: Colors.white,
                          letterSpacing: 0.5,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.8),
                              offset: const Offset(0, 3),
                              blurRadius: 12,
                            ),
                            Shadow(
                              color: ColorPallete.brightPink.withValues(alpha: 0.5),
                              offset: const Offset(0, 0),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Club Name
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ColorPallete.brightPink.withValues(alpha: 0.2),
                                  Colors.purple.withValues(alpha: 0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: ColorPallete.brightPink.withValues(alpha: 0.4),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: ColorPallete.brightPink.withValues(alpha: 0.9),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.eventItem.club.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Music Genres
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
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: widget.eventItem.category.map((categoryId) {
                                        final categoryName = categoryMap[categoryId] ?? categoryId;
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.amber.withValues(alpha: 0.2),
                                                Colors.orange.withValues(alpha: 0.2),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.amber.withValues(alpha: 0.5),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.6),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.music_note,
                                                size: 14,
                                                color: Colors.amber.withValues(alpha: 0.9),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                categoryName,
                                                style: const TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.3,
                                                ),
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
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                                        ),
                                      ),
                                    ),
                                  ),
                                  error: (_, __) => Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: widget.eventItem.category.map((categoryId) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.amber.withValues(alpha: 0.2),
                                              Colors.orange.withValues(alpha: 0.2),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.amber.withValues(alpha: 0.5),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.music_note,
                                              size: 14,
                                              color: Colors.amber.withValues(alpha: 0.9),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              categoryId,
                                              style: const TextStyle(
                                                color: Colors.amber,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.3,
                                              ),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (event.description != null && event.description!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorPallete.cardColor.withValues(alpha: 0.6),
                    ColorPallete.backgroundcolor2.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColorPallete.brightPink.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: ColorPallete.brightPink,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'About This Event',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    event.description!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Date & Time Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorPallete.cardColor.withValues(alpha: 0.6),
                  ColorPallete.backgroundcolor2.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorPallete.brightPink.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: ColorPallete.brightPink,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'When',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDateTimeRow(
                  icon: Icons.calendar_today,
                  label: 'Start',
                  date: DateFormat('EEEE, MMM dd, yyyy').format(startDateTime),
                  time: DateFormat('hh:mm a').format(startDateTime),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 16),
                _buildDateTimeRow(
                  icon: Icons.calendar_today,
                  label: 'End',
                  date: DateFormat('EEEE, MMM dd, yyyy').format(endDateTime),
                  time: DateFormat('hh:mm a').format(endDateTime),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Pricing Card
          Row(


            children: [
              Expanded(
                child: _buildPriceCard(
                  label: 'Women',
                  price: event.femalePrice,
                  icon: Icons.female,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPriceCard(
                  label: 'Men',
                  price: event.malePrice,
                  icon: Icons.male,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Stats & Features
          if (event.freeFemaleDrinkTicket > 0 || event.freeMaleDrinkTicket > 0 || event.isRecurring || event.payAtTheDoor) ...[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (event.freeFemaleDrinkTicket > 0)
                  _buildStatChip(
                    icon: Icons.local_bar,
                    label: 'Free Drinks (Women)',
                    value: event.freeFemaleDrinkTicket.toString(),
                    color: Colors.amber,
                  ),
                if (event.freeMaleDrinkTicket > 0)
                  _buildStatChip(
                    icon: Icons.local_bar,
                    label: 'Free Drinks (Men)',
                    value: event.freeMaleDrinkTicket.toString(),
                    color: Colors.amber,
                  ),
                if (event.isRecurring)
                  _buildStatChip(
                    icon: Icons.repeat,
                    label: 'Recurring Event',
                    value: '',
                    color: Colors.orange,
                  ),
                if (event.payAtTheDoor)
                  _buildStatChip(
                    icon: Icons.payments,
                    label: 'Pay at Door',
                    value: '',
                    color: Colors.purple,
                  ),
              ],
            ),

            // Drink Tickets Information Note
            if (event.freeFemaleDrinkTicket > 0 || event.freeMaleDrinkTicket > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Drink tickets will be generated once your event ticket is scanned at the venue.',
                        style: TextStyle(
                          color: Colors.amber.withValues(alpha: 0.9),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],

          // Location Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorPallete.cardColor.withValues(alpha: 0.6),
                  ColorPallete.backgroundcolor2.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.club.locationAddress ?? event.locationAddress,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white60,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (event.club.lat != 0.0 && event.club.lng != 0.0)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: MapViewWidget(
                      lat: event.club.lat,
                      lon: event.club.lng,
                      locationName: event.club.name,
                    ),
                  )
                else
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            color: Colors.white.withValues(alpha: 0.3),
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Map unavailable',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white70, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorPallete.cardColor.withValues(alpha: 0.6),
            ColorPallete.backgroundcolor2.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
       // border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            price == 0 ? 'Free' : '¥${price.toStringAsFixed(price == price.toInt() ? 0 : 2)}',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            value.isEmpty ? label : '$label: $value',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
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
        borderRadius: BorderRadius.circular(20),
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
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
