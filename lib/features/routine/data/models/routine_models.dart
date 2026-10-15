class RoutineSlot {
  const RoutineSlot({
    required this.id,
    required this.subjectName,
    required this.startTime,
    required this.endTime,
    this.dayOfWeek = '',
    this.examDate = '',
    this.courseCode = '',
    this.teacher = '',
    this.room = '',
  });

  final int id;
  final String subjectName;
  final String startTime;
  final String endTime;
  final String dayOfWeek;
  final String examDate;
  final String courseCode;
  final String teacher;
  final String room;

  factory RoutineSlot.fromJson(Map<String, dynamic> json) => RoutineSlot(
    id: _toInt(json['id']),
    subjectName: _toText(json['subjectName'] ?? json['subject']),
    startTime: _toText(json['startTime']),
    endTime: _toText(json['endTime']),
    dayOfWeek: _toText(json['dayOfWeek'] ?? json['day']),
    examDate: _toText(json['examDate'] ?? json['date']),
    courseCode: _toText(json['courseCode']),
    teacher: _toText(json['teacher']),
    room: _toText(json['room']),
  );

  static int _toInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

  static String _toText(dynamic value) => value?.toString() ?? '';
}

class RoutineImage {
  const RoutineImage({this.title = '', this.imageUrl = ''});

  final String title;
  final String imageUrl;

  factory RoutineImage.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const RoutineImage();
    return RoutineImage(
      title: json['title']?.toString() ?? '',
      imageUrl:
          (json['imageUrl'] ?? json['url'] ?? json['fileUrl'])?.toString() ??
          '',
    );
  }
}

class RoutineToday {
  const RoutineToday({
    required this.day,
    required this.date,
    required this.hasExamToday,
    required this.hasClassesToday,
    required this.hasScheduleToday,
    required this.primarySummary,
    required this.examSummary,
    required this.classSummary,
    required this.todayExams,
    required this.todayClasses,
    required this.classRoutineImageUrl,
    required this.examRoutineImageUrl,
  });

  final String day;
  final String date;
  final bool hasExamToday;
  final bool hasClassesToday;
  final bool hasScheduleToday;
  final String primarySummary;
  final String? examSummary;
  final String classSummary;
  final List<RoutineSlot> todayExams;
  final List<RoutineSlot> todayClasses;
  final String? classRoutineImageUrl;
  final String? examRoutineImageUrl;

  factory RoutineToday.fromJson(Map<String, dynamic> json) {
    final exams = _parseSlots(json['todayExams']);
    final classes = _parseSlots(json['todayClasses']);
    final hasExam = json['hasExamToday'] as bool? ?? exams.isNotEmpty;
    final hasClasses = json['hasClassesToday'] as bool? ?? classes.isNotEmpty;
    return RoutineToday(
      day: json['day']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      hasExamToday: hasExam,
      hasClassesToday: hasClasses,
      hasScheduleToday:
          json['hasScheduleToday'] as bool? ?? (hasExam || hasClasses),
      primarySummary:
          json['primarySummary']?.toString() ??
          json['message']?.toString() ??
          '',
      examSummary: json['examSummary']?.toString(),
      classSummary: json['classSummary']?.toString() ?? '',
      todayExams: exams,
      todayClasses: classes,
      classRoutineImageUrl: _optionalText(json['classRoutineImageUrl']),
      examRoutineImageUrl: _optionalText(json['examRoutineImageUrl']),
    );
  }

  static List<RoutineSlot> _parseSlots(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((slot) => RoutineSlot.fromJson(Map<String, dynamic>.from(slot)))
        .toList();
  }

  static String? _optionalText(dynamic value) {
    final text = value?.toString();
    return text == null || text.isEmpty ? null : text;
  }
}

class RoutineSchedule {
  const RoutineSchedule({
    this.classImage = const RoutineImage(),
    this.examImage = const RoutineImage(),
    this.classSlots = const [],
    this.examSlots = const [],
    this.isCR = false,
  });

  final RoutineImage classImage;
  final RoutineImage examImage;
  final List<RoutineSlot> classSlots;
  final List<RoutineSlot> examSlots;
  final bool isCR;

  factory RoutineSchedule.fromJson(Map<String, dynamic> json) {
    final classRoutine = _map(json['classRoutine']);
    final examRoutine = _map(json['examRoutine']);
    return RoutineSchedule(
      classImage: RoutineImage.fromJson(classRoutine),
      examImage: RoutineImage.fromJson(examRoutine),
      classSlots: _slots(
        classRoutine['slots'] ??
            classRoutine['routineSlots'] ??
            json['classSlots'],
      ),
      examSlots: _slots(
        examRoutine['slots'] ?? examRoutine['examSlots'] ?? json['examSlots'],
      ),
      isCR: json['isCR'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : const {};

  static List<RoutineSlot> _slots(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((slot) => RoutineSlot.fromJson(Map<String, dynamic>.from(slot)))
        .toList();
  }
}
