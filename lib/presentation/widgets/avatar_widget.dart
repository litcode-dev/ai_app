import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String name;
  final double size;
  final String? palette;

  const AvatarWidget({
    super.key,
    required this.name,
    this.size = 40,
    this.palette,
  });

  static const _palettes = {
    'sage': (Color(0xFF2C4838), Color(0xFF7FBE9E)),
    'forest': (Color(0xFF1F3A2C), Color(0xFF4EA378)),
    'moss': (Color(0xFF3A5544), Color(0xFFA3D4B6)),
    'fern': (Color(0xFF264A37), Color(0xFF6CB38A)),
    'pine': (Color(0xFF1A3528), Color(0xFF5FA37F)),
  };

  static const _paletteKeys = ['sage', 'forest', 'moss', 'fern', 'pine'];

  (Color, Color) _resolveColors() {
    final key =
        palette ?? _paletteKeys[name.isNotEmpty ? name.codeUnitAt(0) % _paletteKeys.length : 0];
    return _palettes[key] ?? _palettes['sage']!;
  }

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0];
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final (colorA, colorB) = _resolveColors();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorA, colorB],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.4),
                  radius: 0.7,
                  colors: [Colors.white.withValues(alpha: 0.18), Colors.transparent],
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              _initials.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: size * 0.36,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.92),
                letterSpacing: 0.02 * size,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
