import 'package:aiocyb/src/app.dart';
import 'package:aiocyb/src/data/curriculum.dart';
import 'package:aiocyb/src/data/aoi_library.dart';
import 'package:aiocyb/src/models/aoi_dialogue.dart';
import 'package:aiocyb/src/widgets/aoi_classroom.dart';
import 'package:aiocyb/src/widgets/aoi_portrait.dart';
import 'package:aiocyb/src/screens/lesson_screens.dart';
import 'package:aiocyb/src/state/academy_store.dart';
import 'package:aiocyb/src/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUpAll(() async {
    await AoiLibrary.load();
  });

  testWidgets(
    'Pinned tutor keeps the same dialogue after revisiting and restoring',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 740));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = AcademyStore()..onboarded = true;
      await tester.pumpWidget(
        MaterialApp(
          theme: academyTheme(true),
          home: LessonScreen(lesson: allLessons.first, store: store),
        ),
      );
      await tester.pumpAndSettle();
      final firstDialogue = tester
          .widget<AoiClassroom>(find.byType(AoiClassroom))
          .dialogue!;
      final position = tester.getRect(find.byType(AoiPortrait));
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byType(AoiPortrait)), position);
      _expectNoDialogueControls();
      await tester.ensureVisible(find.text('Teoría'));
      await tester.tap(find.text('Teoría'));
      await tester.pumpAndSettle();
      final theoryDialogue = tester
          .widget<AoiClassroom>(find.byType(AoiClassroom))
          .dialogue!;
      expect(theoryDialogue.stage, AoiStage.theory);
      expect(theoryDialogue.id, isNot(firstDialogue.id));
      await tester.tap(find.text('Inicio'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<AoiClassroom>(find.byType(AoiClassroom)).dialogue!.id,
        firstDialogue.id,
      );
      await store.retrySave();
      await tester.pumpWidget(const SizedBox.shrink());
      final restored = AcademyStore();
      await restored.load();
      await tester.pumpWidget(
        MaterialApp(
          theme: academyTheme(true),
          home: LessonScreen(lesson: allLessons.first, store: restored),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.widget<AoiClassroom>(find.byType(AoiClassroom)).dialogue!.id,
        firstDialogue.id,
      );
      _expectNoDialogueControls();
    },
  );

  testWidgets('Classroom adapts to landscape and large text without overflow', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final library = await AoiLibrary.load();
    final entry = library.entries.first;
    for (final size in [
      const Size(320, 740),
      const Size(915, 412),
      const Size(1024, 480),
      const Size(1200, 800),
    ]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(
        MaterialApp(
          theme: academyTheme(true),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: Scaffold(
            appBar: AppBar(title: const Text('Aula')),
            body: AoiClassroom(
              content: const SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Contenido de la lección'),
                ),
              ),
              dialogue: entry,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AoiPortrait), findsOneWidget);
      expect(find.text(entry.text), findsOneWidget);
      _expectNoDialogueControls();
    }
  });
  setUp(
    () => SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty(),
  );

  testWidgets('Leaving a partial attempt discards it and returns safely', (
    tester,
  ) async {
    final store = AcademyStore();
    final lesson = allLessons.first;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push<int>(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizScreen(
                    store: store,
                    lessonId: lesson.id,
                    title: lesson.title,
                    questions: lesson.questions,
                    passingScore: 2,
                    onComplete: (score) => store.recordScore(lesson, score),
                  ),
                ),
              ),
              child: const Text('Abrir práctica'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir práctica'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(lesson.questions.first.options.first));
    await tester.pump();
    await tester.ensureVisible(find.text('Comprobar respuesta'));
    await tester.tap(find.text('Comprobar respuesta'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('¿Salir de la práctica?'), findsOneWidget);
    await tester.tap(find.text('Salir'));
    await tester.pumpAndSettle();
    expect(find.text('Abrir práctica'), findsOneWidget);
    expect(store.scores, isEmpty);
  });

  testWidgets(
    'Presentation opens the academy on a small Android-sized screen',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = AcademyStore();
      await tester.pumpWidget(AiocybApp(store: store));
      await tester.pumpAndSettle();
      expect(find.text('Menos sustos.\nMás criterio digital.'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Alex');
      await tester.ensureVisible(find.text('Entrar a mi academia'));
      await tester.tap(find.text('Entrar a mi academia'));
      await tester.pumpAndSettle();
      expect(find.text('Hola, Alex'), findsOneWidget);
      expect(store.onboarded, isTrue);
    },
  );

  testWidgets(
    'Course search filters content and settings work at narrow width',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 740));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = AcademyStore()..onboarded = true;
      await tester.pumpWidget(AiocybApp(store: store));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.auto_stories_outlined).last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'pesquen');
      await tester.pumpAndSettle();
      expect(find.text('Que no te pesquen'), findsOneWidget);
      expect(find.text('Tus cuentas, bajo llave'), findsNothing);
      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Tema oscuro'));
      await tester.tap(find.text('Tema oscuro'));
      await tester.pumpAndSettle();
      expect(store.darkMode, isFalse);
      expect(find.text('El humor de Byte'), findsNothing);
      expect(find.text('El humor de Aoi Bite'), findsNothing);
      expect(find.byType(SwitchListTile), findsNWidgets(3));
    },
  );

  testWidgets(
    'Theory and case keep their tutor while hints belong only to exercises',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 740));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = AcademyStore()..onboarded = true;
      await tester.pumpWidget(
        MaterialApp(
          theme: academyTheme(true),
          home: LessonScreen(lesson: allLessons.first, store: store),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AoiPortrait), findsOneWidget);
      await tester.tap(find.text('Teoría'));
      await tester.pumpAndSettle();
      expect(find.text(allLessons.first.sections.first.title), findsOneWidget);
      await tester.ensureVisible(find.text('Caso'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Caso'));
      await tester.pumpAndSettle();
      final scenarioDialogue = tester
          .widget<AoiClassroom>(find.byType(AoiClassroom))
          .dialogue!;
      expect(scenarioDialogue.stage, AoiStage.scenario);
      expect(find.text('Dame una pista'), findsNothing);
      _expectNoDialogueControls();
      await tester.ensureVisible(find.text('Practicar · 3 ejercicios'));
      await tester.tap(find.text('Practicar · 3 ejercicios'));
      await tester.pumpAndSettle();
      expect(
        find.text(allLessons.first.questions.first.prompt),
        findsOneWidget,
      );
      expect(find.text('Dame una pista'), findsOneWidget);
      _expectNoDialogueControls();
    },
  );

  testWidgets(
    'Answers explain mistakes, passing saves progress and retry starts fresh',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = AcademyStore();
      final lesson = allLessons.first;
      await tester.pumpWidget(
        MaterialApp(
          theme: academyTheme(true),
          home: QuizScreen(
            store: store,
            lessonId: lesson.id,
            title: lesson.title,
            questions: lesson.questions,
            passingScore: 2,
            onComplete: (score) => store.recordScore(lesson, score),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final initialQuestionId = tester
          .widget<AoiClassroom>(find.byType(AoiClassroom))
          .dialogue!
          .id;
      String? firstMistakeId;
      for (var i = 0; i < lesson.questions.length; i++) {
        final question = lesson.questions[i];
        final answer = i == 0 ? 0 : question.answer;
        final hint = find.widgetWithIcon(
          OutlinedButton,
          Icons.lightbulb_outline,
        );
        expect(tester.widget<OutlinedButton>(hint).onPressed, isNotNull);
        if (i == 0) {
          await tester.ensureVisible(hint);
          await tester.tap(hint);
          await tester.pumpAndSettle();
          expect(tester.widget<OutlinedButton>(hint).onPressed, isNull);
          expect(
            tester
                .widget<AoiClassroom>(find.byType(AoiClassroom))
                .dialogue!
                .stage,
            AoiStage.hint,
          );
          expect(
            tester
                .widget<AoiPortrait>(find.byType(AoiPortrait))
                .expression
                .name,
            'thinking',
          );
        }
        await tester.ensureVisible(find.text(question.options[answer]));
        await tester.tap(find.text(question.options[answer]));
        await tester.pump();
        await tester.ensureVisible(find.text('Comprobar respuesta'));
        await tester.tap(find.text('Comprobar respuesta'));
        await tester.pumpAndSettle();
        final dialogue = tester
            .widget<AoiClassroom>(find.byType(AoiClassroom))
            .dialogue!;
        expect(dialogue.stage, i == 0 ? AoiStage.incorrect : AoiStage.correct);
        expect(dialogue.anchor, i);
        if (i == 0) {
          firstMistakeId = dialogue.id;
          expect(dialogue.choiceIndex, answer);
        }
        expect(
          tester.widget<AoiPortrait>(find.byType(AoiPortrait)).expression.name,
          i == 0 ? 'disappointed' : 'delighted',
        );
        expect(find.text(dialogue.explanation), findsOneWidget);
        _expectNoDialogueControls();
        final next = find.text(
          i == lesson.questions.length - 1
              ? 'Ver mi resultado'
              : 'Siguiente ejercicio',
        );
        await tester.ensureVisible(next);
        await tester.tap(next);
        await tester.pumpAndSettle();
      }
      expect(find.text('¡Lección superada!'), findsOneWidget);
      expect(store.completedLessons, 1);
      expect(store.scores[lesson.id], 2);
      expect(
        tester.widget<AoiPortrait>(find.byType(AoiPortrait)).expression.name,
        'delighted',
      );
      _expectNoDialogueControls();
      await tester.ensureVisible(find.text('Volver a practicar'));
      await tester.tap(find.text('Volver a practicar'));
      await tester.pumpAndSettle();
      expect(find.text('EJERCICIO 1 DE 3'), findsOneWidget);
      expect(
        tester.widget<AoiClassroom>(find.byType(AoiClassroom)).dialogue!.id,
        initialQuestionId,
      );
      final freshHint = find.widgetWithIcon(
        OutlinedButton,
        Icons.lightbulb_outline,
      );
      expect(tester.widget<OutlinedButton>(freshHint).onPressed, isNotNull);
      await tester.ensureVisible(find.text(lesson.questions.first.options[0]));
      await tester.tap(find.text(lesson.questions.first.options[0]));
      await tester.pump();
      await tester.ensureVisible(find.text('Comprobar respuesta'));
      await tester.tap(find.text('Comprobar respuesta'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<AoiClassroom>(find.byType(AoiClassroom)).dialogue!.id,
        isNot(firstMistakeId),
      );
      expect(
        tester.widget<AoiPortrait>(find.byType(AoiPortrait)).expression,
        AoiExpression.exasperated,
      );
      expect(store.mistakeCount(lesson.id, 0), 2);
      expect(store.xp, 50);
    },
  );

  testWidgets('A failed attempt shows disappointment and preserves progress', (
    tester,
  ) async {
    final store = AcademyStore();
    final lesson = allLessons.first;
    await tester.pumpWidget(
      MaterialApp(
        theme: academyTheme(true),
        home: QuizScreen(
          store: store,
          lessonId: lesson.id,
          title: lesson.title,
          questions: lesson.questions,
          passingScore: 2,
          onComplete: (score) => store.recordScore(lesson, score),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (var i = 0; i < lesson.questions.length; i++) {
      final question = lesson.questions[i];
      final wrongAnswer = (question.answer + 1) % question.options.length;
      await tester.ensureVisible(find.text(question.options[wrongAnswer]));
      await tester.tap(find.text(question.options[wrongAnswer]));
      await tester.pump();
      await tester.ensureVisible(find.text('Comprobar respuesta'));
      await tester.tap(find.text('Comprobar respuesta'));
      await tester.pumpAndSettle();
      final next = find.text(
        i == lesson.questions.length - 1
            ? 'Ver mi resultado'
            : 'Siguiente ejercicio',
      );
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    expect(find.text('Un repaso y otra oportunidad.'), findsOneWidget);
    expect(store.completedLessons, 0);
    expect(store.scores[lesson.id], 0);
    expect(
      tester.widget<AoiPortrait>(find.byType(AoiPortrait)).expression.name,
      'disappointed',
    );
    _expectNoDialogueControls();
  });

  testWidgets('First course completion shows pride only on that achievement', (
    tester,
  ) async {
    final store = AcademyStore();
    final course = courses.first;
    for (final completed in course.lessons.take(course.lessons.length - 1)) {
      await store.recordScore(completed, completed.questions.length);
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
          passingScore: 2,
          onComplete: (score) => store.recordScore(lesson, score),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (var attempt = 0; attempt < 2; attempt++) {
      for (var i = 0; i < lesson.questions.length; i++) {
        final question = lesson.questions[i];
        await tester.ensureVisible(
          find.text(question.options[question.answer]),
        );
        await tester.tap(find.text(question.options[question.answer]));
        await tester.pump();
        await tester.ensureVisible(find.text('Comprobar respuesta'));
        await tester.tap(find.text('Comprobar respuesta'));
        await tester.pumpAndSettle();
        final next = find.text(
          i == lesson.questions.length - 1
              ? 'Ver mi resultado'
              : 'Siguiente ejercicio',
        );
        await tester.ensureVisible(next);
        await tester.tap(next);
        await tester.pumpAndSettle();
      }
      expect(store.courseProgress(course), 1);
      expect(store.xp, course.lessons.length * 50);
      expect(
        tester.widget<AoiPortrait>(find.byType(AoiPortrait)).expression.name,
        attempt == 0 ? 'proud' : 'delighted',
      );
      expect(
        tester
            .widget<AoiClassroom>(find.byType(AoiClassroom))
            .dialogue!
            .stage
            .name,
        attempt == 0 ? 'courseComplete' : 'result',
      );
      _expectNoDialogueControls();
      if (attempt == 0) {
        await tester.ensureVisible(find.text('Volver a practicar'));
        await tester.tap(find.text('Volver a practicar'));
        await tester.pumpAndSettle();
      }
    }
  });
}

void _expectNoDialogueControls() {
  for (final label in [
    'Otra explicación',
    'Conversación guardada',
    'Releer explicaciones vistas',
  ]) {
    expect(find.text(label), findsNothing);
    expect(find.byTooltip(label), findsNothing);
  }
}
