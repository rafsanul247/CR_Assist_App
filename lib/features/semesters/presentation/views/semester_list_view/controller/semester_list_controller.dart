import 'dart:async';

import 'package:cr_assist/core/event_bus/notice_bus.dart';
import 'package:cr_assist/features/notice/data/models/notice_model.dart';
import 'package:cr_assist/features/notice/presentation/manager/controller/notice_controller.dart';
import 'package:cr_assist/core/storage/storage_service.dart';
import 'package:cr_assist/core/utils/constant.dart';
import 'package:get/get.dart';

class SemesterListController extends GetxController {
  final NoticeBus _noticeBus = Get.find<NoticeBus>();

  final RxInt unreadNoticeCount = 0.obs;
  final Rxn<NoticeModel> latestNotice = Rxn<NoticeModel>();

  StreamSubscription<NoticeAddedEvent>? _busSub;

  @override
  void onInit() {
    super.onInit();
    unreadNoticeCount.value =
        StorageService.get<int>(Constants.keyUnreadNoticeCount) ?? 0;
    _busSub = _noticeBus.stream.listen((event) {
      latestNotice.value = event.notice;
      _setUnreadCount(unreadNoticeCount.value + 1);
    });
  }

  void clearUnreadBadge() {
    _setUnreadCount(0);
  }

  void _setUnreadCount(int count) {
    unreadNoticeCount.value = count;
    StorageService.set(Constants.keyUnreadNoticeCount, count);
  }

  @override
  void onClose() {
    _busSub?.cancel();
    super.onClose();
  }

  /// Reuse the same NoticeController that drives the Notices screen so
  /// pulling/refresh on home actually hits the same list.
  NoticeController get notices => Get.find<NoticeController>();
}
