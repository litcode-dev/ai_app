import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/colors.dart';
import '../../domain/entities/contact.dart';
import '../../domain/entities/contact_detail.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/entities/timeline_item.dart';
import '../bloc/halo_bloc.dart';
import '../bloc/halo_event.dart';
import '../bloc/halo_state.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/halo_nav_bar.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HaloBloc, HaloState>(
      builder: (context, state) {
        final accent = getAccent(state.accent);
        final contact = state.selectedContact;
        if (contact == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context
                        .read<HaloBloc>()
                        .add(const NavigateToScreen(HaloScreen.people)),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: HaloIcon(name: 'back', size: 26),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: HaloIcon(
                      name: contact.starred ? 'star-fill' : 'star',
                      size: 22,
                      color: contact.starred ? accent.line : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: accent.line.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accent.line.withValues(alpha: 0.2),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                        ),
                        AvatarWidget(name: contact.name, size: 108, palette: contact.palette),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      contact.name,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HaloIcon(
                          name: 'clock',
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Last interaction was yesterday',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ActionButton(
                          icon: 'spark',
                          label: 'Brief',
                          isPrimary: true,
                          accent: accent,
                          onTap: () => context
                              .read<HaloBloc>()
                              .add(const NavigateToScreen(HaloScreen.confirm)),
                        ),
                        const SizedBox(width: 12),
                        _ActionButton(icon: 'msg', label: 'Message', accent: accent),
                        const SizedBox(width: 12),
                        _ActionButton(icon: 'edit', label: 'Note', accent: accent),
                        const SizedBox(width: 12),
                        _ActionButton(icon: 'more', label: 'More', accent: accent),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _ContactTabs(state: state, accent: accent),
                    const SizedBox(height: 14),
                    _TabContent(state: state, contact: contact, accent: accent),
                    const SizedBox(height: 40),
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

class _ActionButton extends StatelessWidget {
  final String icon;
  final String label;
  final bool isPrimary;
  final AccentColors accent;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.accent,
    this.isPrimary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPrimary ? accent.solid : Colors.white.withValues(alpha: 0.06),
              border: isPrimary ? null : Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: isPrimary
                  ? [BoxShadow(color: accent.glow, blurRadius: 20, offset: const Offset(0, 6))]
                  : null,
            ),
            child: Center(
              child: HaloIcon(name: icon, size: 22, color: isPrimary ? kOnAccent : Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
        ),
      ],
    );
  }
}

class _ContactTabs extends StatelessWidget {
  final HaloState state;
  final AccentColors accent;

  const _ContactTabs({required this.state, required this.accent});

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (label: 'Timeline', value: ContactTab.timeline),
      (label: 'Reminders', value: ContactTab.reminders),
      (label: 'Details', value: ContactTab.details),
    ];
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: tabs.map((t) {
          final isActive = state.contactTab == t.value;
          return GestureDetector(
            onTap: () => context.read<HaloBloc>().add(ChangeContactTab(t.value)),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive ? accent.solid : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                t.label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  final HaloState state;
  final Contact contact;
  final AccentColors accent;

  const _TabContent({required this.state, required this.contact, required this.accent});

  @override
  Widget build(BuildContext context) {
    switch (state.contactTab) {
      case ContactTab.timeline:
        return _TimelineList(items: contact.timeline, accent: accent);
      case ContactTab.reminders:
        return _RemindersList(items: contact.reminders, accent: accent);
      case ContactTab.details:
        return _DetailsList(details: contact.details, accent: accent);
    }
  }
}

class _TimelineList extends StatelessWidget {
  final List<TimelineItem> items;
  final AccentColors accent;

  const _TimelineList({required this.items, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.asMap().entries.map((e) {
        final item = e.value;
        final isLast = e.key == items.length - 1;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.line.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: accent.line.withValues(alpha: 0.18)),
                ),
                child: Center(child: HaloIcon(name: item.icon, size: 16, color: accent.line)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.when.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.45),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.text,
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        height: 1.45,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _RemindersList extends StatelessWidget {
  final List<Reminder> items;
  final AccentColors accent;

  const _RemindersList({required this.items, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((r) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.solid, width: 1.5),
                ),
                child: Center(child: HaloIcon(name: 'calendar', size: 16, color: accent.solid)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.text, style: GoogleFonts.inter(fontSize: 14.5, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(
                      r.due,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DetailsList extends StatelessWidget {
  final List<ContactDetail> details;
  final AccentColors accent;

  const _DetailsList({required this.details, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: details.asMap().entries.map((e) {
        final d = e.value;
        final isLast = e.key == details.length - 1;
        return Container(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
          ),
          child: Row(
            children: [
              HaloIcon(name: d.icon, size: 18, color: accent.solid),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.label.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.45),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(d.value, style: GoogleFonts.inter(fontSize: 14.5, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
