import 'package:cr_assist/core/constants/colors.dart';
import 'package:cr_assist/core/common/app_feedback.dart';
import 'package:cr_assist/core/extensions/context_extension.dart';
import 'package:cr_assist/core/routes/app_router.dart';
import 'package:cr_assist/core/theme/widgets_theme/elevated_button_theme.dart';
import 'package:cr_assist/features/auth/presentation/manager/controller/auth_controller.dart';
import 'package:cr_assist/features/semesters/presentation/manager/controller/semesters_controller.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_2, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => AppRouter.pop(),
        ),
        title: Text(
          subjectName,
          style: context.tt.titleLarge,
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
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: controller.resources.isEmpty
              ? ListView(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    Center(child: Text("No resources found", style: context.tt.bodyMedium)),
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text("Delete Resource", style: context.tt.titleLarge),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: UElevatedButtonTheme.radius12(context),
            onPressed: () async {
              final success = await controller.deleteResource(subjectId, resourceId);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  AppFeedback.showSuccess(context, message: 'Resource deleted successfully');
                } else {
                  AppFeedback.showError(context, message: controller.errorMessage.value, title: 'Delete failed');
                }
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select Upload Type", style: context.tt.titleLarge),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Iconsax.document_1, color: UColors.error),
              title: Text("Upload PDF", style: context.tt.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                _showTitleDialog(context, controller, 'PDF');
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.image, color: UColors.primary),
              title: Text("Upload Notes (Multiple Images)", style: context.tt.bodyLarge),
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text("Enter Title", style: context.tt.titleLarge),
        content: TextField(
          controller: titleController,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(hintText: "e.g. Lecture 01", hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
           if (success) {
             AppFeedback.showSuccess(context, message: 'Upload successful');
           } else {
             AppFeedback.showError(context, message: 'Upload failed', title: 'Upload failed');
           }
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppFeedback.showError(context, message: 'Error picking files: $e', title: 'File selection failed');
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
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: () => _launchResource(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(resource.title, style: context.tt.titleMedium),
        subtitle: Text(resource.type.toString().toUpperCase(), style: context.tt.bodySmall),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCR) IconButton(icon: const Icon(Iconsax.trash, color: UColors.error, size: 20), onPressed: onDelete),
            IconButton(
              icon: const Icon(Iconsax.receive_square, color: UColors.primary),
              tooltip: 'Download resource',
              onPressed: () => _downloadResource(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadResource(BuildContext context) async {
    final url = resource.url.toString().trim();
    if (url.isEmpty) {
      AppFeedback.showError(context, message: 'This resource has no download link.');
      return;
    }

    AppFeedback.showInfo(context, message: 'Downloading ${resource.title}...', title: 'Please wait');

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = _fileName(resource.title.toString(), resource.type.toString());
      final filePath = '${directory.path}/$fileName';

      await Dio().download(url, filePath);
      if (!context.mounted) return;

      final result = await OpenFilex.open(filePath);
      if (!context.mounted) return;
      if (result.type != ResultType.done) {
        AppFeedback.showError(context, message: 'The file was downloaded but could not be opened.');
        return;
      }
      AppFeedback.showSuccess(context, message: 'Saved and opened $fileName');
    } on DioException catch (error) {
      if (context.mounted) {
        AppFeedback.showError(
          context,
          message: error.message ?? 'Unable to download this resource.',
          title: 'Download failed',
        );
      }
    } catch (_) {
      if (context.mounted) {
        AppFeedback.showError(context, message: 'Unable to download this resource.', title: 'Download failed');
      }
    }
  }

  Future<void> _launchResource(BuildContext context) async {
    final url = resource.url.toString().trim();
    if (url.isEmpty) {
      AppFeedback.showError(context, message: 'This resource has no file link.');
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      if (context.mounted) {
        AppFeedback.showError(context, message: 'Unable to open this resource.', title: 'Open failed');
      }
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      AppFeedback.showError(
        context,
        message: 'No browser or compatible app is available to open this link.',
        title: 'Open failed',
      );
    }
  }

  String _fileName(String title, String type) {
    final cleanTitle = title.replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
    final normalizedType = type.toLowerCase();
    final uri = Uri.tryParse(resource.url.toString());
    final urlExtension = uri?.pathSegments.isNotEmpty == true
        ? uri!.pathSegments.last.split('.').last.toLowerCase()
        : '';
    final supportedImageExtensions = {'jpg', 'jpeg', 'png', 'webp', 'gif'};
    final extension = normalizedType.contains('pdf')
        ? 'pdf'
        : supportedImageExtensions.contains(urlExtension)
            ? urlExtension
            : 'jpg';
    return '$cleanTitle.$extension';
  }
}
