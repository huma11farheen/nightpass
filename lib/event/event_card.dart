import 'package:clubship/design/brutal.dart';
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
    return '$formattedDate · $time';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Square event image — no border radius
              Expanded(
                child: SizedBox(
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
                style: Brutal.display(size: 15, color: Brutal.paper),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                eventItem.club.name,
                style: Brutal.body(size: 12, color: Brutal.dim),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _getEventInfo(),
                      style: Brutal.label(size: 10, color: Brutal.mute),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (eventItem.freeFemaleDrinkTicket > 0 ||
                      eventItem.freeMaleDrinkTicket > 0)
                    const Icon(Icons.local_bar, size: 12, color: Brutal.cyan),
                ],
              ),
            ],
          ),
          // Price tag — flat Brutal style, top-right
          Positioned(
            top: 10,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              color: Brutal.magenta,
              child: Text(
                eventItem.femalePrice == 0
                    ? 'FREE'
                    : '¥${eventItem.femalePrice.toInt()}',
                style: Brutal.label(size: 11, color: Brutal.paper),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

