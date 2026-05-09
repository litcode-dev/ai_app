import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/colors.dart';
import 'injection_container.dart';
import 'presentation/bloc/halo_bloc.dart';
import 'presentation/bloc/halo_event.dart';
import 'presentation/bloc/halo_state.dart';
import 'presentation/pages/confirm_page.dart';
import 'presentation/pages/contact_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/listen_page.dart';
import 'presentation/pages/note_page.dart';
import 'presentation/pages/people_page.dart';
import 'presentation/widgets/halo_nav_bar.dart';

class HaloApp extends StatelessWidget {
  const HaloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HaloBloc>()..add(const AppStarted()),
      child: MaterialApp(
        title: 'Halo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: kBackground,
          textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
          colorScheme: const ColorScheme.dark(
            surface: kBackground,
            primary: Color(0xFF3AEB8E),
          ),
        ),
        home: const _HaloShell(),
      ),
    );
  }
}

class _HaloShell extends StatelessWidget {
  const _HaloShell();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return BlocBuilder<HaloBloc, HaloState>(
      builder: (context, state) {
        final accent = getAccent(state.accent);
        final showAmbient =
            state.screen == HaloScreen.home || state.screen == HaloScreen.listen;
        final showNav =
            state.screen == HaloScreen.home || state.screen == HaloScreen.people;

        return Scaffold(
          backgroundColor: kBackground,
          body: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.4, -0.6),
                radius: 1.0,
                colors: [accent.glowMid, Colors.transparent],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  if (showAmbient)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(0, 0.2),
                              radius: 0.8,
                              colors: [
                                accent.glow.withValues(alpha: 0.18),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  Column(
                    children: [
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 360),
                          transitionBuilder: (child, animation) => FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.03),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          ),
                          child: _buildPage(state),
                        ),
                      ),
                      if (showNav) const HaloNavBar(hasBadge: true),
                      if (!showNav && state.screen != HaloScreen.note)
                        const SizedBox(height: 28),
                    ],
                  ),
                  if (state.screen == HaloScreen.confirm)
                    const Positioned.fill(child: ConfirmPage()),
                  if (state.screen != HaloScreen.note)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 134,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPage(HaloState state) {
    switch (state.screen) {
      case HaloScreen.home:
        return const HomePage(key: ValueKey('home'));
      case HaloScreen.listen:
        return const ListenPage(key: ValueKey('listen'));
      case HaloScreen.note:
        return const NotePage(key: ValueKey('note'));
      case HaloScreen.contact:
      case HaloScreen.confirm:
        return const ContactPage(key: ValueKey('contact'));
      case HaloScreen.people:
        return const PeoplePage(key: ValueKey('people'));
    }
  }
}
