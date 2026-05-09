import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/usecases/usecase.dart';
import '../../domain/usecases/get_contact.dart';
import '../../domain/usecases/get_contacts.dart';
import '../../domain/usecases/get_suggestions.dart';
import 'halo_event.dart';
import 'halo_state.dart';

class HaloBloc extends Bloc<HaloEvent, HaloState> {
  final GetContacts _getContacts;
  final GetContact _getContact;
  final GetSuggestions _getSuggestions;

  HaloBloc({
    required GetContacts getContacts,
    required GetContact getContact,
    required GetSuggestions getSuggestions,
  })  : _getContacts = getContacts,
        _getContact = getContact,
        _getSuggestions = getSuggestions,
        super(HaloState.initial()) {
    on<AppStarted>(_onAppStarted);
    on<LoadContacts>(_onLoadContacts);
    on<LoadSuggestions>(_onLoadSuggestions);
    on<SelectContact>(_onSelectContact);
    on<NavigateToScreen>(_onNavigate);
    on<ChangeAccent>(_onChangeAccent);
    on<ChangeContactTab>(_onChangeContactTab);
    on<ChangeNavTab>(_onChangeNavTab);
    on<UpdateDraft>(_onUpdateDraft);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<HaloState> emit) async {
    emit(state.copyWith(isLoading: true));
    await Future.wait([
      _loadContacts(emit),
      _loadSuggestions(emit),
    ]);
    emit(state.copyWith(isLoading: false));
  }

  Future<void> _onLoadContacts(LoadContacts event, Emitter<HaloState> emit) =>
      _loadContacts(emit);

  Future<void> _onLoadSuggestions(LoadSuggestions event, Emitter<HaloState> emit) =>
      _loadSuggestions(emit);

  Future<void> _loadContacts(Emitter<HaloState> emit) async {
    final result = await _getContacts(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (contacts) => emit(state.copyWith(contacts: contacts)),
    );
  }

  Future<void> _loadSuggestions(Emitter<HaloState> emit) async {
    final result = await _getSuggestions(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (suggestions) => emit(state.copyWith(suggestions: suggestions)),
    );
  }

  Future<void> _onSelectContact(SelectContact event, Emitter<HaloState> emit) async {
    final result = await _getContact(GetContactParams(event.contactName));
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (contact) => emit(
        state.copyWith(selectedContact: contact, screen: HaloScreen.contact),
      ),
    );
  }

  void _onNavigate(NavigateToScreen event, Emitter<HaloState> emit) {
    emit(state.copyWith(screen: event.screen));
  }

  void _onChangeAccent(ChangeAccent event, Emitter<HaloState> emit) {
    emit(state.copyWith(accent: event.accent));
  }

  void _onChangeContactTab(ChangeContactTab event, Emitter<HaloState> emit) {
    emit(state.copyWith(contactTab: event.tab));
  }

  void _onChangeNavTab(ChangeNavTab event, Emitter<HaloState> emit) {
    HaloScreen screen = state.screen;
    if (event.tab == NavTab.orb) {
      screen = HaloScreen.home;
    } else if (event.tab == NavTab.people) {
      screen = HaloScreen.people;
    }
    emit(state.copyWith(navTab: event.tab, screen: screen));
  }

  void _onUpdateDraft(UpdateDraft event, Emitter<HaloState> emit) {
    emit(state.copyWith(draft: event.draft));
  }
}
