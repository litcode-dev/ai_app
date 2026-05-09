# Settings Screen — Design Spec
*Halo AI App · 2026-05-09*

---

## Overview

Add a full settings screen reachable via the `sliders` nav tab. Settings are owned by a new `SettingsCubit` (separate from `HaloBloc`) and persisted via `SharedPreferences`. Three concern areas: user profile, AI behavior, and notifications.

---

## Architecture

### New state management

`SettingsCubit` extends `Cubit<SettingsState>` and is registered as a lazy singleton in `get_it`. It owns all settings state; `HaloBloc` is not modified except to wire `NavTab.sliders → HaloScreen.settings`.

```
SettingsState
  profileName: String           default: 'You'
  profileTagline: String        default: 'Relationship intelligence'
  profileAvatarPath: String?    default: null  (local file path)
  suggestionsEnabled: bool      default: true
  voiceEnabled: bool            default: true
  tone: ResponseTone            default: ResponseTone.balanced
  notificationsEnabled: bool    default: true
  quietHoursStart: TimeOfDay    default: 22:00
  quietHoursEnd: TimeOfDay      default: 07:00

enum ResponseTone { concise, balanced, detailed }
```

`SettingsCubit` methods (each emits new state then writes to SharedPreferences):
- `loadSettings()` — called once at app init; reads all keys, emits `SettingsState`
- `updateProfile(name, tagline, avatarPath?)`
- `toggleSuggestions(bool)`
- `toggleVoice(bool)`
- `setTone(ResponseTone)`
- `toggleNotifications(bool)`
- `setQuietHours(TimeOfDay start, TimeOfDay end)`

### SharedPreferences keys

| Key | Type | Default |
|---|---|---|
| `halo_profile_name` | String | `'You'` |
| `halo_profile_tagline` | String | `'Relationship intelligence'` |
| `halo_profile_avatar` | String? | null |
| `halo_suggestions_enabled` | bool | `true` |
| `halo_voice_enabled` | bool | `true` |
| `halo_tone` | String | `'balanced'` |
| `halo_notifications_enabled` | bool | `true` |
| `halo_quiet_start` | String | `'22:00'` |
| `halo_quiet_end` | String | `'07:00'` |

Quiet hours are stored as `'HH:mm'` strings and parsed back to `TimeOfDay` on load.

### Dependency injection

`initDependencies()` in `injection_container.dart` becomes `async`:

```dart
Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton(() => SettingsCubit(sl())..loadSettings());
  // ... existing registrations unchanged
}
```

`main.dart` becomes:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const HaloApp());
}
```

`app.dart` wraps with `MultiBlocProvider`:
```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => sl<HaloBloc>()..add(const AppStarted())),
    BlocProvider(create: (_) => sl<SettingsCubit>()),
  ],
  child: MaterialApp(...),
)
```

---

## Settings Screen UI

File: `lib/presentation/pages/settings_page.dart`

Scrollable `ListView` with four sections, separated by section headers in white-40% small caps. The nav bar remains visible (settings is a primary tab destination).

### Profile section
- Tappable avatar circle (64 px): accent-colored border, shows `FileImage` if avatar path set, otherwise initials from `profileName` in accent color on dark background
- Tapping avatar invokes `image_picker` → `ImageSource.gallery` → saves path via `updateProfile`
- Inline editable `TextField` for name (style: white, 18sp, weight 600)
- Inline editable `TextField` for tagline (style: white-60%, 13sp)
- Fields auto-save on `onEditingComplete` / `onTapOutside`

### Accent section
- Row of 4 circular swatches (fern / cobalt / amber / magenta)
- Active swatch: accent-colored ring + checkmark inside
- Tap dispatches `ChangeAccent(name)` to `HaloBloc` (accent stays in HaloBloc because it drives the global ambient gradient)

### AI Behavior section
- **Suggestion chips** — `Switch` (accent-colored when on)
- **Voice mode** — `Switch`
- **Response tone** — three-segment control: `Concise | Balanced | Detailed`; active segment has accent background, others dark with white-50% text

### Notifications section
- **Reminders** — `Switch` (master toggle)
- **Quiet hours** — two `ListTile`s showing start/end times; tapping opens `showTimePicker`; entire group disabled + dimmed when master toggle is off

---

## Integration with Existing Screens

### `_HaloShell` (app.dart)
- `showNav` updated: `state.screen == HaloScreen.settings` added to the condition
- `_buildPage` switch gains `HaloScreen.settings → SettingsPage`

### `HaloBloc._onChangeNavTab`
```dart
} else if (event.tab == NavTab.sliders) {
  screen = HaloScreen.settings;
}
```

### `halo_event.dart`
`HaloScreen` enum gains `settings` value.

### `HomePage`
Suggestion chips row wrapped in `BlocBuilder<SettingsCubit, SettingsState>` — rendered only when `state.suggestionsEnabled` is true.

### `ListenPage`
Mic/record action gated by `context.read<SettingsCubit>().state.voiceEnabled`. When false, button shows dimmed state; page still reachable via nav.

---

## New Files

```
lib/presentation/bloc/settings_cubit.dart
lib/presentation/bloc/settings_state.dart
lib/presentation/pages/settings_page.dart
```

## Modified Files

```
pubspec.yaml                               ← add: shared_preferences, image_picker
lib/main.dart                              ← async init
lib/injection_container.dart               ← async, SharedPreferences, SettingsCubit
lib/app.dart                               ← MultiBlocProvider, showNav, _buildPage
lib/presentation/bloc/halo_event.dart      ← HaloScreen.settings
lib/presentation/bloc/halo_bloc.dart       ← sliders tab wiring
lib/presentation/pages/home_page.dart      ← suggestions gate
lib/presentation/pages/listen_page.dart    ← voice gate
```

---

## Edge Cases

- **Empty profile name** — display falls back to `'You'`; stored value may be empty string
- **Quiet hours wrap midnight** — end time < start time is valid (interpreted as next-day); no validation error, just store as-is
- **Same quiet hours start/end** — treat as "quiet all day"; acceptable for MVP
- **SharedPreferences init failure** — `SettingsState.initial()` defaults used; no crash
- **Image picker permission denied** — catch `PlatformException`, show `SnackBar`, keep existing avatar
- **Avatar file deleted externally** — `FileImage` load fails; fall back to initials silently via `errorBuilder`

---

## Out of Scope (this iteration)

- Remote sync of settings to a backend
- Per-contact notification preferences
- Dark/light theme toggle (app is dark-only)
- Biometric lock / privacy screen
