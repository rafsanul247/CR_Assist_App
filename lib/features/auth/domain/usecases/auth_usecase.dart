import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class AuthUseCase {
  final AuthRepository repository;

  AuthUseCase({required this.repository});

  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    return await repository.login(email: email, password: password);
  }

  Future<Either<Failure, UserEntity>> register({
    required String username,
    required String email,
    required String password,
    required String universityName,
    required String deptName,
    required String batchName,
    required bool isCR,
    String? classCode,
  }) async {
    return await repository.register(
      username: username,
      email: email,
      password: password,
      universityName: universityName,
      deptName: deptName,
      batchName: batchName,
      isCR: isCR,
      classCode: classCode,
    );
  }

  Future<Either<Failure, void>> logout() async {
    return await repository.logout();
  }

  Future<bool> isLoggedIn() async {
    return await repository.isLoggedIn();
  }

  Future<Either<Failure, String>> getMyClassCode() async {
    return await repository.getMyClassCode();
  }
}
