import 'package:clubship/colors.dart';
import 'package:clubship/event/event_view_model.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/widgets/cached_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final EventViewModel eventItem;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.eventItem,
    required this.onTap,
  });

  String _getEventInfo() {
    final date = DateTime.parse(eventItem.startDate);
    final formattedDate = DateFormat('MMM dd').format(date);
    final time = eventItem.startDate.toTimeString();
    return '$formattedDate • $time';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Event Image
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: NomuCachedNetworkImage(
                      imageUrl: eventItem.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Event Details
                const SizedBox(height: 6),
                Text(
                  eventItem.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  eventItem.club.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date/Time info
                    Expanded(
                      child: Text(
                        _getEventInfo(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Drink icon if free drinks included
                    if (eventItem.freeFemaleDrinkTicket > 0 ||
                        eventItem.freeMaleDrinkTicket > 0)
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: ColorPallete.brightPink.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(


                          Icons.local_bar,
                          size: 16,
                          color: Colors.yellowAccent,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Price ribbon
          Positioned(
            top: 10,
            right: -20,
            child: _RibbonBanner(
              text: eventItem.femalePrice == 0
                  ? 'Free Entry'
                  : '¥${eventItem.femalePrice.toInt()}',
            ),
          ),
        ],
      ),
    );
  }
}

class _RibbonBanner extends StatelessWidget {
  final String text;

  const _RibbonBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: const BoxDecoration(
            color: ColorPallete.brightPink,
            boxShadow: [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        Positioned(
          bottom: -8,
          right: 0,
          child: CustomPaint(
            size: const Size(16, 8),
            painter: _FoldedCornerPainter(),
          ),
        ),
      ],
    );
  }
}

class _FoldedCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD81B60)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
