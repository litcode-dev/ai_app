import 'package:flutter/material.dart';

const Color kBackground = Color(0xFF0A0D0B);
const Color kPhoneBg1 = Color(0xFF0A1612);
const Color kPhoneBg2 = Color(0xFF050908);
const Color kOnAccent = Color(0xFF062213);

class AccentColors {
  final Color line;
  final Color glow;
  final Color glowMid;
  final Color core;
  final Color solid;

  const AccentColors({
    required this.line,
    required this.glow,
    required this.glowMid,
    required this.core,
    required this.solid,
  });
}

const Map<String, AccentColors> kAccents = {
  'fern': AccentColors(
    line: Color(0xFF5DFFA1),
    glow: Color(0x8C3AEB8E),
    glowMid: Color(0x401CB46E),
    core: Color(0xFF5DFFA1),
    solid: Color(0xFF3AEB8E),
  ),
  'cobalt': AccentColors(
    line: Color(0xFF7DA9FF),
    glow: Color(0x8C5E8CFF),
    glowMid: Color(0x40305AC8),
    core: Color(0xFF7DA9FF),
    solid: Color(0xFF5B8CFF),
  ),
  'amber': AccentColors(
    line: Color(0xFFFFC56A),
    glow: Color(0x80FFB244),
    glowMid: Color(0x40C8821E),
    core: Color(0xFFFFC56A),
    solid: Color(0xFFFFB344),
  ),
  'magenta': AccentColors(
    line: Color(0xFFFF84D4),
    glow: Color(0x80F050B4),
    glowMid: Color(0x40B42882),
    core: Color(0xFFFF84D4),
    solid: Color(0xFFED5CB8),
  ),
};

AccentColors getAccent(String name) => kAccents[name] ?? kAccents['fern']!;
