
import 'package:clubship/widgets/app_icon.dart';
import 'package:clubship/widgets/app_text_styles.dart';
import 'package:flutter/material.dart';

class TimeRow extends StatelessWidget {
  const TimeRow({
    super.key,
    required this.openingHour,
    required this.openingMinute,
    this.text,
  });
  final String openingHour;
  final String openingMinute;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIcons.clocl(),
        const SizedBox(width: 9),
        if (text != null) Text(text!),
        if (text == null)
          Text(
            '$openingHour:$openingMinute ${int.parse(openingHour) > 12 ? 'PM' : 'AM'} ',
            textAlign: TextAlign.left,
            style: AppTextStyles.titleSmall,
          )
        else
          Text(
            '$openingHour:$openingMinute',
            textAlign: TextAlign.left,
            style: AppTextStyles.titleSmall,
          ),
      ],
    );
  }
}
