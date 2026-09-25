import 'package:clubship/design/brutal.dart';
import 'package:flutter/material.dart';

class LocationDetailsRow extends StatelessWidget {
  const LocationDetailsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(
          Icons.pin_drop_sharp,
          color: Brutal.magenta,
          size: 20,
          weight: 2,
        ),
        SizedBox(width: 9),
        Text(
          'Location and address here',
          textAlign: TextAlign.left,
          style: TextStyle(
            height: 1.6,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
