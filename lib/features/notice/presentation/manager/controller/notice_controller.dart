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
    // Listen for background updates without showing global loading spinner
    _busSub = _noticeBus.stream.listen((_) => refreshNotices(showLoading: false));
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

  /// Refreshes the notices list.
  /// [showLoading] determines if the global [isLoading] reactive variable should be updated.
  Future<void> refreshNotices({bool showLoading = true}) async {
    if (showLoading) {
      if (isLoading.value) return;
      isLoading.value = true;
    }
    
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
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  Future<void> fetchNotices() => refreshNotices();

  Future<bool> postNotice(String title, String description) async {
    // We don't set global isLoading here to avoid flickering the main screen list
    // The dialog manages its own local loading state
    try {
      final response = await _dioClient.post(
        ApiEndpoint.notices,
        data: {
          'title': title,
          'description': description,
        },
      );

      final created = NoticeModel.fromJson(
        response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : (response.data['notice'] as Map<String, dynamic>? ??
                response.data as Map<String, dynamic>),
      );

      // Insert locally for immediate feedback
      notices.insert(0, created);

      // Emit to the bus - this will trigger a full refresh in the background
      _noticeBus.emit(NoticeAddedEvent(created));

      return true;
    } catch (e) {
      return false;
    }
  }
}
