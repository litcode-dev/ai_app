import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import 'orb_painter.dart';

class OrbWidget extends StatefulWidget {
  final double size;
  final bool listening;
  final AccentColors accent;

  const OrbWidget({
    super.key,
    required this.size,
    required this.accent,
    this.listening = false,
  });

  @override
  State<OrbWidget> createState() => _OrbWidgetState();
}

class _OrbWidgetState extends State<OrbWidget> with TickerProviderStateMixin {
  late AnimationController _breatheCtrl;
  late AnimationController _coreBreatheCtrl;
  late List<AnimationController> _ringCtls;

  static const _baseDurations = [11000, 7000, 13000, 6000, 15000];
  static const _initAngles = [0.0, 45.0, 85.0, 170.0, 230.0];
  static const _reverse = [false, true, false, true, false];

  @override
  void initState() {
    super.initState();
    _breatheCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _coreBreatheCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _ringCtls = List.generate(5, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: _baseDurations[i]),
      )..repeat();
    });
  }

  @override
  void didUpdateWidget(OrbWidget old) {
    super.didUpdateWidget(old);
    if (widget.listening != old.listening) {
      final factor = widget.listening ? 0.5 : 1.0;
      _breatheCtrl.duration = Duration(milliseconds: widget.listening ? 1600 : 6000);
      _coreBreatheCtrl.duration = Duration(milliseconds: widget.listening ? 1200 : 4000);
      for (int i = 0; i < 5; i++) {
        _ringCtls[i].duration = Duration(
          milliseconds: (_baseDurations[i] * factor).round(),
        );
      }
    }
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    _coreBreatheCtrl.dispose();
    for (final c in _ringCtls) {
      c.dispose();
    }
    super.dispose();
  }

  List<double> get _ringAngles => List.generate(5, (i) {
    final init = _initAngles[i] * pi / 180;
    final t = _reverse[i] ? (1.0 - _ringCtls[i].value) : _ringCtls[i].value;
    return init + t * 2 * pi;
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breatheCtrl, _coreBreatheCtrl, ..._ringCtls]),
      builder: (context, _) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: OrbPainter(
          ringAngles: _ringAngles,
          breathe: _breatheCtrl.value,
          coreBreathe: _coreBreatheCtrl.value,
          accent: widget.accent,
        ),
      ),
    );
  }
}
