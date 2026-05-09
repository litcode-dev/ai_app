import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/halo_theme.dart';
import '../../domain/entities/contact.dart';
import '../bloc/halo_bloc.dart';
import '../bloc/halo_event.dart';
import '../bloc/halo_state.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/halo_nav_bar.dart';

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});

  Map<String, List<Contact>> _groupContacts(List<Contact> contacts) {
    final groups = <String, List<Contact>>{};
    for (final c in contacts) {
      if (c.group != null) {
        (groups[c.group!] ??= []).add(c);
      }
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HaloBloc, HaloState>(
      builder: (context, state) {
        final accent = getAccent(state.accent);
        final t = Theme.of(context).extension<HaloTheme>()!;
        final groups = _groupContacts(state.contacts);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'People',
                    style: GoogleFonts.urbanist(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.6,
                      color: t.onSurface,
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.cardSurface,
                      border: Border.all(color: t.borderColor),
                    ),
                    child: Center(child: HaloIcon(name: 'plus', size: 18, color: t.onSurface)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: t.muted(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: t.cardSurface),
                ),
                child: Row(
                  children: [
                    Text(
                      '⌕',
                      style: TextStyle(fontSize: 18, color: t.muted(0.45)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Search by name, company, context…',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: t.muted(0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.only(bottom: 16),
                      children: groups.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
                              child: Text(
                                entry.key.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 1.2,
                                  color: t.muted(0.45),
                                ),
                              ),
                            ),
                            ...entry.value.map((c) => _ContactRow(
                              contact: c,
                              accent: accent,
                              t: t,
                              onTap: () => context
                                  .read<HaloBloc>()
                                  .add(SelectContact(c.name)),
                            )),
                            const SizedBox(height: 6),
                          ],
                        );
                      }).toList(),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ContactRow extends StatelessWidget {
  final Contact contact;
  final AccentColors accent;
  final HaloTheme t;
  final VoidCallback onTap;

  const _ContactRow({
    required this.contact,
    required this.accent,
    required this.t,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        color: Colors.transparent,
        child: Row(
          children: [
            AvatarWidget(name: contact.name, size: 44, palette: contact.palette),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: GoogleFonts.inter(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.1,
                      color: t.onSurface,
                    ),
                  ),
                  if (contact.snippet != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      contact.snippet!,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: t.muted(0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (contact.due != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.line.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  contact.due!,
                  style: GoogleFonts.inter(fontSize: 11, color: accent.line),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
