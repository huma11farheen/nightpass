import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clubship/colors.dart';
import 'package:clubship/widgets/app_icon.dart';

class ModernBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback? onCenterTap;
  final List<BottomNavItem> items;
  final bool isVisible;

  const ModernBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.onCenterTap,
    this.isVisible = true,
  });

  @override
  State<ModernBottomNav> createState() => _ModernBottomNavState();
}

class _ModernBottomNavState extends State<ModernBottomNav>
     {
  // late AnimationController _rippleController;
  // late AnimationController _discoController;
  // late Animation<double> _scaleAnimation;
  // late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    // _rippleController = AnimationController(
    //   duration: const Duration(milliseconds: 400),
    //   vsync: this,
    // );
    // _discoController = AnimationController(
    //   duration: const Duration(seconds: 10),
    //   vsync: this,
    // );
    //
    // _scaleAnimation = Tween<double>(
    //   begin: 0.0,
    //   end: 1.0,
    // ).animate(CurvedAnimation(
    //   parent: _rippleController,
    //   curve: Curves.elasticOut,
    // ));
    //
    // _rotationAnimation = Tween<double>(
    //   begin: 0.0,
    //   end: 1.0,
    // ).animate(CurvedAnimation(
    //   parent: _discoController,
    //   curve: Curves.linear,
    // ));
    //
    // // Start subtle disco animation
    // _discoController.repeat();
  }

  @override
  void dispose() {
    // _rippleController.dispose();
    // _discoController.dispose();
    super.dispose();
  }

  void _onItemTap(int index) {
    HapticFeedback.lightImpact();
    // _rippleController.forward().then((_) {
    //   _rippleController.reverse();
    // });
    widget.onTap(index);
  }

  void _onCenterTap() {
    HapticFeedback.mediumImpact();
    // _rippleController.forward().then((_) {
    //   _rippleController.reverse();
    // });
    widget.onCenterTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      height: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: ColorPallete.brightPink.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 5),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1A2E).withOpacity(0.95),
                const Color(0xFF16213E).withOpacity(0.9),
                ColorPallete.cardColor.withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
            child: Row(
              children: [
                // Left section (2 items)
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      _buildNavItem(0),
                      _buildNavItem(1),
                    ],
                  ),
                ),
                // Center FAB
                _buildCenterFAB(),
                // Right section (2 items)
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      _buildNavItem(2),
                      _buildNavItem(3),
                    ],
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = index == widget.currentIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTap(index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ColorPallete.brightPink.withOpacity(0.2),
                      ColorPallete.backgroundcolor2.withOpacity(0.1),
                    ],
                  )
                : null,
            border: isSelected
                ? Border.all(
                    color: ColorPallete.brightPink.withOpacity(0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(1),
                  child: widget.items[index].icon,
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  widget.items[index].label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? ColorPallete.brightPink : Colors.white60,
                    fontSize: isSelected ? 10 : 9,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 0.3,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterFAB() {
    return Container(
      width: 64,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _onCenterTap,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: ColorPallete.brightPink.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: ColorPallete.brightPink.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Center(
                child: AppIcons.logo(
                  size: 28,
                  color: ColorPallete.brightPink.withOpacity(0.8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Tickets',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 9,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavItem {
  final Widget icon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.label,
  });
}