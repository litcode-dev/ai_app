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
      darkModeEnabled: _prefs.getBool('halo_dark_mode') ?? true,
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

  void toggleDarkMode(bool value) {
    emit(state.copyWith(darkModeEnabled: value));
    _prefs.setBool('halo_dark_mode', value);
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
