import 'package:cr_assist/core/network/dio_client.dart';
import 'package:cr_assist/features/routine/presentation/manager/controller/routine_controller.dart';
import 'package:cr_assist/features/routine/presentation/views/routine_screen.dart';
import 'package:cr_assist/injection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;

class _RoutineDioClient extends DioClient {
  _RoutineDioClient({
    this.hasScheduleToday = true,
    this.teacher = 'Dr. Sabrina Rahman',
    this.multipleTodaySlots = false,
    this.isCR = false,
  }) : super();

  final bool hasScheduleToday;
  final String teacher;
  final bool multipleTodaySlots;
  final bool isCR;

  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final data = path.endsWith('/today')
        ? <String, dynamic>{
            'date': '2026-10-12',
            'day': 'MONDAY',
            'hasScheduleToday': hasScheduleToday,
            'hasClassesToday': hasScheduleToday,
            'hasExamToday': multipleTodaySlots,
            'primarySummary': 'No classes scheduled for today.',
            'todayClasses': hasScheduleToday
                ? [
                    {
                      'id': 3,
                      'subjectName': 'Physics',
                      'startTime': '09:00 AM',
                      'endTime': '10:30 AM',
                      'teacher': teacher,
                      'room': '202',
                    },
                    if (multipleTodaySlots)
                      {
                        'id': 4,
                        'subjectName': 'Chemistry',
                        'startTime': '11:00 AM',
                        'endTime': '12:30 PM',
                        'teacher': 'Dr. Karim',
                        'room': '305',
                      },
                  ]
                : [],
            'todayExams': multipleTodaySlots
                ? [
                    {
                      'id': 5,
                      'subjectName': 'Mathematics Exam',
                      'startTime': '02:00 PM',
                      'endTime': '05:00 PM',
                      'examDate': '2026-10-12',
                      'room': 'Exam Hall',
                    },
                  ]
                : [],
          }
        : <String, dynamic>{
            'classRoutine': {
              'title': 'Weekly classes',
              'imageUrl': '',
              'slots': [
                {
                  'id': 1,
                  'dayOfWeek': 'MONDAY',
                  'subjectName': 'Physics',
                  'startTime': '08:30 AM',
                  'endTime': '09:45 AM',
                },
                {
                  'id': 3,
                  'dayOfWeek': 'TUESDAY',
                  'subjectName': 'Chemistry',
                  'startTime': '09:00 AM',
                  'endTime': '10:00 AM',
                },
                {
                  'id': 4,
                  'dayOfWeek': 'TUESDAY',
                  'subjectName': 'Biology',
                  'startTime': '10:30 AM',
                  'endTime': '11:30 AM',
                },
                {
                  'id': 5,
                  'dayOfWeek': 'TUESDAY',
                  'subjectName': 'Statistics',
                  'startTime': '12:00 PM',
                  'endTime': '01:00 PM',
                },
              ],
            },
            'examRoutine': {
              'title': 'Upcoming exams',
              'imageUrl': '',
              'examSlots': [
                {
                  'id': 2,
                  'examDate': '2026-10-12',
                  'subjectName': 'Mathematics',
                  'startTime': '10:00 AM',
                  'endTime': '01:00 PM',
                },
                {
                  'id': 6,
                  'examDate': '2026-10-25',
                  'subjectName': 'Physics Exam',
                  'startTime': '02:00 PM',
                  'endTime': '05:00 PM',
                },
              ],
            },
            'isCR': isCR,
          };
    return Response(
      requestOptions: RequestOptions(path: path),
      data: data,
    );
  }

  @override
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {'status': 'success'},
    );
  }
}

void main() {
  setUp(() async {
    Get.reset();
    await sl.reset();
    sl.registerSingleton<DioClient>(_RoutineDioClient());
    Get.put(RoutineController());
  });

  tearDown(() async {
    Get.reset();
    await sl.reset();
  });

  testWidgets('switching routine sections does not deactivate dependents', (
    tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: RoutineScreen()));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Weekly timetable'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Weekly timetable'), findsOneWidget);
    await tester.tap(find.text('Exam routine'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Exam schedule'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Exam schedule'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('12 Oct, 2026'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('12 Oct, 2026'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('25 Oct, 2026'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('25 Oct, 2026'), findsOneWidget);

    await tester.tap(find.text('Class routine'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Weekly timetable'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Weekly timetable'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('routine class counts are filtered for the selected weekday', (
    tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: RoutineScreen()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Weekly timetable'),
      250,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(find.text('MON'));
    await tester.pumpAndSettle();
    expect(find.text('1 class · 1 exam'), findsOneWidget);

    await tester.tap(find.text('TUE'));
    await tester.pumpAndSettle();
    expect(find.text('3 classes · 0 exams'), findsOneWidget);
    expect(find.text('Chemistry'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Statistics'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Statistics'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('routine title is centered and today notification is hidden', (
    tester,
  ) async {
    Get.reset();
    await sl.reset();
    sl.registerSingleton<DioClient>(_RoutineDioClient(isCR: true));
    Get.put(RoutineController());

    await tester.pumpWidget(const GetMaterialApp(home: RoutineScreen()));
    await tester.pumpAndSettle();

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.centerTitle, isTrue);

    await tester.scrollUntilVisible(
      find.text('Weekly timetable'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text("Send Today's Notification"), findsNothing);
  });

  testWidgets('home today card shows the scheduled class details', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(body: RoutineTodayCard(onOpenRoutine: () {})),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Physics'), findsOneWidget);
    expect(find.text('Monday, 12 October'), findsOneWidget);
    expect(find.text('09:00 AM - 10:30 AM'), findsOneWidget);
    expect(find.text('ROOM'), findsOneWidget);
    expect(find.text('202'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('ROUTINE')).dy,
      lessThan(tester.getTopLeft(find.text('Physics')).dy),
    );
    expect(
      tester.getTopLeft(find.text('Physics')).dx,
      lessThan(tester.getTopLeft(find.text('ROOM')).dx),
    );
    expect(
      tester.getTopLeft(find.text('Monday, 12 October')).dx,
      lessThan(tester.getTopLeft(find.text('ROOM')).dx),
    );
    expect(
      tester.getTopLeft(find.text('09:00 AM - 10:30 AM')).dy,
      tester.getTopLeft(find.text('Dr. Sabrina Rahman')).dy,
    );
  });

  testWidgets(
    'home routine card handles long teacher names on narrow screens',
    (tester) async {
      const teacher =
          'Professor Sabrina Rahman with a deliberately very long name';
      Get.reset();
      await sl.reset();
      sl.registerSingleton<DioClient>(_RoutineDioClient(teacher: teacher));
      Get.put(RoutineController());
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: RoutineTodayCard(onOpenRoutine: () {})),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(teacher), findsOneWidget);
      expect(find.text('202'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('today cards swipe across classes and exams', (tester) async {
    Get.reset();
    await sl.reset();
    sl.registerSingleton<DioClient>(
      _RoutineDioClient(multipleTodaySlots: true),
    );
    Get.put(RoutineController());

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(body: RoutineTodayCard(onOpenRoutine: () {})),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Physics'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Chemistry'), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Mathematics Exam'), findsOneWidget);
    expect(find.text('EXAM'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home routine card uses a placeholder while loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(body: RoutineTodayCard(onOpenRoutine: () {})),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pumpAndSettle();
  });

  testWidgets('home today card shows the academic plan when the day is free', (
    tester,
  ) async {
    Get.reset();
    await sl.reset();
    sl.registerSingleton<DioClient>(_RoutineDioClient(hasScheduleToday: false));
    Get.put(RoutineController());

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(body: RoutineTodayCard(onOpenRoutine: () {})),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('YOUR ACADEMIC PLAN'), findsOneWidget);
    expect(find.text('Routine'), findsOneWidget);
    expect(find.text('0 class slots'), findsOneWidget);
    expect(find.text('0 exams'), findsOneWidget);
  });

  testWidgets('adding a class slot saves and closes dialog cleanly', (
    tester,
  ) async {
    Get.reset();
    await sl.reset();
    sl.registerSingleton<DioClient>(_RoutineDioClient(isCR: true));
    Get.put(RoutineController());

    await tester.pumpWidget(const GetMaterialApp(home: RoutineScreen()));
    await tester.pumpAndSettle();

    final addBtn = find.text('Add class slot');
    await tester.scrollUntilVisible(
      addBtn,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(addBtn, findsOneWidget);

    await tester.tap(addBtn);
    await tester.pumpAndSettle();

    expect(find.text('Add class'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Subject name'),
      'Computer Architecture',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Start time (e.g. 08:30 AM)'),
      '09:00 AM',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'End time (e.g. 09:45 AM)'),
      '10:30 AM',
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Add class'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
