import 'dart:ui';
import 'package:clubship/colors.dart';
import 'package:clubship/widgets/cached_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserTile extends StatelessWidget {
  const UserTile({
    super.key,
    required this.image,
    required this.onSelected,
    required this.isSelected,
    required this.name,
  });

  final String image;
  final String name;
  final VoidCallback onSelected;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [
                        ColorPallete.brightPink.withValues(alpha: 0.25),
                        Colors.purple.withValues(alpha: 0.25),
                      ]
                    : [
                        const Color(0xFF1A1A2E).withValues(alpha: 0.5),
                        const Color(0xFF16213E).withValues(alpha: 0.5),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? ColorPallete.brightPink.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.1),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: ColorPallete.brightPink.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Avatar with gradient border when selected
                Container(
                  padding: isSelected ? const EdgeInsets.all(3) : null,
                  decoration: isSelected
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              ColorPallete.brightPink,
                              Colors.purple,
                            ],
                          ),
                        )
                      : null,
                  child: Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0F0F1E),
                      border: !isSelected
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1,
                            )
                          : null,
                    ),
                    child: ClipOval(
                      child: image.isEmpty
                          ? Image.asset(
                              'assets/images/default_profile_img.png',
                              fit: BoxFit.cover,
                            )
                          : NomuCachedNetworkImage(
                              imageUrl: image,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Name
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Check icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ColorPallete.brightPink
                        : Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelected ? Icons.check_rounded : Icons.circle_outlined,
                    color: Colors.white,
                    size: 20,
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
