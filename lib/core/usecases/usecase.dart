import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class UseCase<Out, Params> {
  Future<Either<Failure, Out>> call(Params params);
}

class NoParams {
  const NoParams();
}
