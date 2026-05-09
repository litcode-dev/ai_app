import 'package:get_it/get_it.dart';

import 'data/datasources/local/halo_local_datasource.dart';
import 'data/repositories/contact_repository_impl.dart';
import 'domain/repositories/contact_repository.dart';
import 'domain/usecases/get_contact.dart';
import 'domain/usecases/get_contacts.dart';
import 'domain/usecases/get_suggestions.dart';
import 'presentation/bloc/halo_bloc.dart';

final sl = GetIt.instance;

void initDependencies() {
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
