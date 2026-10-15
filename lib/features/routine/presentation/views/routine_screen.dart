import 'dart:typed_data';
import 'package:cr_assist/core/common/app_feedback.dart';
import 'package:cr_assist/core/constants/colors.dart';
import 'package:cr_assist/core/routes/app_router.dart';
import 'package:cr_assist/features/auth/presentation/manager/controller/auth_controller.dart';
import 'package:cr_assist/features/routine/data/models/routine_models.dart';
import 'package:cr_assist/features/routine/presentation/manager/controller/routine_controller.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class RoutineTodayCard extends StatefulWidget {
  const RoutineTodayCard({super.key, this.onOpenRoutine});

  final VoidCallback? onOpenRoutine;

  @override
  State<RoutineTodayCard> createState() => _RoutineTodayCardState();
}

class _RoutineTodayCardState extends State<RoutineTodayCard> {
  late final RoutineController _controller;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<RoutineController>();
    _controller.fetchToday();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final today = _controller.today.value;
      if (_controller.isTodayLoading.value && today == null) {
        return const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: _TodayCardLoadingPlaceholder(),
        );
      }
      if (today == null) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: _TodayCardSurface(
            onTap: _controller.fetchToday,
            eyebrow: 'ROUTINE',
            title: 'Couldn\'t load today\'s schedule',
            subtitle: _controller.todayErrorMessage.value.isEmpty
                ? 'Tap to try again.'
                : _controller.todayErrorMessage.value,
            isUnavailable: true,
          ),
        );
      }

      final slots = [
        ...today.todayClasses.map((slot) => (slot: slot, isExam: false)),
        ...today.todayExams.map((slot) => (slot: slot, isExam: true)),
      ];
      final empty = !today.hasScheduleToday;
      if (_currentPage >= slots.length && slots.isNotEmpty) {
        _currentPage = slots.length - 1;
      }
      if (slots.isNotEmpty) {
        final cards = PageView.builder(
          controller: _pageController,
          itemCount: slots.length,
          onPageChanged: (index) => setState(() => _currentPage = index),
          itemBuilder: (context, index) {
            final item = slots[index];
            final slot = item.slot;
            return _TodayCardSurface(
              onTap: widget.onOpenRoutine ?? () => AppRouter.go('/routine'),
              eyebrow: item.isExam ? 'EXAM' : 'ROUTINE',
              title: slot.subjectName.isEmpty
                  ? (item.isExam ? 'Today\'s exam' : 'Today\'s class')
                  : slot.subjectName,
              subtitle: _formatRoutineDate(
                item.isExam && slot.examDate.isNotEmpty
                    ? slot.examDate
                    : today.date,
              ),
              timeLabel: _formatTime(slot),
              teacher: item.isExam ? null : slot.teacher,
              room: slot.room,
            );
          },
        );
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 156, child: cards),
              if (slots.length > 1) ...[
                const SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slots.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: index == _currentPage ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: UColors.primary.withValues(
                          alpha: index == _currentPage ? 1 : 0.3,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
        child: _TodayCardSurface(
          onTap: widget.onOpenRoutine ?? () => AppRouter.go('/routine'),
          eyebrow: 'YOUR ACADEMIC PLAN',
          title: 'Routine',
          subtitle: _formatRoutineDate(today.date),
          classCount: today.todayClasses.length,
          examCount: today.todayExams.length,
          empty: empty,
        ),
      );
    });
  }

  String _formatRoutineDate(String value) {
    final date = DateTime.tryParse(value) ?? DateTime.now();
    return DateFormat('EEEE, d MMMM').format(date);
  }

  String _formatTime(RoutineSlot slot) {
    if (slot.startTime.isEmpty) return slot.endTime;
    if (slot.endTime.isEmpty) return slot.startTime;
    return '${slot.startTime} - ${slot.endTime}';
  }
}

class _TodayCardLoadingPlaceholder extends StatelessWidget {
  const _TodayCardLoadingPlaceholder();

  @override
  Widget build(BuildContext context) => Container(
    height: 156,
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: UColors.primary.withValues(alpha: 0.18),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _placeholderBar(width: 84, height: 10, opacity: 0.25),
        const SizedBox(height: 14),
        _placeholderBar(width: 174, height: 26, opacity: 0.32),
        const SizedBox(height: 9),
        _placeholderBar(width: 142, height: 16, opacity: 0.22),
        const Spacer(),
        _placeholderBar(width: 216, height: 14, opacity: 0.2),
      ],
    ),
  );

  Widget _placeholderBar({
    required double width,
    required double height,
    required double opacity,
  }) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(height),
    ),
  );
}

class _TodayCardSurface extends StatelessWidget {
  const _TodayCardSurface({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.timeLabel,
    this.teacher,
    this.room,
    this.classCount = 0,
    this.examCount = 0,
    this.empty = false,
    this.isUnavailable = false,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? timeLabel;
  final String? teacher;
  final String? room;
  final int classCount;
  final int examCount;
  final bool empty;
  final bool isUnavailable;

  @override
  Widget build(BuildContext context) {
    const colors = [Color(0xFF3B82F6), Color(0xFF1D4ED8)];
    final dateText = subtitle;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 156),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: UColors.primary.withValues(alpha: 0.22),
                blurRadius: 20,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: empty || isUnavailable
              ? _buildEmptyState(context, dateText)
              : _buildScheduleState(context, dateText),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String dateText) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _eyebrowText(textTheme),
              const SizedBox(height: 8),
              Text(
                title,
                style: textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateText,
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _countBadge(
                    context,
                    icon: Icons.view_week_rounded,
                    text: '$classCount class slots',
                  ),
                  _countBadge(
                    context,
                    icon: Icons.event_available_rounded,
                    text: '$examCount exams',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Icon(
          Icons.calendar_month_rounded,
          size: 42,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ],
    );
  }

  Widget _buildScheduleState(BuildContext context, String dateText) {
    final textTheme = Theme.of(context).textTheme;
    final roomNumber = room?.trim().isNotEmpty == true
        ? room!.trim().replaceFirst(
            RegExp(r'^(room|rm)\s*', caseSensitive: false),
            '',
          )
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _eyebrowText(textTheme),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            if (roomNumber != null) ...[
              const SizedBox(width: 12),
              Container(
                constraints: const BoxConstraints(
                  minWidth: 90,
                  maxWidth: 112,
                  minHeight: 60,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ROOM',
                      style: textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF2555D9),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roomNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF102451),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        if (timeLabel?.isNotEmpty == true || teacher?.isNotEmpty == true) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              if (timeLabel?.isNotEmpty == true)
                Flexible(
                  flex: 5,
                  child: Text(
                    timeLabel!,
                    maxLines: 1,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (timeLabel?.isNotEmpty == true &&
                  teacher?.isNotEmpty == true) ...[
                const SizedBox(width: 5),
                const Icon(Icons.circle, size: 4, color: Colors.white),
                const SizedBox(width: 5),
              ],
              if (teacher?.isNotEmpty == true)
                Expanded(
                  flex: 6,
                  child: Text(
                    teacher!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _eyebrowText(TextTheme textTheme) => Text(
    eyebrow,
    style: textTheme.labelLarge?.copyWith(
      color: Colors.white.withValues(alpha: 0.76),
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    ),
  );

  Widget _countBadge(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.13),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  static const _days = [
    ('SATURDAY', 'SAT'),
    ('SUNDAY', 'SUN'),
    ('MONDAY', 'MON'),
    ('TUESDAY', 'TUE'),
    ('WEDNESDAY', 'WED'),
    ('THURSDAY', 'THU'),
    ('FRIDAY', 'FRI'),
  ];

  late final RoutineController _controller;
  String _selectedDay = _days[(DateTime.now().weekday + 1) % 7].$1;
  int _selectedRoutineTab = 0;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<RoutineController>();
    _controller.fetchSchedule();
    _controller.fetchToday();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(centerTitle: true, title: const Text('Routine')),
      body: Obx(() {
        if (_controller.isScheduleLoading.value &&
            _controller.schedule.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: UColors.primary),
          );
        }
        if (_controller.schedule.value == null) {
          return _loadError(context);
        }
        final schedule = _controller.schedule.value!;
        final isCR =
            (Get.isRegistered<AuthController>() &&
                Get.find<AuthController>().isCR) ||
            schedule.isCR;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: _buildRoutineHero(context, schedule),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _buildRoutineSelector(context),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedRoutineTab,
                children: [
                  _buildClassRoutine(context, schedule, isCR),
                  _buildExamRoutine(context, schedule, isCR),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildRoutineHero(BuildContext context, RoutineSchedule schedule) {
    final theme = Theme.of(context);
    final selectedDate = _dateForSelectedDay();
    final selectedDateKey = DateFormat('yyyy-MM-dd').format(selectedDate);
    final classCount = schedule.classSlots
        .where((slot) => slot.dayOfWeek.toUpperCase() == _selectedDay)
        .length;
    final examCount = schedule.examSlots
        .where((slot) => slot.examDate == selectedDateKey)
        .length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: UColors.primary.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Iconsax.calendar, color: Colors.white, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, d MMMM').format(selectedDate),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _routineCountPill(
                      context,
                      icon: Iconsax.calendar,
                      label:
                          '$classCount ${classCount == 1 ? 'class' : 'classes'}',
                    ),
                    _routineCountPill(
                      context,
                      icon: Iconsax.calendar,
                      label: '$examCount ${examCount == 1 ? 'exam' : 'exams'}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        
        ],
      ),
    );
  }

  Widget _routineCountPill(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 13),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );

  DateTime _dateForSelectedDay() {
    final baseDate =
        DateTime.tryParse(_controller.today.value?.date ?? '') ??
        DateTime.now();
    const weekdayNumbers = {
      'MONDAY': DateTime.monday,
      'TUESDAY': DateTime.tuesday,
      'WEDNESDAY': DateTime.wednesday,
      'THURSDAY': DateTime.thursday,
      'FRIDAY': DateTime.friday,
      'SATURDAY': DateTime.saturday,
      'SUNDAY': DateTime.sunday,
    };
    final targetWeekday = weekdayNumbers[_selectedDay] ?? baseDate.weekday;
    final daysUntilSelected = (targetWeekday - baseDate.weekday + 7) % 7;
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day + daysUntilSelected,
    );
  }

  Widget _buildRoutineSelector(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          _routineTabButton(context, 0, 'Class routine', Iconsax.calendar),
          _routineTabButton(
            context,
            1,
            'Exam routine',
            Icons.edit_calendar_rounded,
          ),
        ],
      ),
    );
  }

  Widget _routineTabButton(
    BuildContext context,
    int index,
    String label,
    IconData icon,
  ) {
    final selected = _selectedRoutineTab == index;
    final theme = Theme.of(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: theme.brightness == Brightness.dark
                            ? 0.16
                            : 0.06,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(13),
              onTap: () {
                if (_selectedRoutineTab != index) {
                  setState(() => _selectedRoutineTab = index);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 17,
                      color: selected
                          ? UColors.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: selected
                              ? UColors.primary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadError(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: UColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: UColors.error,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Routine couldn\'t load',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            _controller.scheduleErrorMessage.value.isEmpty
                ? 'Check your connection and try again.'
                : _controller.scheduleErrorMessage.value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _controller.fetchSchedule,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    ),
  );

  Widget _buildClassRoutine(
    BuildContext context,
    RoutineSchedule schedule,
    bool isCR,
  ) {
    final scheduleDate = _dateForSelectedDay();
    final scheduleDateKey = DateFormat('yyyy-MM-dd').format(scheduleDate);
    final daySlots =
        schedule.classSlots
            .where((slot) => slot.dayOfWeek.toUpperCase() == _selectedDay)
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final examsForDay = schedule.examSlots
        .where((slot) => slot.examDate == scheduleDateKey)
        .length;
    return RefreshIndicator(
      onRefresh: _controller.fetchSchedule,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          _routineImageCard(
            context,
            image: schedule.classImage,
            type: 'CLASS',
            isCR: isCR,
          ),
          const SizedBox(height: 18),
          _sectionHeader(
            context,
            'Weekly timetable',
            ifCR: isCR,
            action: isCR ? 'Add class slot' : null,
            onAction: isCR ? () => _editSlot(exam: false) : null,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final day = _days[index];
                final selected = _selectedDay == day.$1;
                final count = schedule.classSlots
                    .where((slot) => slot.dayOfWeek.toUpperCase() == day.$1)
                    .length;
                return Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(13),
                    onTap: () => setState(() => _selectedDay = day.$1),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? const LinearGradient(
                                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: selected
                            ? null
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: selected
                              ? UColors.primary
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            day.$2,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: selected
                                      ? Colors.white
                                      : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            constraints: const BoxConstraints(minWidth: 18),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: selected
                                        ? Colors.white
                                        : Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.calendar, size: 17, color: UColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${daySlots.length} ${daySlots.length == 1 ? 'class' : 'classes'} · '
                    '$examsForDay ${examsForDay == 1 ? 'exam' : 'exams'}',
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  DateFormat('d MMM').format(scheduleDate),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (daySlots.isEmpty)
            _emptyMessage(
              'No classes scheduled for ${_selectedDay.toLowerCase()}.',
            )
          else
            ...daySlots.map(
              (slot) => _slotCard(
                context,
                slot,
                isCR: isCR,
                onEdit: () => _editSlot(exam: false, slot: slot),
                onDelete: () => _deleteSlot(slot, exam: false),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExamRoutine(
    BuildContext context,
    RoutineSchedule schedule,
    bool isCR,
  ) {
    final todayDate =
        _controller.today.value?.date ??
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    final exams =
        schedule.examSlots
            .where((slot) => slot.examDate.compareTo(todayDate) >= 0)
            .toList()
          ..sort((a, b) => a.examDate.compareTo(b.examDate));
    final examsByDate = <String, List<RoutineSlot>>{};
    for (final exam in exams) {
      examsByDate.putIfAbsent(exam.examDate, () => []).add(exam);
    }
    return RefreshIndicator(
      onRefresh: _controller.fetchSchedule,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          _routineImageCard(
            context,
            image: schedule.examImage,
            type: 'EXAM',
            isCR: isCR,
          ),
          const SizedBox(height: 18),
          _sectionHeader(
            context,
            'Exam schedule',
            ifCR: isCR,
            action: isCR ? 'Add exam' : null,
            onAction: isCR ? () => _editSlot(exam: true) : null,
          ),
          const SizedBox(height: 12),
          if (exams.isEmpty)
            _emptyMessage('No upcoming exams have been scheduled.')
          else
            ...examsByDate.entries.expand(
              (entry) => [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Iconsax.calendar,
                        size: 18,
                        color: UColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(entry.key),
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                ...entry.value.map(
                  (slot) => _slotCard(
                    context,
                    slot,
                    isCR: isCR,
                    isExam: true,
                    onEdit: () => _editSlot(exam: true, slot: slot),
                    onDelete: () => _deleteSlot(slot, exam: true),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context,
    String title, {
    required bool ifCR,
    String? action,
    VoidCallback? onAction,
  }) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
      if (ifCR && action != null)
        TextButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.add, size: 18),
          label: Text(action),
        ),
    ],
  );

  Widget _routineImageCard(
    BuildContext context, {
    required RoutineImage image,
    required String type,
    required bool isCR,
  }) {
    final hasImage = image.imageUrl.isNotEmpty;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: UColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    type == 'CLASS'
                        ? Icons.calendar_view_week_rounded
                        : Icons.edit_calendar_rounded,
                    color: UColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        image.title.isNotEmpty ? image.title : '$type ROUTINE',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasImage ? 'Tap image to zoom' : 'Routine timetable',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (hasImage)
                  Icon(
                    Icons.open_in_full_rounded,
                    size: 17,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
          if (hasImage)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _RoutineImageViewer(
                        imageUrl: image.imageUrl,
                        title: image.title.isEmpty
                            ? '$type Routine'
                            : image.title,
                      ),
                    ),
                  ),
                  child: Image.network(
                    image.imageUrl,
                    height: 210,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      final total = progress.expectedTotalBytes;
                      return SizedBox(
                        height: 170,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: UColors.primary,
                            value: total == null
                                ? null
                                : progress.cumulativeBytesLoaded / total,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, _, _) => Container(
                      height: 170,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                            size: 30,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Could not load this routine image',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.48),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.image_search_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isCR
                        ? 'Add a clear ${type.toLowerCase()} timetable image for your batch.'
                        : 'No routine image uploaded yet.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 6,
              children: [
                if (hasImage)
                  TextButton.icon(
                    onPressed: () =>
                        _downloadImage(image.imageUrl, image.title),
                    icon: const Icon(Iconsax.receive_square, size: 18),
                    label: const Text('Download'),
                  ),
                if (isCR)
                  TextButton.icon(
                    onPressed: () => _uploadImage(type),
                    icon: Icon(hasImage ? Icons.edit_outlined : Icons.add),
                    label: Text(hasImage ? 'Change' : 'Upload Image'),
                  ),
                if (isCR && hasImage)
                  IconButton(
                    tooltip: 'Delete image',
                    onPressed: () => _deleteImage(type),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: UColors.error,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _slotCard(
    BuildContext context,
    RoutineSlot slot, {
    required bool isCR,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    bool isExam = false,
  }) {
    final todayString =
        _controller.today.value?.date ??
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isToday = isExam && slot.examDate.startsWith(todayString);
    final dateLabel = isExam && slot.examDate.isNotEmpty
        ? _formatDate(slot.examDate)
        : '';
    final color = isToday ? UColors.error : UColors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isToday
              ? UColors.error.withValues(alpha: 0.35)
              : Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 82,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
            ),
          ),
          const SizedBox(width: 13),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              isExam ? Icons.edit_calendar_rounded : Icons.menu_book_rounded,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          slot.subjectName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (isToday)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: UColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'TODAY',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: UColors.error,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    [
                      if (dateLabel.isNotEmpty) dateLabel,
                      if (slot.courseCode.isNotEmpty) slot.courseCode,
                      '${slot.startTime} - ${slot.endTime}',
                      if (!isExam && slot.teacher.isNotEmpty) slot.teacher,
                      if (slot.room.isNotEmpty) 'Room ${slot.room}',
                    ].join('  ·  '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          if (isCR)
            PopupMenuButton<String>(
              onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _emptyMessage(String message) => Container(
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Theme.of(context).dividerColor),
    ),
    child: Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: UColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.event_available_rounded,
            color: UColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );

  Future<void> _uploadImage(String type) async {
    final List<PlatformFile> pickedFiles;
    try {
      pickedFiles = await FilePicker.pickFiles(type: FileType.image);
    } catch (error) {
      if (mounted) {
        AppFeedback.showError(
          context,
          message: 'Unable to select an image: $error',
          title: 'Image selection failed',
        );
      }
      return;
    }
    if (!mounted || pickedFiles.isEmpty) return;
    final path = pickedFiles.first.path;
    if (path == null) {
      AppFeedback.showError(
        context,
        message: 'The selected image could not be accessed. Please try again.',
        title: 'Image upload failed',
      );
      return;
    }
    final success = await _controller.uploadImage(
      type: type,
      title: '$type ROUTINE',
      filePath: path,
    );
    if (mounted) {
      _showMutationResult(success, success ? 'Routine image uploaded.' : null);
    }
  }

  Future<void> _deleteImage(String type) async {
    final confirmed = await _confirm('Delete routine image?');
    if (!mounted || !confirmed) return;
    final success = await _controller.deleteImage(type);
    if (mounted) {
      _showMutationResult(success, success ? 'Routine image deleted.' : null);
    }
  }

  Future<void> _deleteSlot(RoutineSlot slot, {required bool exam}) async {
    final confirmed = await _confirm('Delete ${slot.subjectName}?');
    if (!mounted || !confirmed) return;
    final success = await _controller.deleteSlot(exam: exam, slotId: slot.id);
    if (mounted) {
      _showMutationResult(success, success ? 'Schedule entry deleted.' : null);
    }
  }

  Future<bool> _confirm(String message) async {
    var isClosing = false;
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  if (isClosing) return;
                  isClosing = true;
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (isClosing) return;
                  isClosing = true;
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _editSlot({required bool exam, RoutineSlot? slot}) async {
    final values = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => _EditSlotDialog(
        exam: exam,
        slot: slot,
        selectedDay: _selectedDay,
        days: _days,
      ),
    );
    if (!mounted || values == null) return;
    final success = await _controller.saveSlot(
      exam: exam,
      values: values,
      slotId: slot?.id,
    );
    if (mounted) {
      _showMutationResult(success, success ? 'Schedule saved.' : null);
    }
  }

  Future<void> _downloadImage(String url, String title) async {
    try {
      final response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data ?? const []);
      final safeTitle = title.replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '_');
      final saved = await FilePicker.saveFile(
        dialogTitle: 'Save routine image',
        fileName: '${safeTitle.isEmpty ? 'routine' : safeTitle}.jpg',
        bytes: bytes,
        type: FileType.image,
      );
      if (mounted && saved != null) {
        AppFeedback.showSuccess(context, message: 'Routine image saved.');
      }
    } on DioException catch (error) {
      if (mounted) {
        AppFeedback.showError(
          context,
          message: error.message ?? 'Unable to download the routine image.',
          title: 'Download failed',
        );
      }
    } catch (error) {
      if (mounted) {
        AppFeedback.showError(
          context,
          message: 'Unable to save the routine image: $error',
          title: 'Download failed',
        );
      }
    }
  }

  void _showMutationResult(bool success, String? message) {
    if (success && message != null) {
      AppFeedback.showSuccess(context, message: message);
    } else if (!success) {
      AppFeedback.showError(
        context,
        message: _controller.errorMessage.value.isEmpty
            ? 'The request could not be completed.'
            : _controller.errorMessage.value,
        title: 'Routine update failed',
      );
    }
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);
    return date == null ? value : DateFormat('dd MMM, yyyy').format(date);
  }
}

class _RoutineImageViewer extends StatelessWidget {
  const _RoutineImageViewer({required this.imageUrl, required this.title});
  final String imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: InteractiveViewer(
        minScale: 0.7,
        maxScale: 5,
        child: Image.network(
          imageUrl,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.broken_image_outlined, size: 48),
        ),
      ),
    ),
  );
}

class _EditSlotDialog extends StatefulWidget {
  const _EditSlotDialog({
    required this.exam,
    this.slot,
    required this.selectedDay,
    required this.days,
  });

  final bool exam;
  final RoutineSlot? slot;
  final String selectedDay;
  final List<(String, String)> days;

  @override
  State<_EditSlotDialog> createState() => _EditSlotDialogState();
}

class _EditSlotDialogState extends State<_EditSlotDialog> {
  late final TextEditingController _subjectController;
  late final TextEditingController _codeController;
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  late final TextEditingController _teacherController;
  late final TextEditingController _roomController;
  late String _selectedDay;
  DateTime? _examDate;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    final slot = widget.slot;
    _subjectController = TextEditingController(text: slot?.subjectName ?? '');
    _codeController = TextEditingController(text: slot?.courseCode ?? '');
    _startController = TextEditingController(text: slot?.startTime ?? '');
    _endController = TextEditingController(text: slot?.endTime ?? '');
    _teacherController = TextEditingController(text: slot?.teacher ?? '');
    _roomController = TextEditingController(text: slot?.room ?? '');
    _selectedDay = (slot?.dayOfWeek.isNotEmpty == true
        ? slot!.dayOfWeek
        : widget.selectedDay);
    _examDate = DateTime.tryParse(slot?.examDate ?? '');
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _codeController.dispose();
    _startController.dispose();
    _endController.dispose();
    _teacherController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '${widget.slot == null ? 'Add' : 'Edit'} ${widget.exam ? 'exam' : 'class'}',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.exam)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _examDate == null
                      ? 'Choose exam date'
                      : DateFormat('dd MMM yyyy').format(_examDate!),
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _examDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(
                      const Duration(days: 3650),
                    ),
                  );
                  if (date != null && mounted) {
                    setState(() => _examDate = date);
                  }
                },
              )
            else
              DropdownButtonFormField<String>(
                initialValue: _selectedDay,
                decoration: const InputDecoration(labelText: 'Day'),
                items: widget.days
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.$1,
                        child: Text(item.$2),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedDay = value);
                  }
                },
              ),
            _formField(_subjectController, 'Subject name'),
            _formField(_codeController, 'Course code (optional)'),
            _formField(_startController, 'Start time (e.g. 08:30 AM)'),
            _formField(_endController, 'End time (e.g. 09:45 AM)'),
            if (!widget.exam)
              _formField(_teacherController, 'Teacher (optional)'),
            _formField(_roomController, 'Room (optional)'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_isClosing) return;
            _isClosing = true;
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_isClosing) return;
            if (_subjectController.text.trim().isEmpty ||
                _startController.text.trim().isEmpty ||
                _endController.text.trim().isEmpty ||
                (widget.exam && _examDate == null)) {
              AppFeedback.showError(
                context,
                message: widget.exam && _examDate == null
                    ? 'Choose the exam date.'
                    : 'Enter a subject and both start and end times.',
                title: 'Required fields',
              );
              return;
            }
            _isClosing = true;
            Navigator.of(context).pop({
              if (widget.exam)
                'examDate': DateFormat('yyyy-MM-dd').format(_examDate!)
              else
                'dayOfWeek': _selectedDay,
              'subjectName': _subjectController.text.trim(),
              'courseCode': _codeController.text.trim(),
              'startTime': _startController.text.trim(),
              'endTime': _endController.text.trim(),
              if (!widget.exam) 'teacher': _teacherController.text.trim(),
              'room': _roomController.text.trim(),
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _formField(TextEditingController controller, String label) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      textCapitalization: TextCapitalization.sentences,
    ),
  );
}

