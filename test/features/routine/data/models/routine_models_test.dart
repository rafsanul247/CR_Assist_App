import 'package:cr_assist/features/routine/data/models/routine_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RoutineToday', () {
    test('parses the no-classes and no-exams response', () {
      final today = RoutineToday.fromJson({
        'day': 'MONDAY',
        'date': '2026-10-12',
        'hasScheduleToday': false,
        'hasExamToday': false,
        'hasClassesToday': false,
        'message': 'No classes and exams today',
        'primarySummary': 'No classes and exams today',
        'examSummary': null,
        'classSummary': 'No classes scheduled for today.',
        'todayExams': [],
        'todayClasses': [],
        'classRoutineImageUrl': null,
        'examRoutineImageUrl': null,
      });

      expect(today.day, 'MONDAY');
      expect(today.hasScheduleToday, isFalse);
      expect(today.hasExamToday, isFalse);
      expect(today.hasClassesToday, isFalse);
      expect(today.primarySummary, 'No classes and exams today');
      expect(today.todayExams, isEmpty);
      expect(today.todayClasses, isEmpty);
      expect(today.classRoutineImageUrl, isNull);
    });

    test('infers schedule flags from the returned slots when absent', () {
      final today = RoutineToday.fromJson({
        'todayClasses': [
          {
            'id': 2,
            'subjectName': 'Physics-1',
            'startTime': '08:30 AM',
            'endTime': '09:45 AM',
            'room': '101',
          },
        ],
      });

      expect(today.hasScheduleToday, isTrue);
      expect(today.hasClassesToday, isTrue);
      expect(today.todayClasses.single.subjectName, 'Physics-1');
    });
  });

  test('parses routine image and class/exam slots', () {
    final schedule = RoutineSchedule.fromJson({
      'isCR': true,
      'classRoutine': {
        'title': 'Fall 2026',
        'imageUrl': 'https://example.test/class.png',
        'slots': [
          {'id': 1, 'dayOfWeek': 'MONDAY', 'subjectName': 'Math'},
        ],
      },
      'examRoutine': {
        'imageUrl': 'https://example.test/exam.png',
        'examSlots': [
          {'id': 3, 'examDate': '2026-10-25', 'subjectName': 'Physics'},
        ],
      },
    });

    expect(schedule.isCR, isTrue);
    expect(schedule.classImage.imageUrl, 'https://example.test/class.png');
    expect(schedule.classSlots.single.dayOfWeek, 'MONDAY');
    expect(schedule.examSlots.single.subjectName, 'Physics');
  });
}
