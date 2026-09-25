import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/design/brutal.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/widgets/cached_image.dart';
import 'package:flutter/material.dart';

class ClubCard extends StatelessWidget {
  final Club club;
  final VoidCallback onTap;

  const ClubCard({super.key, required this.onTap, required this.club});

  @override
  Widget build(BuildContext context) {
    final isOpen = isClubOpen(club.openingTime, club.closingTime, club.workingDay);
    final time = formatOpeningTime(club.openingTime);


    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 240,
        margin: const EdgeInsets.only(bottom: 1),
        decoration: BoxDecoration(
          color: Brutal.card,
          border: Border.all(
            color: isOpen ? Brutal.magenta.withValues(alpha: 0.6) : Brutal.hairlineColor,
            width: isOpen ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Full-bleed image
            Positioned.fill(
              child: NomuCachedNetworkImage(
                imageUrl: club.image ?? '',
                fit: BoxFit.cover,
              ),
            ),

            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: const [
                      Colors.transparent,
                      Color(0x88000000),
                      Color(0xEE000000),
                    ],
                    stops: const [0.3, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // Open/Closed badge — top right
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                color: isOpen ? Brutal.magenta : Brutal.elevated,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isOpen ? Brutal.paper : Brutal.mute,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isOpen ? 'OPEN' : 'CLOSED',
                      style: Brutal.label(
                        size: 8,
                        color: isOpen ? Brutal.paper : Brutal.mute,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Guestlist badge — top left
            if (club.guestlist > 0)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: Brutal.yellow,
                  child: Text(
                    'GUESTLIST',
                    style: Brutal.label(size: 9, color: Brutal.bg),
                  ),
                ),
              ),

            // Bottom content
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Club name
                  Text(
                    club.name,
                    style: Brutal.display(size: 24, color: Brutal.paper),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Location + time row
                  Row(
                    children: [
                      if (club.locationAddress != null) ...[
                        const Icon(Icons.location_on, size: 12, color: Brutal.magenta),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            club.locationAddress!,
                            style: Brutal.label(size: 10, color: Brutal.dim),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ] else
                        const Spacer(),
                      const SizedBox(width: 8),
                      Text(
                        'From ¥${club.femalePrice.toInt()}',
                        style: Brutal.label(size: 10, color: Brutal.magenta),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 12, color: Brutal.mute),
                      const SizedBox(width: 4),
                      Text('Opens $time', style: Brutal.label(size: 10, color: Brutal.mute)),
                      if (club.femaleDrinkTicket > 0 || club.maleDrinkTicket > 0) ...[
                        const Spacer(),
                        const Icon(Icons.local_bar, size: 12, color: Brutal.cyan),
                        const SizedBox(width: 4),
                        Text('Drinks incl.', style: Brutal.label(size: 10, color: Brutal.cyan)),
                      ],
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
