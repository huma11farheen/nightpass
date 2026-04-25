import 'package:clubship/colors.dart';
import 'package:flutter/material.dart';

class DotsIndicator extends StatelessWidget {
  final int currentIndex;
  final int dotCount;
  final Color dotColor;
  final Color selectedDotColor;

  const DotsIndicator({super.key,
    required this.currentIndex,
    required this.dotCount,
    this.dotColor = Colors.grey,
    this.selectedDotColor = ColorPallete.backgroundcolor3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        dotCount,
            (index) {
          return Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == currentIndex ? selectedDotColor : dotColor,
            ),
          );
        },
      ),
    );
  }
}
