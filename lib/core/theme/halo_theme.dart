import 'package:flutter/material.dart';

class HaloTheme extends ThemeExtension<HaloTheme> {
  final Color surface;
  final Color cardSurface;
  final Color borderColor;
  final Color onSurface;
  final bool ambientGlow;

  const HaloTheme({
    required this.surface,
    required this.cardSurface,
    required this.borderColor,
    required this.onSurface,
    required this.ambientGlow,
  });

  Color muted(double opacity) => onSurface.withValues(alpha: opacity);

  static const HaloTheme dark = HaloTheme(
    surface:     Color(0xFF0A0D0B),
    cardSurface: Color(0x0AFFFFFF),   // white @ 4%
    borderColor: Color(0x14FFFFFF),   // white @ 8%
    onSurface:   Color(0xFFFFFFFF),
    ambientGlow: true,
  );

  static const HaloTheme light = HaloTheme(
    surface:     Color(0xFFF2F7F4),   // off-white, faint green tint
    cardSurface: Color(0xB3FFFFFF),   // white @ 70%
    borderColor: Color(0x14000000),   // black @ 8%
    onSurface:   Color(0xFF0D1A12),   // near-black
    ambientGlow: false,
  );

  @override
  HaloTheme copyWith({
    Color? surface,
    Color? cardSurface,
    Color? borderColor,
    Color? onSurface,
    bool? ambientGlow,
  }) {
    return HaloTheme(
      surface:     surface     ?? this.surface,
      cardSurface: cardSurface ?? this.cardSurface,
      borderColor: borderColor ?? this.borderColor,
      onSurface:   onSurface   ?? this.onSurface,
      ambientGlow: ambientGlow ?? this.ambientGlow,
    );
  }

  @override
  HaloTheme lerp(HaloTheme? other, double t) {
    if (other == null) return this;
    return HaloTheme(
      surface:     Color.lerp(surface,     other.surface,     t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      onSurface:   Color.lerp(onSurface,   other.onSurface,   t)!,
      ambientGlow: t < 0.5 ? ambientGlow : other.ambientGlow,
    );
  }
}
