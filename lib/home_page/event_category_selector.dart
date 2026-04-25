import 'package:cached_network_image/cached_network_image.dart';
import 'package:clubship/colors.dart';
import 'package:clubship/data/supabase_models/event_category.dart';
import 'package:clubship/event/providers/get_category_provider.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/utils/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

EventCategory _allStub() => EventCategory(
    id: 'all',
    category: 'All',
    order: -1,
    createdAt: '',
    image:
        'https://res.cloudinary.com/dhwmo32qg/image/upload/v1755585220/20250819_1532_Vibrant_Club_Celebration_simple_compose_01k30gaxgwfy9tsmhm27xfz7h6_qifmxc.png');

class CategorySelector extends ConsumerStatefulWidget {
  const CategorySelector({
    super.key,
    required this.onTap,
    this.onCategorySelected,
  });

  final Function(EventCategory) onTap;
  final VoidCallback? onCategorySelected;

  @override
  ConsumerState<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends ConsumerState<CategorySelector> {
  EventCategory? selectedCategory;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final eventTypesAsyncValue = ref.watch(getCategoryProvider);
    return eventTypesAsyncValue.when(
      data: (category) {
        // Cache sorted categories using useMemoized or simple list
        final allCategories = [_allStub(), ...category]..sort((a, b) => a.order.compareTo(b.order));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: ColorPallete.brightPink,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Filter by Category',
                    style: Theme.of(context).labelLarge!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                  ),
                ],
              ).pad.bottom.p12,

              // Animated category chips
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: allCategories.length,
                  itemBuilder: (context, index) {
                    final cat = allCategories[index];
                    final isSelected = selectedCategory?.id == cat.id;

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _AnimatedCategoryChip(
                        category: cat,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            selectedCategory = cat;
                          });
                          widget.onTap(cat);
                          widget.onCategorySelected?.call();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      error: (err, st) => Text(err.toString()),
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Skeletonizer(
          effect: ShimmerEffect(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[900]!,
            duration: const Duration(milliseconds: 800),
          ),
          enabled: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Loading categories',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ).pad.bottom.p12,

              // Categories skeleton
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: const [
                    Text(
                      'All',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '|',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'Category 1',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '|',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'Category 2',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '|',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'Category 3',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedCategoryChip extends StatefulWidget {
  final EventCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedCategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AnimatedCategoryChip> createState() => _AnimatedCategoryChipState();
}

class _AnimatedCategoryChipState extends State<_AnimatedCategoryChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? ColorPallete.brightPink
                : ColorPallete.cardColor.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isSelected
                  ? ColorPallete.brightPink.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.2),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x66EC407A),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isSelected) ...[
                const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.category.category ?? '',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
