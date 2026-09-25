import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Brutal {
  Brutal._();

  // ─── Surfaces ───────────────────────────────────────────────────────────────
  static const Color bg       = Color(0xFF050505);
  static const Color surface  = Color(0xFF0A0A0B);
  static const Color card     = Color(0xFF121214);
  static const Color elevated = Color(0xFF1A1A1D);
  static const Color hover    = Color(0xFF242428);

  // ─── Text ───────────────────────────────────────────────────────────────────
  static const Color paper    = Color(0xFFF4F1EA);
  static const Color dim      = Color(0xFFB8B4AC);
  static const Color mute     = Color(0xFF7A7770);

  // ─── Accents ────────────────────────────────────────────────────────────────
  static const Color magenta      = Color(0xFFFF1FA3); // primary pink — buttons, tags, CTAs
  static const Color magentaDark  = Color(0xFFBB0055); // pressed / shadow variant
  static const Color magentaAlt   = Color(0xFFFF2D78); // real-club map markers
  static const Color yellow       = Color(0xFFE6FF3A);
  static const Color cyan         = Color(0xFF6DF7FF);

  // ─── Borders ────────────────────────────────────────────────────────────────
  static const Color hairlineColor = Color(0x14F4F1EA); // paper @ 8%

  static const Border hairline = Border.fromBorderSide(
    BorderSide(color: hairlineColor, width: 1),
  );

  static Border neon({Color color = magenta, double width = 2}) =>
      Border.all(color: color, width: width);

  // ─── Decorations ────────────────────────────────────────────────────────────
  static const BoxDecoration flatCard = BoxDecoration(
    color: card,
    borderRadius: BorderRadius.zero,
    border: hairline,
  );

  static BoxDecoration accentCard({Color color = magenta}) => BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: color, width: 2),
      );

  // ─── Typography ─────────────────────────────────────────────────────────────

  /// BricolageGrotesque 800 — titles, section headers, event names.
  static TextStyle display({double size = 24, Color color = paper}) =>
      GoogleFonts.bricolageGrotesque(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: size * -0.04,
        height: 1.05,
      );

  /// InterTight 500 — body copy, captions, addresses.
  static TextStyle body({double size = 15, Color color = dim}) =>
      GoogleFonts.interTight(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.4,
      );

  /// JetBrainsMono 700 uppercase — chrome labels, status, prices, timestamps.
  static TextStyle label({double size = 11, Color color = mute}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: size * 0.12,
        fontFeatures: const [FontFeature.enable('case')],
      );

  /// Fraunces italic — editorial accents ("feat.", "by", quotes).
  static TextStyle serif({double size = 15, Color color = dim}) =>
      GoogleFonts.fraunces(
        fontSize: size,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.3,
      );
}
