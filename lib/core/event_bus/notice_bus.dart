import 'dart:async';

import 'package:cr_assist/features/notice/data/models/notice_model.dart';

class NoticeAddedEvent {
  final NoticeModel notice;
  NoticeAddedEvent(this.notice);
}

class NoticeBus {
  final _controller = StreamController<NoticeAddedEvent>.broadcast();

  Stream<NoticeAddedEvent> get stream => _controller.stream;

  void emit(NoticeAddedEvent event) {
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}
