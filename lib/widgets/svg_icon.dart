import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon {
  SvgIcon._private();

  static SvgPicture from(
      String assetName, {
        Key? key,
        double? width,
        double? height,
        double? size,
        BoxFit? fit,
        Color? color,
      }) =>
      SvgPicture.asset(
        assetName,
        key: key,
        width: size ?? width,
        height: size ?? height,
        fit: fit ?? BoxFit.contain,
        colorFilter:
        color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      );

  static SvgPicture size24(
      String assetName, {
        Key? key,
        BoxFit? fit,
      }) =>
      from(
        assetName,
        key: key,
        size: 24,
        fit: fit,
      );
}
