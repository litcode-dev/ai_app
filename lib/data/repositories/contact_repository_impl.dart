import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasources/local/halo_local_datasource.dart';

class ContactRepositoryImpl implements ContactRepository {
  final HaloLocalDataSource _dataSource;

  const ContactRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Contact>>> getContacts() async {
    try {
      final models = await _dataSource.getContacts();
      return Right(models.map((m) => m.toDomain()).toList());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Contact>> getContactByName(String name) async {
    try {
      final model = await _dataSource.getContactByName(name);
      return Right(model.toDomain());
    } on Exception catch (e) {
      if (e.toString().contains('not found')) return const Left(NotFoundFailure());
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<String>>> getSuggestions() async {
    try {
      final suggestions = await _dataSource.getSuggestions();
      return Right(suggestions);
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
