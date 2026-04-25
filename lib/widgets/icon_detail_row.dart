import 'package:clubship/widgets/app_icon.dart';
import 'package:clubship/widgets/app_text_styles.dart';
import 'package:flutter/material.dart';

class IconDetailRow extends StatelessWidget {
  const IconDetailRow({
    super.key,
    required this.description, required this.icon,
  });

  final String description;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        icon,
        const SizedBox(width: 9),
        Text(
          description,
          textAlign: TextAlign.left,
          style: AppTextStyles.heading,
        ),
      ],
    );
  }
}

class LocationRow extends StatelessWidget {
  const LocationRow({
    super.key,
    required this.description
  });

  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AppIcons.purpleLocation(),
        const SizedBox(width: 9),
        Flexible(
          child: Text(
            description,
            textAlign: TextAlign.left,
            style: AppTextStyles.heading,
          ),
        ),
      ],
    );
  }
}