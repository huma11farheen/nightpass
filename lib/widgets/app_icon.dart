import 'package:clubship/widgets/svg_icon.dart';
import 'package:flutter/material.dart';

enum AppIconType {
  homeSolid,
  homeLine,
  profileSolid,
  profileLine,
  bookingsLine,
  bookingsSolid,
  eventsSolid,
  eventsLine,
  clubsSolid,
  clubsLine
  // TODO: Add images folder assets to this class too? And handle all assets from one class
}

Widget appIcon({
  required AppIconType appIconType,
  Size? size,
  required BuildContext context,
  Color? color,
  bool forceLightMode = false,
}) {
  return color != null
      ? Image.asset(
          _appIconAssetPath(appIconType, context),
          width: size?.width,
          height: size?.height,
          color: color,
          fit: BoxFit.scaleDown,
        )
      : Image.asset(
          _appIconAssetPath(appIconType, context),
          width: size?.width,
          height: size?.height,
          fit: BoxFit.scaleDown,
        );
}

String _appIconAssetPath(
  AppIconType appIconType,
  BuildContext context,
) {
  switch (appIconType) {
    case AppIconType.profileLine:
      return 'assets/images/nav_bar/profile_line.png';
    case AppIconType.profileSolid:
      return 'assets/images/nav_bar/profile_solid.png';
    case AppIconType.bookingsLine:
      return 'assets/images/nav_bar/booking_line.png';
    case AppIconType.bookingsSolid:
      return 'assets/images/nav_bar/booking_solid.png';
    case AppIconType.clubsLine:
      return 'assets/images/nav_bar/clubs_line.png';
    case AppIconType.clubsSolid:
      return 'assets/images/nav_bar/clubs_solid.png';
    case AppIconType.homeLine:
      return 'assets/images/nav_bar/home_line.png';
    case AppIconType.homeSolid:
      return 'assets/images/nav_bar/home_solid.png';
    case AppIconType.eventsLine:
      return 'assets/images/nav_bar/events_line.png';
    case AppIconType.eventsSolid:
      return 'assets/images/nav_bar/events_solid.png';
  }
}

class AppIcons {
  AppIcons._private();

  static const _iconsPath = 'assets/icons';

  static Widget location({
    double? size,
  }) =>
      SvgIcon.from(
        '$_iconsPath/location.svg',
        size: size,
      );

  static Widget logo({double? size, Color? color}) => SvgIcon.from(
        '$_iconsPath/logo.svg',
        size: size,
        color: color,
      );

  static Widget money({
    double? size,
  }) =>
      SvgIcon.from(
        '$_iconsPath/money.svg',
        size: size,
      );

  static Widget purpleLocation({
    double? size,
  }) =>
      SvgIcon.from(
        '$_iconsPath/location_purple.svg',
        size: size,
      );

  static Widget clocl({double? size, Color? color}) => SvgIcon.from(
        '$_iconsPath/clock.svg',
        size: size,
        color: color,
      );

  static Widget whiteClock({
    double? size,
  }) =>
      SvgIcon.from(
        '$_iconsPath/clock_white.svg',
        size: size,
      );

  static Widget calender({
    double? size,
    Color? color,
  }) =>
      SvgIcon.from('$_iconsPath/calendar.svg', size: size, color: color);

  static Widget whiteCalender({double? size, final Color? color}) =>
      SvgIcon.from('$_iconsPath/calender_white.svg', size: size, color: color);

  static Widget price({
    double? size,
  }) =>
      SvgIcon.from(
        '$_iconsPath/price.svg',
        size: size,
      );

  static Widget ticketDiscount({
    double? size,
  }) =>
      SvgIcon.from(
        '$_iconsPath/ticket_discount.svg',
        size: size,
      );

  static Widget bookTable({
    double? size,
  }) =>
      SvgIcon.from(
        '$_iconsPath/book_table.svg',
        size: size,
      );

  static Widget payAtVenue({
    double? size,
  }) =>
      SvgIcon.from(
        '$_iconsPath/pay_venue.svg',
        size: size,
      );
}
