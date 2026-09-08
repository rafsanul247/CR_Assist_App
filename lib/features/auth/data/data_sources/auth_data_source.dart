import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/api_endpoint.dart';
import '../../../../core/error/exception_handler.dart';
import '../models/auth_model.dart';

class AuthResult {
  final UserModel user;
  final String token;
  AuthResult({required this.user, required this.token});
}

abstract class AuthDataSource {
  Future<AuthResult> login({required String email, required String password});
  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
    required String universityName,
    required String deptName,
    required String batchName,
    required bool isCR,
    String? classCode,
  });
  Future<String> getMyClassCode();
}

class AuthDataSourceImplement implements AuthDataSource {
  final DioClient dioClient;
  AuthDataSourceImplement({required this.dioClient});

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    try {
      final response = await dioClient.post(
        ApiEndpoint.login,
        data: {'email': email, 'password': password},
      );
      return AuthResult(
        user: UserModel.fromJson(response.data['user']),
        token: response.data['token'] as String,
      );
    } catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  @override
  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
    required String universityName,
    required String deptName,
    required String batchName,
    required bool isCR,
    String? classCode,
  }) async {
    try {
      // Backend expects these exact keys to save in Database
      final response = await dioClient.post(
        ApiEndpoint.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'universityName': universityName,
          'deptName': deptName,
          'batchName': batchName,
          'isCR': isCR, // Sending as boolean
          'role': isCR ? 'CR' : 'STUDENT',
          'classCode': classCode, // Null if CR, value if Student
        },
      );
      return AuthResult(
        user: UserModel.fromJson(response.data['user']),
        token: response.data['token'] as String,
      );
    } catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }

  @override
  Future<String> getMyClassCode() async {
    try {
      final response = await dioClient.get(ApiEndpoint.myClassCode);
      return response.data['classCode'] as String;
    } catch (e) {
      throw ExceptionHandler.handleException(e);
    }
  }
}
