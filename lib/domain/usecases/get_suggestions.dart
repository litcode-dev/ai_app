import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/contact_repository.dart';

class GetSuggestions implements UseCase<List<String>, NoParams> {
  final ContactRepository _repository;

  const GetSuggestions(this._repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) {
    return _repository.getSuggestions();
  }
}
