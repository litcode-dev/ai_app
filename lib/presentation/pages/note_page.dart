import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/halo_theme.dart';
import '../bloc/halo_bloc.dart';
import '../bloc/halo_event.dart';
import '../bloc/halo_state.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/halo_nav_bar.dart';

class NotePage extends StatelessWidget {
  const NotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HaloBloc, HaloState>(
      builder: (context, state) {
        final accent = getAccent(state.accent);
        final t = Theme.of(context).extension<HaloTheme>()!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: GestureDetector(
                onTap: () => context
                    .read<HaloBloc>()
                    .add(const NavigateToScreen(HaloScreen.listen)),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: HaloIcon(name: 'back', size: 26, color: t.onSurface),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
                      decoration: BoxDecoration(
                        color: t.ambientGlow
                            ? accent.line.withValues(alpha: 0.08)
                            : t.muted(0.06),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: t.ambientGlow
                              ? accent.line.withValues(alpha: 0.2)
                              : t.muted(0.12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AvatarWidget(name: 'Sarah Logan', size: 22, palette: 'sage'),
                          const SizedBox(width: 8),
                          Text(
                            'Note about Sarah Logan',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: t.ambientGlow ? accent.line : t.muted(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                state.draft,
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  height: 1.42,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.3,
                                  color: t.onSurface,
                                ),
                              ),
                            ),
                            _Caret(color: t.ambientGlow ? accent.line : t.muted(0.5)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: GestureDetector(
                onTap: () => context
                    .read<HaloBloc>()
                    .add(SelectContact('Sarah Logan')),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: accent.solid,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(color: accent.glow, blurRadius: 24, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Next',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: kOnAccent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _IOSKeyboard(),
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
          height: 26,
          margin: const EdgeInsets.only(left: 2, top: 4),
          color: widget.color,
        ),
      ),
    );
  }
}

class _IOSKeyboard extends StatelessWidget {
  const _IOSKeyboard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<HaloTheme>()!;
    final keyBg = t.muted(0.22);
    final glyphColor = t.muted(0.70);
    final specialKeyBg = t.muted(0.10);

    Widget key(String label, {double? width, bool isReturn = false, bool isSpecial = false}) {
      return Container(
        width: width,
        height: 42,
        decoration: BoxDecoration(
          color: isReturn
              ? const Color(0xFF0088FF)
              : isSpecial ? specialKeyBg : keyBg,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Color(0x13000000), offset: Offset(0, 1), blurRadius: 0, spreadRadius: 1),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isSpecial ? 16 : 22,
              fontWeight: FontWeight.w400,
              color: isReturn ? Colors.white : glyphColor,
            ),
          ),
        ),
      );
    }

    Widget row(List<String> keys, {double pad = 0}) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: pad),
        child: Row(
          children: keys.asMap().entries.map((e) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: e.key == 0 ? 0 : 3.25,
                  right: e.key == keys.length - 1 ? 0 : 3.25,
                ),
                child: key(e.value),
              ),
            );
          }).toList(),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: t.cardSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: t.borderColor)),
      ),
      padding: const EdgeInsets.fromLTRB(6.5, 11, 6.5, 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Row(
              children: ['"The"', 'the', 'to'].asMap().entries.map((e) {
                return Expanded(
                  child: Row(
                    children: [
                      if (e.key > 0)
                        Container(
                          width: 1,
                          height: 25,
                          color: t.muted(0.12),
                        ),
                      Expanded(
                        child: Center(
                          child: Text(
                            e.value,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: t.muted(0.6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Column(
            children: [
              row(['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p']),
              const SizedBox(height: 12),
              row(['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'], pad: 20),
              const SizedBox(height: 12),
              Row(
                children: [
                  key('⇧', width: 45, isSpecial: true),
                  const SizedBox(width: 6.5),
                  ...['z', 'x', 'c', 'v', 'b', 'n', 'm'].asMap().entries.map((e) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: e.key == 0 ? 0 : 3.25,
                          right: e.key == 6 ? 0 : 3.25,
                        ),
                        child: key(e.value),
                      ),
                    );
                  }),
                  const SizedBox(width: 6.5),
                  key('⌫', width: 45, isSpecial: true),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  key('ABC', width: 92, isSpecial: true),
                  const SizedBox(width: 6),
                  const Expanded(child: SizedBox(height: 42)),
                  const SizedBox(width: 6),
                  key('↵', width: 92, isReturn: true),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
