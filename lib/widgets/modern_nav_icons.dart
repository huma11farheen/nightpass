import 'package:clubship/design/brutal.dart';
import 'package:flutter/material.dart';
import 'package:clubship/colors.dart';

class ModernNavIcons {
  static Widget home({
    required bool isSelected,
    double size = 24,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Icon(
        isSelected ? Icons.home_rounded : Icons.home_outlined,
        size: size,
        color: isSelected ? ColorPallete.brightPink : Colors.white60,
      ),
    );
  }

  static Widget events({
    required bool isSelected,
    double size = 24,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Icon(
        isSelected ? Icons.celebration_rounded : Icons.celebration_outlined,
        size: size,
        color: isSelected ? ColorPallete.brightPink : Colors.white60,
      ),
    );
  }

  static Widget clubs({
    required bool isSelected,
    double size = 24,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Icon(
        isSelected ? Icons.nightlife_rounded : Icons.nightlife_outlined,
        size: size,
        color: isSelected ? ColorPallete.brightPink : Colors.white60,
      ),
    );
  }

  static Widget profile({
    required bool isSelected,
    double size = 24,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Icon(
        isSelected ? Icons.person_rounded : Icons.person_outline_rounded,
        size: size,
        color: isSelected ? ColorPallete.brightPink : Colors.white60,
      ),
    );
  }

  // Alternative custom icons with better nightlife theme
  static Widget homeCustom({
    required bool isSelected,
    double size = 24,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(2),
      decoration: isSelected
          ? BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ColorPallete.brightPink.withOpacity(0.2),
                  ColorPallete.brightPink.withOpacity(0.1),
                ],
              ),
            )
          : null,
      child: Icon(
        Icons.dashboard_rounded,
        size: size,
        color: isSelected ? ColorPallete.brightPink : Colors.white60,
      ),
    );
  }

  static Widget eventsCustom({
    required bool isSelected,
    double size = 24,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(2),
      decoration: isSelected
          ? BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ColorPallete.brightPink.withOpacity(0.2),
                  ColorPallete.brightPink.withOpacity(0.1),
                ],
              ),
            )
          : null,
      child: Icon(
        isSelected ? Icons.local_fire_department_rounded : Icons.local_fire_department_outlined,
        size: size,
        color: isSelected ? ColorPallete.brightPink : Colors.white60,
      ),
    );
  }

  static Widget clubsCustom({
    required bool isSelected,
    double size = 24,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(2),
      decoration: isSelected
          ? BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ColorPallete.brightPink.withOpacity(0.2),
                  ColorPallete.brightPink.withOpacity(0.1),
                ],
              ),
            )
          : null,
      child: Icon(
        isSelected ? Icons.music_note_rounded : Icons.music_note_outlined,
        size: size,
        color: isSelected ? ColorPallete.brightPink : Colors.white60,
      ),
    );
  }

  static Widget profileCustom({
    required bool isSelected,
    double size = 24,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(2),
      decoration: isSelected
          ? BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  ColorPallete.brightPink.withOpacity(0.2),
                  ColorPallete.brightPink.withOpacity(0.1),
                ],
              ),
            )
          : null,
      child: Icon(
        isSelected ? Icons.account_circle_rounded : Icons.account_circle_outlined,
        size: size,
        color: isSelected ? ColorPallete.brightPink : Colors.white60,
      ),
    );
  }

  // Premium gradient icons
  static Widget homeGradient({
    required bool isSelected,
    double size = 24,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: isSelected
              ? [ColorPallete.brightPink, ColorPallete.backgroundcolor2]
              : [Colors.white60, Colors.white60],
        ).createShader(bounds),
        child: Icon(
          isSelected ? Icons.home_rounded : Icons.home_outlined,
          size: size,
          color: Colors.white,
        ),
      ),
    );
  }

  static Widget eventsGradient({
    required bool isSelected,
    double size = 24,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: isSelected
              ? [ColorPallete.brightPink, Brutal.magenta]
              : [Colors.white60, Colors.white60],
        ).createShader(bounds),
        child: Icon(
          isSelected ? Icons.celebration_rounded : Icons.celebration_outlined,
          size: size,
          color: Colors.white,
        ),
      ),
    );
  }

  static Widget clubsGradient({
    required bool isSelected,
    double size = 24,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: isSelected
              ? [ColorPallete.brightPink, ColorPallete.backgroundcolor2]
              : [Colors.white60, Colors.white60],
        ).createShader(bounds),
        child: Icon(
          isSelected ? Icons.nightlife_rounded : Icons.nightlife_outlined,
          size: size,
          color: Colors.white,
        ),
      ),
    );
  }

  static Widget profileGradient({
    required bool isSelected,
    double size = 24,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: isSelected
              ? [ColorPallete.brightPink, Brutal.magenta]
              : [Colors.white60, Colors.white60],
        ).createShader(bounds),
        child: Icon(
          isSelected ? Icons.person_rounded : Icons.person_outline_rounded,
          size: size,
          color: Colors.white,
        ),
      ),
    );
  }

  // Animated icons with micro-interactions
  static Widget homeAnimated({
    required bool isSelected,
    double size = 24,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 + (value * 0.1),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: ColorPallete.brightPink.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isSelected ? Icons.home_rounded : Icons.home_outlined,
              size: size,
              color: Color.lerp(Colors.white60, ColorPallete.brightPink, value),
            ),
          ),
        );
      },
    );
  }

  static Widget eventsAnimated({
    required bool isSelected,
    double size = 24,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 + (value * 0.1),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: ColorPallete.brightPink.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isSelected ? Icons.local_fire_department_rounded : Icons.local_fire_department_outlined,
              size: size,
              color: Color.lerp(Colors.white60, ColorPallete.brightPink, value),
            ),
          ),
        );
      },
    );
  }

  static Widget clubsAnimated({
    required bool isSelected,
    double size = 24,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 + (value * 0.1),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: ColorPallete.brightPink.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isSelected ? Icons.music_note_rounded : Icons.music_note_outlined,
              size: size,
              color: Color.lerp(Colors.white60, ColorPallete.brightPink, value),
            ),
          ),
        );
      },
    );
  }

  static Widget profileAnimated({
    required bool isSelected,
    double size = 24,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 + (value * 0.1),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: ColorPallete.brightPink.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isSelected ? Icons.person_rounded : Icons.person_outline_rounded,
              size: size,
              color: Color.lerp(Colors.white60, ColorPallete.brightPink, value),
            ),
          ),
        );
      },
    );
  }
}