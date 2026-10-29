import 'dart:convert';

import 'package:aiocyb/src/data/aoi_library.dart';
import 'package:aiocyb/src/data/curriculum.dart';
import 'package:aiocyb/src/models/learning_overview.dart';
import 'package:aiocyb/src/screens/academy_screens.dart';
import 'package:aiocyb/src/screens/explore_screens.dart';
import 'package:aiocyb/src/screens/lesson_screens.dart';
import 'package:aiocyb/src/state/academy_store.dart';
import 'package:aiocyb/src/theme.dart';
import 'package:aiocyb/src/widgets/aoi_classroom.dart';
import 'package:aiocyb/src/widgets/common.dart';
import 'package:aiocyb/src/widgets/learning_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

Future<void> tapLabel(WidgetTester tester, String label) async {
  final target = find.text(label).first;
  await Scrollable.ensureVisible(tester.element(target), alignment: .25);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

AcademyStore partialStore() {
  final store = AcademyStore()
    ..onboarded = true
    ..name = 'Alex';
  store.scores = {
    for (final lesson in courses.first.lessons)
      lesson.id: lesson.questions.length,
  };
  store.scores[courses[1].lessons.first.id] = 1;
  store.lastLessonId = courses
      .firstWhere((c) => c.id == 'linux-start')
      .lessons
      .first
      .id;
  store.startedCourseIds.add('linux-start');
  return store;
}

Future<void> showScreen(
  WidgetTester tester,
  Widget screen, {
  Size size = const Size(390, 844),
  bool dark = true,
  double scale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  await tester.pumpWidget(
    MaterialApp(
      key: UniqueKey(),
      theme: academyTheme(dark, palette: NeonTheme.violet),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(size: size, textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: screen,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await AoiLibrary.load();
  });
  setUp(
    () => SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty(),
  );

  test('Overview counts real grades, weights lessons and includes unresolved diagnostic reviews without writes', () async {
    final store = partialStore();
    await store.recordMistake(courses.first.lessons.first.id, 0);
    await store.recordMistake('diagnostic', 2);
    final before = await SharedPreferencesAsync().getString(
      AcademyStore.storageKey,
    );
    final overview = LearningOverview(store);
    expect(overview.completedCourses, 1);
    expect(store.completedLessons, 10);
    expect(store.xp, 500);
    expect(overview.attemptedLessons, 11);
    expect(overview.gradedQuestions, 33);
    expect(overview.bestCorrectAnswers, 31);
    expect(overview.bestAccuracy, closeTo(31 / 33, .000001));
    expect(overview.pendingReviews, 2);
    expect(overview.completedPaths, 0);
    expect(overview.paths.first.completedLessons, 10);
    expect(overview.paths.first.progress, closeTo(1 / 3, .000001));
    expect(store.progress, closeTo(10 / 490, .000001));
    expect(overview.activePath.path.id, 'linux');
    expect(overview.activePath.nextLesson.id, store.lastLessonId);
    expect(overview.recommendedCourses.map((c) => c.id), [
      'linux-start',
      'terminal-tools',
      'linux-access',
    ]);
    expect(overview.status(courses[1]), 'En curso');
    expect(
      await SharedPreferencesAsync().getString(AcademyStore.storageKey),
      before,
    );
    await store.markReviewed('diagnostic', 2);
    expect(overview.pendingReviews, 1);
    final restored = AcademyStore();
    await restored.load();
    expect(LearningOverview(restored).bestCorrectAnswers, 31);
    expect(restored.xp, 500);
    expect(jsonDecode(before!)['scores'].length, 11);
  });

  test('Empty, zero-score and complete states do not invent accuracy, progress or XP', () {
    final store = AcademyStore();
    var overview = LearningOverview(store);
    expect(overview.bestAccuracy, isNull);
    expect(overview.attemptedLessons, 0);
    expect(overview.paths.every((p) => p.status == 'Por comenzar'), isTrue);
    store.scores[courses.first.lessons.first.id] = 0;
    expect(overview.status(courses.first), 'En curso');
    expect(overview.attemptedLessons, 1);
    expect(overview.bestAccuracy, 0);
    expect(store.completedLessons, 0);
    expect(store.xp, 0);
    store.scores = {
      for (final lesson in allLessons) lesson.id: lesson.questions.length,
    };
    overview = LearningOverview(store);
    expect(overview.completedCourses, 31);
    expect(overview.completedPaths, 6);
    expect(overview.gradedQuestions, 1290);
    expect(store.completedPractice, 0);
    expect(overview.bestAccuracy, 1);
    expect(store.xp, 24500);
    expect(
      overview.paths.every((p) => p.isComplete && p.progress == 1),
      isTrue,
    );
    expect(overview.recommendedCourses, courses.take(3).toList());
  });

  test('Legacy starts migrate and visiting another course retains earlier starts across reloads', () async {
    final linux = courses
        .firstWhere((course) => course.id == 'linux-start')
        .lessons
        .first;
    final coding = courses
        .firstWhere((course) => course.id == 'secure-coding')
        .lessons
        .first;
    await SharedPreferencesAsync().setString(
      AcademyStore.storageKey,
      jsonEncode({
        'onboarded': true,
        'name': 'Alex',
        'darkMode': false,
        'neonTheme': 'violet',
        'favoriteLessons': [linux.id],
        'lastLessonId': linux.id,
        'scores': {courses[1].lessons.first.id: 0},
        'startedCourseIds': ['missing-course', 42],
      }),
    );
    final store = AcademyStore();
    await store.load();
    expect(store.startedCourseIds, {'linux-start', 'identity'});
    expect(LearningOverview(store).status(courses[1]), 'En curso');
    await store.openLesson(coding);
    final restored = AcademyStore();
    await restored.load();
    expect(restored.startedCourseIds, {
      'linux-start',
      'identity',
      'secure-coding',
    });
    expect(restored.completedLessons, 0);
    expect(restored.xp, 0);
    expect(restored.scores[courses[1].lessons.first.id], 0);
    expect(restored.neonTheme, NeonTheme.violet);
    expect(restored.darkMode, false);
    expect(restored.favoriteLessons, {linux.id});
    await restored.resetProgress();
    final reset = AcademyStore();
    await reset.load();
    expect(reset.startedCourseIds, isEmpty);
    expect(
      LearningOverview(reset).paths.every((p) => p.status == 'Por comenzar'),
      true,
    );
    expect(reset.favoriteLessons, {linux.id});
    expect(reset.neonTheme, NeonTheme.violet);
  });

  testWidgets(
    'Home limits recommendations and resumes the actual last incomplete lesson',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = partialStore();
      final before = Map<String, int>.from(store.scores);
      await showScreen(
        tester,
        Scaffold(
          body: HomeScreen(store: store, onCourses: () {}),
        ),
      );
      expect(find.text('Hola, Alex'), findsOneWidget);
      expect(find.text('6 caminos para elegir'), findsOneWidget);
      expect(find.byType(CourseCard), findsNWidgets(3));
      expect(find.text('En curso · 0% completado'), findsOneWidget);
      await tapLabel(tester, 'Continuar aprendiendo');
      expect(
        tester
            .widget<AoiClassroom>(find.byType(AoiClassroom))
            .dialogue!
            .lessonId,
        store.lastLessonId,
      );
      expect(find.text('LECCIÓN 1 DE 10 · 15 min'), findsOneWidget);
      expect(store.scores, before);
      expect(store.xp, 500);
    },
  );

  testWidgets(
    'Routes expose all six paths and all six Linux courses without locking the last course',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = partialStore();
      await showScreen(tester, RoutesScreen(store: store));
      expect(find.text('6 CAMINOS · UN MISMO CRITERIO'), findsOneWidget);
      expect(find.byType(PathSummaryCard), findsNWidgets(6));
      await tapLabel(tester, 'Linux: observa, comprende e investiga');
      expect(find.byType(PathDetailScreen), findsOneWidget);
      final linux = LearningOverview(store).activePath;
      for (final course in linux.includedCourses) {
        expect(find.text(course.title), findsOneWidget);
      }
      await tapLabel(tester, linux.includedCourses.last.title);
      expect(find.byType(CourseScreen), findsOneWidget);
      expect(find.text(linux.includedCourses.last.title), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tapLabel(tester, 'En curso');
      expect(find.byType(PathSummaryCard), findsNWidgets(2));
      await tapLabel(tester, 'Completadas');
      expect(
        find.text('Todavía no hay rutas con este estado.'),
        findsOneWidget,
      );
      await tapLabel(tester, 'Ver todas las rutas');
      expect(find.byType(PathSummaryCard), findsNWidgets(6));
      expect(store.xp, 500);
    },
  );

  testWidgets(
    'Progress finds original grades and combines course status with search',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = partialStore();
      final lesson = courses[1].lessons.first;
      await showScreen(tester, Scaffold(body: ProgressScreen(store: store)));
      expect(find.text(lesson.title), findsNothing);
      await tester.ensureVisible(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), lesson.title);
      await tester.pumpAndSettle();
      expect(find.text('Mejor resultado: 1/3'), findsOneWidget);
      final lessonRow = find.descendant(
        of: find.byType(ListTile),
        matching: find.text(lesson.title),
      );
      await Scrollable.ensureVisible(tester.element(lessonRow), alignment: .25);
      await tester.pumpAndSettle();
      await tester.tap(lessonRow);
      await tester.pumpAndSettle();
      expect(find.byType(LessonScreen), findsOneWidget);
      expect(
        tester
            .widget<AoiClassroom>(find.byType(AoiClassroom))
            .dialogue!
            .lessonId,
        lesson.id,
      );
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byTooltip('Limpiar búsqueda de progreso'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Limpiar búsqueda de progreso'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'cuentas tus');
      await tester.pumpAndSettle();
      expect(find.text('Mejor resultado: 1/3'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      await tapLabel(tester, 'Completados');
      expect(find.text('1 curso en este estado'), findsOneWidget);
      expect(find.text(courses.first.title), findsOneWidget);
      expect(find.text(courses[1].title), findsNothing);
      expect(store.scores[lesson.id], 1);
      expect(store.xp, 500);
    },
  );

  testWidgets(
    'Dashboard review link opens original pending questions without changing grades',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = partialStore();
      final lesson = courses.first.lessons.first;
      await store.recordMistake(lesson.id, 1);
      await showScreen(tester, Scaffold(body: ProgressScreen(store: store)));
      await tapLabel(tester, 'Repasar errores');
      expect(find.byType(ReviewListScreen), findsOneWidget);
      expect(find.text(lesson.questions[1].prompt), findsOneWidget);
      expect(store.scores[lesson.id], 3);
      expect(store.xp, 500);
    },
  );

  testWidgets(
    'Path and course cards expose one labelled action with real progress to accessibility',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final handle = tester.ensureSemantics();
      try {
        final store = partialStore();
        await showScreen(tester, RoutesScreen(store: store));
        final path = find.bySemanticsLabel('Ruta: Tu primera defensa');
        await Scrollable.ensureVisible(tester.element(path), alignment: .25);
        await tester.pumpAndSettle();
        expect(
          tester.getSemantics(path),
          matchesSemantics(
            label: 'Ruta: Tu primera defensa',
            value: 'En curso. 10 de 30 lecciones superadas. 33 por ciento. 3 cursos.',
            hint: 'Ver cursos. Empieza por tus datos, tus cuentas y las decisiones que evitan engaños.',
            isButton: true,
            hasTapAction: true,
          ),
        );
        await tester.tap(path);
        await tester.pumpAndSettle();
        expect(find.byType(PathDetailScreen), findsOneWidget);
        final course = find.bySemanticsLabel('Curso: Que no te pesquen');
        await Scrollable.ensureVisible(tester.element(course), alignment: .25);
        await tester.pumpAndSettle();
        await tester.tap(course);
        await tester.pumpAndSettle();
        expect(find.byType(CourseScreen), findsOneWidget);
        expect(store.xp, 500);
      } finally {
        handle.dispose();
      }
    },
  );

  testWidgets(
    'New dashboards and path detail fit narrow, large-text and desktop layouts',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final (size, dark, scale) in [
        (const Size(320, 640), true, 1.0),
        (const Size(320, 740), false, 1.5),
        (const Size(1440, 1000), false, 1.15),
      ]) {
        final store = partialStore();
        for (final screen in [
          Scaffold(
            body: HomeScreen(store: store, onCourses: () {}),
          ),
          Scaffold(body: ProgressScreen(store: store)),
          RoutesScreen(store: store),
          PathDetailScreen(pathId: 'linux', store: store),
        ]) {
          await showScreen(
            tester,
            screen,
            size: size,
            dark: dark,
            scale: scale,
          );
          final scrollable = find.byType(SingleChildScrollView).first;
          await tester.drag(scrollable, const Offset(0, -1200));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      }
    },
  );
}
