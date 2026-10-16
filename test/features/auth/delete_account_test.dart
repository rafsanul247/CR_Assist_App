import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cr_assist/core/common/delete_account_dialog.dart';
import 'package:cr_assist/core/error/failures.dart';
import 'package:cr_assist/core/network/dio_client.dart';
import 'package:cr_assist/core/network/network_info.dart';
import 'package:cr_assist/core/services/fcm_service.dart';
import 'package:cr_assist/core/storage/storage_service.dart';
import 'package:cr_assist/core/utils/api_endpoint.dart';
import 'package:cr_assist/core/utils/constant.dart';
import 'package:cr_assist/features/auth/data/data_sources/auth_data_source.dart';
import 'package:cr_assist/features/auth/data/repositories/auth_repository_implement.dart';
import 'package:cr_assist/features/auth/domain/entities/auth_entity.dart';
import 'package:cr_assist/features/auth/domain/repositories/auth_repository.dart';
import 'package:cr_assist/features/auth/domain/usecases/auth_usecase.dart';
import 'package:cr_assist/features/auth/presentation/manager/controller/auth_controller.dart';
import 'package:cr_assist/injection.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:hive_flutter/hive_flutter.dart';

class _FakeDioClient extends DioClient {
  String? lastDeletedPath;
  Options? lastDeletedOptions;

  @override
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    lastDeletedPath = path;
    lastDeletedOptions = options;
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: {'message': 'Account deleted successfully'},
    );
  }
}

class _FakeNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;

  @override
  Stream<bool> get onConnectivityChanged => Stream.value(true);
}

class _FakeAuthDataSource implements AuthDataSource {
  bool deleteAccountCalled = false;

  @override
  Future<void> deleteAccount() async {
    deleteAccountCalled = true;
  }

  @override
  Future<String> getMyClassCode() async => 'CODE123';

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    throw UnimplementedError();
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
    throw UnimplementedError();
  }
}

class _FakeFcmService extends FcmService {
  _FakeFcmService() : super(dioClient: _FakeDioClient(), messaging: null);

  bool unsubscribed = false;
  bool disposed = false;

  @override
  Future<void> unsubscribeFromCurrentTopic() async {
    unsubscribed = true;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => tempDir.path,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider_windows'),
      (MethodCall methodCall) async => tempDir.path,
    );
    await StorageService.init();
  });

  tearDownAll(() async {
    await StorageService.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    await StorageService.clear();
    Get.reset();
  });

  group('Delete Account API & Architecture', () {
    test('AuthDataSourceImplement calls delete with correct endpoint and header', () async {
      final fakeDio = _FakeDioClient();
      await StorageService.set(Constants.keyAuthToken, 'test-jwt-token');

      final dataSource = AuthDataSourceImplement(dioClient: fakeDio);
      await dataSource.deleteAccount();

      expect(fakeDio.lastDeletedPath, ApiEndpoint.deleteAccount);
      expect(fakeDio.lastDeletedPath, '/auth/delete-account');
      expect(fakeDio.lastDeletedOptions?.headers?['Authorization'], 'Bearer test-jwt-token');
    });

    test('AuthRepositoryImplement clears session storage on deleteAccount success', () async {
      final fakeDataSource = _FakeAuthDataSource();
      final fakeDio = _FakeDioClient();
      final repo = AuthRepositoryImplement(
        dataSource: fakeDataSource,
        networkInfo: _FakeNetworkInfo(),
        dioClient: fakeDio,
      );

      await StorageService.set(Constants.keyAuthToken, 'token-123');
      await StorageService.set(Constants.keyUserId, 42);
      await StorageService.set(Constants.keyUserRole, 'CR');
      await StorageService.set(Constants.keyUserName, 'John Doe');
      await StorageService.set(Constants.keyUserEmail, 'john@example.com');
      await StorageService.set(Constants.keyUserBatchId, 10);
      await StorageService.set(Constants.keyUserDeptName, 'CSE');
      await StorageService.set(Constants.keyUserBatchName, 'Batch 52');
      await StorageService.set(Constants.keyUserUniversityName, 'Leading Univ');
      await StorageService.set(Constants.keyUnreadNoticeCount, 5);

      final result = await repo.deleteAccount();

      expect(result.isRight(), true);
      expect(fakeDataSource.deleteAccountCalled, true);
      expect(StorageService.containsKey(Constants.keyAuthToken), false);
      expect(StorageService.containsKey(Constants.keyUserId), false);
      expect(StorageService.containsKey(Constants.keyUserRole), false);
      expect(StorageService.containsKey(Constants.keyUserName), false);
      expect(StorageService.containsKey(Constants.keyUserEmail), false);
      expect(StorageService.containsKey(Constants.keyUserBatchId), false);
      expect(StorageService.containsKey(Constants.keyUserDeptName), false);
      expect(StorageService.containsKey(Constants.keyUserBatchName), false);
      expect(StorageService.containsKey(Constants.keyUserUniversityName), false);
      expect(StorageService.containsKey(Constants.keyUnreadNoticeCount), false);
    });

    test('AuthUseCase delegates deleteAccount to repository', () async {
      final fakeDataSource = _FakeAuthDataSource();
      final fakeDio = _FakeDioClient();
      final repo = AuthRepositoryImplement(
        dataSource: fakeDataSource,
        networkInfo: _FakeNetworkInfo(),
        dioClient: fakeDio,
      );
      final useCase = AuthUseCase(repository: repo);

      final result = await useCase.deleteAccount();

      expect(result.isRight(), true);
      expect(fakeDataSource.deleteAccountCalled, true);
    });
  });

  group('DeleteAccountDialog UI & Role Warnings', () {
    testWidgets('displays CR-specific warning message when user is CR', (tester) async {
      // Setup sl
      if (sl.isRegistered<AuthUseCase>()) sl.unregister<AuthUseCase>();
      if (sl.isRegistered<FcmService>()) sl.unregister<FcmService>();

      final fakeDataSource = _FakeAuthDataSource();
      final fakeDio = _FakeDioClient();
      final repo = AuthRepositoryImplement(
        dataSource: fakeDataSource,
        networkInfo: _FakeNetworkInfo(),
        dioClient: fakeDio,
      );
      sl.registerLazySingleton<AuthUseCase>(() => AuthUseCase(repository: repo));
      final fakeFcm = _FakeFcmService();
      sl.registerLazySingleton<FcmService>(() => fakeFcm);

      final authController = Get.put(AuthController());
      authController.user.value = const UserEntity(
        id: 1,
        username: 'CR User',
        email: 'cr@test.com',
        role: 'CR',
        batchId: 10,
        deptName: 'CSE',
        batchName: '52',
        universityName: 'LU',
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: DeleteAccountDialog(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Delete Account?'), findsOneWidget);
      expect(
        find.text(
          'Warning: As a CR, deleting your account will permanently delete your entire batch and all associated classes, routines, resources, and student data.',
        ),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.byIcon(Icons.delete_forever), findsOneWidget);
    });

    testWidgets('displays Student warning message when user is Student', (tester) async {
      if (sl.isRegistered<AuthUseCase>()) sl.unregister<AuthUseCase>();
      if (sl.isRegistered<FcmService>()) sl.unregister<FcmService>();

      final fakeDataSource = _FakeAuthDataSource();
      final fakeDio = _FakeDioClient();
      final repo = AuthRepositoryImplement(
        dataSource: fakeDataSource,
        networkInfo: _FakeNetworkInfo(),
        dioClient: fakeDio,
      );
      sl.registerLazySingleton<AuthUseCase>(() => AuthUseCase(repository: repo));
      final fakeFcm = _FakeFcmService();
      sl.registerLazySingleton<FcmService>(() => fakeFcm);

      final authController = Get.put(AuthController());
      authController.user.value = const UserEntity(
        id: 2,
        username: 'Student User',
        email: 'student@test.com',
        role: 'STUDENT',
        batchId: 10,
        deptName: 'CSE',
        batchName: '52',
        universityName: 'LU',
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: DeleteAccountDialog(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Delete Account?'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete your account? This action cannot be undone.'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
  });
}
