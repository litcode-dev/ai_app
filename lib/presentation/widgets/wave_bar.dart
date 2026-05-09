import 'dart:math';
import 'package:flutter/material.dart';

class WaveBar extends StatefulWidget {
  final Color color;
  final double height;

  const WaveBar({super.key, required this.color, this.height = 28});

  @override
  State<WaveBar> createState() => _WaveBarState();
}

class _WaveBarState extends State<WaveBar> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  static const _delays = [0.0, 0.1, 0.2, 0.3, 0.15, 0.05, 0.25];
  static const _heights = [0.3, 0.6, 1.0, 0.8, 0.5, 0.7, 0.4];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(7, (i) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1100),
      );
      Future.delayed(
        Duration(milliseconds: (_delays[i] * 1000).round()),
        () {
          if (mounted) ctrl.repeat(reverse: true);
        },
      );
      return ctrl;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(_controllers),
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(7, (i) {
            final scale = 0.4 + _controllers[i].value * 0.8;
            final barH = widget.height * _heights[i] * scale;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 3,
                height: max(4.0, barH),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
