import 'package:flutter/material.dart';

class BookClubItem extends StatelessWidget {
  const BookClubItem({
    super.key,
    required this.icon,
    required this.title,
  });
  final Widget icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      icon,
      const SizedBox(
        height: 4,
      ),
      Text(title),
    ]);
  }
}