# Settings Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a full settings screen (profile, accent, AI behavior, notifications) reachable via the sliders nav tab, backed by a `SettingsCubit` that persists to `SharedPreferences`.

**Architecture:** A new `SettingsCubit` (separate from `HaloBloc`) owns all settings state and writes to `SharedPreferences` on every mutation. `HaloBloc` gains a `HaloScreen.settings` value and wires `NavTab.sliders` to it. `HomePage` and `ListenPage` read from `SettingsCubit` to gate suggestion chips and voice mode respectively.

**Tech Stack:** Flutter BLoC (`flutter_bloc`), `shared_preferences ^2.3.5`, `image_picker ^1.1.2`, `equatable`, `google_fonts`, `get_it`.

---

## File Map

| Action | Path | Responsibility |
|---|---|---|
| Create | `lib/presentation/bloc/settings_state.dart` | `ResponseTone` enum + `SettingsState` data class |
| Create | `lib/presentation/bloc/settings_cubit.dart` | All settings mutations + SharedPreferences persistence |
| Create | `lib/presentation/pages/settings_page.dart` | Full settings UI |
| Create | `test/presentation/bloc/settings_cubit_test.dart` | Unit tests for SettingsCubit |
| Modify | `pubspec.yaml` | Add `shared_preferences`, `image_picker` |
| Modify | `lib/presentation/bloc/halo_event.dart` | Add `settings` to `HaloScreen` enum |
| Modify | `lib/presentation/bloc/halo_bloc.dart` | Wire `NavTab.sliders → HaloScreen.settings` |
| Modify | `lib/injection_container.dart` | Register `SharedPreferences` + `SettingsCubit`; make async |
| Modify | `lib/main.dart` | `async main`, await `initDependencies()` |
| Modify | `lib/app.dart` | `MultiBlocProvider`, `showNav` includes settings, `_buildPage` switch |
| Modify | `lib/presentation/pages/home_page.dart` | Gate suggestion chips on `suggestionsEnabled` |
| Modify | `lib/presentation/pages/listen_page.dart` | Show demo banner when `voiceEnabled` is false |

---

### Task 1: Add Dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add packages to pubspec.yaml**

Open `pubspec.yaml` and add two lines under `dependencies:` (after `dartz: ^0.10.1`):

```yaml
  shared_preferences: ^2.3.5
  image_picker: ^1.1.2
```

The `dependencies` block should look like:
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_bloc: ^9.1.1
  equatable: ^2.0.7
  google_fonts: ^6.2.1
  get_it: ^8.0.3
  dartz: ^0.10.1
  shared_preferences: ^2.3.5
  image_picker: ^1.1.2
```

- [ ] **Step 2: Fetch packages**

```bash
flutter pub get
```

Expected: `Got dependencies!` with no errors.

- [ ] **Step 3: iOS platform setup for image_picker**

Open `ios/Runner/Info.plist` and add before the closing `</dict>` tag:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Halo uses your photo library to set your profile picture.</string>
```

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock ios/Runner/Info.plist
git commit -m "feat: add shared_preferences and image_picker dependencies"
```

---

### Task 2: SettingsState

**Files:**
- Create: `lib/presentation/bloc/settings_state.dart`

- [ ] **Step 1: Write the file**

Create `lib/presentation/bloc/settings_state.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ResponseTone { concise, balanced, detailed }

const Object _kSentinel = Object();

class SettingsState extends Equatable {
  final String profileName;
  final String profileTagline;
  final String? profileAvatarPath;
  final bool suggestionsEnabled;
  final bool voiceEnabled;
  final ResponseTone tone;
  final bool notificationsEnabled;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;

  const SettingsState({
    required this.profileName,
    required this.profileTagline,
    this.profileAvatarPath,
    required this.suggestionsEnabled,
    required this.voiceEnabled,
    required this.tone,
    required this.notificationsEnabled,
    required this.quietHoursStart,
    required this.quietHoursEnd,
  });

  factory SettingsState.initial() => const SettingsState(
    profileName: 'You',
    profileTagline: 'Relationship intelligence',
    suggestionsEnabled: true,
    voiceEnabled: true,
    tone: ResponseTone.balanced,
    notificationsEnabled: true,
    quietHoursStart: TimeOfDay(hour: 22, minute: 0),
    quietHoursEnd: TimeOfDay(hour: 7, minute: 0),
  );

  SettingsState copyWith({
    String? profileName,
    String? profileTagline,
    Object? profileAvatarPath = _kSentinel,
    bool? suggestionsEnabled,
    bool? voiceEnabled,
    ResponseTone? tone,
    bool? notificationsEnabled,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
  }) {
    return SettingsState(
      profileName: profileName ?? this.profileName,
      profileTagline: profileTagline ?? this.profileTagline,
      profileAvatarPath: identical(profileAvatarPath, _kSentinel)
          ? this.profileAvatarPath
          : profileAvatarPath as String?,
      suggestionsEnabled: suggestionsEnabled ?? this.suggestionsEnabled,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      tone: tone ?? this.tone,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }

  @override
  List<Object?> get props => [
    profileName,
    profileTagline,
    profileAvatarPath,
    suggestionsEnabled,
    voiceEnabled,
    tone,
    notificationsEnabled,
    quietHoursStart,
    quietHoursEnd,
  ];
}
```

- [ ] **Step 2: Verify it compiles**

```bash
flutter analyze lib/presentation/bloc/settings_state.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/bloc/settings_state.dart
git commit -m "feat: add SettingsState with ResponseTone enum"
```

---

### Task 3: SettingsCubit + Unit Tests

**Files:**
- Create: `lib/presentation/bloc/settings_cubit.dart`
- Create: `test/presentation/bloc/settings_cubit_test.dart`

- [ ] **Step 1: Write the failing tests first**

Create `test/presentation/bloc/settings_cubit_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ai_app/presentation/bloc/settings_cubit.dart';
import 'package:ai_app/presentation/bloc/settings_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsCubit', () {
    late SharedPreferences prefs;
    late SettingsCubit cubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      cubit = SettingsCubit(prefs);
    });

    tearDown(() => cubit.close());

    test('initial state uses defaults', () {
      expect(cubit.state, SettingsState.initial());
    });

    test('loadSettings uses defaults when prefs empty', () {
      cubit.loadSettings();
      expect(cubit.state.profileName, 'You');
      expect(cubit.state.profileTagline, 'Relationship intelligence');
      expect(cubit.state.suggestionsEnabled, true);
      expect(cubit.state.voiceEnabled, true);
      expect(cubit.state.tone, ResponseTone.balanced);
      expect(cubit.state.notificationsEnabled, true);
      expect(cubit.state.quietHoursStart, const TimeOfDay(hour: 22, minute: 0));
      expect(cubit.state.quietHoursEnd, const TimeOfDay(hour: 7, minute: 0));
    });

    test('loadSettings reads persisted values', () async {
      SharedPreferences.setMockInitialValues({
        'halo_profile_name': 'Alice',
        'halo_profile_tagline': 'Founder',
        'halo_suggestions_enabled': false,
        'halo_tone': 'concise',
        'halo_quiet_start': '23:30',
        'halo_quiet_end': '06:00',
      });
      prefs = await SharedPreferences.getInstance();
      cubit = SettingsCubit(prefs);
      cubit.loadSettings();
      expect(cubit.state.profileName, 'Alice');
      expect(cubit.state.profileTagline, 'Founder');
      expect(cubit.state.suggestionsEnabled, false);
      expect(cubit.state.tone, ResponseTone.concise);
      expect(cubit.state.quietHoursStart, const TimeOfDay(hour: 23, minute: 30));
      expect(cubit.state.quietHoursEnd, const TimeOfDay(hour: 6, minute: 0));
    });

    test('toggleSuggestions emits new state and persists', () {
      cubit.toggleSuggestions(false);
      expect(cubit.state.suggestionsEnabled, false);
      expect(prefs.getBool('halo_suggestions_enabled'), false);
    });

    test('toggleVoice emits new state and persists', () {
      cubit.toggleVoice(false);
      expect(cubit.state.voiceEnabled, false);
      expect(prefs.getBool('halo_voice_enabled'), false);
    });

    test('setTone emits new state and persists', () {
      cubit.setTone(ResponseTone.detailed);
      expect(cubit.state.tone, ResponseTone.detailed);
      expect(prefs.getString('halo_tone'), 'detailed');
    });

    test('toggleNotifications emits new state and persists', () {
      cubit.toggleNotifications(false);
      expect(cubit.state.notificationsEnabled, false);
      expect(prefs.getBool('halo_notifications_enabled'), false);
    });

    test('setQuietHours emits new state and persists as HH:mm', () {
      cubit.setQuietHours(
        const TimeOfDay(hour: 21, minute: 30),
        const TimeOfDay(hour: 6, minute: 0),
      );
      expect(cubit.state.quietHoursStart, const TimeOfDay(hour: 21, minute: 30));
      expect(cubit.state.quietHoursEnd, const TimeOfDay(hour: 6, minute: 0));
      expect(prefs.getString('halo_quiet_start'), '21:30');
      expect(prefs.getString('halo_quiet_end'), '06:00');
    });

    test('updateProfile emits new state and persists', () {
      cubit.updateProfile('Bob', 'Sales lead');
      expect(cubit.state.profileName, 'Bob');
      expect(cubit.state.profileTagline, 'Sales lead');
      expect(prefs.getString('halo_profile_name'), 'Bob');
      expect(prefs.getString('halo_profile_tagline'), 'Sales lead');
      expect(cubit.state.profileAvatarPath, isNull);
    });

    test('updateProfile with avatarPath persists path', () {
      cubit.updateProfile('Bob', 'Sales lead', avatarPath: '/img/photo.jpg');
      expect(cubit.state.profileAvatarPath, '/img/photo.jpg');
      expect(prefs.getString('halo_profile_avatar'), '/img/photo.jpg');
    });

    test('updateProfile without avatarPath preserves existing avatar', () {
      cubit.updateProfile('Bob', 'Sales', avatarPath: '/img/photo.jpg');
      cubit.updateProfile('Bobby', 'Sales lead');
      expect(cubit.state.profileAvatarPath, '/img/photo.jpg');
    });
  });
}
```

- [ ] **Step 2: Run tests to confirm they fail**

```bash
flutter test test/presentation/bloc/settings_cubit_test.dart
```

Expected: FAIL — `Target of URI doesn't exist: 'package:ai_app/presentation/bloc/settings_cubit.dart'`

- [ ] **Step 3: Create SettingsCubit**

Create `lib/presentation/bloc/settings_cubit.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;

  SettingsCubit(this._prefs) : super(SettingsState.initial());

  void loadSettings() {
    emit(SettingsState(
      profileName: _prefs.getString('halo_profile_name') ?? 'You',
      profileTagline:
          _prefs.getString('halo_profile_tagline') ?? 'Relationship intelligence',
      profileAvatarPath: _prefs.getString('halo_profile_avatar'),
      suggestionsEnabled: _prefs.getBool('halo_suggestions_enabled') ?? true,
      voiceEnabled: _prefs.getBool('halo_voice_enabled') ?? true,
      tone: _parseTone(_prefs.getString('halo_tone')),
      notificationsEnabled: _prefs.getBool('halo_notifications_enabled') ?? true,
      quietHoursStart: _parseTime(_prefs.getString('halo_quiet_start')) ??
          const TimeOfDay(hour: 22, minute: 0),
      quietHoursEnd: _parseTime(_prefs.getString('halo_quiet_end')) ??
          const TimeOfDay(hour: 7, minute: 0),
    ));
  }

  void updateProfile(String name, String tagline, {String? avatarPath}) {
    emit(state.copyWith(
      profileName: name,
      profileTagline: tagline,
      profileAvatarPath: avatarPath ?? state.profileAvatarPath,
    ));
    _prefs.setString('halo_profile_name', name);
    _prefs.setString('halo_profile_tagline', tagline);
    if (avatarPath != null) _prefs.setString('halo_profile_avatar', avatarPath);
  }

  void toggleSuggestions(bool value) {
    emit(state.copyWith(suggestionsEnabled: value));
    _prefs.setBool('halo_suggestions_enabled', value);
  }

  void toggleVoice(bool value) {
    emit(state.copyWith(voiceEnabled: value));
    _prefs.setBool('halo_voice_enabled', value);
  }

  void setTone(ResponseTone tone) {
    emit(state.copyWith(tone: tone));
    _prefs.setString('halo_tone', tone.name);
  }

  void toggleNotifications(bool value) {
    emit(state.copyWith(notificationsEnabled: value));
    _prefs.setBool('halo_notifications_enabled', value);
  }

  void setQuietHours(TimeOfDay start, TimeOfDay end) {
    emit(state.copyWith(quietHoursStart: start, quietHoursEnd: end));
    _prefs.setString('halo_quiet_start', _formatTime(start));
    _prefs.setString('halo_quiet_end', _formatTime(end));
  }

  static ResponseTone _parseTone(String? value) => ResponseTone.values.firstWhere(
        (t) => t.name == value,
        orElse: () => ResponseTone.balanced,
      );

  static TimeOfDay? _parseTime(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
```

- [ ] **Step 4: Run tests to confirm they pass**

```bash
flutter test test/presentation/bloc/settings_cubit_test.dart
```

Expected: All 10 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/bloc/settings_cubit.dart test/presentation/bloc/settings_cubit_test.dart
git commit -m "feat: add SettingsCubit with SharedPreferences persistence"
```

---

### Task 4: Wire Settings Navigation

**Files:**
- Modify: `lib/presentation/bloc/halo_event.dart` (line 3)
- Modify: `lib/presentation/bloc/halo_bloc.dart` (lines 88–94)

- [ ] **Step 1: Add `settings` to HaloScreen enum**

In `lib/presentation/bloc/halo_event.dart`, change line 3:

```dart
// Before:
enum HaloScreen { home, listen, note, contact, confirm, people }

// After:
enum HaloScreen { home, listen, note, contact, confirm, people, settings }
```

- [ ] **Step 2: Wire sliders tab to settings screen in HaloBloc**

In `lib/presentation/bloc/halo_bloc.dart`, replace `_onChangeNavTab` (lines 87–95):

```dart
void _onChangeNavTab(ChangeNavTab event, Emitter<HaloState> emit) {
  HaloScreen screen = state.screen;
  if (event.tab == NavTab.orb) {
    screen = HaloScreen.home;
  } else if (event.tab == NavTab.people) {
    screen = HaloScreen.people;
  } else if (event.tab == NavTab.sliders) {
    screen = HaloScreen.settings;
  }
  emit(state.copyWith(navTab: event.tab, screen: screen));
}
```

- [ ] **Step 3: Verify no analysis errors**

```bash
flutter analyze lib/presentation/bloc/
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/bloc/halo_event.dart lib/presentation/bloc/halo_bloc.dart
git commit -m "feat: wire NavTab.sliders to HaloScreen.settings"
```

---

### Task 5: Async DI — Wire SharedPreferences and SettingsCubit

**Files:**
- Modify: `lib/injection_container.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Make injection_container.dart async and register new dependencies**

Replace the entire contents of `lib/injection_container.dart`:

```dart
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/local/halo_local_datasource.dart';
import 'data/repositories/contact_repository_impl.dart';
import 'domain/repositories/contact_repository.dart';
import 'domain/usecases/get_contact.dart';
import 'domain/usecases/get_contacts.dart';
import 'domain/usecases/get_suggestions.dart';
import 'presentation/bloc/halo_bloc.dart';
import 'presentation/bloc/settings_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // Settings
  sl.registerLazySingleton(() => SettingsCubit(sl())..loadSettings());

  // Bloc — factory so each creation gets a fresh instance
  sl.registerFactory(
    () => HaloBloc(
      getContacts: sl(),
      getContact: sl(),
      getSuggestions: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetContacts(sl()));
  sl.registerLazySingleton(() => GetContact(sl()));
  sl.registerLazySingleton(() => GetSuggestions(sl()));

  // Repository — registered as the abstract type so use cases depend on the interface
  sl.registerLazySingleton<ContactRepository>(
    () => ContactRepositoryImpl(sl()),
  );

  // Data sources
  sl.registerLazySingleton<HaloLocalDataSource>(
    () => HaloLocalDataSourceImpl(),
  );
}
```

- [ ] **Step 2: Make main.dart async**

Replace the entire contents of `lib/main.dart`:

```dart
import 'package:flutter/material.dart';

import 'app.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const HaloApp());
}
```

- [ ] **Step 3: Verify**

```bash
flutter analyze lib/main.dart lib/injection_container.dart
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/injection_container.dart lib/main.dart
git commit -m "feat: async DI init, register SharedPreferences and SettingsCubit"
```

---

### Task 6: Wire App Shell

**Files:**
- Modify: `lib/app.dart`

- [ ] **Step 1: Update app.dart — MultiBlocProvider, showNav, _buildPage**

Replace the entire contents of `lib/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/colors.dart';
import 'injection_container.dart';
import 'presentation/bloc/halo_bloc.dart';
import 'presentation/bloc/halo_event.dart';
import 'presentation/bloc/halo_state.dart';
import 'presentation/bloc/settings_cubit.dart';
import 'presentation/pages/confirm_page.dart';
import 'presentation/pages/contact_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/listen_page.dart';
import 'presentation/pages/note_page.dart';
import 'presentation/pages/people_page.dart';
import 'presentation/pages/settings_page.dart';
import 'presentation/widgets/halo_nav_bar.dart';

class HaloApp extends StatelessWidget {
  const HaloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<HaloBloc>()..add(const AppStarted())),
        BlocProvider(create: (_) => sl<SettingsCubit>()),
      ],
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
        final showNav = state.screen == HaloScreen.home ||
            state.screen == HaloScreen.people ||
            state.screen == HaloScreen.settings;

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
      case HaloScreen.settings:
        return const SettingsPage(key: ValueKey('settings'));
    }
  }
}
```

- [ ] **Step 2: Verify (SettingsPage import will resolve after Task 7)**

```bash
flutter analyze lib/app.dart
```

Expected: One error about `SettingsPage` not found — that's expected at this point.

- [ ] **Step 3: Commit**

```bash
git add lib/app.dart
git commit -m "feat: MultiBlocProvider, wire settings screen into shell"
```

---

### Task 7: Create SettingsPage

**Files:**
- Create: `lib/presentation/pages/settings_page.dart`

- [ ] **Step 1: Create the file**

Create `lib/presentation/pages/settings_page.dart`:

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/colors.dart';
import '../bloc/halo_bloc.dart';
import '../bloc/halo_event.dart';
import '../bloc/halo_state.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HaloBloc, HaloState>(
      builder: (context, haloState) {
        final accent = getAccent(haloState.accent);
        return BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              children: [
                _Header(accent: accent),
                const SizedBox(height: 24),
                _ProfileCard(settings: settings, accent: accent),
                const SizedBox(height: 28),
                _sectionHeader('ACCENT'),
                const SizedBox(height: 12),
                _AccentRow(currentAccent: haloState.accent, accent: accent),
                const SizedBox(height: 28),
                _sectionHeader('AI BEHAVIOR'),
                const SizedBox(height: 12),
                _BehaviorSection(settings: settings, accent: accent),
                const SizedBox(height: 28),
                _sectionHeader('NOTIFICATIONS'),
                const SizedBox(height: 12),
                _NotificationSection(settings: settings, accent: accent),
              ],
            );
          },
        );
      },
    );
  }

  Widget _sectionHeader(String label) => Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Colors.white.withValues(alpha: 0.4),
        ),
      );
}

class _Header extends StatelessWidget {
  final AccentColors accent;
  const _Header({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Settings',
          style: GoogleFonts.fraunces(
            fontSize: 26,
            fontWeight: FontWeight.w500,
            color: Colors.white,
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
    final name = _nameCtrl.text.trim();
    context.read<SettingsCubit>().updateProfile(
      name.isEmpty ? 'You' : name,
      _taglineCtrl.text.trim(),
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
    final settings = widget.settings;
    final accent = widget.accent;
    final initials =
        (settings.profileName.isNotEmpty ? settings.profileName[0] : 'Y').toUpperCase();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
                        errorBuilder: (_, __, ___) =>
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
                    color: Colors.white,
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
                    color: Colors.white.withValues(alpha: 0.55),
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
  final AccentColors accent;

  const _AccentRow({required this.currentAccent, required this.accent});

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
    required this.label,
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.87),
          ),
        ),
        const Spacer(),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: accent.solid,
          activeTrackColor: accent.glow.withValues(alpha: 0.5),
          inactiveThumbColor: Colors.white.withValues(alpha: 0.4),
          inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
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
    return Row(
      children: [
        Text(
          'Response tone',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.87),
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
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
                      color: isActive ? kOnAccent : Colors.white.withValues(alpha: 0.5),
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
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.87),
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
```

- [ ] **Step 2: Verify full project analyzes clean**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/pages/settings_page.dart
git commit -m "feat: add SettingsPage with profile, accent, behavior, and notification sections"
```

---

### Task 8: Gate Suggestion Chips in HomePage

**Files:**
- Modify: `lib/presentation/pages/home_page.dart`

The suggestion chips block currently lives at lines 127–141 of `home_page.dart` inside a `BlocBuilder<HaloBloc, HaloState>`. Wrap it in a nested `BlocBuilder<SettingsCubit, SettingsState>` so it reacts to settings changes.

- [ ] **Step 1: Add import for SettingsCubit and SettingsState**

At the top of `lib/presentation/pages/home_page.dart`, add after the existing bloc imports:

```dart
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';
```

- [ ] **Step 2: Wrap suggestion chips in a SettingsCubit builder**

In `home_page.dart`, replace lines 127–141 (the `if (suggestions.isNotEmpty)` block):

```dart
// Before:
if (suggestions.isNotEmpty)
  SizedBox(
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
  ),

// After:
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
```

- [ ] **Step 3: Verify**

```bash
flutter analyze lib/presentation/pages/home_page.dart
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/pages/home_page.dart
git commit -m "feat: gate suggestion chips on SettingsCubit.suggestionsEnabled"
```

---

### Task 9: Gate Voice Mode in ListenPage

**Files:**
- Modify: `lib/presentation/pages/listen_page.dart`

When voice mode is disabled, the `LISTENING` label becomes `DEMO MODE` and a tap-to-settings banner appears below it. The transcript animation still runs (it's a demo app), but the user sees a clear indicator.

- [ ] **Step 1: Add imports**

At the top of `lib/presentation/pages/listen_page.dart`, add after the existing imports:

```dart
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';
```

- [ ] **Step 2: Wrap the status label in a SettingsCubit builder**

In `listen_page.dart`, replace lines 58–71 (the `Text('LISTENING', ...)` and `WaveBar` section):

```dart
// Before:
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

// After:
BlocBuilder<SettingsCubit, SettingsState>(
  builder: (context, settings) {
    return Column(
      children: [
        Text(
          settings.voiceEnabled ? 'LISTENING' : 'DEMO MODE',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: settings.voiceEnabled
                ? accent.line
                : Colors.white.withValues(alpha: 0.4),
            letterSpacing: 1.4,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (!settings.voiceEnabled) ...[
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => context
                .read<HaloBloc>()
                .add(const ChangeNavTab(NavTab.sliders)),
            child: Text(
              'Enable in Settings',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: accent.solid,
                decoration: TextDecoration.underline,
                decorationColor: accent.solid,
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        WaveBar(color: accent.line),
      ],
    );
  },
),
```

- [ ] **Step 3: Verify**

```bash
flutter analyze lib/presentation/pages/listen_page.dart
```

Expected: `No issues found!`

- [ ] **Step 4: Run all tests**

```bash
flutter test
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/pages/listen_page.dart
git commit -m "feat: show demo mode banner in ListenPage when voice mode disabled"
```

---

## Spec Coverage Check

| Spec requirement | Task |
|---|---|
| Profile: editable name, tagline, avatar with SharedPreferences | Tasks 2, 3, 7 |
| Accent selector dispatches ChangeAccent | Task 7 (_AccentRow) |
| Suggestion chips toggle | Tasks 3, 7, 8 |
| Voice mode toggle | Tasks 3, 7, 9 |
| Response tone selector (Concise/Balanced/Detailed) | Tasks 2, 3, 7 |
| Notifications master toggle + quiet hours | Tasks 2, 3, 7 |
| sliders tab navigates to settings screen | Task 4 |
| Nav bar visible on settings screen | Task 6 |
| SharedPreferences keys persist on every mutation | Task 3 |
| Async DI init | Task 5 |
| image_picker with error handling | Task 7 (_ProfileCardState._pickAvatar) |
| Avatar fallback to initials on load error | Task 7 (Image.file errorBuilder) |
| Quiet hours rows dimmed when notifications off | Task 7 (_NotificationSection Opacity) |
