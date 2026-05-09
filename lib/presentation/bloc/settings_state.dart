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
  final bool darkModeEnabled;

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
    required this.darkModeEnabled,
  });

  factory SettingsState.initial() => const SettingsState(
    profileName:          'You',
    profileTagline:       'Relationship intelligence',
    profileAvatarPath:    null,
    suggestionsEnabled:   true,
    voiceEnabled:         true,
    tone:                 ResponseTone.balanced,
    notificationsEnabled: true,
    quietHoursStart:      TimeOfDay(hour: 22, minute: 0),
    quietHoursEnd:        TimeOfDay(hour: 7, minute: 0),
    darkModeEnabled:      true,
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
    bool? darkModeEnabled,
  }) {
    return SettingsState(
      profileName:          profileName          ?? this.profileName,
      profileTagline:       profileTagline       ?? this.profileTagline,
      profileAvatarPath:    identical(profileAvatarPath, _kSentinel)
                              ? this.profileAvatarPath
                              : profileAvatarPath as String?,
      suggestionsEnabled:   suggestionsEnabled   ?? this.suggestionsEnabled,
      voiceEnabled:         voiceEnabled         ?? this.voiceEnabled,
      tone:                 tone                 ?? this.tone,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      quietHoursStart:      quietHoursStart      ?? this.quietHoursStart,
      quietHoursEnd:        quietHoursEnd        ?? this.quietHoursEnd,
      darkModeEnabled:      darkModeEnabled      ?? this.darkModeEnabled,
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
    darkModeEnabled,
  ];
}
