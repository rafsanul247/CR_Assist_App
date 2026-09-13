import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'core/network/dio_client.dart';
import 'core/network/network_info.dart';

import 'features/auth/data/data_sources/auth_data_source.dart';
import 'features/auth/data/repositories/auth_repository_implement.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/auth_usecase.dart';
import 'features/auth/presentation/manager/controller/auth_controller.dart';

import 'features/notice/data/data_sources/notice_data_source.dart';
import 'features/notice/data/repositories/notice_repository_implement.dart';
import 'features/notice/domain/repositories/notice_repository.dart';
import 'features/notice/domain/usecases/notice_usecase.dart';
import 'features/notice/presentation/manager/controller/notice_controller.dart';

import 'features/semesters/data/data_sources/semesters_data_source.dart';
import 'features/semesters/data/repositories/semesters_repository_implement.dart';
import 'features/semesters/domain/repositories/semesters_repository.dart';
import 'features/semesters/domain/usecases/semesters_usecase.dart';
import 'features/semesters/presentation/manager/controller/semesters_controller.dart';

import 'features/settings/data/data_sources/settings_data_source.dart';
import 'features/settings/data/repositories/settings_repository_implement.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/domain/usecases/settings_usecase.dart';
import 'features/settings/presentation/manager/controller/settings_controller.dart';
import 'core/event_bus/notice_bus.dart';
import 'package:get/get.dart';

import 'core/services/fcm_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  Get.put(NoticeBus());
  sl.registerLazySingleton<FcmService>(
    () => FcmService(dioClient: sl()),
  );
  _setUpCore();
  await _setUpAuth();
  await _setUpNotice();
  await _setUpSemesters();
  await _setUpSettings();
}

Future<void> initDependencies() async => init();

// Core: Shared resources for all features
void _setUpCore() {
  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);
  
  // Connectivity & Network Info
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfo(sl()));
}

Future<void> _setUpAuth() async {
  // Data Sources
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthDataSourceImplement(dioClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImplement(
      dataSource: sl(),
      networkInfo: sl(),
      dioClient: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => AuthUseCase(repository: sl()));


    // Controllers
    sl.registerFactory(() => AuthController());
    Get.lazyPut(() => sl<AuthController>());
}

Future<void> _setUpNotice() async {
  // Data Sources
  sl.registerLazySingleton<NoticeDataSource>(
    () => NoticeDataSourceImplement(dio: sl()),
  );

  // Repositories
  sl.registerLazySingleton<NoticeRepository>(
    () => NoticeRepositoryImplement(dataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => NoticeUseCase(repository: sl()));


    // Controllers
    sl.registerFactory(() => NoticeController());
    Get.lazyPut(() => sl<NoticeController>());
}

Future<void> _setUpSemesters() async {
  // Data Sources
  sl.registerLazySingleton<SemestersDataSource>(
    () => SemestersDataSourceImplement(dioClient: sl()),
  );

  // Repositories
  sl.registerLazySingleton<SemestersRepository>(
    () => SemestersRepositoryImplement(
      dataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => SemestersUseCase(repository: sl()));

  // Controllers
  sl.registerFactory(() => SemestersController());
  Get.lazyPut(() => sl<SemestersController>());
}

Future<void> _setUpSettings() async {
  // Data Sources
  sl.registerLazySingleton<SettingsDataSource>(
    () => SettingsDataSourceImplement(dio: sl()),
  );

  // Repositories
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImplement(dataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => SettingsUseCase(repository: sl()));


    // Controllers
    sl.registerFactory(() => SettingsController(sl()));
    Get.lazyPut(() => sl<SettingsController>());
}
