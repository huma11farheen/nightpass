import 'package:dart_openapi_model_gen/string_helpers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EventInfoCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String eventDate;
  final String time;
  final String eventClosingTime;

  const EventInfoCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.eventDate,
    required this.time,
    required this.eventClosingTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.network(
                imageUrl,
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
                      Colors.black.withValues(alpha:0.3),
                      Colors.black.withValues(alpha:0.85),
                    ],
                  ),
                ),
              ),
            ),

            // Event Title
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Text(
                title.capitalize(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black87,
                      offset: Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),

            // Close Button
            Positioned(
              top: 12,
              left: 12,
              child: GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha:0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
