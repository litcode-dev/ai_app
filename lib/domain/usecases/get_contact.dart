import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/contact.dart';
import '../repositories/contact_repository.dart';

class GetContactParams {
  final String name;
  const GetContactParams(this.name);
}

class GetContact implements UseCase<Contact, GetContactParams> {
  final ContactRepository _repository;

  const GetContact(this._repository);

  @override
  Future<Either<Failure, Contact>> call(GetContactParams params) {
    return _repository.getContactByName(params.name);
  }
}
