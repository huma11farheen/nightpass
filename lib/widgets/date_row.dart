import 'package:clubship/widgets/app_icon.dart';
import 'package:clubship/widgets/app_text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DateRow extends StatelessWidget {
  const DateRow({
    super.key,
    required this.startDate,
    this.text,
  });
  final String startDate;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Row(

      children: [
        SizedBox(
          width: 120,
          child: Row(children: [
            AppIcons.clocl(),
            const SizedBox(width: 9),
            if (text != null) Text('$text : ',style:AppTextStyles.heading,),
          ],),
        ),

          Text(
            '$startDate ',

            textAlign: TextAlign.left,
            style: AppTextStyles.heading,
          )
      ],
    );
  }
}