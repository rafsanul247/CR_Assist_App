import 'package:cr_assist/core/constants/colors.dart';
import 'package:cr_assist/core/routes/app_router.dart';
import 'package:cr_assist/core/theme/widgets_theme/elevated_button_theme.dart';
import 'package:cr_assist/features/auth/presentation/manager/controller/auth_controller.dart';
import 'package:cr_assist/features/semesters/presentation/manager/controller/semesters_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SubjectListView extends StatefulWidget {
  final int semesterId;
  final String semesterName;

  const SubjectListView({
    super.key,
    required this.semesterId,
    required this.semesterName,
  });

  @override
  State<SubjectListView> createState() => _SubjectListViewState();
}

class _SubjectListViewState extends State<SubjectListView> {
  final SemestersController controller = Get.find<SemestersController>();
  final AuthController authController = Get.find<AuthController>();

  static const List<Color> _accentColors = [
    Color(0xFF3B82F6), // blue
    Color(0xFF8B5CF6), // violet
    Color(0xFF10B981), // emerald
    Color(0xFFF59E0B), // amber
    Color(0xFFEC4899), // pink
    Color(0xFF06B6D4), // cyan
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSubjects(widget.semesterId);
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
          onPressed: () => AppRouter.pop(),
        ),
        title: Text(
          widget.semesterName,
          style: const TextStyle(color: UColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.subjects.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: UColors.primary));
        }

        if (controller.errorMessage.isNotEmpty && controller.subjects.isEmpty) {
          return Center(child: Text(controller.errorMessage.value, style: const TextStyle(color: UColors.error)));
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchSubjects(widget.semesterId),
          color: UColors.primary,
          backgroundColor: UColors.containerDark,
          child: controller.subjects.isEmpty
              ? ListView(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    const Center(child: Text("No subjects found", style: TextStyle(color: UColors.textSecondary))),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.subjects.length,
                  itemBuilder: (context, index) {
                    final subject = controller.subjects[index];
                    final accentColor = _accentColors[index % _accentColors.length];
                    return _SubjectCard(
                      subject: subject,
                      accentColor: accentColor,
                      isCR: authController.isCR,
                      onDelete: () => _showDeleteConfirm(subject.id),
                      onTap: () => AppRouter.push('/resources', extra: {
                        'subjectId': subject.id,
                        'subjectName': subject.name,
                      }),
                    );
                  },
                ),
        );
      }),
      floatingActionButton: Obx(() {
        if (!authController.isCR) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => _showAddSubjectDialog(context),
          backgroundColor: UColors.primary,
          icon: const Icon(Iconsax.add, color: Colors.white),
          label: const Text("Add Subject", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        );
      }),
    );
  }

  void _showDeleteConfirm(int subjectId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UColors.containerDark,
        title: const Text("Delete Subject", style: TextStyle(color: UColors.textPrimary)),
        content: const Text("Are you sure? All resources will be deleted.", style: TextStyle(color: UColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: UElevatedButtonTheme.radius12(context),
            onPressed: () async {
              final success = await controller.deleteSubject(widget.semesterId, subjectId);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? "Subject deleted successfully" : controller.errorMessage.value),
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

  void _showAddSubjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UColors.containerDark,
        title: const Text("Add New Subject", style: TextStyle(color: UColors.textPrimary)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter subject name",
            hintStyle: const TextStyle(color: UColors.textSecondary),
            filled: true,
            fillColor: UColors.dark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final success = await controller.addSubject(widget.semesterId, nameController.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? "Subject added successfully" : controller.errorMessage.value),
                      backgroundColor: success ? UColors.success : UColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final dynamic subject;
  final Color accentColor;
  final bool isCR;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subject,
    required this.accentColor,
    required this.isCR,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: UColors.containerDark,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Iconsax.book_saved, color: UColors.white),
        ),
        title: Text(
          subject.name,
          style: const TextStyle(color: UColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "${subject.resourceCount ?? 0} resources",
          style: TextStyle(color: accentColor, fontWeight: FontWeight.w500, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCR)
              IconButton(
                icon: const Icon(Iconsax.trash, color: UColors.error, size: 20),
                onPressed: onDelete,
              ),
            const Icon(Iconsax.arrow_right_3, color: UColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
