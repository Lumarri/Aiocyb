import 'dart:io';

import 'package:aiocyb/src/data/aoi_library.dart';
import 'package:aiocyb/src/data/course_presentation.dart';
import 'package:aiocyb/src/data/curriculum.dart';
import 'package:aiocyb/src/screens/course_catalog.dart';
import 'package:aiocyb/src/screens/lesson_screens.dart';
import 'package:aiocyb/src/state/academy_store.dart';
import 'package:aiocyb/src/theme.dart';
import 'package:aiocyb/src/widgets/aoi_classroom.dart';
import 'package:aiocyb/src/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

Future<void> tapLabel(WidgetTester tester, String text) async {
  final matches = find.text(text);
  for (var scroll = 0; matches.evaluate().isEmpty && scroll < 8; scroll++) {
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
  }
  final target = matches.first;
  await Scrollable.ensureVisible(tester.element(target), alignment: .25);
  await tester.pumpAndSettle();
  await tester.tap(target);
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

  test('Every course has a local cover, specific outcomes and previews of its own theory', () {
    expect(
      courseProfiles.keys.toSet(),
      courses.map((course) => course.id).toSet(),
    );
    final covers = <String>{};
    final objectives = <String>{};
    for (final course in courses) {
      final cover = 'assets/artwork/${trackFor(course).cover}-v1.png';
      expect(File(cover).existsSync(), isTrue);
      covers.add(cover);
      final profile = courseProfiles[course.id]!;
      expect(profile.skills, hasLength(3));
      expect(profile.outcomes, hasLength(3));
      for (final outcome in profile.outcomes) {
        expect(objectives.add(outcome), isTrue);
      }
      expect(courseConcepts(course), hasLength(3));
      for (final concept in courseConcepts(course)) {
        expect(course.lessons.contains(concept.lesson), isTrue);
        expect(concept.lesson.sections.contains(concept.section), isTrue);
      }
    }
    expect(covers, hasLength(5));
  });

  testWidgets(
    'Catalog combines accent-insensitive search, progress filters and duration ordering',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 740));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = AcademyStore();
      await store.recordScore(courses.first.lessons.first, 2);
      await tester.pumpWidget(
        MaterialApp(
          theme: academyTheme(true),
          home: Scaffold(body: CatalogScreen(store: store)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'criptografia');
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<CourseCard>(find.byType(CourseCard))
            .map((c) => c.course.id),
        ['crypto-foundations', 'keys-data', 'web-security', 'secure-coding'],
      );
      await tester.ensureVisible(find.byTooltip('Limpiar búsqueda'));
      await tester.tap(find.byTooltip('Limpiar búsqueda'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Filtrar por progreso'));
      await tester.tap(find.byTooltip('Filtrar por progreso'));
      await tester.pumpAndSettle();
      await tester.tap(
        find
            .ancestor(
              of: find.text('En curso'),
              matching: find.byType(CheckedPopupMenuItem<String>),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<CourseCard>(find.byType(CourseCard))
            .map((c) => c.course.id),
        ['foundations'],
      );
      await tapLabel(tester, 'Quitar filtros');
      expect(find.byType(CourseCard), findsNWidgets(25));
      await tester.ensureVisible(find.byTooltip('Ordenar cursos'));
      await tester.tap(find.byTooltip('Ordenar cursos'));
      await tester.pumpAndSettle();
      await tester.tap(
        find
            .ancestor(
              of: find.text('Menor duración'),
              matching: find.byType(CheckedPopupMenuItem<String>),
            )
            .first,
      );
      await tester.pumpAndSettle();
      final durations = tester
          .widgetList<CourseCard>(find.byType(CourseCard))
          .map((card) => card.course.minutes)
          .toList();
      expect(durations, [...durations]..sort());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'A concept opens its original theory and the linked lesson; syllabus changes lessons safely',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final course = courses.firstWhere((course) => course.id == 'linux-start');
      final store = AcademyStore();
      await tester.pumpWidget(
        MaterialApp(
          theme: academyTheme(true),
          home: CourseScreen(course: course, store: store),
        ),
      );
      await tester.pumpAndSettle();
      await tapLabel(tester, 'Conceptos');
      await tapLabel(tester, 'Leer concepto');
      expect(
        find.text(course.lessons.first.sections.first.body),
        findsOneWidget,
      );
      await tapLabel(tester, 'Estudiar esta lección');
      expect(store.lastLessonId, course.lessons.first.id);
      expect(
        tester
            .widget<AoiClassroom>(find.byType(AoiClassroom))
            .dialogue!
            .lessonId,
        course.lessons.first.id,
      );
      await tester.tap(find.byTooltip('Temario del curso'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(course.lessons.last.title),
        400,
        scrollable: find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );
      await tapLabel(tester, course.lessons.last.title);
      expect(find.text(course.lessons.last.title), findsOneWidget);
      expect(store.lastLessonId, course.lessons.last.id);
      expect(store.scores, isEmpty);
      expect(
        tester
            .widget<AoiClassroom>(find.byType(AoiClassroom))
            .dialogue!
            .lessonId,
        course.lessons.last.id,
      );
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Tu curso'), findsOneWidget);
      expect(find.text('Tu aula con Aoi'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Continue opens the last incomplete lesson and retains best grades',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final course = courses.first;
      final store = AcademyStore();
      await store.recordScore(course.lessons.first, 3);
      store.openLesson(course.lessons[6]);
      await tester.pumpWidget(
        MaterialApp(
          theme: academyTheme(true),
          home: CourseScreen(course: course, store: store),
        ),
      );
      await tester.pumpAndSettle();
      await tapLabel(tester, 'Continuar curso');
      expect(find.text(course.lessons[6].title), findsOneWidget);
      expect(store.scores[course.lessons.first.id], 3);
      expect(store.completedLessons, 1);
    },
  );

  testWidgets(
    'Course outline and concept reader fit small phones, desktop, light theme and large text',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final course = courses.firstWhere(
        (course) => course.id == 'linux-investigation',
      );
      for (final (size, dark, scale) in [
        (const Size(320, 640), true, 1.0),
        (const Size(320, 740), false, 1.5),
        (const Size(1440, 960), false, 1.15),
      ]) {
        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(
          MaterialApp(
            theme: academyTheme(dark, palette: NeonTheme.violet),
            key: UniqueKey(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(size: size, textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: CourseScreen(
              key: UniqueKey(),
              course: course,
              store: AcademyStore(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tapLabel(tester, 'Temario');
        await tapLabel(tester, 'Módulo 3 · ${course.lessons[8].title}');
        await tester.ensureVisible(find.text(course.lessons.last.title));
        expect(find.text(course.lessons.last.title), findsOneWidget);
        await tapLabel(tester, 'Conceptos');
        await tapLabel(tester, 'Leer concepto');
        expect(
          find.text(course.lessons.first.sections.first.body),
          findsOneWidget,
        );
        await tester.tap(find.byTooltip('Cerrar concepto'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    },
  );
}
