import 'package:aiocyb/src/data/aoi_library.dart';
import 'package:aiocyb/src/data/curriculum.dart';
import 'package:aiocyb/src/data/extended_curriculum.g.dart';
import 'package:aiocyb/src/models/aoi_dialogue.dart';
import 'package:aiocyb/src/screens/lesson_screens.dart';
import 'package:aiocyb/src/state/academy_store.dart';
import 'package:aiocyb/src/theme.dart';
import 'package:aiocyb/src/widgets/aoi_classroom.dart';
import 'package:aiocyb/src/widgets/aoi_portrait.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUpAll(() async {
    await AoiLibrary.load();
  });
  setUp(
    () => SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty(),
  );

  test('Six complete routes contain 240 distinct, usable micro-lessons', () {
    expect(extendedCourses, hasLength(6));
    expect(courses, hasLength(25));
    expect(allLessons, hasLength(430));
    final sourceIds = sources.map((source) => source.id).toSet();
    final ids = <String>{};
    final theories = <String>{};
    final scripts = <String>{};
    for (final course in extendedCourses) {
      expect(course.lessons, hasLength(40), reason: course.id);
      for (final lesson in course.lessons) {
        expect(ids.add(lesson.id), isTrue, reason: lesson.id);
        expect(theories.add(lesson.sections.single.body), isTrue);
        expect(
          lesson.sections.single.body.split(RegExp(r'\s+')).length,
          greaterThanOrEqualTo(60),
        );
        expect(lesson.questions, hasLength(1));
        expect(
          lesson.sourceIds.every(sourceIds.contains),
          isTrue,
          reason: lesson.id,
        );
        for (final line in lesson.tutor.values) {
          expect(scripts.add(line), isTrue, reason: lesson.id);
        }
        final question = lesson.questions.single;
        for (var choice = 0; choice < 3; choice++) {
          if (choice != question.answer) {
            expect(question.wrongExplanations[choice], isNotEmpty);
          }
        }
      }
    }
  });

  testWidgets(
    'A long course keeps its final lesson accessible through the course outline',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final course = extendedCourses.first;
      final store = AcademyStore();
      await tester.pumpWidget(
        MaterialApp(
          theme: academyTheme(true),
          home: CourseScreen(course: course, store: store),
        ),
      );
      await tester.pumpAndSettle();
      final block = find.text('Módulo 4 · ${course.lessons[30].title}');
      await tester.ensureVisible(block);
      await tester.pumpAndSettle();
      await tester.tap(block);
      await tester.pumpAndSettle();
      final last = find.text(course.lessons.last.title);
      await tester.ensureVisible(last);
      await tester.pumpAndSettle();
      await tester.tap(last);
      await tester.pumpAndSettle();
      expect(find.text('Tu aula con Aoi'), findsOneWidget);
      expect(find.text(course.lessons.last.title), findsOneWidget);
      expect(
        tester
            .widget<AoiClassroom>(find.byType(AoiClassroom))
            .dialogue!
            .lessonId,
        course.lessons.last.id,
      );
      await tester.ensureVisible(find.text('Practicar · 1 ejercicio'));
      await tester.tap(find.text('Practicar · 1 ejercicio'));
      await tester.pumpAndSettle();
      expect(find.text(course.lessons.last.scenario), findsOneWidget);
      expect(find.text('Caso de la lección'), findsOneWidget);
    },
  );

  testWidgets(
    'Last micro-lesson handles failure, repeat and a forty-lesson achievement',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = AcademyStore();
      final course = extendedCourses.first;
      for (final lesson in course.lessons.take(39)) {
        await store.recordScore(lesson, 1);
      }
      final lesson = course.lessons.last;
      final question = lesson.questions.single;
      await tester.pumpWidget(
        MaterialApp(
          theme: academyTheme(true),
          home: QuizScreen(
            store: store,
            lessonId: lesson.id,
            title: lesson.title,
            questions: lesson.questions,
            scenario: lesson.scenario,
            passingScore: store.passingScore(lesson),
            onComplete: (score) => store.recordScore(lesson, score),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (var attempt = 0; attempt < 3; attempt++) {
        expect(find.text('EJERCICIO 1 DE 1'), findsOneWidget);
        final choice = attempt == 2
            ? question.answer
            : (question.answer + 1) % 3;
        await tester.ensureVisible(find.text(question.options[choice]));
        await tester.tap(find.text(question.options[choice]));
        await tester.pump();
        await tester.ensureVisible(find.text('Comprobar respuesta'));
        await tester.tap(find.text('Comprobar respuesta'));
        await tester.pumpAndSettle();
        final dialogue = tester
            .widget<AoiClassroom>(find.byType(AoiClassroom))
            .dialogue!;
        expect(
          dialogue.stage,
          attempt == 2 ? AoiStage.correct : AoiStage.incorrect,
        );
        expect(
          tester.widget<AoiPortrait>(find.byType(AoiPortrait)).expression,
          [
            AoiExpression.disappointed,
            AoiExpression.exasperated,
            AoiExpression.delighted,
          ][attempt],
        );
        if (attempt < 2) {
          expect(dialogue.explanation, question.wrongExplanations[choice]);
        }
        await tester.ensureVisible(find.text('Ver mi resultado'));
        await tester.tap(find.text('Ver mi resultado'));
        await tester.pumpAndSettle();
        if (attempt < 2) {
          expect(store.courseProgress(course), 39 / 40);
          await tester.ensureVisible(find.text('Volver a practicar'));
          await tester.tap(find.text('Volver a practicar'));
          await tester.pumpAndSettle();
        }
      }
      expect(find.text('¡Curso completado!'), findsOneWidget);
      expect(store.courseProgress(course), 1);
      expect(store.xp, 2000);
      expect(
        tester.widget<AoiPortrait>(find.byType(AoiPortrait)).expression,
        AoiExpression.proud,
      );
      final restored = AcademyStore();
      await restored.load();
      expect(restored.courseProgress(course), 1);
      expect(restored.mistakeCount(lesson.id, 0), 2);
    },
  );
}
