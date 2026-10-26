import 'dart:convert';

import 'package:aiocyb/src/data/aoi_library.dart';
import 'package:aiocyb/src/data/curriculum.dart';
import 'package:aiocyb/src/models/aoi_dialogue.dart';
import 'package:aiocyb/src/screens/lesson_screens.dart';
import 'package:aiocyb/src/state/academy_store.dart';
import 'package:aiocyb/src/theme.dart';
import 'package:aiocyb/src/widgets/aoi_classroom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late AoiLibrary library;
  setUpAll(() async => library = await AoiLibrary.load());
  setUp(
    () => SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty(),
  );

  test(
    'Each starter course offers thirty distinct, fully explained exercises',
    () {
      final prompts = <String>{};
      final lines = <String>{};
      final cases = <String>{};
      final explanations = <String>{};
      for (final course in starterCourses) {
        expect(course.lessons, hasLength(10));
        expect(
          course.lessons.expand((lesson) => lesson.questions),
          hasLength(30),
        );
        final original = initialCourses.singleWhere((c) => c.id == course.id);
        expect(course.lessons.take(2), orderedEquals(original.lessons));
        for (final lesson in course.lessons.skip(2)) {
          expect(lesson.questions, hasLength(3));
          for (final question in lesson.questions) {
            expect(prompts.add(question.prompt), isTrue);
            expect(question.scenario, isNotNull);
            expect(cases.add(question.scenario!), isTrue);
            expect(question.scenario, isNot(lesson.scenario));
            expect(explanations.add(question.explanation), isTrue);
            for (var choice = 0; choice < question.options.length; choice++) {
              if (choice != question.answer) {
                expect(
                  explanations.add(question.wrongExplanations[choice]!),
                  isTrue,
                );
              }
            }
            for (final line in question.tutor.values) {
              expect(lines.add(line), isTrue);
            }
          }
        }
      }
      expect(prompts, hasLength(72));
      expect(cases, hasLength(72));
      expect(lines, hasLength(360));
      expect(explanations, hasLength(216));
      expect(allLessons.expand((lesson) => lesson.questions), hasLength(930));
    },
  );

  test(
    'Every new question selects its own fixed hint, answer and error script',
    () {
      final session = AoiConversation(
        library: library,
        seenIds: <String>{},
        onSeen: (_) {},
      );
      for (final course in starterCourses) {
        for (final lesson in course.lessons.skip(2)) {
          for (final (index, question) in lesson.questions.indexed) {
            for (final (stage, field) in [
              (AoiStage.question, 'question'),
              (AoiStage.hint, 'hint'),
              (AoiStage.correct, 'correct'),
            ]) {
              final first = session.open(lesson.id, stage, index)!;
              expect(first.text, question.tutor[field]);
              expect(session.open(lesson.id, stage, index)!.id, first.id);
              expect(
                first.explanation,
                stage == AoiStage.correct ? question.explanation : isEmpty,
              );
            }
            for (var choice = 0; choice < question.options.length; choice++) {
              if (choice == question.answer) continue;
              final gentle = session.open(
                lesson.id,
                AoiStage.incorrect,
                index,
                choiceIndex: choice,
              )!;
              final sharp = session.open(
                lesson.id,
                AoiStage.incorrect,
                index,
                choiceIndex: choice,
                repeatedMistake: true,
              )!;
              expect(gentle.text, question.tutor['soft']);
              expect(sharp.text, question.tutor['sharp']);
              expect(gentle.expression, 'disappointed');
              expect(sharp.expression, 'exasperated');
              expect(gentle.explanation, question.wrongExplanations[choice]);
              expect(sharp.explanation, question.wrongExplanations[choice]);
            }
          }
        }
      }
    },
  );

  test(
    'Existing grades, XP and mistake history survive the content expansion',
    () async {
      const legacyAnswers = {
        'digital-life': [1, 0, 2],
        'risk-routine': [0, 1, 2],
        'passwords': [0, 1, 2],
        'mfa': [1, 0, 2],
        'phishing-signals': [1, 2, 0],
        'safe-response': [2, 0, 1],
      };
      await SharedPreferencesAsync().setString(
        AcademyStore.storageKey,
        jsonEncode({
          'onboarded': true,
          'name': 'Alex',
          'scores': {for (final id in legacyAnswers.keys) id: 3},
          'mistakeCounts': {'passwords:1': 2},
          'heardDialogueIds': ['f-digital-life-intro-0-1'],
          'lastLessonId': 'safe-response',
        }),
      );
      final restored = AcademyStore();
      await restored.load();
      expect(restored.storageError, isNull);
      expect(restored.name, 'Alex');
      expect(restored.completedLessons, 6);
      expect(restored.xp, 300);
      expect(restored.mistakeCount('passwords', 1), 2);
      expect(restored.heardDialogueIds, contains('f-digital-life-intro-0-1'));
      expect(restored.lastLessonId, 'safe-response');
      for (final course in starterCourses) {
        expect(restored.courseProgress(course), 2 / 10);
        for (final lesson in course.lessons.take(2)) {
          expect(
            lesson.questions.map((q) => q.answer),
            legacyAnswers[lesson.id],
          );
          expect(restored.scores[lesson.id], 3);
        }
        expect(course.lessons.skip(2).any(restored.isComplete), isFalse);
      }
    },
  );

  testWidgets(
    'Practice changes the case and Aoi together and remembers repeated errors',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = AcademyStore();
      final course = starterCourses.first;
      final lesson = course.lessons[2];
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
      Future<void> tap(String label) async {
        await tester.ensureVisible(find.text(label));
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
      }

      for (var attempt = 0; attempt < 2; attempt++) {
        for (final (index, question) in lesson.questions.indexed) {
          expect(find.text('Caso del ejercicio'), findsOneWidget);
          expect(find.text(question.scenario!), findsOneWidget);
          expect(find.text(lesson.scenario), findsNothing);
          if (index > 0) {
            expect(
              find.text(lesson.questions[index - 1].scenario!),
              findsNothing,
            );
          }
          expect(dialogue().text, question.tutor['question']);
          expect(dialogue().explanation, isEmpty);
          await tap('Dame una pista');
          expect(dialogue().text, question.tutor['hint']);
          expect(dialogue().explanation, isEmpty);
          expect(
            tester
                .widget<OutlinedButton>(
                  find.widgetWithText(OutlinedButton, 'Dame una pista'),
                )
                .onPressed,
            isNull,
          );
          final choice = index == 0
              ? (question.answer + 1) % 3
              : question.answer;
          await tap(question.options[choice]);
          await tap('Comprobar respuesta');
          expect(
            dialogue().text,
            question.tutor[index == 0
                ? (attempt == 0 ? 'soft' : 'sharp')
                : 'correct'],
          );
          expect(
            dialogue().explanation,
            index == 0
                ? question.wrongExplanations[choice]
                : question.explanation,
          );
          await tap(index == 2 ? 'Ver mi resultado' : 'Siguiente ejercicio');
        }
        expect(find.text('2 / 3'), findsOneWidget);
        expect(find.text('¡Lección superada!'), findsOneWidget);
        expect(store.scores[lesson.id], 2);
        expect(store.xp, 50);
        expect(store.courseProgress(course), 1 / 10);
        expect(dialogue().stage, AoiStage.result);
        expect(find.text('Otra explicación'), findsNothing);
        expect(find.text('Conversación guardada'), findsNothing);
        if (attempt == 0) await tap('Volver a practicar');
      }
      final restored = AcademyStore();
      await restored.load();
      expect(restored.scores[lesson.id], 2);
      expect(restored.xp, 50);
      expect(restored.mistakeCount(lesson.id, 0), 2);
      expect(restored.mistakeCount(lesson.id, 1), 0);
    },
  );
}
