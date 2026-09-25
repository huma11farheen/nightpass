import 'package:clubship/colors.dart';
import 'package:clubship/widgets/back_button.dart';
import 'dart:ui';
import 'package:clubship/clubs/club_list_page.dart';
import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/data/supabase_models/event_ticket.dart';
import 'package:clubship/event/event_view_model.dart';
import 'package:clubship/event/providers/get_events_provider.dart';
import 'package:clubship/my_page/providers/get_user_detail_provider.dart';
import 'package:clubship/qr_code/qr_code.dart';
import 'package:clubship/router.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/widgets/cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clubship/design/brutal.dart';

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
    // Prefer the real event from the provider — it has correct prices,
    // guestlist counts, drink ticket counts, etc.
    final realEvent = ref
        .read(getEventsProvider)
        .valueOrNull
        ?.where((e) => e.id == widget.ticket.eventId)
        .firstOrNull;
    if (realEvent != null) return realEvent;

    // Fallback: reconstruct from ticket data (read-only view, no buying)
    final clubsState = ref.read(clubListProvider);
    Club? actualClub;
    try {
      actualClub = clubsState.clubs.firstWhere(
        (club) => club.id == widget.ticket.clubId,
      );
    } catch (_) {}

    final club = actualClub ??
        Club(
          id: widget.ticket.clubId ?? 'unknown',
          createdAt: DateTime.now().toIso8601String(),
          openingTime: '18:00',
          closingTime: '06:00',
          description: '',
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

    return EventViewModel(
      id: widget.ticket.eventId,
      createdAt: widget.ticket.createdAt,
      name: widget.ticket.eventName ?? 'Unknown Event',
      image: widget.ticket.image ?? '',
      description: '',
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
      backgroundColor: Brutal.bg,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(color: Brutal.bg),
          ),

          // Content
          CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: Colors.transparent,
                leading: const AppBackButton(forAppBar: true),
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
                                Brutal.magenta,
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
                              Brutal.bg,
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
                              style:
                                  Brutal.display(size: 26, color: Brutal.paper),
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
                                    color:
                                        Brutal.magenta.withValues(alpha: 0.9),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      widget.ticket.clubName ?? '',
                                      style: Brutal.body(
                                          size: 15, color: Brutal.dim),
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
                                    Brutal.magenta,
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
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Brutal.elevated,
                            border: Border.all(
                                color: Brutal.hairlineColor, width: 1),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'YOUR TICKET',
                                style:
                                    Brutal.label(size: 13, color: Brutal.mute),
                              ),
                              const SizedBox(height: 20),

                              // QR Code
                              Container(
                                padding: const EdgeInsets.all(20),
                                color: Colors.white,
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
                                style: Brutal.label(
                                  size: 14,
                                  color: widget.ticket.checkedIn == true
                                      ? Colors.green
                                      : Brutal.magenta,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                'TICKET #${widget.ticket.id.substring(0, 8).toUpperCase()}',
                                style:
                                    Brutal.label(size: 12, color: Brutal.mute),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Drink Ticket Info Banner
                    if (widget.ticket.checkedIn != true)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Brutal.elevated,
                            border: Border.all(
                              color: Brutal.yellow.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_bar_rounded,
                                color: Brutal.yellow,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Drink Tickets',
                                      style: Brutal.body(
                                          size: 16, color: Brutal.paper),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Your drink tickets will be generated after scanning this ticket at the entrance',
                                      style: Brutal.body(
                                          size: 14, color: Brutal.dim),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                                final eventViewModel =
                                    _createEventViewModelFromTicket();
                                context.push(Routes.eventDetail,
                                    extra: eventViewModel);
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
                          style: Brutal.display(size: 38, color: Brutal.paper),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'This ticket has been used',
                          style: Brutal.body(size: 18, color: Brutal.dim),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      child: Text(
        text,
        style: Brutal.label(size: 12, color: Colors.white),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Brutal.elevated,
        border: Border.all(color: Brutal.hairlineColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 16, color: Brutal.magenta.withValues(alpha: 0.9)),
              const SizedBox(width: 6),
              Text(label.toUpperCase(),
                  style: Brutal.label(size: 11, color: Brutal.mute)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Brutal.body(size: 18, color: Brutal.paper),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Brutal.elevated,
          border: Border.all(color: Brutal.hairlineColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Brutal.paper),
            const SizedBox(width: 8),
            Text(label, style: Brutal.body(size: 16, color: Brutal.paper)),
          ],
        ),
      ),
    );
  }
}
