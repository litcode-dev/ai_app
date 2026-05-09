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
