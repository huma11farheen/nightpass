import 'package:clubship/colors.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/event_ticket/providers/drink_ticket_view_model.dart';
import 'package:clubship/my_page/providers/get_user_detail_provider.dart';
import 'package:clubship/qr_code/qr_code.dart';
import 'package:clubship/router.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/widgets/cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DrinkTicketCard extends ConsumerWidget {
  const DrinkTicketCard({super.key, required this.drinkTicket});

  final DrinkTicketViewModel drinkTicket;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.parse(drinkTicket.drinkTicket.expiryDate ?? '');
    final formattedDate = formatEventDate(date);

    final eventName = drinkTicket.drinkTicket.eventName ?? '';
    final drinkName = drinkTicket.drinkTicket.eventName ?? 'Drink Voucher';
    final redeemerName = drinkTicket.drinkTicket.redeemerName ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Stack(
        children: [
          // Main ticket card
          Container(
            decoration: BoxDecoration(
              color: Brutal.elevated,
              border: Border.all(color: Brutal.hairlineColor, width: 1),
            ),
            child: Column(
              children: [
                // Top section - Drink image
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: NomuCachedNetworkImage(
                          imageUrl: drinkTicket.drinkTicket.image ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Gradient overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.3),
                                Colors.black.withValues(alpha: 0.95),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Drink name and event
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              drinkName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Brutal.display(size: 22, color: Brutal.paper),
                            ),
                            if (eventName.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.event_rounded,
                                    size: 14,
                                    color: Brutal.cyan.withValues(alpha: 0.9),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      eventName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Brutal.body(size: 14, color: Brutal.dim),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Drink ticket badge
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          color: Brutal.cyan,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_bar, size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                'DRINK TICKET',
                                style: Brutal.label(size: 11, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tear-line divider
                SizedBox(
                  height: 24,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 30,
                        right: 30,
                        top: 12,
                        child: Row(
                          children: List.generate(
                            30,
                            (i) => Expanded(
                              child: Container(
                                height: 1,
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                color: Brutal.hairlineColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -12,
                        top: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Brutal.bg,
                            shape: BoxShape.circle,
                            border: Border.all(color: Brutal.hairlineColor, width: 1),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -12,
                        top: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Brutal.bg,
                            shape: BoxShape.circle,
                            border: Border.all(color: Brutal.hairlineColor, width: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Ticket info section
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _InfoColumn(
                              icon: Icons.schedule_rounded,
                              label: 'VALID UNTIL',
                              value: formattedDate,
                              subValue: 'Expires after event',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            color: Brutal.hairlineColor,
                          ),
                          Expanded(
                            child: _InfoColumn(
                              icon: Icons.person_rounded,
                              label: 'REDEEMER',
                              value: redeemerName,
                              subValue: 'Ticket holder',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // QR Code section
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: Column(
                          children: [
                            QRCodeGenerator(
                              drinkTicket.drinkTicket.qrCode ?? '',
                              height: 180,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'SCAN AT BAR',
                              style: Brutal.label(size: 12, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'TICKET #${drinkTicket.drinkTicket.id.substring(0, 8).toUpperCase()}',
                        style: Brutal.label(size: 11, color: Brutal.mute),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Send button
          if (drinkTicket.drinkTicket.usedTime == null)
            Positioned(
              top: 16,
              left: 16,
              child: GestureDetector(
                onTap: () {
                  context.push(Routes.sendDrinkTicket, extra: drinkTicket.drinkTicket.id);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  color: Brutal.magenta,
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),

          // REDEEMED overlay
          if (drinkTicket.drinkTicket.usedTime != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.88),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 64,
                        color: Colors.green.withValues(alpha: 0.9),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'REDEEMED',
                        style: Brutal.display(size: 34, color: Brutal.paper),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This drink ticket has been used',
                        style: Brutal.body(size: 16, color: Brutal.dim),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subValue;

  const _InfoColumn({
    required this.icon,
    required this.label,
    required this.value,
    this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Brutal.cyan.withValues(alpha: 0.8)),
            const SizedBox(width: 6),
            Text(label, style: Brutal.label(size: 10, color: Brutal.mute)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Brutal.body(size: 16, color: Brutal.paper),
        ),
        if (subValue != null && subValue!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subValue!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Brutal.body(size: 14, color: Brutal.dim),
          ),
        ],
      ],
    );
  }
}
