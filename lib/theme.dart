import 'package:flutter/material.dart';
import 'package:clubship/colors.dart';

final theme = ThemeData(
  fontFamily: 'jakarta',
  useMaterial3: true,

  // Color Scheme
  colorScheme: const ColorScheme.dark(
    primary: ColorPallete.brightPink,
    secondary: ColorPallete.backgroundcolor2,
    surface: Colors.black,
    error: Colors.redAccent,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onError: Colors.white,
    surfaceContainerHighest: ColorPallete.cardColor,
  ),

  scaffoldBackgroundColor: Colors.black,

  // Text Theme
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 0.5,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.white70,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: Colors.white,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Colors.white70,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: Colors.white60,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.white70,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: Colors.white60,
    ),
  ),

  // AppBar Theme
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: 'jakarta',
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
      size: 24,
    ),
  ),

  // Card Theme
  cardTheme: CardThemeData(
    color: ColorPallete.cardColor,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8),
  ),

  // Button Themes
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ColorPallete.brightPink,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'jakarta',
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: ColorPallete.brightPink,
      side: BorderSide(color: ColorPallete.brightPink.withValues(alpha: 0.5)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'jakarta',
      ),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: ColorPallete.brightPink,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'jakarta',
      ),
    ),
  ),

  // Input Decoration Theme — flat/square to match Brutal design system
  inputDecorationTheme: const InputDecorationTheme(
    filled: false,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
    labelStyle: TextStyle(color: Colors.white70, fontSize: 14),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),

  // Icon Theme
  iconTheme: const IconThemeData(
    color: Colors.white,
    size: 24,
  ),

  // Divider Theme
  dividerTheme: const DividerThemeData(
    color: Colors.white12,
    thickness: 1,
    space: 1,
  ),

  // Chip Theme
  chipTheme: ChipThemeData(
    backgroundColor: ColorPallete.cardColor.withValues(alpha: 0.3),
    selectedColor: ColorPallete.brightPink,
    disabledColor: Colors.grey.shade800,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    labelStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w500,
      fontFamily: 'jakarta',
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),

  // Bottom Navigation Bar Theme
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.black,
    selectedItemColor: ColorPallete.brightPink,
    unselectedItemColor: Colors.white54,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    selectedLabelStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      fontFamily: 'jakarta',
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fontFamily: 'jakarta',
    ),
  ),

  // Tab Bar Theme
  tabBarTheme: const TabBarThemeData(
    labelColor: ColorPallete.brightPink,
    unselectedLabelColor: Colors.white54,
    indicatorColor: ColorPallete.brightPink,
    indicatorSize: TabBarIndicatorSize.label,
    labelStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: 'jakarta',
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      fontFamily: 'jakarta',
    ),
  ),

  // Dialog Theme
  dialogTheme: DialogThemeData(
    backgroundColor: ColorPallete.cardColor,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: 'jakarta',
    ),
    contentTextStyle: const TextStyle(
      fontSize: 14,
      color: Colors.white70,
      fontFamily: 'jakarta',
    ),
  ),

  // Snackbar Theme
  snackBarTheme: SnackBarThemeData(
    backgroundColor: ColorPallete.cardColor,
    contentTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontFamily: 'jakarta',
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    behavior: SnackBarBehavior.floating,
  ),

  // FloatingActionButton Theme
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: ColorPallete.brightPink,
    foregroundColor: Colors.white,
    elevation: 4,
  ),

  // Switch Theme
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return ColorPallete.brightPink;
      }
      return Colors.grey;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return ColorPallete.brightPink.withValues(alpha: 0.5);
      }
      return Colors.grey.withValues(alpha: 0.3);
    }),
  ),

  // Checkbox Theme
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return ColorPallete.brightPink;
      }
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
  ),

  // Radio Theme
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return ColorPallete.brightPink;
      }
      return Colors.white54;
    }),
  ),

  // Slider Theme
  sliderTheme: SliderThemeData(
    activeTrackColor: ColorPallete.brightPink,
    inactiveTrackColor: ColorPallete.brightPink.withValues(alpha: 0.3),
    thumbColor: ColorPallete.brightPink,
    overlayColor: ColorPallete.brightPink.withValues(alpha: 0.2),
    valueIndicatorColor: ColorPallete.brightPink,
    valueIndicatorTextStyle: const TextStyle(
      color: Colors.white,
      fontFamily: 'jakarta',
    ),
  ),

  // Progress Indicator Theme
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: ColorPallete.brightPink,
    linearTrackColor: Colors.white12,
    circularTrackColor: Colors.white12,
  ),

  // Bottom Sheet Theme
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: ColorPallete.backgroundcolor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    modalBackgroundColor: ColorPallete.backgroundcolor,
    modalElevation: 8,
  ),

  // List Tile Theme
  listTileTheme: const ListTileThemeData(
    textColor: Colors.white,
    iconColor: Colors.white70,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),

  // Drawer Theme
  drawerTheme: const DrawerThemeData(
    backgroundColor: ColorPallete.backgroundcolor,
    elevation: 16,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
    ),
  ),

  // Navigation Rail Theme
  navigationRailTheme: const NavigationRailThemeData(
    backgroundColor: ColorPallete.backgroundcolor,
    selectedIconTheme: IconThemeData(
      color: ColorPallete.brightPink,
      size: 24,
    ),
    unselectedIconTheme: IconThemeData(
      color: Colors.white54,
      size: 24,
    ),
    selectedLabelTextStyle: TextStyle(
      color: ColorPallete.brightPink,
      fontWeight: FontWeight.w600,
      fontFamily: 'jakarta',
    ),
    unselectedLabelTextStyle: TextStyle(
      color: Colors.white54,
      fontWeight: FontWeight.w500,
      fontFamily: 'jakarta',
    ),
  ),

  // Tooltip Theme
  tooltipTheme: TooltipThemeData(
    decoration: BoxDecoration(
      color: ColorPallete.cardColor,
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontFamily: 'jakarta',
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),
);
