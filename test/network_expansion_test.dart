import 'dart:convert';
import 'dart:io';

import 'package:aiocyb/src/data/aoi_library.dart';
import 'package:aiocyb/src/data/curriculum.dart';
import 'package:aiocyb/src/data/extended_curriculum.g.dart';
import 'package:aiocyb/src/data/learning_paths.dart';
import 'package:aiocyb/src/data/network_expansion.g.dart';
import 'package:aiocyb/src/models/aoi_dialogue.dart';
import 'package:aiocyb/src/models/learning_overview.dart';
import 'package:aiocyb/src/screens/practice_bank.dart';
import 'package:aiocyb/src/state/academy_store.dart';
import 'package:aiocyb/src/theme.dart';
import 'package:aiocyb/src/widgets/aoi_classroom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

Future<void> _tapLabel(WidgetTester tester, String label) async {
  final target = find.text(label).first;
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
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

  test(
    'Six deep courses preserve their authored cases and all 360 decisions',
    () {
      expect(advancedNetworkCourses, hasLength(6));
      expect(courses, hasLength(31));
      expect(allLessons, hasLength(490));
      expect(allPracticeLessons, hasLength(240));
      expect(allAssessmentLessons, hasLength(730));
      expect(
        allAssessmentLessons.expand((lesson) => lesson.questions),
        hasLength(1530),
      );
      expect(
        allAssessmentLessons.map((lesson) => lesson.id).toSet(),
        hasLength(730),
      );
      final sourceIds = sources.map((source) => source.id).toSet();
      final lines = <String>{}, prompts = <String>{}, feedback = <String>{};
      final cases = <String>{}, theories = <String>{};
      for (final course in advancedNetworkCourses) {
        expect(course.lessons, hasLength(10), reason: course.id);
        expect(course.practiceLessons, isEmpty);
        expect(course.exerciseCount, 60);
        expect(lines.add(course.completionTutor), isTrue);
        final raw = jsonDecode(
          File('assets/network_expansion/${course.id}.json').readAsStringSync(),
        ) as Map<String, dynamic>;
        final originals = (raw['lessons'] as List).cast<Map<String, dynamic>>();
        final positions = [0, 0, 0];
        for (final (index, lesson) in course.lessons.indexed) {
          final original = originals[index];
          expect(lesson.id, original['id']);
          expect(
            lesson.theoryWordCount,
            inInclusiveRange(600, 900),
            reason: lesson.id,
          );
          expect(lesson.sections, hasLength(4));
          expect(lesson.cases, hasLength(2));
          expect(lesson.questions, hasLength(6));
          expect(lesson.steps.length, greaterThanOrEqualTo(3));
          expect(lesson.sourceIds.length, greaterThanOrEqualTo(2));
          expect(lesson.sourceIds.every(sourceIds.contains), isTrue);
          expect(lesson.tutor, original['aoi']);
          final authoredLines = [
            ...lesson.tutor.values,
            ...lesson.questions.expand((question) => question.tutor.values),
          ];
          expect(authoredLines.toSet(), hasLength(39), reason: lesson.id);
          for (final line in authoredLines) {
            expect(line.split(RegExp(r'\s+')).length, greaterThanOrEqualTo(7));
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
            expect(question.scenario, authored['scenario']);
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
        expect(positions, [20, 20, 20], reason: course.id);
      }
      expect(theories, hasLength(240));
      expect(cases, hasLength(120));
      expect(prompts, hasLength(360));
      expect(feedback, hasLength(1080));
      expect(lines, hasLength(2346));
      expect(
        learningPaths
            .singleWhere((path) => path.id == 'advanced-networks')
            .courseIds,
        advancedNetworkCourses.map((course) => course.id),
      );
      expect(learningPaths, hasLength(6));
      expect(
        learningPaths.expand((path) => path.courseIds).toSet(),
        courses.map((course) => course.id).toSet(),
      );
    },
  );

  test(
    'Optional reinforcement keeps all 240 old lesson objects and 1/1 passes',
    () {
      final store = AcademyStore();
      expect(extendedCourses, hasLength(6));
      expect(networkReinforcementQuestions, hasLength(240));
      final originalIds = <String>{}, practiceIds = <String>{};
      final prompts = <String>{}, lines = <String>{};
      for (final original in extendedCourses) {
        final enriched = courses.singleWhere(
          (course) => course.id == original.id,
        );
        expect(identical(enriched.lessons, original.lessons), isTrue);
        expect(enriched.lessons, hasLength(40));
        expect(enriched.practiceLessons, hasLength(40));
        expect(enriched.exerciseCount, 80);
        for (final (index, lesson) in original.lessons.indexed) {
          expect(identical(enriched.lessons[index], lesson), isTrue);
          expect(lesson.questions, hasLength(1));
          expect(store.passingScore(lesson), 1);
          expect(originalIds.add(lesson.id), isTrue);
          final practice = enriched.practiceLessons[index];
          expect(practice.id, '${lesson.id}-reinforcement');
          expect(practiceIds.add(practice.id), isTrue);
          expect(practice.questions, hasLength(1));
          expect(store.passingScore(practice), 1);
          final question = networkReinforcementQuestions[lesson.id]!;
          expect(identical(practice.questions.single, question), isTrue);
          expect(question.prompt, isNot(lesson.questions.single.prompt));
          expect(question.scenario, isNot(lesson.scenario));
          expect(prompts.add(question.prompt), isTrue);
          expect(question.tutor.keys.toSet(), {
            'question',
            'hint',
            'correct',
            'soft',
            'sharp',
            'pass',
            'review',
          });
          expect(practice.tutor['pass'], question.tutor['pass']);
          expect(practice.tutor['review'], question.tutor['review']);
          for (final line in question.tutor.values) {
            expect(lines.add(line), isTrue, reason: practice.id);
          }
          expect(allLessons, isNot(contains(practice)));
          expect(allPracticeLessons, contains(practice));
          expect(allAssessmentLessons, contains(practice));
        }
      }
      expect(originalIds, networkReinforcementQuestions.keys.toSet());
      expect(practiceIds.intersection(originalIds), isEmpty);
      expect(lines, hasLength(1680));
    },
  );

  test('Version 1.6 saves retain grades, resume, preferences and old course completion', () async {
    final newIds = advancedNetworkCourses.map((course) => course.id).toSet();
    final oldCourses = courses.where((course) => !newIds.contains(course.id));
    final previous = oldCourses.expand((course) => course.lessons).toList();
    expect(oldCourses, hasLength(25));
    expect(previous, hasLength(430));
    final resume = previous.last;
    final oldScores = {
      for (final lesson in previous) lesson.id: lesson.questions.length,
      resume.id: 0,
    };
    final oldMistake = '${previous.first.id}:0';
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
        'lastLessonId': resume.id,
        'diagnosticScore': 4,
        'favoriteLessons': [previous.first.id, resume.id],
        'completedLabs': ['protection'],
        'labMistakes': {'protection:0': 2},
        'mistakeCounts': {oldMistake: 2},
        'reviewedMistakes': {oldMistake: 2},
        'heardDialogueIds': ['old-fixed-dialogue'],
      }),
    );
    final store = AcademyStore();
    await store.load();
    expect(store.storageError, isNull);
    expect(store.scores, oldScores);
    expect(store.completedLessons, 429);
    expect(store.completedPractice, 0);
    expect(store.xp, 21450);
    expect(store.lastLessonId, resume.id);
    expect(identical(store.resumeLesson, resume), isTrue);
    expect(store.favoriteLessons, {previous.first.id, resume.id});
    expect(store.completedLabs, {'protection'});
    expect(store.labMistakes, {'protection:0': 2});
    expect(store.darkMode, isFalse);
    expect(store.largeText, isTrue);
    expect(store.neonTheme, NeonTheme.violet);
    expect(store.neonGlow, isFalse);
    expect(store.name, 'Alex');
    expect(store.onboarded, isTrue);
    expect(store.diagnosticScore, 4);
    expect(store.mistakeCount(previous.first.id, 0), 2);
    expect(store.needsReview(previous.first.id, 0), isFalse);
    expect(store.heardDialogueIds, contains('old-fixed-dialogue'));
    expect(
      store.startedCourseIds,
      oldCourses.map((course) => course.id).toSet(),
    );
    expect(store.startedCourseIds.intersection(newIds), isEmpty);
    for (final original in extendedCourses) {
      final enriched = courses.singleWhere(
        (course) => course.id == original.id,
      );
      expect(store.courseProgress(enriched), 1);
      expect(enriched.lessons.where(store.isComplete), hasLength(40));
      expect(enriched.practiceLessons.where(store.isComplete), isEmpty);
    }
    final overview = LearningOverview(store);
    expect(overview.attemptedLessons, 430);
    expect(overview.gradedQuestions, 930);
    expect(overview.pendingReviews, 0);
  });

  test('Six-question lessons require four and keep best grades and single XP awards', () async {
    final store = AcademyStore(), course = advancedNetworkCourses.first;
    for (final lesson in course.lessons.take(9)) {
      expect(store.passingScore(lesson), 4);
      await store.recordScore(lesson, 4);
    }
    final finalLesson = course.lessons.last;
    await store.recordScore(finalLesson, 3);
    expect(store.isComplete(finalLesson), isFalse);
    expect(store.courseProgress(course), .9);
    expect(store.xp, 450);
    await store.recordScore(finalLesson, 4);
    expect(store.isComplete(finalLesson), isTrue);
    expect(store.courseProgress(course), 1);
    expect(store.xp, 500);
    await store.recordScore(finalLesson, 2);
    await store.recordScore(finalLesson, 4);
    final restored = AcademyStore();
    await restored.load();
    expect(restored.scores[finalLesson.id], 4);
    expect(restored.completedLessons, 10);
    expect(restored.completedPractice, 0);
    expect(restored.xp, 500);
    final closure = AoiConversation(
      library: library,
      seenIds: {},
      onSeen: (_) {},
    ).open(finalLesson.id, AoiStage.courseComplete, 0)!;
    expect(closure.expression, 'celebrating');
    expect(closure.text, course.completionTutor);
  });

  test('Practice grades and review survive reload without changing completion or XP', () async {
    final course = courses.singleWhere(
      (course) => course.id == extendedCourses.first.id,
    );
    final practice = course.practiceLessons.first;
    final original = course.lessons.first;
    final resume = extendedCourses[1].lessons.first;
    final store = AcademyStore();
    await store.finishOnboarding('Alex');
    await store.updateSettings(
      dark: false,
      biggerText: true,
      palette: NeonTheme.violet,
      glow: false,
    );
    for (final lesson in course.lessons) {
      await store.recordScore(lesson, 1);
    }
    await store.openLesson(resume);
    await store.toggleFavorite(original.id);
    await store.recordMistake(practice.id, 0);
    await store.recordScore(practice, 0);
    expect(store.scores[original.id], 1);
    expect(store.courseProgress(course), 1);
    expect(store.completedPractice, 0);
    expect(store.xp, 2000);
    expect(LearningOverview(store).pendingReviews, 1);
    final failed = AcademyStore();
    await failed.load();
    expect(failed.scores[practice.id], 0);
    expect(failed.mistakeCount(practice.id, 0), 1);
    expect(failed.needsReview(practice.id, 0), isTrue);
    expect(failed.resumeLesson.id, resume.id);
    await failed.recordMistake(practice.id, 0);
    await failed.markReviewed(practice.id, 0);
    await failed.recordScore(practice, 1);
    await failed.recordScore(practice, 0);
    final passed = AcademyStore();
    await passed.load();
    expect(passed.scores[practice.id], 1);
    expect(passed.scores[original.id], 1);
    expect(passed.mistakeCount(practice.id, 0), 2);
    expect(passed.reviewedMistakes['${practice.id}:0'], 2);
    expect(passed.needsReview(practice.id, 0), isFalse);
    expect(passed.completedPractice, 1);
    expect(passed.completedLessons, 40);
    expect(passed.courseProgress(course), 1);
    expect(passed.xp, 2000);
    expect(passed.lastLessonId, resume.id);
    expect(LearningOverview(passed).attemptedLessons, 40);
    expect(LearningOverview(passed).gradedQuestions, 41);
    expect(LearningOverview(passed).bestCorrectAnswers, 41);
    expect(LearningOverview(passed).pendingReviews, 0);
    expect(() => passed.recordScore(practice, 2), throwsArgumentError);
    await passed.recordMistake(practice.id, 0);
    expect(passed.needsReview(practice.id, 0), isTrue);
    await passed.resetProgress();
    final reset = AcademyStore();
    await reset.load();
    expect(reset.scores, isEmpty);
    expect(reset.completedLessons, 0);
    expect(reset.completedPractice, 0);
    expect(reset.xp, 0);
    expect(reset.mistakeCounts, isEmpty);
    expect(reset.reviewedMistakes, isEmpty);
    expect(reset.lastLessonId, isNull);
    expect(reset.favoriteLessons, {original.id});
    expect(reset.name, 'Alex');
    expect(reset.largeText, isTrue);
    expect(reset.darkMode, isFalse);
    expect(reset.neonTheme, NeonTheme.violet);
    expect(reset.neonGlow, isFalse);
  });

  test('Practice scripts are fixed, choice-specific and escalate only repeated errors', () {
    final conversation = AoiConversation(
      library: library,
      seenIds: {},
      onSeen: (_) {},
    );
    for (final lesson in allPracticeLessons) {
      final question = lesson.questions.single;
      final first = conversation.open(lesson.id, AoiStage.question, 0)!;
      expect(first.text, question.tutor['question']);
      expect(first.expression, 'focused');
      expect(conversation.open(lesson.id, AoiStage.question, 0)!.id, first.id);
      expect(
        conversation.open(lesson.id, AoiStage.hint, 0)!.text,
        question.tutor['hint'],
      );
      for (var choice = 0; choice < question.options.length; choice++) {
        if (choice == question.answer) continue;
        final soft = conversation.open(
          lesson.id,
          AoiStage.incorrect,
          0,
          choiceIndex: choice,
        )!;
        final sharp = conversation.open(
          lesson.id,
          AoiStage.incorrect,
          0,
          choiceIndex: choice,
          repeatedMistake: true,
        )!;
        expect(soft.text, question.tutor['soft']);
        expect(soft.expression, 'pouting');
        expect(sharp.text, question.tutor['sharp']);
        expect(sharp.expression, 'exasperated');
        expect(sharp.id, isNot(soft.id));
        expect(soft.explanation, question.wrongExplanations[choice]);
        expect(sharp.explanation, question.wrongExplanations[choice]);
      }
      expect(
        conversation.open(lesson.id, AoiStage.correct, 0)!.text,
        question.tutor['correct'],
      );
      expect(
        conversation.open(lesson.id, AoiStage.result, 0)!.text,
        question.tutor['pass'],
      );
      expect(
        conversation.open(lesson.id, AoiStage.result, 1)!.text,
        question.tutor['review'],
      );
      expect(conversation.open(lesson.id, AoiStage.courseComplete, 0), isNull);
    }
  });

  testWidgets(
    'Practice bank retries keep contextual Aoi, original resume and independent results',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final course = courses.singleWhere(
        (course) => course.id == extendedCourses.first.id,
      );
      final practice = course.practiceLessons.first;
      final question = practice.questions.single;
      final resume = extendedCourses[1].lessons.first;
      final store = AcademyStore();
      for (final lesson in course.lessons) {
        await store.recordScore(lesson, 1);
      }
      await store.openLesson(resume);
      await tester.pumpWidget(
        MaterialApp(
          theme: academyTheme(true),
          home: PracticeBankScreen(course: course, store: store),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('0 de 40 refuerzos superados'), findsOneWidget);
      await _tapLabel(tester, '1. ${practice.title}');
      expect(find.text('Refuerzo con Aoi'), findsOneWidget);
      AoiDialogue dialogue() =>
          tester.widget<AoiClassroom>(find.byType(AoiClassroom)).dialogue!;
      expect(dialogue().text, question.tutor['question']);
      final initialId = dialogue().id;
      await tester.pump();
      expect(dialogue().id, initialId);
      await _tapLabel(tester, 'Dame una pista');
      expect(dialogue().text, question.tutor['hint']);
      for (var attempt = 0; attempt < 3; attempt++) {
        final wrong = attempt < 2;
        await _tapLabel(
          tester,
          question.options[wrong ? (question.answer + 1) % 3 : question.answer],
        );
        await _tapLabel(tester, 'Comprobar respuesta');
        expect(
          dialogue().text,
          question.tutor[wrong ? (attempt == 0 ? 'soft' : 'sharp') : 'correct'],
        );
        expect(
          dialogue().expression,
          wrong ? (attempt == 0 ? 'pouting' : 'exasperated') : 'relieved',
        );
        expect(
          dialogue().explanation,
          wrong
              ? question.wrongExplanations[(question.answer + 1) % 3]
              : question.explanation,
        );
        for (final label in [
          'Otra explicación',
          'Conversación guardada',
          'Desactivar diálogos irónicos',
        ]) {
          expect(find.text(label), findsNothing);
        }
        await _tapLabel(tester, 'Ver mi resultado');
        expect(store.scores[practice.id], wrong ? 0 : 1);
        expect(store.xp, 2000);
        expect(store.completedLessons, 40);
        expect(store.completedPractice, wrong ? 0 : 1);
        expect(store.courseProgress(course), 1);
        expect(store.lastLessonId, resume.id);
        expect(dialogue().text, question.tutor[wrong ? 'review' : 'pass']);
        expect(dialogue().expression, wrong ? 'disappointed' : 'blushing');
        expect(find.text('¡Curso completado!'), findsNothing);
        if (attempt < 2) {
          await _tapLabel(tester, 'Volver a practicar');
          expect(dialogue().id, initialId);
        }
      }
      expect(find.text('¡Refuerzo superado!'), findsOneWidget);
      await _tapLabel(tester, 'Volver a los refuerzos');
      expect(find.text('Refuerzos del curso'), findsOneWidget);
      expect(find.text('1 de 40 refuerzos superados'), findsOneWidget);
      expect(find.text('Mejor nota: 1 / 1'), findsOneWidget);
      final restored = AcademyStore();
      await restored.load();
      expect(restored.scores[practice.id], 1);
      expect(restored.mistakeCount(practice.id, 0), 2);
      expect(restored.needsReview(practice.id, 0), isTrue);
      expect(restored.lastLessonId, resume.id);
      expect(restored.xp, 2000);
      expect(tester.takeException(), isNull);
    },
  );
}
