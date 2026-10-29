import 'dart:convert';
import 'dart:io';

import 'package:aiocyb/src/data/aoi_library.dart';
import 'package:aiocyb/src/data/curriculum.dart';
import 'package:aiocyb/src/data/learning_paths.dart';
import 'package:aiocyb/src/data/linux_curriculum.g.dart';
import 'package:aiocyb/src/data/network_expansion.g.dart';
import 'package:aiocyb/src/models/aoi_dialogue.dart';
import 'package:aiocyb/src/screens/lesson_screens.dart';
import 'package:aiocyb/src/state/academy_store.dart';
import 'package:aiocyb/src/theme.dart';
import 'package:aiocyb/src/widgets/aoi_classroom.dart';
import 'package:aiocyb/src/widgets/aoi_portrait.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

Future<void> tapLabel(WidgetTester tester, String label) async {
  final target = find.text(label).first;
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  late AoiLibrary library;
  setUpAll(() async => library = await AoiLibrary.load());
  setUp(
    () => SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty(),
  );

  test('Six complete original courses match editorial sources and the chosen depth', () {
    expect(linuxCourses, hasLength(6));
    expect(courses, hasLength(31));
    expect(allLessons, hasLength(490));
    expect(allLessons.expand((lesson) => lesson.questions), hasLength(1290));
    final sourceIds = sources.map((source) => source.id).toSet();
    expect(sourceIds.length, sources.length);
    final lines = <String>{},
        theories = <String>{},
        prompts = <String>{},
        feedback = <String>{},
        cases = <String>{};
    for (final course in linuxCourses) {
      expect(course.lessons, hasLength(10));
      expect(course.exerciseCount, 40);
      expect(lines.add(course.completionTutor), isTrue);
      final raw = jsonDecode(
        File('assets/linux/${course.id}.json').readAsStringSync(),
      );
      final positions = [0, 0, 0];
      for (final (index, lesson) in course.lessons.indexed) {
        final original = raw['lessons'][index];
        expect(lesson.id, original['id']);
        expect(
          lesson.theoryWordCount,
          inInclusiveRange(600, 900),
          reason: lesson.id,
        );
        expect(lesson.sections, hasLength(4));
        expect(lesson.cases, hasLength(2));
        expect(lesson.questions, hasLength(4));
        expect(lesson.sourceIds.length, greaterThanOrEqualTo(2));
        expect(lesson.sourceIds.every(sourceIds.contains), isTrue);
        final ownLines = [
          ...lesson.tutor.values,
          ...lesson.questions.expand((question) => question.tutor.values),
        ];
        expect(ownLines.toSet(), hasLength(29));
        expect(ownLines.length, greaterThanOrEqualTo(25));
        for (final line in ownLines) {
          expect(lines.add(line), isTrue, reason: lesson.id);
        }
        for (final (i, section) in lesson.sections.indexed) {
          expect(section.body, original['sections'][i]['body']);
          expect(theories.add(section.body), isTrue);
        }
        for (final (i, studyCase) in lesson.cases.indexed) {
          expect(studyCase.scenario, original['cases'][i]['scenario']);
          expect(studyCase.explanation, original['cases'][i]['explanation']);
          expect(cases.add(studyCase.scenario), isTrue);
        }
        for (final (i, question) in lesson.questions.indexed) {
          final authored = original['questions'][i];
          expect(question.prompt, authored['prompt']);
          expect(question.options, authored['options']);
          expect(question.answer, authored['answer']);
          expect(question.explanation, authored['explanation']);
          expect(question.wrongExplanations, authored['wrongExplanations']);
          expect(question.tutor, authored['aoi']);
          expect(question.wrongExplanations[question.answer], isNull);
          positions[question.answer]++;
          expect(prompts.add(question.prompt), isTrue);
          for (final text in [
            question.explanation,
            ...question.wrongExplanations.whereType<String>(),
          ]) {
            expect(feedback.add(text), isTrue);
          }
        }
      }
      expect(positions.every((count) => count >= 11), isTrue);
    }
    expect(theories, hasLength(240));
    expect(cases, hasLength(120));
    expect(prompts, hasLength(240));
    expect(feedback, hasLength(720));
    expect(lines, hasLength(1746));
    expect(
      learningPaths.singleWhere((path) => path.id == 'linux').courseIds,
      linuxCourses.map((course) => course.id),
    );
    expect(
      learningPaths.expand((path) => path.courseIds).toSet(),
      courses.map((course) => course.id).toSet(),
    );
  });

  test('New expressions and feedback stay fixed by situation and selected distractor', () {
    expect(AoiExpression.values, hasLength(16));
    final seen = <String>{};
    final conversation = AoiConversation(
      library: library,
      seenIds: seen,
      onSeen: (_) {},
    );
    for (final course in linuxCourses) {
      final lesson = course.lessons.first;
      AoiDialogue entry(AoiStage stage, int anchor) =>
          conversation.open(lesson.id, stage, anchor)!;
      final intro = entry(AoiStage.intro, 0);
      expect(intro.expression, 'curious');
      expect(intro.text, lesson.tutor['intro']);
      expect(entry(AoiStage.theory, 0).expression, 'focused');
      expect(entry(AoiStage.theory, 3).expression, 'playful');
      expect(entry(AoiStage.scenario, 0).expression, 'surprised');
      expect(entry(AoiStage.scenario, 1).expression, 'curious');
      expect(entry(AoiStage.result, 0).expression, 'blushing');
      expect(entry(AoiStage.courseComplete, 0).expression, 'celebrating');
      for (final (index, question) in lesson.questions.indexed) {
        expect(
          entry(AoiStage.question, index).text,
          question.tutor['question'],
        );
        expect(entry(AoiStage.hint, index).text, question.tutor['hint']);
        expect(entry(AoiStage.correct, index).expression, 'relieved');
        for (var choice = 0; choice < 3; choice++) {
          if (choice == question.answer) continue;
          final soft = conversation.open(
            lesson.id,
            AoiStage.incorrect,
            index,
            choiceIndex: choice,
          )!;
          expect(soft.expression, 'pouting');
          expect(soft.text, question.tutor['soft']);
          expect(soft.explanation, question.wrongExplanations[choice]);
          final sharp = conversation.open(
            lesson.id,
            AoiStage.incorrect,
            index,
            choiceIndex: choice,
            repeatedMistake: true,
          )!;
          expect(sharp.expression, 'exasperated');
          expect(sharp.text, question.tutor['sharp']);
          expect(sharp.explanation, question.wrongExplanations[choice]);
        }
      }
      expect(entry(AoiStage.intro, 0).id, intro.id);
    }
  });

  test(
    'All 370 previous grades and preferences survive adding sixty lessons',
    () async {
      final previous = courses
          .where(
            (course) =>
                !linuxCourses.contains(course) &&
                !advancedNetworkCourses.contains(course),
          )
          .expand((course) => course.lessons)
          .toList();
      expect(previous, hasLength(370));
      final oldScores = {
        for (final lesson in previous) lesson.id: lesson.questions.length,
      };
      final old = previous.first;
      await SharedPreferencesAsync().setString(
        AcademyStore.storageKey,
        jsonEncode({
          'onboarded': true,
          'name': 'Alex',
          'darkMode': false,
          'largeText': true,
          'neonTheme': 'violet',
          'neonGlow': false,
          'scores': oldScores,
          'lastLessonId': previous.last.id,
          'diagnosticScore': 4,
          'favoriteLessons': [old.id],
          'completedLabs': ['protection'],
          'mistakeCounts': {'${old.id}:0': 2},
          'reviewedMistakes': {'${old.id}:0': 2},
          'heardDialogueIds': ['micro-${old.id}-intro-0--1-false'],
        }),
      );
      final store = AcademyStore();
      await store.load();
      expect(store.scores, oldScores);
      expect(store.completedLessons, 370);
      expect(store.xp, 18500);
      expect(store.resumeLesson.id, linuxCourses.first.lessons.first.id);
      expect(store.favoriteLessons, {old.id});
      expect(store.completedLabs, {'protection'});
      expect(store.darkMode, isFalse);
      expect(store.largeText, isTrue);
      expect(store.neonTheme, NeonTheme.violet);
      expect(store.neonGlow, isFalse);
      expect(store.needsReview(old.id, 0), isFalse);
      expect(store.diagnosticScore, 4);
      final lesson = linuxCourses.first.lessons.first;
      expect(store.passingScore(lesson), 3);
      await store.recordScore(lesson, 2);
      expect(store.xp, 18500);
      await store.recordScore(lesson, 3);
      expect(store.xp, 18550);
      await store.recordScore(lesson, 1);
      expect(store.scores[lesson.id], 3);
      await store.toggleFavorite(lesson.id);
      final restored = AcademyStore();
      await restored.load();
      expect(restored.scores.length, 371);
      expect(restored.scores[lesson.id], 3);
      expect(restored.favoriteLessons, {old.id, lesson.id});
      expect(restored.name, 'Alex');
      expect(restored.mistakeCount(old.id, 0), 2);
    },
  );

  testWidgets(
    'New portraits stay beside deep theory and both cases on phone and desktop',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final size in [const Size(320, 640), const Size(1024, 480)]) {
        await tester.binding.setSurfaceSize(size);
        final lesson = linuxCourses.first.lessons.first;
        await tester.pumpWidget(
          MaterialApp(
            key: UniqueKey(),
            theme: academyTheme(true),
            home: LessonScreen(lesson: lesson, store: AcademyStore()),
          ),
        );
        await tester.pumpAndSettle();
        AoiExpression portrait() =>
            tester.widget<AoiPortrait>(find.byType(AoiPortrait)).expression;
        expect(portrait(), AoiExpression.curious);
        await tapLabel(tester, 'Teoría');
        expect(portrait(), AoiExpression.focused);
        expect(find.text(lesson.sections.first.body), findsOneWidget);
        for (var i = 0; i < 3; i++) {
          await tapLabel(tester, 'Siguiente');
        }
        expect(portrait(), AoiExpression.playful);
        await tapLabel(tester, 'Casos');
        expect(portrait(), AoiExpression.surprised);
        expect(find.text(lesson.cases.first.explanation), findsOneWidget);
        await tapLabel(tester, 'Siguiente');
        expect(portrait(), AoiExpression.curious);
        expect(find.text(lesson.cases.last.explanation), findsOneWidget);
        for (final label in [
          'Otra explicación',
          'Conversación guardada',
          'Desactivar diálogos irónicos',
        ]) {
          expect(find.text(label), findsNothing);
        }
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'Four questions preserve softer mistakes, escalation and one course celebration',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = AcademyStore(), course = linuxCourses.first;
      for (final lesson in course.lessons.take(9)) {
        await store.recordScore(lesson, 3);
      }
      final lesson = course.lessons.last;
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
      AoiDialogue dialogue() =>
          tester.widget<AoiClassroom>(find.byType(AoiClassroom)).dialogue!;
      await tapLabel(tester, 'Dame una pista');
      expect(dialogue().expression, 'focused');
      expect(dialogue().text, lesson.questions.first.tutor['hint']);
      for (var attempt = 0; attempt < 3; attempt++) {
        for (final (index, question) in lesson.questions.indexed) {
          final wrong = attempt == 0 ? index < 2 : attempt == 1 && index == 0;
          await tapLabel(
            tester,
            question.options[wrong
                ? (question.answer + 1) % 3
                : question.answer],
          );
          await tapLabel(tester, 'Comprobar respuesta');
          expect(
            dialogue().text,
            question.tutor[wrong
                ? (attempt == 0 ? 'soft' : 'sharp')
                : 'correct'],
          );
          expect(
            dialogue().expression,
            wrong ? (attempt == 0 ? 'pouting' : 'exasperated') : 'relieved',
          );
          await tapLabel(
            tester,
            index == 3 ? 'Ver mi resultado' : 'Siguiente ejercicio',
          );
        }
        expect(store.scores[lesson.id], attempt + 2);
        expect(store.xp, attempt == 0 ? 450 : 500);
        expect(
          dialogue().expression,
          ['disappointed', 'celebrating', 'blushing'][attempt],
        );
        if (attempt == 1) {
          expect(dialogue().text, course.completionTutor);
        }
        if (attempt < 2) {
          await tapLabel(tester, 'Volver a practicar');
        }
      }
      final restored = AcademyStore();
      await restored.load();
      expect(restored.xp, 500);
      expect(restored.scores[lesson.id], 4);
      expect(restored.mistakeCount(lesson.id, 0), 2);
      expect(tester.takeException(), isNull);
    },
  );
}
