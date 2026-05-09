import 'package:equatable/equatable.dart';

import '../../domain/entities/contact.dart';
import 'halo_event.dart';

const _kInitialDraft =
    'Sarah Logan told her brother-in-law Tom is the new CTO of a major hospital network. '
    'Potential healthcare entry. Follow up in two weeks after my vacation.';

class HaloState extends Equatable {
  final HaloScreen screen;
  final String accent;
  final ContactTab contactTab;
  final NavTab navTab;
  final String draft;
  final List<Contact> contacts;
  final Contact? selectedContact;
  final List<String> suggestions;
  final bool isLoading;
  final String? error;

  const HaloState({
    required this.screen,
    required this.accent,
    required this.contactTab,
    required this.navTab,
    required this.draft,
    required this.contacts,
    required this.suggestions,
    this.selectedContact,
    this.isLoading = false,
    this.error,
  });

  factory HaloState.initial() => const HaloState(
    screen: HaloScreen.home,
    accent: 'fern',
    contactTab: ContactTab.timeline,
    navTab: NavTab.orb,
    draft: _kInitialDraft,
    contacts: [],
    suggestions: [],
    isLoading: true,
  );

  HaloState copyWith({
    HaloScreen? screen,
    String? accent,
    ContactTab? contactTab,
    NavTab? navTab,
    String? draft,
    List<Contact>? contacts,
    Contact? selectedContact,
    List<String>? suggestions,
    bool? isLoading,
    String? error,
  }) {
    return HaloState(
      screen: screen ?? this.screen,
      accent: accent ?? this.accent,
      contactTab: contactTab ?? this.contactTab,
      navTab: navTab ?? this.navTab,
      draft: draft ?? this.draft,
      contacts: contacts ?? this.contacts,
      selectedContact: selectedContact ?? this.selectedContact,
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    screen,
    accent,
    contactTab,
    navTab,
    draft,
    contacts,
    selectedContact,
    suggestions,
    isLoading,
    error,
  ];
}
