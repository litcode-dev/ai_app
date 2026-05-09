import 'package:equatable/equatable.dart';

enum HaloScreen { home, listen, note, contact, confirm, people, settings }

enum ContactTab { timeline, reminders, details }

enum NavTab { orb, people, sliders }

abstract class HaloEvent extends Equatable {
  const HaloEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends HaloEvent {
  const AppStarted();
}

class LoadContacts extends HaloEvent {
  const LoadContacts();
}

class LoadSuggestions extends HaloEvent {
  const LoadSuggestions();
}

class SelectContact extends HaloEvent {
  final String contactName;
  const SelectContact(this.contactName);

  @override
  List<Object?> get props => [contactName];
}

class NavigateToScreen extends HaloEvent {
  final HaloScreen screen;
  const NavigateToScreen(this.screen);

  @override
  List<Object?> get props => [screen];
}

class ChangeAccent extends HaloEvent {
  final String accent;
  const ChangeAccent(this.accent);

  @override
  List<Object?> get props => [accent];
}

class ChangeContactTab extends HaloEvent {
  final ContactTab tab;
  const ChangeContactTab(this.tab);

  @override
  List<Object?> get props => [tab];
}

class ChangeNavTab extends HaloEvent {
  final NavTab tab;
  const ChangeNavTab(this.tab);

  @override
  List<Object?> get props => [tab];
}

class UpdateDraft extends HaloEvent {
  final String draft;
  const UpdateDraft(this.draft);

  @override
  List<Object?> get props => [draft];
}
