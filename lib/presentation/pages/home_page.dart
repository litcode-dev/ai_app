import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/halo_theme.dart';
import '../bloc/halo_bloc.dart';
import '../bloc/halo_event.dart';
import '../bloc/halo_state.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';
import '../widgets/halo_nav_bar.dart';
import '../widgets/orb_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _prompt = 'I can search new contacts';
  Timer? _timer;
  int _phraseIndex = 0;
  int _charIndex = 0;
  bool _deleting = false;

  static const _phrases = [
    'I can search new contacts',
    'I can brief you before meetings',
    'I can draft a follow-up note',
    'I can find someone in your network',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1500), _tick);
  }

  void _tick() {
    if (!mounted) return;
    final phrase = _phrases[_phraseIndex];
    if (!_deleting) {
      _charIndex++;
      setState(() => _prompt = phrase.substring(0, _charIndex));
      if (_charIndex == phrase.length) {
        _deleting = true;
        _timer = Timer(const Duration(milliseconds: 1800), _tick);
        return;
      }
    } else {
      _charIndex--;
      setState(() => _prompt = phrase.substring(0, _charIndex));
      if (_charIndex == 0) {
        _deleting = false;
        _phraseIndex = (_phraseIndex + 1) % _phrases.length;
      }
    }
    _timer = Timer(Duration(milliseconds: _deleting ? 24 : 56), _tick);
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
        final t = Theme.of(context).extension<HaloTheme>()!;
        final suggestions = state.suggestions;
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            _prompt,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: t.muted(0.55),
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                        _Caret(color: accent.line),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'What can I do\nfor you today?',
                      textAlign: TextAlign.center,
                      style: t.ambientGlow
                          ? GoogleFonts.fraunces(
                              fontSize: 34,
                              fontWeight: FontWeight.w500,
                              height: 1.12,
                              letterSpacing: -0.5,
                              foreground: Paint()
                                ..shader = LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color.lerp(Colors.white, accent.line, 0.25)!,
                                    accent.line,
                                  ],
                                ).createShader(const Rect.fromLTWH(0, 0, 300, 80)),
                            )
                          : GoogleFonts.fraunces(
                              fontSize: 34,
                              fontWeight: FontWeight.w500,
                              height: 1.12,
                              letterSpacing: -0.5,
                              color: t.muted(0.75),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Center(
                        child: GestureDetector(
                          onTap: () => context
                              .read<HaloBloc>()
                              .add(const NavigateToScreen(HaloScreen.listen)),
                          child: OrbWidget(size: 260, accent: accent),
                        ),
                      ),
                    ),
                    BlocBuilder<SettingsCubit, SettingsState>(
                      builder: (context, settings) {
                        if (!settings.suggestionsEnabled || suggestions.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: suggestions.length,
                            separatorBuilder: (context, _) => const SizedBox(width: 8),
                            itemBuilder: (context, i) => _SuggestionChip(
                              label: suggestions[i],
                              onTap: () => context
                                  .read<HaloBloc>()
                                  .add(const NavigateToScreen(HaloScreen.listen)),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => context
                          .read<HaloBloc>()
                          .add(const NavigateToScreen(HaloScreen.note)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                        decoration: BoxDecoration(
                          color: t.cardSurface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: t.borderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HaloIcon(
                              name: 'kbd',
                              size: 18,
                              color: t.muted(0.78),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Use keyboard',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: t.muted(0.78),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
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
          height: 14,
          margin: const EdgeInsets.only(left: 2),
          color: widget.color,
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<HaloTheme>()!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: t.cardSurface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: t.borderColor),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, color: t.muted(0.78)),
        ),
      ),
    );
  }
}
