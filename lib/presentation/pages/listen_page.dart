import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/colors.dart';
import '../bloc/halo_bloc.dart';
import '../bloc/halo_event.dart';
import '../bloc/halo_state.dart';
import '../widgets/orb_widget.dart';
import '../widgets/wave_bar.dart';

class ListenPage extends StatefulWidget {
  const ListenPage({super.key});

  @override
  State<ListenPage> createState() => _ListenPageState();
}

class _ListenPageState extends State<ListenPage> {
  String _transcript = '';
  Timer? _timer;
  static const _fullText =
      "Sarah told her brother-in-law Tom is the new CTO of a major hospital network";
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 38), (_) {
      if (!mounted) return;
      if (_charIndex < _fullText.length) {
        _charIndex++;
        setState(() => _transcript = _fullText.substring(0, _charIndex));
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HaloBloc, HaloState>(
      builder: (context, state) {
        final accent = getAccent(state.accent);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'LISTENING',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: accent.line,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  WaveBar(color: accent.line),
                ],
              ),
            ),
            Expanded(
              child: Center(child: OrbWidget(size: 300, accent: accent, listening: true)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 86),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _transcript,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              height: 1.45,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                        ),
                        _Caret(color: accent.line),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _Button(
                          label: 'Cancel',
                          onTap: () => context
                              .read<HaloBloc>()
                              .add(const NavigateToScreen(HaloScreen.home)),
                          isPrimary: false,
                          accent: accent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _Button(
                          label: 'Save note',
                          onTap: () => context
                              .read<HaloBloc>()
                              .add(const NavigateToScreen(HaloScreen.note)),
                          isPrimary: true,
                          accent: accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Caret extends StatefulWidget {
  final Color color;
  const _Caret({required this.color});

  @override
  State<_Caret> createState() => _CaretState();
}

class _CaretState extends State<_Caret> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => Opacity(
        opacity: _ctrl.value < 0.5 ? 1.0 : 0.0,
        child: Container(
          width: 2,
          height: 21,
          margin: const EdgeInsets.only(left: 2, top: 2),
          color: widget.color,
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final AccentColors accent;

  const _Button({
    required this.label,
    required this.onTap,
    required this.isPrimary,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? accent.solid : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(999),
          border: isPrimary ? null : Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: isPrimary
              ? [BoxShadow(color: accent.glow, blurRadius: 24, offset: const Offset(0, 6))]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
              color: isPrimary ? kOnAccent : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
