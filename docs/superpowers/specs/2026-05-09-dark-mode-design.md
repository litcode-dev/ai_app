# Dark Mode Toggle — Design Spec
*Halo AI App · 2026-05-09*

---

## Overview

Add a manually-controlled dark/light mode toggle to the Settings screen. The current dark appearance is preserved exactly. A new light theme (off-white surface, dark text, accent colors unchanged) is introduced via Flutter's `ThemeExtension` system. The device system setting is ignored entirely — the user's preference is the only control, persisted via `SharedPreferences`.

---

## Architecture

### HaloTheme ThemeExtension

A new `HaloTheme extends ThemeExtension<HaloTheme>` is defined in `lib/core/theme/halo_theme.dart`. It carries all semantic color tokens needed by the app. `MaterialApp` is rebuilt via `BlocBuilder<SettingsCubit>` when `darkModeEnabled` changes, passing the correct extension instance.

```dart
class HaloTheme extends ThemeExtension<HaloTheme> {
  final Color surface;       // scaffold/page background
  final Color cardSurface;   // frosted card backgrounds
  final Color borderColor;   // card/input borders
  final Color onSurface;     // primary text color
  final bool ambientGlow;    // whether to render RadialGradient ambient overlays

  Color muted(double opacity) => onSurface.withValues(alpha: opacity);

  static const HaloTheme dark = HaloTheme(
    surface:     Color(0xFF0A0D0B),
    cardSurface: Color(0x0AFFFFFF),   // white @ 4%
    borderColor: Color(0x14FFFFFF),   // white @ 8%
    onSurface:   Colors.white,
    ambientGlow: true,
  );

  static const HaloTheme light = HaloTheme(
    surface:     Color(0xFFF2F7F4),   // off-white, faint green tint
    cardSurface: Color(0xB3FFFFFF),   // white @ 70%
    borderColor: Color(0x14000000),   // black @ 8%
    onSurface:   Color(0xFF0D1A12),   // near-black
    ambientGlow: false,
  );
}
```

Widgets access the theme via:
```dart
final t = Theme.of(context).extension<HaloTheme>()!;
// t.surface, t.onSurface, t.muted(0.55), t.cardSurface, t.borderColor, t.ambientGlow
```

### MaterialApp integration

`app.dart` wraps `MaterialApp` in a `BlocBuilder<SettingsCubit, SettingsState>`. When `darkModeEnabled` is true, `ThemeData.dark()` + `HaloTheme.dark` is used; when false, `ThemeData.light()` + `HaloTheme.light`. `themeMode` is always `ThemeMode.dark` or `ThemeMode.light` to match (controls `SystemChrome` status bar brightness automatically).

```dart
BlocBuilder<SettingsCubit, SettingsState>(
  buildWhen: (prev, curr) => prev.darkModeEnabled != curr.darkModeEnabled,
  builder: (context, settings) {
    final isDark = settings.darkModeEnabled;
    return MaterialApp(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: HaloTheme.light.surface,
        extensions: [HaloTheme.light],
        ...
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: HaloTheme.dark.surface,
        extensions: [HaloTheme.dark],
        ...
      ),
      ...
    );
  },
)
```

### SettingsCubit changes

`SettingsState` gains:
```dart
final bool darkModeEnabled;   // default: true
```

`SettingsCubit` gains:
```dart
void toggleDarkMode(bool value) {
  emit(state.copyWith(darkModeEnabled: value));
  _prefs.setBool('halo_dark_mode', value);
}
```

`loadSettings()` reads `_prefs.getBool('halo_dark_mode') ?? true`.

---

## Token Replacement Map

All hardcoded color references are replaced with `HaloTheme` tokens:

| Old | New |
|---|---|
| `Colors.white.withValues(alpha: X)` | `t.muted(X)` |
| `kBackground` (in widget trees) | `t.surface` |
| `Colors.white.withValues(alpha: 0.04)` | `t.cardSurface` |
| `Colors.white.withValues(alpha: 0.06)` | `t.cardSurface` |
| `Colors.white.withValues(alpha: 0.08)` | `t.borderColor` |
| Ambient `RadialGradient` overlays | gated on `t.ambientGlow` |
| `ThemeData.dark().textTheme` | derived from `themeMode` |

**Note:** `AccentColors` (`accent.solid`, `accent.line`, `accent.glow`, `accent.glowMid`) are NOT changed. Accent swatches read from `HaloBloc` and look correct on both light and dark surfaces. `kOnAccent` (`#062213`) is also unchanged.

**Note:** `Colors.white` used inside `HaloIcon` (CustomPainter) and `_OrbMini` active glow are also replaced with `t.onSurface`.

---

## Light Theme Visual Decisions

- **Orb:** unchanged — renders via `ui.Gradient.sweep` on its own canvas; accent colors look great on light backgrounds
- **Ambient glow overlays:** disabled (`ambientGlow: false`) — they depend on dark surroundings to be visible
- **Top `RadialGradient` in shell:** remains, driven by `accent.glowMid` — subtle enough on light, adds warmth
- **Nav bar:** transparent background, inherits `surface`
- **Cards / chips:** white at 70% opacity with 8% dark border — readable on `#F2F7F4`
- **Status bar icons:** `ThemeMode` controls this automatically — dark icons in light mode, light icons in dark mode
- **Google Fonts text:** base `textTheme` switches between `ThemeData.dark()` / `ThemeData.light()` so default text color is correct

---

## Settings Screen Change

New "APPEARANCE" section inserted above "ACCENT":

```
APPEARANCE
Dark mode                    [toggle]
```

Uses the existing `_ToggleRow` widget. Toggle calls `context.read<SettingsCubit>().toggleDarkMode(v)`.

---

## New & Modified Files

**New:**
```
lib/core/theme/halo_theme.dart
```

**Modified:**
```
lib/core/theme/colors.dart                    ← kBackground usage in widget trees replaced with t.surface; constant retained in file
lib/presentation/bloc/settings_state.dart     ← add darkModeEnabled field
lib/presentation/bloc/settings_cubit.dart     ← add toggleDarkMode + load key
lib/app.dart                                  ← BlocBuilder around MaterialApp, theme/darkTheme/themeMode
lib/presentation/pages/settings_page.dart     ← APPEARANCE section + t token usage
lib/presentation/pages/home_page.dart         ← t token replacements
lib/presentation/pages/listen_page.dart       ← t token replacements
lib/presentation/pages/note_page.dart         ← t token replacements
lib/presentation/pages/contact_page.dart      ← t token replacements
lib/presentation/pages/people_page.dart       ← t token replacements
lib/presentation/pages/confirm_page.dart      ← t token replacements
lib/presentation/widgets/halo_nav_bar.dart    ← t token replacements (HaloIcon color, nav bg)
lib/presentation/widgets/wave_bar.dart        ← t token if hardcoded white
lib/presentation/widgets/avatar_widget.dart   ← t token if hardcoded white
test/presentation/bloc/settings_cubit_test.dart ← add toggleDarkMode test
```

**Note:** `kBackground` in `colors.dart` is only removed from widget-tree usage; the constant itself stays as a reference value to avoid breaking any future use.

---

## Edge Cases

- **First launch:** `darkModeEnabled` defaults to `true` — existing dark appearance is unchanged for all current users
- **`Theme.of(context).extension<HaloTheme>()!` null safety:** safe because both `theme` and `darkTheme` in `MaterialApp` always include the extension
- **`SystemChrome` status bar:** currently set manually in `_HaloShell` via `setSystemUIOverlayStyle`. Remove this manual call — `MaterialApp` with `themeMode` sets status bar brightness automatically based on theme brightness
- **OrbWidget:** no changes needed — it receives `AccentColors` directly, not `HaloTheme` tokens
- **WaveBar / AvatarWidget:** read at implementation time; replace if hardcoded white found, skip if already using parameters

---

## Out of Scope

- System theme following (`MediaQuery.platformBrightness`)
- Per-screen theme overrides
- Animated theme transition (cross-fade between light/dark)
- Separate accent palettes tuned per theme
