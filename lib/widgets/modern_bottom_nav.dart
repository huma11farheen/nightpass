import 'package:clubship/design/brutal.dart';
import 'package:clubship/widgets/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModernBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback? onCenterTap;
  final List<BottomNavItem> items;
  final bool isVisible;
  final BottomNavItem? centerItem;
  final bool isCenterSelected;

  const ModernBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.onCenterTap,
    this.isVisible = true,
    this.centerItem,
    this.isCenterSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Brutal.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top hairline
          Container(height: 1, color: Brutal.hairlineColor),

          // Nav row
          SizedBox(
            height: 64,
            child: Row(
              children: [
                _NavItem(index: 0, item: items[0], isSelected: currentIndex == 0, onTap: onTap),
                _NavItem(index: 1, item: items[1], isSelected: currentIndex == 1, onTap: onTap),
                _CenterItem(
                  isSelected: isCenterSelected,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onCenterTap?.call();
                  },
                ),
                _NavItem(index: 2, item: items[2], isSelected: currentIndex == 2, onTap: onTap),
                _NavItem(index: 3, item: items[3], isSelected: currentIndex == 3, onTap: onTap),
              ],
            ),
          ),

          // System nav inset
          SizedBox(height: bottomInset),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final int index;
  final BottomNavItem item;
  final bool isSelected;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          onTap(index);
        },
        child: SizedBox(
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Active top bar
              if (isSelected)
                Positioned(
                  top: 0,
                  left: 12,
                  right: 12,
                  child: Container(height: 2, color: Brutal.magenta),
                ),

              // Icon + label
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      key: ValueKey(isSelected),
                      isSelected ? item.selectedIcon : item.icon,
                      size: 22,
                      color: isSelected ? Brutal.magenta : Brutal.mute,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label.toUpperCase(),
                    style: Brutal.label(
                      size: 10,
                      color: isSelected ? Brutal.magenta : Brutal.mute,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterItem extends StatelessWidget {
  const _CenterItem({required this.isSelected, required this.onTap});

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 72,
        height: 64,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Active top bar
            if (isSelected)
              Positioned(
                top: 0,
                left: 8,
                right: 8,
                child: Container(height: 2, color: Brutal.magenta),
              ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Square ticket icon — elevated when selected
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 40,
                  height: 40,
                  color: isSelected ? Brutal.magenta : Brutal.elevated,
                  child: Center(
                    child: AppIcons.logo(
                      size: 20,
                      color: isSelected ? Brutal.paper : Brutal.mute,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'TICKETS',
                  style: Brutal.label(
                    size: 8,
                    color: isSelected ? Brutal.magenta : Brutal.mute,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.label,
    IconData? selectedIcon,
  }) : selectedIcon = selectedIcon ?? icon;
}
