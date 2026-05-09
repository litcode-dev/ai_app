import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/colors.dart';
import '../bloc/halo_bloc.dart';
import '../bloc/halo_event.dart';
import '../bloc/halo_state.dart';
import 'orb_widget.dart';

class HaloNavBar extends StatelessWidget {
  final bool hasBadge;

  const HaloNavBar({super.key, this.hasBadge = true});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HaloBloc, HaloState>(
      builder: (context, state) {
        final accent = getAccent(state.accent);
        return Container(
          padding: const EdgeInsets.only(bottom: 28, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                tab: NavTab.people,
                activeTab: state.navTab,
                accent: accent,
                hasBadge: hasBadge,
                child: HaloIcon(
                  name: 'people',
                  size: 24,
                  color: state.navTab == NavTab.people
                      ? accent.solid
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
              _NavItem(
                tab: NavTab.orb,
                activeTab: state.navTab,
                accent: accent,
                child: _OrbMini(accent: accent, active: state.navTab == NavTab.orb),
              ),
              _NavItem(
                tab: NavTab.sliders,
                activeTab: state.navTab,
                accent: accent,
                child: HaloIcon(
                  name: 'sliders',
                  size: 24,
                  color: state.navTab == NavTab.sliders
                      ? accent.solid
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  final NavTab tab;
  final NavTab activeTab;
  final AccentColors accent;
  final Widget child;
  final bool hasBadge;

  const _NavItem({
    required this.tab,
    required this.activeTab,
    required this.accent,
    required this.child,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<HaloBloc>().add(ChangeNavTab(tab)),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            if (hasBadge && tab == NavTab.people && activeTab != NavTab.people)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accent.solid,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: accent.solid, blurRadius: 6)],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OrbMini extends StatelessWidget {
  final AccentColors accent;
  final bool active;

  const _OrbMini({required this.accent, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: active
            ? [BoxShadow(color: accent.glow, blurRadius: 20, spreadRadius: 2)]
            : null,
      ),
      child: OrbWidget(
        size: 48,
        accent: accent,
      ),
    );
  }
}

class HaloIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color color;
  final double strokeWidth;

  const HaloIcon({
    super.key,
    required this.name,
    this.size = 22,
    this.color = Colors.white,
    this.strokeWidth = 1.8,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _IconPainter(name: name, color: color, strokeWidth: strokeWidth),
    );
  }
}

class _IconPainter extends CustomPainter {
  final String name;
  final Color color;
  final double strokeWidth;

  const _IconPainter({
    required this.name,
    required this.color,
    required this.strokeWidth,
  });

  Paint get _stroke =>
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

  Paint get _fill => Paint()..color = color..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.scale(s, s);

    switch (name) {
      case 'back':
        canvas.drawPath(Path()..moveTo(15, 18)..lineTo(9, 12)..lineTo(15, 6), _stroke);
      case 'star':
        canvas.drawPath(
          Path()
            ..moveTo(12, 3)..lineTo(14.6, 9)..lineTo(21, 9.6)..lineTo(16.2, 14)
            ..lineTo(17.6, 20.4)..lineTo(12, 17)..lineTo(6.4, 20.4)..lineTo(7.8, 14)
            ..lineTo(3, 9.6)..lineTo(9.4, 9)..close(),
          _stroke,
        );
      case 'star-fill':
        canvas.drawPath(
          Path()
            ..moveTo(12, 3)..lineTo(14.6, 9)..lineTo(21, 9.6)..lineTo(16.2, 14)
            ..lineTo(17.6, 20.4)..lineTo(12, 17)..lineTo(6.4, 20.4)..lineTo(7.8, 14)
            ..lineTo(3, 9.6)..lineTo(9.4, 9)..close(),
          _fill,
        );
      case 'mic':
        canvas.drawRRect(RRect.fromLTRBR(9, 3, 15, 15, const Radius.circular(3)), _stroke);
        canvas.drawPath(Path()..moveTo(5, 11)..cubicTo(5, 16, 19, 16, 19, 11), _stroke);
        canvas.drawLine(const Offset(12, 18), const Offset(12, 21), _stroke);
        canvas.drawLine(const Offset(8, 21), const Offset(16, 21), _stroke);
      case 'people':
        canvas.drawCircle(const Offset(9, 8), 3.2, _stroke);
        canvas.drawPath(
          Path()..moveTo(3, 20)..cubicTo(3, 16.5, 5.7, 14, 9, 14)..cubicTo(12.3, 14, 15, 16.5, 15, 20),
          _stroke,
        );
        canvas.drawCircle(const Offset(17, 7), 2.4, _stroke);
        canvas.drawPath(Path()..moveTo(16, 14)..cubicTo(18.8, 14, 21, 16, 21, 19), _stroke);
      case 'sliders':
        canvas.drawLine(const Offset(4, 6), const Offset(14, 6), _stroke);
        canvas.drawLine(const Offset(18, 6), const Offset(20, 6), _stroke);
        canvas.drawLine(const Offset(4, 12), const Offset(6, 12), _stroke);
        canvas.drawLine(const Offset(10, 12), const Offset(20, 12), _stroke);
        canvas.drawLine(const Offset(4, 18), const Offset(16, 18), _stroke);
        canvas.drawCircle(const Offset(16, 6), 2, _stroke);
        canvas.drawCircle(const Offset(8, 12), 2, _stroke);
        canvas.drawCircle(const Offset(18, 18), 2, _stroke);
      case 'spark':
        canvas.drawPath(
          Path()
            ..moveTo(12, 3)..lineTo(12, 7)
            ..moveTo(12, 17)..lineTo(12, 21)
            ..moveTo(3, 12)..lineTo(7, 12)
            ..moveTo(17, 12)..lineTo(21, 12)
            ..moveTo(5.6, 5.6)..lineTo(8.4, 8.4)
            ..moveTo(15.6, 15.6)..lineTo(18.4, 18.4)
            ..moveTo(5.6, 18.4)..lineTo(8.4, 15.6)
            ..moveTo(15.6, 8.4)..lineTo(18.4, 5.6),
          _stroke,
        );
      case 'edit':
        canvas.drawPath(
          Path()..moveTo(14, 4)..lineTo(20, 10)..lineTo(9, 21)..lineTo(3, 21)..lineTo(3, 15)..close(),
          _stroke,
        );
      case 'msg':
        canvas.drawPath(
          Path()..moveTo(4, 5)..lineTo(20, 5)..lineTo(20, 16)..lineTo(8, 16)..lineTo(4, 20)..close(),
          _stroke,
        );
      case 'more':
        canvas.drawCircle(const Offset(6, 12), 1.4, _fill);
        canvas.drawCircle(const Offset(12, 12), 1.4, _fill);
        canvas.drawCircle(const Offset(18, 12), 1.4, _fill);
      case 'plus':
        canvas.drawLine(const Offset(12, 5), const Offset(12, 19), _stroke);
        canvas.drawLine(const Offset(5, 12), const Offset(19, 12), _stroke);
      case 'check':
        canvas.drawPath(Path()..moveTo(5, 12)..lineTo(9, 16)..lineTo(19, 6), _stroke);
      case 'clock':
        canvas.drawCircle(const Offset(12, 12), 9, _stroke);
        canvas.drawPath(Path()..moveTo(12, 7)..lineTo(12, 12)..lineTo(15, 14), _stroke);
      case 'calendar':
        canvas.drawRRect(RRect.fromLTRBR(3.5, 5, 20.5, 20, const Radius.circular(2)), _stroke);
        canvas.drawLine(const Offset(3.5, 10), const Offset(20.5, 10), _stroke);
        canvas.drawLine(const Offset(8, 3), const Offset(8, 7), _stroke);
        canvas.drawLine(const Offset(16, 3), const Offset(16, 7), _stroke);
      case 'tag':
        canvas.drawPath(
          Path()..moveTo(3, 12)..lineTo(3, 4)..lineTo(11, 4)..lineTo(21, 14)..lineTo(13, 22)..close(),
          _stroke,
        );
        canvas.drawCircle(const Offset(8, 8), 1.4, _fill);
      case 'briefcase':
        canvas.drawRRect(RRect.fromLTRBR(3, 7, 21, 20, const Radius.circular(2)), _stroke);
        canvas.drawPath(
          Path()
            ..moveTo(9, 7)..lineTo(9, 5)
            ..cubicTo(9, 4, 10, 3, 11, 3)..lineTo(13, 3)
            ..cubicTo(14, 3, 15, 4, 15, 5)..lineTo(15, 7),
          _stroke,
        );
        canvas.drawLine(const Offset(3, 13), const Offset(21, 13), _stroke);
      case 'gift':
        canvas.drawRRect(RRect.fromLTRBR(3, 9, 21, 20, const Radius.circular(1)), _stroke);
        canvas.drawLine(const Offset(3, 13), const Offset(21, 13), _stroke);
        canvas.drawLine(const Offset(12, 9), const Offset(12, 20), _stroke);
        canvas.drawPath(
          Path()
            ..moveTo(8, 9)..cubicTo(6, 9, 5, 8, 5, 6.5)..cubicTo(5, 5, 6, 4, 7.5, 4)
            ..cubicTo(10, 4, 12, 5, 12, 9),
          _stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(16, 9)..cubicTo(18, 9, 19, 8, 19, 6.5)..cubicTo(19, 5, 18, 4, 16.5, 4)
            ..cubicTo(14, 4, 12, 5, 12, 9),
          _stroke,
        );
      case 'thread':
        canvas.drawLine(const Offset(4, 6), const Offset(20, 6), _stroke);
        canvas.drawLine(const Offset(4, 12), const Offset(16, 12), _stroke);
        canvas.drawLine(const Offset(4, 18), const Offset(20, 18), _stroke);
      case 'kbd':
        canvas.drawRRect(RRect.fromLTRBR(2.5, 6.5, 21.5, 17.5, const Radius.circular(2)), _stroke);
        for (final x in [6.0, 9.0, 12.0, 15.0, 18.0]) {
          canvas.drawCircle(Offset(x, 10), 0.6, _fill);
        }
        for (final x in [6.0, 9.0, 18.0]) {
          canvas.drawCircle(Offset(x, 13.5), 0.6, _fill);
        }
        canvas.drawLine(const Offset(12, 13.5), const Offset(16, 13.5), _stroke);
    }
  }

  @override
  bool shouldRepaint(_IconPainter old) => old.name != name || old.color != color;
}
