import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_keys.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/halo_theme.dart';
import '../bloc/halo_bloc.dart';
import '../bloc/halo_event.dart';
import '../bloc/halo_state.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _darkModeRowKey = GlobalKey();

  Future<void> _toggleDarkMode(bool value) async {
    final rowContext = _darkModeRowKey.currentContext;
    if (rowContext == null || !mounted) return;

    // Position: right edge of the row (where the switch sits)
    final box = rowContext.findRenderObject() as RenderBox;
    final origin = box.localToGlobal(Offset(box.size.width - 20, box.size.height / 2));

    // Capture current screen
    final boundaryContext = appShellRepaintKey.currentContext;
    if (boundaryContext == null) {
      context.read<SettingsCubit>().toggleDarkMode(value);
      return;
    }
    final boundary = boundaryContext.findRenderObject() as RenderRepaintBoundary;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final image = await boundary.toImage(pixelRatio: pixelRatio);

    if (!mounted) return;

    // Max radius = distance from origin to farthest screen corner
    final size = MediaQuery.of(context).size;
    final maxRadius = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ].fold<double>(0, (r, c) => math.max(r, (c - origin).distance));

    final overlay = Overlay.of(context);
    final cubit = context.read<SettingsCubit>();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: _CircularRevealOverlay(
          image: image,
          origin: origin,
          maxRadius: maxRadius,
          onComplete: () => entry.remove(),
        ),
      ),
    );

    // Show overlay first, then change theme underneath it
    overlay.insert(entry);
    cubit.toggleDarkMode(value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HaloBloc, HaloState>(
      builder: (context, haloState) {
        final accent = getAccent(haloState.accent);
        return BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) {
            final t = Theme.of(context).extension<HaloTheme>()!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              children: [
                _Header(accent: accent),
                const SizedBox(height: 24),
                _ProfileCard(settings: settings, accent: accent),
                const SizedBox(height: 28),
                _sectionHeader('APPEARANCE', t),
                const SizedBox(height: 12),
                _ToggleRow(
                  key: _darkModeRowKey,
                  label: 'Dark mode',
                  value: settings.darkModeEnabled,
                  accent: accent,
                  onChanged: _toggleDarkMode,
                ),
                const SizedBox(height: 28),
                _sectionHeader('ACCENT', t),
                const SizedBox(height: 12),
                _AccentRow(currentAccent: haloState.accent),
                const SizedBox(height: 28),
                _sectionHeader('AI BEHAVIOR', t),
                const SizedBox(height: 12),
                _BehaviorSection(settings: settings, accent: accent),
                const SizedBox(height: 28),
                _sectionHeader('NOTIFICATIONS', t),
                const SizedBox(height: 12),
                _NotificationSection(settings: settings, accent: accent),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _sectionHeader(String label, HaloTheme t) => Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: t.muted(0.4),
        ),
      );
}

class _CircularRevealOverlay extends StatefulWidget {
  final ui.Image image;
  final Offset origin;
  final double maxRadius;
  final VoidCallback onComplete;

  const _CircularRevealOverlay({
    required this.image,
    required this.origin,
    required this.maxRadius,
    required this.onComplete,
  });

  @override
  State<_CircularRevealOverlay> createState() => _CircularRevealOverlayState();
}

class _CircularRevealOverlayState extends State<_CircularRevealOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _radius;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _radius = Tween<double>(begin: 0, end: widget.maxRadius).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _radius,
      builder: (context, _) => ClipPath(
        clipper: _CircleRevealClipper(radius: _radius.value, center: widget.origin),
        child: RawImage(image: widget.image, fit: BoxFit.fill, scale: 1),
      ),
    );
  }
}

// Clips the old-theme image everywhere EXCEPT the growing circle,
// revealing the new theme underneath as the circle expands.
class _CircleRevealClipper extends CustomClipper<Path> {
  final double radius;
  final Offset center;

  const _CircleRevealClipper({required this.radius, required this.center});

  @override
  Path getClip(Size size) => Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
      );

  @override
  bool shouldReclip(_CircleRevealClipper old) => old.radius != radius;
}

class _Header extends StatelessWidget {
  final AccentColors accent;
  const _Header({required this.accent});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<HaloTheme>()!;
    return Row(
      children: [
        Text(
          'Settings',
          style: GoogleFonts.inter(
            fontSize: 26,
            fontWeight: FontWeight.w500,
            color: t.onSurface,
          ),
        ),
        const Spacer(),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: accent.solid,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: accent.glow, blurRadius: 8)],
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatefulWidget {
  final SettingsState settings;
  final AccentColors accent;

  const _ProfileCard({required this.settings, required this.accent});

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> {
  late TextEditingController _nameCtrl;
  late TextEditingController _taglineCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.settings.profileName);
    _taglineCtrl = TextEditingController(text: widget.settings.profileTagline);
  }

  @override
  void didUpdateWidget(_ProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.profileName != widget.settings.profileName &&
        _nameCtrl.text != widget.settings.profileName) {
      _nameCtrl.text = widget.settings.profileName;
    }
    if (oldWidget.settings.profileTagline != widget.settings.profileTagline &&
        _taglineCtrl.text != widget.settings.profileTagline) {
      _taglineCtrl.text = widget.settings.profileTagline;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _taglineCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!mounted) return;
    final name = _nameCtrl.text.trim();
    final tagline = _taglineCtrl.text.trim();
    context.read<SettingsCubit>().updateProfile(
      name.isEmpty ? 'You' : name,
      tagline.isEmpty ? 'Relationship intelligence' : tagline,
    );
  }

  Future<void> _pickAvatar() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (file == null || !mounted) return;
      final name = _nameCtrl.text.trim();
      context.read<SettingsCubit>().updateProfile(
        name.isEmpty ? 'You' : name,
        _taglineCtrl.text.trim(),
        avatarPath: file.path,
      );
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not access photo library')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<HaloTheme>()!;
    final settings = widget.settings;
    final accent = widget.accent;
    final initials =
        (settings.profileName.isNotEmpty ? settings.profileName[0] : 'Y').toUpperCase();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.borderColor),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickAvatar,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accent.solid, width: 2),
                color: accent.glow.withValues(alpha: 0.2),
              ),
              child: ClipOval(
                child: settings.profileAvatarPath != null
                    ? Image.file(
                        File(settings.profileAvatarPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => // ignore: unnecessary_underscores
                            _Initials(initials: initials, accent: accent),
                      )
                    : _Initials(initials: initials, accent: accent),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameCtrl,
                  onEditingComplete: _save,
                  onTapOutside: (_) => _save(),
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: t.onSurface,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _taglineCtrl,
                  onEditingComplete: _save,
                  onTapOutside: (_) => _save(),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: t.muted(0.55),
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String initials;
  final AccentColors accent;

  const _Initials({required this.initials, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: accent.solid,
        ),
      ),
    );
  }
}

class _AccentRow extends StatelessWidget {
  final String currentAccent;

  const _AccentRow({required this.currentAccent});

  static const _options = ['fern', 'cobalt', 'amber', 'magenta'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options.map((name) {
        final colors = getAccent(name);
        final isActive = name == currentAccent;
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => context.read<HaloBloc>().add(ChangeAccent(name)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.solid,
                border: isActive
                    ? Border.all(color: Colors.white, width: 2.5)
                    : Border.all(color: Colors.transparent, width: 2.5),
                boxShadow: isActive
                    ? [BoxShadow(color: colors.glow, blurRadius: 12, spreadRadius: 1)]
                    : null,
              ),
              child: isActive
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BehaviorSection extends StatelessWidget {
  final SettingsState settings;
  final AccentColors accent;

  const _BehaviorSection({required this.settings, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ToggleRow(
          label: 'Suggestion chips',
          value: settings.suggestionsEnabled,
          accent: accent,
          onChanged: (v) => context.read<SettingsCubit>().toggleSuggestions(v),
        ),
        const SizedBox(height: 16),
        _ToggleRow(
          label: 'Voice mode',
          value: settings.voiceEnabled,
          accent: accent,
          onChanged: (v) => context.read<SettingsCubit>().toggleVoice(v),
        ),
        const SizedBox(height: 16),
        _ToneSelector(tone: settings.tone, accent: accent),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final AccentColors accent;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<HaloTheme>()!;
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: t.muted(0.87),
          ),
        ),
        const Spacer(),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: accent.solid, // ignore: deprecated_member_use
          activeTrackColor: accent.glow.withValues(alpha: 0.5),
          inactiveThumbColor: t.muted(0.4),
          inactiveTrackColor: t.muted(0.1),
        ),
      ],
    );
  }
}

class _ToneSelector extends StatelessWidget {
  final ResponseTone tone;
  final AccentColors accent;

  const _ToneSelector({required this.tone, required this.accent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<HaloTheme>()!;
    return Row(
      children: [
        Text(
          'Response tone',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: theme.muted(0.87),
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: theme.muted(0.07),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: ResponseTone.values.map((t) {
              final isActive = t == tone;
              final label = t.name[0].toUpperCase() + t.name.substring(1);
              return GestureDetector(
                onTap: () => context.read<SettingsCubit>().setTone(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? accent.solid : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isActive ? kOnAccent : theme.muted(0.5),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _NotificationSection extends StatelessWidget {
  final SettingsState settings;
  final AccentColors accent;

  const _NotificationSection({required this.settings, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ToggleRow(
          label: 'Reminders',
          value: settings.notificationsEnabled,
          accent: accent,
          onChanged: (v) => context.read<SettingsCubit>().toggleNotifications(v),
        ),
        const SizedBox(height: 16),
        Opacity(
          opacity: settings.notificationsEnabled ? 1.0 : 0.35,
          child: Column(
            children: [
              _TimeRow(
                label: 'Quiet from',
                time: settings.quietHoursStart,
                accent: accent,
                onTap: () async {
                  if (!settings.notificationsEnabled) return;
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: settings.quietHoursStart,
                  );
                  if (picked != null && context.mounted) {
                    context
                        .read<SettingsCubit>()
                        .setQuietHours(picked, settings.quietHoursEnd);
                  }
                },
              ),
              const SizedBox(height: 12),
              _TimeRow(
                label: 'Quiet until',
                time: settings.quietHoursEnd,
                accent: accent,
                onTap: () async {
                  if (!settings.notificationsEnabled) return;
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: settings.quietHoursEnd,
                  );
                  if (picked != null && context.mounted) {
                    context
                        .read<SettingsCubit>()
                        .setQuietHours(settings.quietHoursStart, picked);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeRow extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final AccentColors accent;
  final VoidCallback onTap;

  const _TimeRow({
    required this.label,
    required this.time,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<HaloTheme>()!;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: t.muted(0.87),
            ),
          ),
          const Spacer(),
          Text(
            time.format(context),
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: accent.solid,
            ),
          ),
        ],
      ),
    );
  }
}
