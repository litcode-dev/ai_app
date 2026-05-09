import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/contact.dart';

abstract class ContactRepository {
  Future<Either<Failure, List<Contact>>> getContacts();
  Future<Either<Failure, Contact>> getContactByName(String name);
  Future<Either<Failure, List<String>>> getSuggestions();
}
