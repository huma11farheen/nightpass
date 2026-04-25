import 'package:clubship/event/event_view_model.dart';
import 'package:clubship/router.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/utils/typography.dart';
import 'package:clubship/widgets/app_icon.dart';
import 'package:clubship/widgets/cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventsCard extends ConsumerWidget {
  const EventsCard({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    this.imagePath,
    this.height = 220,
    this.width = 160,
    required this.event,
  });

  final String id;
  final String name;
  final double price;
  final String? imagePath;
  final double height;
  final double width;
  final EventViewModel event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.parse(event.startDate); // Converts to DateTime
    final formattedDate = formatEventDate(date);
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          context.push(
            Routes.eventDetail,
            extra: event,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            width: width,
            height: height,
            color: Colors.grey[900],
            child: Stack(
              children: [
                // Image as background
                Positioned.fill(
                  child: NomuCachedNetworkImage(
                    imageUrl: event.image ?? '',
                    fit: BoxFit.cover,
                  ),
                ),

                // Gradient overlay at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                        stops: const [
                          0.0,
                          0.2,
                          0.4,
                          0.5,
                          0.6,
                          0.8,
                          0.8,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          event.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .labelMedium!
                              .copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            AppIcons.location(
                              size: 12,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Expanded(
                              child: Text(
                                event.club.locationAddress??'',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 10,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0.5, 0.5),
                                      blurRadius: 3.0,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            AppIcons.whiteCalender(
                              size: 12,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              formattedDate,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 10,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0.5, 0.5),
                                    blurRadius: 3.0,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ],
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
