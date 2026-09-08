import 'dart:async';
import 'package:cr_assist/core/event_bus/notice_bus.dart';
import 'package:cr_assist/features/notice/data/models/notice_model.dart';
import 'package:cr_assist/features/notice/presentation/manager/controller/notice_controller.dart';
import 'package:get/get.dart';

class SemesterListController extends GetxController {
  final NoticeBus _noticeBus = Get.find<NoticeBus>();

  final RxInt unreadNoticeCount = 0.obs;
  final Rxn<NoticeModel> latestNotice = Rxn<NoticeModel>();

  StreamSubscription<NoticeAddedEvent>? _busSub;

  @override
  void onInit() {
    super.onInit();
    _busSub = _noticeBus.stream.listen((event) {
      latestNotice.value = event.notice;
      unreadNoticeCount.value += 1;
    });
  }

  void clearUnreadBadge() {
    unreadNoticeCount.value = 0;
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
