import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_swiper/card_swiper.dart';

class FeaturedDrinkRow extends ConsumerStatefulWidget {
  const FeaturedDrinkRow({super.key});

  @override
  ConsumerState<FeaturedDrinkRow> createState() => _FeaturedDrinkRowState();
}

class _FeaturedDrinkRowState extends ConsumerState<FeaturedDrinkRow> {
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return drinkCarousel();
  }

  Widget drinkCarousel() {
    final images = [
      "assets/images/banner/banner_one.png",
      "assets/images/banner/banner_two.png",
      "assets/images/banner/banner_three.png",
      "assets/images/banner/banner_four.png",
    ];

    // final images = [
    //   "assets/images/category/Afro.png",
    //   "assets/images/category/Bollywood.png",
    //   "assets/images/category/Latin.png",
    //   "assets/images/category/R&B.png",
    // ];

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: Swiper(
            viewportFraction: 0.95,
            scale: 0.9,
            onIndexChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) =>
                _SingleFeaturedDrinkCard(image: images[index]),
            itemCount: min(5, images.length),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(images.length, (index) {
            final isSelected = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 8,
              width: isSelected ? 24 : 8,
              decoration: BoxDecoration(
                color: isSelected ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SingleFeaturedDrinkCard extends ConsumerWidget {
  const _SingleFeaturedDrinkCard({required this.image});

  final String image;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ClipRRect(
    borderRadius: const BorderRadius.all(Radius.circular(18)),
    child: SizedBox(
      child: InkWell(
        onTap: () {
          //context.push(Routes.eventDetail, extra: event);
        },
        child: Image.asset(
          image,
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}
