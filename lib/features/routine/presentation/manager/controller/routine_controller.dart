import 'package:cr_assist/core/error/exception_handler.dart';
import 'package:cr_assist/core/network/dio_client.dart';
import 'package:cr_assist/core/utils/api_endpoint.dart';
import 'package:cr_assist/features/routine/data/models/routine_models.dart';
import 'package:cr_assist/injection.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;

class RoutineController extends GetxController {
  final DioClient _dioClient = sl<DioClient>();

  final Rxn<RoutineToday> today = Rxn<RoutineToday>();
  final Rxn<RoutineSchedule> schedule = Rxn<RoutineSchedule>();
  final RxBool isTodayLoading = false.obs;
  final RxBool isScheduleLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString todayErrorMessage = ''.obs;
  final RxString scheduleErrorMessage = ''.obs;

  Future<void> fetchToday() async {
    isTodayLoading.value = true;
    try {
      final response = await _dioClient.get(ApiEndpoint.routineToday);
      today.value = RoutineToday.fromJson(_payload(response.data));
      todayErrorMessage.value = '';
    } catch (error) {
      todayErrorMessage.value = ExceptionHandler.handleException(error).message;
    } finally {
      isTodayLoading.value = false;
    }
  }

  Future<void> fetchSchedule() async {
    isScheduleLoading.value = true;
    try {
      final response = await _dioClient.get(ApiEndpoint.routine);
      schedule.value = RoutineSchedule.fromJson(_payload(response.data));
      scheduleErrorMessage.value = '';
    } catch (error) {
      scheduleErrorMessage.value = ExceptionHandler.handleException(error)
          .message;
    } finally {
      isScheduleLoading.value = false;
    }
  }

  Future<bool> uploadImage({
    required String type,
    required String title,
    required String filePath,
  }) async {
    return _runMutation(() async {
      final filename = filePath.split(RegExp(r'[/\\]')).last;
      final data = FormData.fromMap({
        'title': title,
        'type': type,
        'file': await MultipartFile.fromFile(filePath, filename: filename),
      });
      await _dioClient.post(ApiEndpoint.routineImage, data: data);
    });
  }

  Future<bool> deleteImage(String type) async => _runMutation(
    () => _dioClient.delete(
      ApiEndpoint.routineImage,
      queryParameters: {'type': type},
    ),
  );

  Future<bool> saveSlot({
    required bool exam,
    required Map<String, dynamic> values,
    int? slotId,
  }) async {
    final endpoint = exam ? ApiEndpoint.examSlots : ApiEndpoint.routineSlots;
    return _runMutation(() async {
      if (slotId == null) {
        await _dioClient.post(endpoint, data: values);
      } else {
        await _dioClient.put('$endpoint/$slotId', data: values);
      }
    });
  }

  Future<bool> deleteSlot({required bool exam, required int slotId}) async {
    final endpoint = exam ? ApiEndpoint.examSlots : ApiEndpoint.routineSlots;
    return _runMutation(() => _dioClient.delete('$endpoint/$slotId'));
  }

  Future<bool> sendTodayNotification() async =>
      _runMutation(() => _dioClient.post(ApiEndpoint.notifyToday));

  Future<bool> _runMutation(Future<dynamic> Function() action) async {
    isSaving.value = true;
    errorMessage.value = '';
    try {
      await action();
      await Future.wait([fetchSchedule(), fetchToday()]);
      return true;
    } catch (error) {
      errorMessage.value = ExceptionHandler.handleException(error).message;
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Map<String, dynamic> _payload(dynamic response) {
    if (response is! Map) {
      throw const FormatException('The routine response was not an object.');
    }
    var payload = Map<String, dynamic>.from(response);
    if (payload['data'] is Map) {
      payload = Map<String, dynamic>.from(payload['data'] as Map);
    }
    return payload;
  }
}
