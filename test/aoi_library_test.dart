import 'dart:convert';
import 'dart:io';

import 'package:aiocyb/src/data/aoi_library.dart';
import 'package:aiocyb/src/data/curriculum.dart';
import 'package:aiocyb/src/data/linux_curriculum.g.dart';
import 'package:aiocyb/src/data/micro_lesson_dialogues.dart';
import 'package:aiocyb/src/data/network_expansion.g.dart';
import 'package:aiocyb/src/models/aoi_dialogue.dart';
import 'package:flutter_test/flutter_test.dart';

String normalized(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9áéíóúüñ]'), '');

void main() {
  late AoiLibrary library;
  setUpAll(() async {
    final entries = <AoiDialogue>[];
    for (final asset in AoiLibrary.assetPaths) {
      final decoded =
          jsonDecode(await File(asset).readAsString()) as Map<String, dynamic>;
      entries.addAll(
        (decoded['dialogues'] as List).map(
          (item) =>
              AoiDialogue.fromJson(Map<String, dynamic>.from(item as Map)),
        ),
      );
    }
    library = AoiLibrary([...entries, ...microLessonDialogues()]);
  });

  test('At least 500 authored conversations and explanations are unique', () {
    final authored = library.entries
        .where((entry) => !entry.id.startsWith('micro-'))
        .toList();
    expect(authored.length, greaterThanOrEqualTo(500));
    expect(
      library.entries.map((entry) => entry.id).toSet().length,
      library.entries.length,
    );
    expect(
      authored.map((entry) => normalized(entry.text)).toSet().length,
      authored.length,
    );
    expect(
      authored.map((entry) => normalized(entry.explanation)).toSet().length,
      authored.length,
    );
    for (final entry in authored) {
      expect(
        entry.text.split(RegExp(r'\s+')).length,
        greaterThanOrEqualTo(15),
        reason: entry.id,
      );
      expect(
        entry.explanation.split(RegExp(r'\s+')).length,
        greaterThanOrEqualTo(25),
        reason: entry.id,
      );
    }
  });

  test('Every context and distractor maps to an actual lesson element', () {
    for (final entry in library.entries) {
      final diagnostic = entry.lessonId == 'diagnostic';
      final lesson = diagnostic
          ? null
          : allAssessmentLessons.singleWhere(
              (lesson) => lesson.id == entry.lessonId,
            );
      final questions = lesson?.questions ?? diagnosticQuestions;
      final maxAnchor = switch (entry.stage) {
        AoiStage.intro || AoiStage.courseComplete => 1,
        AoiStage.scenario => lesson!.cases.isEmpty ? 1 : lesson.cases.length,
        AoiStage.theory => lesson!.sections.length,
        AoiStage.procedure => lesson!.steps.length,
        AoiStage.result => 2,
        _ => questions.length,
      };
      expect(
        entry.anchor,
        inInclusiveRange(0, maxAnchor - 1),
        reason: entry.id,
      );
      if (entry.stage == AoiStage.incorrect) {
        expect(
          entry.choiceIndex,
          inInclusiveRange(0, questions[entry.anchor].options.length - 1),
          reason: entry.id,
        );
        expect(
          entry.choiceIndex,
          isNot(questions[entry.anchor].answer),
          reason: entry.id,
        );
      }
    }
  });

  test(
    'Every lesson has complete teaching and course celebration coverage',
    () {
      for (final lesson in allLessons) {
        final original = lesson.tutor.isEmpty;
        expect(
          library.entries.where((entry) => entry.lessonId == lesson.id).length,
          greaterThanOrEqualTo(15),
        );
        expect(
          library.forContext(lesson.id, AoiStage.courseComplete, 0),
          isNotEmpty,
        );
        for (var section = 0; section < lesson.sections.length; section++) {
          expect(
            library.forContext(lesson.id, AoiStage.theory, section).length,
            original ? 6 : 1,
          );
        }
        for (var step = 0; step < lesson.steps.length; step++) {
          expect(
            library.forContext(lesson.id, AoiStage.procedure, step),
            isNotEmpty,
          );
        }
        for (var index = 0; index < lesson.questions.length; index++) {
          expect(
            library.forContext(lesson.id, AoiStage.question, index).length,
            original ? 3 : 1,
          );
          expect(
            library.forContext(lesson.id, AoiStage.hint, index).length,
            original ? 4 : 1,
          );
          expect(
            library.forContext(lesson.id, AoiStage.correct, index).length,
            original ? 3 : 1,
          );
          for (
            var choice = 0;
            choice < lesson.questions[index].options.length;
            choice++
          ) {
            if (choice == lesson.questions[index].answer) continue;
            expect(
              library
                  .forContext(
                    lesson.id,
                    AoiStage.incorrect,
                    index,
                    choiceIndex: choice,
                  )
                  .length,
              2,
            );
          }
        }
      }
    },
  );

  test('Context selects a fixed explanation, including after restoring', () {
    final seen = <String>{};
    final selected = <String>[];
    final session = AoiConversation(
      library: library,
      seenIds: seen,
      onSeen: selected.add,
    );
    final intro = session.open('digital-life', AoiStage.intro, 0)!;
    expect(session.open('digital-life', AoiStage.intro, 0)!.id, intro.id);
    final theory = session.open('digital-life', AoiStage.theory, 0)!;
    expect(theory.id, isNot(intro.id));
    expect(session.open('digital-life', AoiStage.intro, 0)!.id, intro.id);
    expect(selected, [intro.id, theory.id]);
    final restored = AoiConversation(
      library: library,
      seenIds: {...seen},
      onSeen: selected.add,
    );
    expect(restored.open('digital-life', AoiStage.intro, 0)!.id, intro.id);
    expect(selected.length, 2);
  });

  test(
    'Wrong-answer conversations explain the specific selected distractor',
    () {
      final session = AoiConversation(
        library: library,
        seenIds: {},
        onSeen: (_) {},
      );
      for (final lesson in allAssessmentLessons) {
        for (var index = 0; index < lesson.questions.length; index++) {
          for (
            var choice = 0;
            choice < lesson.questions[index].options.length;
            choice++
          ) {
            if (choice == lesson.questions[index].answer) continue;
            final entry = session.open(
              lesson.id,
              AoiStage.incorrect,
              index,
              choiceIndex: choice,
            )!;
            expect(entry.choiceIndex, choice);
            expect(entry.anchor, index);
          }
        }
      }
    },
  );

  test('First error and repeated error have fixed, distinct reactions', () {
    final session = AoiConversation(
      library: library,
      seenIds: {},
      onSeen: (_) {},
    );
    for (final lesson in allAssessmentLessons) {
      final question = lesson.questions.first;
      final choice = (question.answer + 1) % question.options.length;
      final first = session.open(
        lesson.id,
        AoiStage.incorrect,
        0,
        choiceIndex: choice,
      )!;
      final repeat = session.open(
        lesson.id,
        AoiStage.incorrect,
        0,
        choiceIndex: choice,
        repeatedMistake: true,
      )!;
      expect(repeat.id, isNot(first.id), reason: lesson.id);
      expect(repeat.text, isNot(first.text), reason: lesson.id);
      final expressive =
          linuxCourses.any((course) => course.lessons.contains(lesson)) ||
          advancedNetworkCourses.any(
            (course) => course.lessons.contains(lesson),
          ) ||
          allPracticeLessons.contains(lesson);
      expect(first.expression, expressive ? 'pouting' : 'disappointed');
      expect(repeat.expression, 'exasperated');
      expect(
        session
            .open(
              lesson.id,
              AoiStage.incorrect,
              0,
              choiceIndex: choice,
              repeatedMistake: true,
            )!
            .id,
        repeat.id,
      );
    }
  });
}
