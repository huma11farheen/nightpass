import 'dart:ui';
import 'package:clubship/colors.dart';
import 'package:clubship/clubs/club_list_page.dart';
import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/data/supabase_models/event_ticket.dart';
import 'package:clubship/event/event_view_model.dart';
import 'package:clubship/my_page/providers/get_user_detail_provider.dart';
import 'package:clubship/qr_code/qr_code.dart';
import 'package:clubship/router.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/widgets/cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class EventTicketDetailPage extends ConsumerStatefulWidget {
  final EventTicket ticket;

  const EventTicketDetailPage({super.key, required this.ticket});

  @override
  ConsumerState<EventTicketDetailPage> createState() =>
      _EventTicketDetailPageState();
}

class _EventTicketDetailPageState extends ConsumerState<EventTicketDetailPage> {
  bool _showQR = true;

  EventViewModel _createEventViewModelFromTicket() {
    // Fetch club data from the club list provider to get actual coordinates
    final clubsState = ref.read(clubListProvider);

    // Try to find the actual club with coordinates
    Club? actualClub;
    try {
      actualClub = clubsState.clubs.firstWhere(
        (club) => club.id == widget.ticket.clubId,
      );
    } catch (e) {
      // Club not found in list
      actualClub = null;
    }

    // Use actual club if found, otherwise create minimal club
    final club = actualClub ?? Club(
      id: widget.ticket.clubId ?? 'unknown',
      createdAt: DateTime.now().toIso8601String(),
      openingTime: '18:00',
      closingTime: '06:00',
      description: 'Club for ${widget.ticket.eventName ?? 'Event'}',
      femalePrice: widget.ticket.price,
      menPrice: widget.ticket.price,
      name: widget.ticket.clubName ?? 'Unknown Club',
      image: widget.ticket.image,
      lat: 0.0,
      lng: 0.0,
      locationAddress: widget.ticket.clubName ?? 'Unknown Location',
      femaleDrinkTicket: 0,
      maleDrinkTicket: 0,
      guestlist: 0,
      guestlistDiscount: 0.0,
    );

    // Create EventViewModel from ticket data
    return EventViewModel(
      id: widget.ticket.eventId,
      createdAt: widget.ticket.createdAt,
      name: widget.ticket.eventName ?? 'Unknown Event',
      image: widget.ticket.image ?? '',
      description: 'Event details for ${widget.ticket.eventName ?? 'this event'}',
      femalePrice: widget.ticket.price,
      malePrice: widget.ticket.price,
      startDate: widget.ticket.eventDate ?? DateTime.now().toIso8601String(),
      endDate: widget.ticket.eventDate ?? DateTime.now().toIso8601String(),
      locationAddress: widget.ticket.clubName ?? 'Unknown Location',
      clubId: widget.ticket.clubId,
      payAtTheDoor: widget.ticket.isPayAtDoor,
      club: club,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(getUserDetailProvider);
    final date = DateTime.parse(widget.ticket.eventDate ?? '');
    final formattedDate = formatEventDate(date);
    final time =
    formatTimeToHour(widget.ticket.eventDate?.toTimeString() ?? '');

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF0F0F1E),
                  ],
                ),
              ),
            ),
          ),

          // Content
          CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.transparent,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ),
                actions: [
                  if (!widget.ticket.isPayAtDoor &&
                      widget.ticket.checkedIn != true)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          context.push(Routes.sendEventTicket,
                              extra: widget.ticket.id);
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ColorPallete.brightPink,
                                const Color(0xFFE91E63),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: ColorPallete.brightPink
                                    .withValues(alpha: 0.5),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Event Image
                      NomuCachedNetworkImage(
                        imageUrl: widget.ticket.image ?? '',
                        fit: BoxFit.cover,
                      ),

                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                              const Color(0xFF0F0F1E),
                            ],
                            stops: const [0.0, 0.7, 1.0],
                          ),
                        ),
                      ),

                      // Event Title
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.ticket.eventName ?? '',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.ticket.clubName != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 16,
                                    color: ColorPallete.brightPink
                                        .withValues(alpha: 0.9),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      widget.ticket.clubName ?? '',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white
                                            .withValues(alpha: 0.85),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Status badges
                      Positioned(
                        top: 60,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (widget.ticket.isPayAtDoor)
                              _StatusBadge(
                                text: 'PAY AT DOOR',
                                gradient: LinearGradient(
                                  colors: [
                                    ColorPallete.brightPink,
                                    const Color(0xFFE91E63),
                                  ],
                                ),
                                shadowColor: ColorPallete.brightPink,
                              ),
                            if (widget.ticket.isGuestlist) ...[
                              const SizedBox(height: 8),
                              _StatusBadge(
                                text: 'GUESTLIST',
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green,
                                    const Color(0xFF4CAF50),
                                  ],
                                ),
                                shadowColor: Colors.green,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Ticket Info Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.calendar_today_rounded,
                              label: 'Date',
                              value: formattedDate,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.access_time_rounded,
                              label: 'Time',
                              value: time,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.person_rounded,
                              label: 'Attendee',
                              value: widget.ticket.attendeeName ??
                                  user.value?.name ??
                                  '',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.confirmation_number_rounded,
                              label: 'Price',
                              value: widget.ticket.price == 0
                                  ? 'FREE'
                                  : '¥${widget.ticket.price.toInt()}',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // QR Code Section
                    if (_showQR)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF1A1A2E)
                                        .withValues(alpha: 0.8),
                                    const Color(0xFF16213E)
                                        .withValues(alpha: 0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorPallete.brightPink
                                        .withValues(alpha: 0.1),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'YOUR TICKET',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color:
                                      Colors.white.withValues(alpha: 0.5),
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // QR Code
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.2),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: QRCodeGenerator(
                                      widget.ticket.qrCode,
                                      height: 250,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Text(
                                    widget.ticket.checkedIn == true
                                        ? 'TICKET USED'
                                        : 'SCAN AT ENTRANCE',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: widget.ticket.checkedIn == true
                                          ? Colors.green
                                          : ColorPallete.brightPink,
                                      letterSpacing: 1.5,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Text(
                                    'TICKET #${widget.ticket.id
                                        .substring(0, 8)
                                        .toUpperCase()}',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color:
                                      Colors.white.withValues(alpha: 0.4),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Drink Ticket Info Banner
                    if (widget.ticket.checkedIn != true)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.amber.withValues(alpha: 0.2),
                                    Colors.orange.withValues(alpha: 0.15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.amber.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.local_bar_rounded,
                                      color: Colors.amber.shade300,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Drink Tickets',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Your drink tickets will be generated after scanning this ticket at the entrance',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withValues(alpha: 0.7),
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Action Buttons

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              icon: _showQR
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              label: _showQR ? 'Hide QR' : 'Show QR',
                              onTap: () {
                                setState(() {
                                  _showQR = !_showQR;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.info_outline_rounded,
                              label: 'Event Details',
                              onTap: () {

                                final eventViewModel = _createEventViewModelFromTicket();
                                context.push(Routes.eventDetail, extra: eventViewModel);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),

          // Checked In Overlay
          if (widget.ticket.checkedIn == true)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.85),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 80,
                            color: Colors.green.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'CHECKED IN',
                          style: GoogleFonts.outfit(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'This ticket has been used',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final LinearGradient gradient;
  final Color shadowColor;

  const _StatusBadge({
    required this.text,
    required this.gradient,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1A2E).withValues(alpha: 0.6),
                const Color(0xFF16213E).withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: ColorPallete.brightPink.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorPallete.brightPink.withValues(alpha: 0.3),
                  Colors.purple.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
