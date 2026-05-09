import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/contact.dart';
import '../repositories/contact_repository.dart';

class GetContacts implements UseCase<List<Contact>, NoParams> {
  final ContactRepository _repository;

  const GetContacts(this._repository);

  @override
  Future<Either<Failure, List<Contact>>> call(NoParams params) {
    return _repository.getContacts();
  }
}
