import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/colors.dart';
import '../bloc/halo_bloc.dart';
import '../bloc/halo_event.dart';
import '../bloc/halo_state.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/halo_nav_bar.dart';

class ConfirmPage extends StatelessWidget {
  const ConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HaloBloc, HaloState>(
      builder: (context, state) {
        final accent = getAccent(state.accent);
        final contact = state.selectedContact;
        final firstName = contact?.name.split(' ').first ?? 'Contact';

        return Container(
          color: Colors.black.withValues(alpha: 0.72),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AvatarWidget(
                              name: contact?.name ?? 'Contact',
                              size: 88,
                              palette: contact?.palette ?? 'sage',
                            ),
                            Positioned(
                              bottom: -6,
                              right: -6,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accent.solid,
                                  border: Border.all(color: Colors.black, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accent.glow,
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: HaloIcon(
                                    name: 'check',
                                    size: 18,
                                    color: kOnAccent,
                                    strokeWidth: 2.4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            final isActive = i < 2;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: isActive ? 36 : 8,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? accent.solid
                                      : Colors.white.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          "Added this context to\n$firstName's profile",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.3,
                            height: 1.3,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Halo extracted 3 entities and scheduled a follow-up reminder for two weeks from now.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            height: 1.45,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: GestureDetector(
                    onTap: () => context
                        .read<HaloBloc>()
                        .add(const NavigateToScreen(HaloScreen.contact)),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Center(
                        child: Text(
                          'Done',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
