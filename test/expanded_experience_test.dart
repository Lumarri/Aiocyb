import 'dart:convert';
import 'dart:io';

import 'package:aiocyb/src/app.dart';
import 'package:aiocyb/src/data/aoi_library.dart';
import 'package:aiocyb/src/data/curriculum.dart';
import 'package:aiocyb/src/data/learning_paths.dart';
import 'package:aiocyb/src/data/linux_curriculum.g.dart';
import 'package:aiocyb/src/data/offline_labs.dart';
import 'package:aiocyb/src/data/secure_curriculum.g.dart';
import 'package:aiocyb/src/models/aoi_dialogue.dart';
import 'package:aiocyb/src/screens/academy_screens.dart';
import 'package:aiocyb/src/screens/explore_screens.dart';
import 'package:aiocyb/src/state/academy_store.dart';
import 'package:aiocyb/src/theme.dart';
import 'package:aiocyb/src/widgets/aoi_classroom.dart';
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
  setUpAll(() async {
    await AoiLibrary.load();
  });
  setUp(
    () => SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty(),
  );

  test('Four original courses meet the chosen depth and preserve all 330 previous grades', () async {
    expect(secureCourses, hasLength(4));
    final theories = <String>{},
        cases = <String>{},
        prompts = <String>{},
        lines = <String>{},
        feedback = <String>{};
    final sourceIds = sources.map((source) => source.id).toSet();
    for (final course in secureCourses) {
      expect(course.lessons, hasLength(10));
      expect(course.exerciseCount, 30);
      expect(lines.add(course.completionTutor), isTrue);
      final original = jsonDecode(
        File('assets/secure/${course.id}.json').readAsStringSync(),
      );
      for (final (index, lesson) in course.lessons.indexed) {
        expect(
          lesson.theoryWordCount,
          inInclusiveRange(600, 900),
          reason: lesson.id,
        );
        expect(lesson.sections, hasLength(4));
        expect(lesson.cases, hasLength(2));
        expect(lesson.questions, hasLength(3));
        expect(lesson.sourceIds.every(sourceIds.contains), isTrue);
        for (final (sectionIndex, section) in lesson.sections.indexed) {
          expect(theories.add(section.body), isTrue);
          expect(
            section.body,
            original['lessons'][index]['sections'][sectionIndex]['body'],
          );
        }
        for (final studyCase in lesson.cases) {
          expect(cases.add(studyCase.scenario), isTrue);
          expect(
            studyCase.explanation.split(RegExp(r'\s+')).length,
            greaterThanOrEqualTo(35),
          );
        }
        for (final line in lesson.tutor.values) {
          expect(lines.add(line), isTrue);
        }
        for (final question in lesson.questions) {
          expect(prompts.add(question.prompt), isTrue);
          expect(cases.add(question.scenario!), isTrue);
          expect(question.wrongExplanations[question.answer], isNull);
          for (final text in [
            question.explanation,
            ...question.wrongExplanations.whereType<String>(),
          ]) {
            expect(feedback.add(text), isTrue);
          }
          for (final line in question.tutor.values) {
            expect(lines.add(line), isTrue);
          }
        }
      }
    }
    expect(theories, hasLength(160));
    expect(cases, hasLength(200));
    expect(prompts, hasLength(120));
    expect(feedback, hasLength(360));
    expect(lines, hasLength(964));
    expect(
      learningPaths.expand((path) => path.courseIds).toSet(),
      courses.map((course) => course.id).toSet(),
    );
    final previous = courses
        .where(
          (course) =>
              !secureCourses.contains(course) && !linuxCourses.contains(course),
        )
        .expand((course) => course.lessons)
        .toList();
    expect(previous, hasLength(330));
    await SharedPreferencesAsync().setString(
      AcademyStore.storageKey,
      jsonEncode({
        'onboarded': true,
        'name': 'Alex',
        'darkMode': false,
        'largeText': true,
        'scores': {
          for (final lesson in previous) lesson.id: lesson.questions.length,
        },
        'mistakeCounts': {'digital-life:2': 2},
        'heardDialogueIds': ['f-digital-life-intro-0-1'],
      }),
    );
    final restored = AcademyStore();
    await restored.load();
    expect(restored.completedLessons, 330);
    expect(restored.xp, 16500);
    expect(restored.darkMode, isFalse);
    expect(restored.largeText, isTrue);
    expect(restored.neonTheme, NeonTheme.cyan);
    expect(restored.neonGlow, isTrue);
    expect(restored.mistakeCount('digital-life', 2), 2);
    expect(restored.resumeLesson.id, secureCourses.first.lessons.first.id);
  });

  test('Neon, favorites, lab achievements and resolved reviews persist without changing grades', () async {
    final store = AcademyStore();
    final lesson = allLessons.first;
    await store.finishOnboarding('Alex');
    await store.recordScore(lesson, 2);
    await store.toggleFavorite(lesson.id);
    await store.updateSettings(
      palette: NeonTheme.violet,
      glow: false,
      biggerText: true,
    );
    await store.recordMistake(lesson.id, 2);
    expect(store.needsReview(lesson.id, 2), isTrue);
    await store.markReviewed(lesson.id, 2);
    expect(store.needsReview(lesson.id, 2), isFalse);
    await store.recordMistake(lesson.id, 2);
    expect(store.needsReview(lesson.id, 2), isTrue);
    await store.recordMistake('diagnostic', 4);
    await store.markReviewed('diagnostic', 4);
    await store.recordLabMistake(offlineLabs.first.id, 1);
    await store.completeLab(offlineLabs.first.id);
    await store.completeLab(offlineLabs.first.id);
    final restored = AcademyStore();
    await restored.load();
    expect(restored.neonTheme, NeonTheme.violet);
    expect(restored.neonGlow, isFalse);
    expect(restored.favoriteLessons, {lesson.id});
    expect(restored.completedLabs, {offlineLabs.first.id});
    expect(restored.labMistakes['${offlineLabs.first.id}:1'], 1);
    expect(restored.needsReview(lesson.id, 2), isTrue);
    expect(restored.needsReview('diagnostic', 4), isFalse);
    expect(restored.scores[lesson.id], 2);
    expect(restored.xp, 50);
    await restored.resetProgress();
    final reset = AcademyStore();
    await reset.load();
    expect(reset.completedLabs, isEmpty);
    expect(reset.labMistakes, isEmpty);
    expect(reset.reviewedMistakes, isEmpty);
    expect(reset.favoriteLessons, {lesson.id});
    expect(reset.neonTheme, NeonTheme.violet);
    expect(reset.neonGlow, isFalse);
    expect(reset.name, 'Alex');
    expect(reset.xp, 0);
  });

  testWidgets(
    'Settings apply both neon palettes and save glow and light mode',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = AcademyStore();
      await tester.pumpWidget(
        ListenableBuilder(
          listenable: store,
          builder: (context, _) => MaterialApp(
            theme: academyTheme(
              store.darkMode,
              palette: store.neonTheme,
              glow: store.neonGlow,
            ),
            home: Scaffold(body: SettingsScreen(store: store)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tapLabel(tester, 'Neón violeta');
      expect(
        Theme.of(tester.element(find.byType(SettingsScreen)))
            .colorScheme
            .primary,
        const Color(0xFFC4B5FD),
      );
      await tapLabel(tester, 'Brillo suave');
      await tapLabel(tester, 'Tema oscuro');
      expect(
        Theme.of(tester.element(find.byType(SettingsScreen)))
            .extension<NeonStyle>()!
            .glow,
        isFalse,
      );
      expect(
        Theme.of(tester.element(find.byType(SettingsScreen))).brightness,
        Brightness.light,
      );
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, 500),
      );
      await tester.pumpAndSettle();
      await tapLabel(tester, 'Neón cian');
      expect(
        Theme.of(tester.element(find.byType(SettingsScreen)))
            .colorScheme
            .primary,
        const Color(0xFF006578),
      );
      final restored = AcademyStore();
      await restored.load();
      expect(restored.neonTheme, NeonTheme.cyan);
      expect(restored.darkMode, isFalse);
      expect(restored.neonGlow, isFalse);
      expect(find.text('Desactivar diálogos irónicos'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Library searches deep theory, filters bookmarks and removes a favorite from its lesson',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = AcademyStore();
      final lesson = secureCourses.first.lessons.first;
      await store.toggleFavorite(lesson.id);
      await tester.pumpWidget(
        MaterialApp(
          theme: academyTheme(true),
          home: LibraryScreen(store: store),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'técnicas que permiten construir',
      );
      await tester.pumpAndSettle();
      expect(find.text(lesson.title), findsOneWidget);
      await tapLabel(tester, 'Solo favoritos');
      await tapLabel(tester, lesson.title);
      await tester.tap(find.byTooltip('Quitar de favoritos'));
      await tester.pumpAndSettle();
      expect(store.favoriteLessons, isEmpty);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('0 lecciones encontradas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'All four labs require their three correct decisions, remember repeated mistakes and award no course XP',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.binding.setSurfaceSize(const Size(390, 844));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final store = AcademyStore();
        await tester.pumpWidget(
          MaterialApp(
            theme: academyTheme(true),
            home: LabsScreen(store: store),
          ),
        );
        await tester.pumpAndSettle();
        for (final (labIndex, lab) in offlineLabs.indexed) {
          await tapLabel(tester, lab.title);
          if (labIndex == 0) {
            for (var attempt = 0; attempt < 2; attempt++) {
              await tapLabel(
                tester,
                lab.stages.first.options[(lab.stages.first.answer + 1) % 3],
              );
              await tapLabel(tester, 'Probar decisión');
              final dialogue = tester
                  .widget<AoiClassroom>(find.byType(AoiClassroom))
                  .dialogue!;
              expect(
                dialogue.text,
                attempt == 0 ? lab.stages.first.soft : lab.stages.first.sharp,
              );
              expect(store.completedLabs, isEmpty);
              await tapLabel(tester, 'Revisar mi decisión');
            }
          }
          for (final (index, stage) in lab.stages.indexed) {
            expect(find.bySemanticsLabel(stage.evidence), findsOneWidget);
            await tapLabel(tester, stage.options[stage.answer]);
            await tapLabel(tester, 'Probar decisión');
            expect(
              tester
                  .widget<AoiClassroom>(find.byType(AoiClassroom))
                  .dialogue!
                  .text,
              stage.correct,
            );
            await tapLabel(
              tester,
              index == 2 ? 'Terminar simulación' : 'Siguiente etapa',
            );
          }
          expect(store.completedLabs.contains(lab.id), isTrue);
          expect(
            tester
                .widget<AoiClassroom>(find.byType(AoiClassroom))
                .dialogue!
                .text,
            lab.closure,
          );
          await tapLabel(tester, 'Volver al laboratorio');
        }
        final restored = AcademyStore();
        await restored.load();
        expect(
          restored.completedLabs,
          offlineLabs.map((lab) => lab.id).toSet(),
        );
        expect(restored.xp, 0);
        expect(restored.labMistakes['${offlineLabs.first.id}:0'], 2);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'Review uses the original nonzero question anchor and resolves it without changing its grade',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = AcademyStore();
      final lesson = secureCourses.first.lessons.first;
      const index = 2;
      await store.recordScore(lesson, 2);
      await store.recordMistake(lesson.id, index);
      await tester.pumpWidget(
        MaterialApp(
          theme: academyTheme(true),
          home: ReviewExerciseScreen(
            store: store,
            lesson: lesson,
            index: index,
          ),
        ),
      );
      await tester.pumpAndSettle();
      AoiDialogue dialogue() =>
          tester.widget<AoiClassroom>(find.byType(AoiClassroom)).dialogue!;
      expect(dialogue().anchor, index);
      expect(dialogue().text, lesson.questions[index].tutor['question']);
      await tapLabel(tester, 'Dame una pista');
      expect(dialogue().text, lesson.questions[index].tutor['hint']);
      await tapLabel(
        tester,
        lesson.questions[index].options[lesson.questions[index].answer],
      );
      await tapLabel(tester, 'Comprobar respuesta');
      expect(dialogue().text, lesson.questions[index].tutor['correct']);
      expect(dialogue().anchor, index);
      expect(store.needsReview(lesson.id, index), isFalse);
      expect(store.scores[lesson.id], 2);
      expect(store.xp, 50);
      final restored = AcademyStore();
      await restored.load();
      expect(restored.needsReview(lesson.id, index), isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Expanded shell and sections remain usable on a narrow phone and a short desktop',
    (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final size in [const Size(320, 640), const Size(1024, 480)]) {
        await tester.binding.setSurfaceSize(size);
        final store = AcademyStore();
        await store.finishOnboarding('Alex');
        await tester.pumpWidget(AiocybApp(key: UniqueKey(), store: store));
        await tester.pumpAndSettle();
        await tapLabel(tester, 'Explorar');
        for (final section in exploreSections) {
          expect(find.text(section.$1), findsOneWidget);
        }
        await tapLabel(tester, 'Logros');
        expect(find.text('Esto ya es tuyo.'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
      }
    },
  );
}
