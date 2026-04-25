import 'dart:ui';
import 'package:clubship/colors.dart';
import 'package:clubship/data/supabase_models/club.dart';
import 'package:clubship/widgets/cached_image.dart';
import 'package:flutter/material.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:google_fonts/google_fonts.dart';

class ClubCard extends StatelessWidget {
  final Club club;
  final VoidCallback onTap;

  const ClubCard({
    super.key,
    required this.onTap,
    required this.club,
  });

  String _getFirstThreeWords(String? address) {
    if (address == null || address.trim().isEmpty) return "";
    final words = address.trim().split(RegExp(r'\s+'));
    return words.take(3).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final time = formatOpeningTime(club.openingTime);
    final isOpen = isClubOpen(club.openingTime, club.closingTime);
    final shortAddress = _getFirstThreeWords(club.locationAddress);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 240,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E), // Dark background color
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: ColorPallete.brightPink.withValues(alpha: 0.1),
                blurRadius: 30,
                offset: const Offset(0, 5),
                spreadRadius: -5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22.5), // Slightly smaller to account for border
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: NomuCachedNetworkImage(
                    imageUrl: club.image ?? '',
                    fit: BoxFit.cover,
                  ),
                ),

                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.black.withValues(alpha: 0.7),
                            Colors.black.withValues(alpha: 0.95),
                            Colors.black.withValues(alpha: 0.98),
                          ],
                          stops: const [0.0, 0.4, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Club Name
                        Text(
                          club.name,
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),

                        // Location
                        if (shortAddress.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: ColorPallete.brightPink,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  shortAddress,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],

                        // Opening Time & Open/Closed Status
                        Row(
                          children: [
                            // Opening Time
                            Icon(
                              Icons.schedule_rounded,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Opens at $time',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            const Spacer(),

                            // Open/Closed Status Badge

                          ],
                        ),

                        const SizedBox(height: 12),

                        // Price Tags Row
                        Row(
                          children: [
                            // Female Price
                            _PriceTag(
                              label: 'Starts from',
                              price: club.femalePrice,
                            ),
                            const SizedBox(width: 8),

                            const Spacer(),


                            

                            // Drink Tickets Badge
                            if (club.femaleDrinkTicket > 0 || club.maleDrinkTicket > 0)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF00BCD4).withValues(alpha: 0.3),
                                      const Color(0xFF0097A7).withValues(alpha: 0.3),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF00BCD4).withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.local_bar,
                                  size: 16,
                                  color: Colors.cyan[100],
                                ),
                              ),
                            Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isOpen
                                    ? Colors.green.withValues(alpha: 0.2)
                                    : Colors.grey.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isOpen
                                      ? Colors.green.withValues(alpha: 0.6)
                                      : Colors.grey.withValues(alpha: 0.6),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isOpen ? Colors.green : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isOpen ? 'Open' : 'Closed',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isOpen ? Colors.green : Colors.grey,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Guestlist Badge (if applicable)
                  if (club.guestlist > 0)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ColorPallete.brightPink.withValues(alpha: 0.95),
                              const Color(0xFFE91E63).withValues(alpha: 0.95),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: ColorPallete.brightPink.withValues(alpha: 0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'GUESTLIST',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
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
        ),
      );

  }
}

// Price Tag Widget
class _PriceTag extends StatelessWidget {
  final String label;
  final num price;

  const _PriceTag({
    required this.label,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            price == 0 ? 'Free' : '¥${price.toInt()}',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: price == 0 ? Colors.green : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

