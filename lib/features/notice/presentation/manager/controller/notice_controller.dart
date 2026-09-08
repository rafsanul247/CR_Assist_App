import 'dart:async';

import 'package:cr_assist/core/event_bus/notice_bus.dart';
import 'package:cr_assist/core/network/dio_client.dart';
import 'package:cr_assist/core/utils/api_endpoint.dart';
import 'package:cr_assist/features/auth/domain/usecases/auth_usecase.dart';
import 'package:cr_assist/features/notice/data/models/notice_model.dart';
import 'package:cr_assist/injection.dart';
import 'package:get/get.dart';

class NoticeController extends GetxController {
  final AuthUseCase _authUseCase = sl<AuthUseCase>();
  final DioClient _dioClient = sl<DioClient>();
  final NoticeBus _noticeBus = Get.find<NoticeBus>();

  final RxString classCode = ''.obs;
  final RxList<NoticeModel> notices = <NoticeModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription<NoticeAddedEvent>? _busSub;

  @override
  void onInit() {
    super.onInit();
    fetchNotices();
    // Listen for "a notice was just posted" broadcasts so this controller
    // (and the UI it drives) refreshes without polling, regardless of who
    // posted it (this device or any other client in the same batch).
    _busSub = _noticeBus.stream.listen((_) => refreshNotices());
  }

  @override
  void onClose() {
    _busSub?.cancel();
    super.onClose();
  }

  Future<void> fetchMyClassCode() async {
    final result = await _authUseCase.getMyClassCode();
    result.fold(
          (failure) => null,
          (code) => classCode.value = code,
    );
  }

  Future<void> refreshNotices() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _dioClient.get(ApiEndpoint.notices);
      final List<dynamic> data = response.data as List<dynamic>;
      notices.assignAll(
        data.map((json) => NoticeModel.fromJson(json)).toList(),
      );
    } catch (e) {
      errorMessage.value = "Failed to fetch notices";
    } finally {
      isLoading.value = false;
    }
  }

  /// Backwards-compatible alias used by the AppBar refresh icon and
  /// anywhere else that previously called fetchNotices().
  Future<void> fetchNotices() => refreshNotices();

  Future<bool> postNotice(String title, String description) async {
    isLoading.value = true;
    try {
      final response = await _dioClient.post(
        ApiEndpoint.notices,
        data: {
          'title': title,
          'description': description,
        },
      );

      // Build the new notice model straight from the POST response so we
      // can hand it to the bus without an extra GET round-trip.
      final created = NoticeModel.fromJson(
        response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : (response.data['notice'] as Map<String, dynamic>? ??
            response.data as Map<String, dynamic>),
      );

      // Refresh this controller's list locally (the user who posted).
      await refreshNotices();

      // Notify every other mounted controller (other devices, other
      // screens, students in the same batch) that a notice just landed.
      _noticeBus.emit(NoticeAddedEvent(created));

      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
