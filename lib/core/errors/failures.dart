abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure() : super('Not found');
}

class ServerFailure extends Failure {
  const ServerFailure() : super('Server error');
}
