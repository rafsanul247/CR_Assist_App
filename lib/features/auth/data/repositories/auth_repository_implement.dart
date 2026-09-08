import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/utils/constant.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_data_source.dart';

class AuthRepositoryImplement implements AuthRepository {
  final AuthDataSource dataSource;
  final NetworkInfo networkInfo;
  final DioClient dioClient;

  AuthRepositoryImplement({
    required this.dataSource,
    required this.networkInfo,
    required this.dioClient,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final result = await dataSource.login(email: email, password: password);
      await _persistSession(result.token, result.user);
      return Right(result.user);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
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
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final result = await dataSource.register(
        username: username,
        email: email,
        password: password,
        universityName: universityName,
        deptName: deptName,
        batchName: batchName,
        isCR: isCR,
        classCode: classCode,
      );
      await _persistSession(result.token, result.user);
      return Right(result.user);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    dioClient.clearAuthToken();
    await StorageService.delete(Constants.keyAuthToken);
    await StorageService.delete(Constants.keyUserId);
    await StorageService.delete(Constants.keyUserRole);
    await StorageService.delete(Constants.keyUserName);
    await StorageService.delete(Constants.keyUserEmail);
    await StorageService.delete(Constants.keyUserBatchId);
    await StorageService.delete(Constants.keyUserDeptName);
    await StorageService.delete(Constants.keyUserBatchName);
    await StorageService.delete(Constants.keyUserUniversityName);
    return const Right(null);
  }

  @override
  Future<bool> isLoggedIn() async {
    return StorageService.containsKey(Constants.keyAuthToken);
  }

  @override
  Future<Either<Failure, String>> getMyClassCode() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final code = await dataSource.getMyClassCode();
      return Right(code);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  Future<void> _persistSession(String token, UserEntity user) async {
    await StorageService.set(Constants.keyAuthToken, token);
    await StorageService.set(Constants.keyUserId, user.id);
    await StorageService.set(Constants.keyUserRole, user.role);
    await StorageService.set(Constants.keyUserName, user.username);
    await StorageService.set(Constants.keyUserEmail, user.email);
    await StorageService.set(Constants.keyUserBatchId, user.batchId);
    await StorageService.set(Constants.keyUserDeptName, user.deptName);
    await StorageService.set(Constants.keyUserBatchName, user.batchName);
    await StorageService.set(Constants.keyUserUniversityName, user.universityName);
    dioClient.setAuthToken(token);
  }

  Failure _mapExceptionToFailure(AppException e) {
    if (e is ServerException) return ServerFailure(e.message);
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is TimeoutException) return ServerFailure(e.message);
    if (e is AuthException) return AuthFailure(e.message);
    return UnknownFailure(e.message);
  }
}
