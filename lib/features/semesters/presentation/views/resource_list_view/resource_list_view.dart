import 'package:cr_assist/core/constants/colors.dart';
import 'package:cr_assist/core/routes/app_router.dart';
import 'package:cr_assist/core/theme/widgets_theme/elevated_button_theme.dart';
import 'package:cr_assist/features/auth/presentation/manager/controller/auth_controller.dart';
import 'package:cr_assist/features/semesters/presentation/manager/controller/semesters_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceListView extends StatelessWidget {
  final int subjectId;
  final String subjectName;

  const ResourceListView({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  Widget build(BuildContext context) {
    final SemestersController controller = Get.find<SemestersController>();
    final AuthController authController = Get.find<AuthController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchResources(subjectId);
    });

    return Scaffold(
      backgroundColor: UColors.dark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: UColors.textPrimary),
          onPressed: () => AppRouter.pop(),
        ),
        title: Text(
          subjectName,
          style: const TextStyle(color: UColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.resources.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: UColors.primary));
        }

        if (controller.errorMessage.isNotEmpty && controller.resources.isEmpty) {
          return Center(child: Text(controller.errorMessage.value, style: const TextStyle(color: UColors.error)));
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchResources(subjectId),
          color: UColors.primary,
          backgroundColor: UColors.containerDark,
          child: controller.resources.isEmpty
              ? ListView(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    const Center(child: Text("No resources found", style: TextStyle(color: UColors.textSecondary))),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.resources.length,
                  itemBuilder: (context, index) {
                    final resource = controller.resources[index];
                    return _ResourceCard(
                      resource: resource,
                      isCR: authController.isCR,
                      onDelete: () => _showDeleteResourceConfirm(context, controller, resource.id),
                    );
                  },
                ),
        );
      }),
      floatingActionButton: Obx(() {
        if (!authController.isCR) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => _showUploadOptions(context, controller),
          backgroundColor: UColors.primary,
          icon: const Icon(Iconsax.add, color: Colors.white),
          label: const Text("Add Resource", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        );
      }),
    );
  }

  void _showDeleteResourceConfirm(BuildContext context, SemestersController controller, int resourceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UColors.containerDark,
        title: const Text("Delete Resource", style: TextStyle(color: UColors.textPrimary)),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: UElevatedButtonTheme.radius12(context),
            onPressed: () async {
              final success = await controller.deleteResource(subjectId, resourceId);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? "Resource deleted successfully" : controller.errorMessage.value),
                    backgroundColor: success ? UColors.success : UColors.error,
                  ),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUploadOptions(BuildContext context, SemestersController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: UColors.containerDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Select Upload Type", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Iconsax.document_1, color: UColors.error),
              title: const Text("Upload PDF", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showTitleDialog(context, controller, 'PDF');
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.image, color: UColors.primary),
              title: const Text("Upload Notes (Multiple Images)", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showTitleDialog(context, controller, 'NOTE');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTitleDialog(BuildContext context, SemestersController controller, String type) {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UColors.containerDark,
        title: Text("Enter Title", style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: titleController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: "e.g. Lecture 01", hintStyle: TextStyle(color: UColors.textSecondary)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                Navigator.pop(context);
                _pickAndUpload(context, controller, type, titleController.text);
              }
            },
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUpload(BuildContext context, SemestersController controller, String type, String title) async {
    try {
      final List<PlatformFile> pickedFiles = [];

      if (type == 'NOTE') {
        pickedFiles.addAll(await FilePicker.pickFiles(type: FileType.image));
      } else {
        final file = await FilePicker.pickFile(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        if (file != null) pickedFiles.add(file);
      }

      if (pickedFiles.isNotEmpty) {
        final List<String> filePaths = pickedFiles.map((e) => e.path).whereType<String>().toList();
        if (filePaths.isEmpty) return;

        final success = await controller.uploadResourceFiles(subjectId: subjectId, title: title, filePaths: filePaths, type: type);
        if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text(success ? "Upload successful" : "Upload failed"),
               backgroundColor: success ? UColors.success : UColors.error,
             ),
           );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error picking files: $e"), backgroundColor: UColors.error),
        );
      }
    }
  }
}

class _ResourceCard extends StatelessWidget {
  final dynamic resource;
  final bool isCR;
  final VoidCallback onDelete;

  const _ResourceCard({required this.resource, required this.isCR, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final type = (resource.type ?? '').toLowerCase();
    IconData iconData = Iconsax.document_text_1;
    Color iconColor = UColors.primary;

    if (type.contains('pdf')) {
      iconData = Iconsax.document_text_1;
      iconColor = UColors.error;
    } else if (type.contains('image')) {
      iconData = Iconsax.image;
      iconColor = UColors.success;
    }

    return Card(
      color: UColors.containerDark,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(resource.title, style: const TextStyle(color: UColors.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text(resource.type.toString().toUpperCase(), style: const TextStyle(color: UColors.textSecondary, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCR) IconButton(icon: const Icon(Iconsax.trash, color: UColors.error, size: 20), onPressed: onDelete),
            IconButton(
              icon: const Icon(Iconsax.receive_square, color: UColors.primary),
              onPressed: () async {
                final Uri url = Uri.parse(resource.url);
                if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
              },
            ),
          ],
        ),
      ),
    );
  }
}
