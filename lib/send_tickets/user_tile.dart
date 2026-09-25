import 'package:clubship/design/brutal.dart';
import 'package:clubship/widgets/cached_image.dart';
import 'package:flutter/material.dart';

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
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Brutal.bg : Brutal.elevated,
          border: isSelected
              ? Border.all(color: Brutal.magenta, width: 2)
              : Border.all(color: Brutal.hairlineColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Square avatar
            Container(
              width: 44,
              height: 44,
              color: Brutal.card,
              child: ClipRect(
                child: image.isEmpty
                    ? const Icon(Icons.person, color: Brutal.mute, size: 22)
                    : NomuCachedNetworkImage(imageUrl: image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 14),

            // Username
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Brutal.body(
                  size: 15,
                  color: isSelected ? Brutal.paper : Brutal.dim,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Selection indicator
            if (isSelected)
              const Icon(Icons.check, color: Brutal.magenta, size: 18)
            else
              const Icon(Icons.arrow_forward_ios, color: Brutal.mute, size: 13),
          ],
        ),
      ),
    );
  }
}
