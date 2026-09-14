import 'package:cr_assist/core/constants/colors.dart';
import 'package:cr_assist/core/common/app_feedback.dart';
import 'package:cr_assist/features/auth/presentation/manager/controller/auth_controller.dart';
import 'package:cr_assist/features/notice/data/models/notice_model.dart';
import 'package:cr_assist/features/notice/presentation/manager/controller/notice_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  late final AuthController authController;
  late final NoticeController noticeController;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();
    noticeController = Get.find<NoticeController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && authController.isCR) {
        noticeController.fetchMyClassCode();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UColors.dark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: UColors.textPrimary),
          onPressed: () => context.goNamed('main'),
        ),
        title: const Text("Notices",
            style: TextStyle(color: UColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => noticeController.refreshNotices(),
            icon: const Icon(Iconsax.refresh, color: Colors.white, size: 20),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (authController.isCR) ...[
                _buildClassCodeCard(context, noticeController),
                SizedBox(height: 24.h),
              ],
              Text(
                "RECENT NOTICES",
                style: TextStyle(
                    color: UColors.primary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: Obx(() {
                  if (noticeController.isLoading.value && noticeController.notices.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: UColors.primary));
                  }
                  if (noticeController.notices.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => noticeController.refreshNotices(),
                      color: UColors.primary,
                      backgroundColor: UColors.containerDark,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 80.h),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Iconsax.notification_bing,
                                    color: UColors.textSecondary.withValues(alpha: 0.3), size: 48),
                                SizedBox(height: 16.h),
                                const Text("No notices yet",
                                    style: TextStyle(color: UColors.textSecondary)),
                                SizedBox(height: 8.h),
                                const Text("Pull down to refresh",
                                    style: TextStyle(color: UColors.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => noticeController.refreshNotices(),
                    color: UColors.primary,
                    backgroundColor: UColors.containerDark,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: noticeController.notices.length,
                      separatorBuilder: (context, index) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final notice = noticeController.notices[index];
                        final isNew = index == 0 &&
                            DateTime.now().difference(notice.createdAt).inHours < 24;
                        return _buildNoticeCard(notice, isNew: isNew);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: authController.isCR
          ? FloatingActionButton.extended(
              onPressed: () => _showAddNoticeDialog(context, noticeController),
              backgroundColor: UColors.primary,
              icon: const Icon(Iconsax.add, color: Colors.white),
              label: const Text("New Notice",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildNoticeCard(NoticeModel notice, {bool isNew = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isNew ? null : UColors.containerDark,
        gradient: isNew
            ? LinearGradient(
                colors: [
                  UColors.primary.withValues(alpha: 0.15),
                  UColors.accent.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNew
              ? UColors.primary.withValues(alpha: 0.8)
              : UColors.borderDark.withValues(alpha: 0.5),
          width: isNew ? 1.5 : 1,
        ),
        boxShadow: isNew
            ? [
                BoxShadow(
                  color: UColors.primary.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              if (isNew)
                Container(
                  width: 4,
                  color: UColors.primary,
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (isNew) ...[
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              margin: EdgeInsets.only(right: 8.w),
                              decoration: BoxDecoration(
                                color: UColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "NEW",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          Expanded(
                            child: Text(notice.title,
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          Text(
                            DateFormat('dd MMM').format(notice.createdAt.toLocal()),
                            style: TextStyle(
                                color: UColors.textSecondary,
                                fontSize: 12.spMin,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(notice.description,
                          style: const TextStyle(
                              color: UColors.textSecondary, fontSize: 13, height: 1.4)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassCodeCard(BuildContext context, NoticeController controller) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: UColors.containerDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: UColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.personalcard, color: UColors.primary, size: 20),
              SizedBox(width: 8.w),
              const Text("Class Code",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          SizedBox(height: 20.h),
          Obx(() => Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration:
                          BoxDecoration(color: UColors.dark, borderRadius: BorderRadius.circular(12)),
                      child: Text(controller.classCode.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: UColors.primary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: controller.classCode.value));
                      AppFeedback.showInfo(context, message: 'Class code copied to clipboard');
                    },
                    icon: const Icon(Iconsax.copy, color: Colors.white),
                    style: IconButton.styleFrom(
                        backgroundColor: UColors.borderDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Future<void> _showAddNoticeDialog(BuildContext context, NoticeController controller) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    bool isDialogLoading = false;

    try {
      final success = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (stContext, setDialogState) => AlertDialog(
            backgroundColor: UColors.containerDark,
            title: const Text("Post New Notice",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                        controller: titleController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            hintText: "Title",
                            hintStyle: TextStyle(color: UColors.textSecondary))),
                    const SizedBox(height: 12),
                    TextField(
                        controller: descController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            hintText: "Description",
                            hintStyle: TextStyle(color: UColors.textSecondary))),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isDialogLoading ? null : () => Navigator.pop(dialogContext, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: isDialogLoading
                    ? null
                    : () async {
                        final title = titleController.text.trim();
                        final description = descController.text.trim();

                        if (title.isEmpty || description.isEmpty) {
                          AppFeedback.showError(context, message: 'Title and description are required');
                          return;
                        }

                        setDialogState(() => isDialogLoading = true);
                        
                        // Unfocus globally before popping
                        FocusManager.instance.primaryFocus?.unfocus();
                        
                        final result = await controller.postNotice(title, description);
                        
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext, result);
                        }
                      },
                child: isDialogLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("Post"),
              ),
            ],
          ),
        ),
      );

      if (success == null || !context.mounted) return;
      if (success) {
        AppFeedback.showSuccess(context, message: 'Notice posted successfully');
      } else {
        AppFeedback.showError(context, message: 'Failed to post notice', title: 'Notice failed');
      }
    } finally {
      titleController.dispose();
      descController.dispose();
    }
  }
}
