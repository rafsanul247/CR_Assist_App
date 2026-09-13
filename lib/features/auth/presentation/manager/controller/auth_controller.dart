import 'package:cr_assist/core/routes/app_router.dart';
import 'package:cr_assist/core/services/fcm_service.dart';
import 'package:cr_assist/core/storage/storage_service.dart';
import 'package:cr_assist/core/utils/constant.dart';
import 'package:cr_assist/features/auth/domain/entities/auth_entity.dart';
import 'package:cr_assist/features/auth/domain/usecases/auth_usecase.dart';
import 'package:cr_assist/injection.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthUseCase _useCase = sl<AuthUseCase>();
  final FcmService _fcmService = sl<FcmService>();

  final Rxn<UserEntity> user = Rxn<UserEntity>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  bool get isCR {
    final role = user.value?.role ?? StorageService.get<String>(Constants.keyUserRole);
    return role?.toUpperCase() == 'CR';
  }

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  void _loadUserFromStorage() {
    final token = StorageService.get<String>(Constants.keyAuthToken);
    final role = StorageService.get<String>(Constants.keyUserRole);
    final id = StorageService.get<int>(Constants.keyUserId);

    if (token != null && role != null && id != null) {
      user.value = UserEntity(
        id: id,
        username: StorageService.get<String>(Constants.keyUserName) ?? '',
        email: StorageService.get<String>(Constants.keyUserEmail) ?? '',
        role: role,
        batchId: StorageService.get<int>(Constants.keyUserBatchId) ?? 0,
        deptName: StorageService.get<String>(Constants.keyUserDeptName) ?? '',
        batchName: StorageService.get<String>(Constants.keyUserBatchName) ?? '',
        universityName:
        StorageService.get<String>(Constants.keyUserUniversityName) ?? '',
      );
      // অ্যাপ স্টার্ট হওয়ার সময় সাবস্ক্রিপশন নিশ্চিত করা
      _syncNotifications(user.value!);
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await _useCase.login(email: email, password: password);
    result.fold(
          (failure) => errorMessage.value = failure.message,
          (userData) {
        user.value = userData;
        _syncNotifications(userData);
        AppRouter.go('/main');
      },
    );
    isLoading.value = false;
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String universityName,
    required String deptName,
    required String batchName,
    required bool isCR,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await _useCase.register(
      username: username,
      email: email,
      password: password,
      universityName: universityName,
      deptName: deptName,
      batchName: batchName,
      isCR: isCR,
    );
    result.fold(
          (failure) => errorMessage.value = failure.message,
          (userData) {
        user.value = userData;
        _syncNotifications(userData);
        AppRouter.go('/main');
      },
    );
    isLoading.value = false;
  }

  Future<void> logout() async {
    await _useCase.logout();
    await _fcmService.dispose();
    user.value = null;
    AppRouter.go('/login');
  }

  Future<void> _syncNotifications(UserEntity userData) async {
    try {
      await _fcmService.syncTokenWithBackend(
        batchId: userData.batchId,
        role: userData.role,
        universityName: userData.universityName,
        deptName: userData.deptName,
        batchName: userData.batchName,
      );
    } catch (error, stackTrace) {
      debugPrint('[FCM] login notification setup failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
