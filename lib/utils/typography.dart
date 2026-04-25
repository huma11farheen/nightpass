import 'package:flutter/material.dart';

extension ThemeDataExtension on ThemeData {
  TextStyle? get bodyMedium =>
      textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 10);

  TextStyle? get bodyMediumBold =>
      textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 10);

  TextStyle? get bodyLarge =>
      textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, fontSize: 12);

  TextStyle? get labelSmall =>
      textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500, fontSize: 14);

  TextStyle? get labelSmallBold =>
      textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 14);

  TextStyle? get labelMedium => textTheme.labelMedium
      ?.copyWith(fontWeight: FontWeight.w500, fontSize: 17);

  TextStyle? get labelMediumBold =>
      textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 17);

  TextStyle? get labelLarge =>
      textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500, fontSize: 20);

  TextStyle? get labelLargeBold =>
      textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20);

  TextStyle? get headlineMedium => textTheme.headlineMedium
      ?.copyWith(fontWeight: FontWeight.w500, fontSize: 24);

  TextStyle? get headlineLarge => textTheme.headlineLarge
      ?.copyWith(fontWeight: FontWeight.w500, fontSize: 29);

  TextStyle? get headlineLargeBold => textTheme.headlineLarge
      ?.copyWith(fontWeight: FontWeight.w600, fontSize: 29);

  TextStyle? get headlineSize54Weight300 => textTheme.headlineLarge
      ?.copyWith(fontWeight: FontWeight.w500, fontSize: 54);
}
