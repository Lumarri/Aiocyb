import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/curriculum.dart';
import '../data/offline_labs.dart';
import '../models/aoi_dialogue.dart';
import '../models/course.dart';
import '../state/academy_store.dart';
import '../theme.dart';
import '../widgets/aoi_classroom.dart';
import '../widgets/common.dart';
import 'aoi_session_state.dart';
import 'lesson_screens.dart';
import 'learning_routes.dart';
export 'learning_routes.dart';

const diagnosticReviewLesson = Lesson(
  id: 'diagnostic',
  title: 'Diagnóstico inicial',
  minutes: 5,
  intro: 'Repasa las decisiones del diagnóstico con Aoi.',
  sections: [],
  steps: [],
  scenario: 'Revisa una situación cotidiana de ciberseguridad.',
  questions: diagnosticQuestions,
  sourceIds: [],
);

const exploreSections = [
  (
    'Rutas de aprendizaje',
    'Un orden sugerido para avanzar desde cero.',
    Icons.route_outlined,
  ),
  (
    'Laboratorio offline',
    'Simula decisiones con archivos, sesiones, claves y código.',
    Icons.science_outlined,
  ),
  (
    'Biblioteca',
    'Busca teoría y guarda las lecciones que quieres consultar.',
    Icons.local_library_outlined,
  ),
  (
    'Repaso de errores',
    'Vuelve a las preguntas que necesitan otra mirada.',
    Icons.psychology_outlined,
  ),
  (
    'Logros',
    'Reconoce los pasos que ya has dado en la academia.',
    Icons.workspace_premium_outlined,
  ),
];

void openExploreSection(BuildContext context, int index, AcademyStore store) {
  Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (_) => switch (index) {
        0 => RoutesScreen(store: store),
        1 => LabsScreen(store: store),
        2 => LibraryScreen(store: store),
        3 => ReviewListScreen(store: store),
        _ => AchievementsScreen(store: store),
      },
    ),
  );
}

class NeonHeader extends StatelessWidget {
  const NeonHeader({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.auto_awesome_outlined,
  });
  final String title, description;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.primary.withValues(alpha: .3)),
        gradient: LinearGradient(
          colors: [scheme.primary.withValues(alpha: .12), scheme.surface],
        ),
        boxShadow: Theme.of(context).extension<NeonStyle>()?.glow == true
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: .08),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary, size: 30),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          Text(description),
        ],
      ),
    );
  }
}

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key, required this.store});
  final AcademyStore store;
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      const NeonHeader(
        title: 'Más formas de aprender.',
        description: 'Elige una ruta, experimenta o vuelve a lo que te costó. Todo está aquí, sin conexión.',
      ),
      const SizedBox(height: 24),
      const TutorMessage(
        'Cursos para entender, laboratorio para decidir y repaso para ajustar. Sí, cariño: ahora tienes más formas de darme la razón con argumentos.',
      ),
      const SizedBox(height: 24),
      LayoutBuilder(
        builder: (context, constraints) => Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final (index, section) in exploreSections.indexed)
              SizedBox(
                width: constraints.maxWidth >= 700
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth,
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(20),
                    leading: Icon(
                      section.$3,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(section.$1),
                    subtitle: Text(section.$2),
                    trailing: const Icon(Icons.arrow_forward_rounded),
                    onTap: () => openExploreSection(context, index, store),
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, required this.store});
  final AcademyStore store;
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _query = '';
  String? _course;
  bool _favorites = false;
  int _page = 0;
  final _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final entries =
          [
                for (final course in courses)
                  for (final lesson in course.lessons) (course, lesson),
              ]
              .where(
                (entry) =>
                    (_course == null || entry.$1.id == _course) &&
                    (!_favorites ||
                        widget.store.favoriteLessons.contains(entry.$2.id)) &&
                    '${entry.$1.title} ${entry.$2.title} ${entry.$2.sections.map((s) => '${s.title} ${s.body}').join(' ')}'
                        .toLowerCase()
                        .contains(_query.toLowerCase()),
              )
              .toList();
      final page = math.min(_page, math.max(0, (entries.length - 1) ~/ 20));
      return Scaffold(
        appBar: AppBar(title: const Text('Biblioteca')),
        body: PageBody(
          maxWidth: 900,
          children: [
            const NeonHeader(
              title: 'Una idea a mano.',
              description: 'Busca en títulos y teoría. Guarda una lección con el marcador para encontrarla después.',
              icon: Icons.local_library_outlined,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _search,
              decoration: const InputDecoration(
                labelText: 'Buscar en la biblioteca',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() {
                _query = value;
                _page = 0;
              }),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _course ?? '',
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Curso'),
              items: [
                const DropdownMenuItem(
                  value: '',
                  child: Text('Todos los cursos'),
                ),
                for (final course in courses)
                  DropdownMenuItem(
                    value: course.id,
                    child: Text(course.title, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (value) => setState(() {
                _course = value == '' ? null : value;
                _page = 0;
              }),
            ),
            const SizedBox(height: 14),
            FilterChip(
              label: const Text('Solo favoritos'),
              selected: _favorites,
              onSelected: (value) => setState(() {
                _favorites = value;
                _page = 0;
              }),
            ),
            SectionTitle(
              entries.length == 1
                  ? '1 lección encontrada'
                  : '${entries.length} lecciones encontradas',
            ),
            if (entries.isEmpty)
              const Text(
                'No hay coincidencias. Prueba otro término o guarda una lección desde su aula.',
              ),
            for (final (course, lesson) in entries.skip(page * 20).take(20))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    title: Text(lesson.title),
                    subtitle: Text(
                      '${course.title}\n${lesson.theoryWordCount} palabras de teoría · ${lesson.questions.length} ejercicios',
                    ),
                    trailing: IconButton(
                      tooltip: widget.store.favoriteLessons.contains(lesson.id)
                          ? 'Quitar de favoritos'
                          : 'Guardar en biblioteca',
                      icon: Icon(
                        widget.store.favoriteLessons.contains(lesson.id)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                      ),
                      onPressed: () => widget.store.toggleFavorite(lesson.id),
                    ),
                    onTap: () => openLesson(context, lesson, widget.store),
                  ),
                ),
              ),
            if (entries.length > 20)
              Wrap(
                spacing: 14,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: page == 0
                        ? null
                        : () => setState(() => _page = page - 1),
                    child: const Text('Página anterior'),
                  ),
                  Text('Página ${page + 1} de ${(entries.length / 20).ceil()}'),
                  OutlinedButton(
                    onPressed: (page + 1) * 20 >= entries.length
                        ? null
                        : () => setState(() => _page = page + 1),
                    child: const Text('Página siguiente'),
                  ),
                ],
              ),
          ],
        ),
      );
    },
  );
}

class ReviewListScreen extends StatelessWidget {
  const ReviewListScreen({super.key, required this.store});
  final AcademyStore store;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final pending = [
        for (final lesson in [...allLessons, diagnosticReviewLesson])
          for (var i = 0; i < lesson.questions.length; i++)
            if (store.needsReview(lesson.id, i)) (lesson, i),
      ];
      return Scaffold(
        appBar: AppBar(title: const Text('Repaso de errores')),
        body: PageBody(
          maxWidth: 900,
          children: [
            NeonHeader(
              title: 'Volver también es avanzar.',
              description:
                  '${pending.length} ejercicios pendientes. Un acierto aquí resuelve el repaso; la nota y los XP del curso se conservan.',
              icon: Icons.psychology_outlined,
            ),
            const SizedBox(height: 24),
            if (pending.isEmpty)
              const TutorMessage(
                'No tienes repasos pendientes, cariño. Cuando una pregunta se atragante, la traeremos aquí para entenderla con calma.',
              ),
            for (final (lesson, index) in pending)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    title: Text(lesson.questions[index].prompt),
                    subtitle: Text(
                      '${lesson.title} · ${store.mistakeCount(lesson.id, index)} fallos registrados',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewExerciseScreen(
                          store: store,
                          lesson: lesson,
                          index: index,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

class ReviewExerciseScreen extends StatefulWidget {
  const ReviewExerciseScreen({
    super.key,
    required this.store,
    required this.lesson,
    required this.index,
  });
  final AcademyStore store;
  final Lesson lesson;
  final int index;
  @override
  State<ReviewExerciseScreen> createState() => _ReviewExerciseScreenState();
}

class _ReviewExerciseScreenState extends State<ReviewExerciseScreen>
    with AoiSessionState<ReviewExerciseScreen> {
  int? _choice;
  bool _checked = false, _saving = false, _hint = false;
  @override
  AcademyStore get tutorStore => widget.store;
  @override
  String get tutorLessonId => widget.lesson.id;
  Question get question => widget.lesson.questions[widget.index];
  @override
  void onAoiReady() => _say();
  void _say() => speak(
    _checked
        ? (_choice == question.answer ? AoiStage.correct : AoiStage.incorrect)
        : (_hint ? AoiStage.hint : AoiStage.question),
    widget.index,
    choiceIndex: _checked ? _choice : null,
    repeatedMistake:
        _checked &&
        _choice != question.answer &&
        widget.store.mistakeCount(widget.lesson.id, widget.index) > 1,
  );
  Future<void> _check() async {
    if (_choice == null || _saving || _checked) return;
    setState(() => _saving = true);
    if (_choice == question.answer) {
      await widget.store.markReviewed(widget.lesson.id, widget.index);
    } else {
      await widget.store.recordMistake(widget.lesson.id, widget.index);
    }
    if (!mounted) return;
    setState(() {
      _checked = true;
      _saving = false;
    });
    _say();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Un ejercicio, otra mirada')),
    body: SafeArea(
      top: false,
      child: classroom(
        PageBody(
          maxWidth: 760,
          children: [
            AcademyBadge(widget.lesson.title),
            const SizedBox(height: 20),
            Text(question.scenario ?? widget.lesson.scenario),
            const SizedBox(height: 20),
            Text(
              question.prompt,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            for (final (i, option) in question.options.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton.icon(
                  onPressed: _checked || _saving
                      ? null
                      : () => setState(() => _choice = i),
                  icon: Icon(
                    _choice == i
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  label: Text(option),
                ),
              ),
            if (!_checked) ...[
              TextButton(
                onPressed: _hint
                    ? null
                    : () {
                        setState(() => _hint = true);
                        _say();
                      },
                child: const Text('Dame una pista'),
              ),
              FilledButton(
                onPressed: _choice == null || _saving ? null : _check,
                child: Text(_saving ? 'Guardando…' : 'Comprobar respuesta'),
              ),
            ] else ...[
              const SizedBox(height: 10),
              Text(
                _choice == question.answer
                    ? 'Repaso resuelto. Tu nota del curso se conserva.'
                    : 'Revisa la explicación y vuelve a intentarlo.',
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (_choice == question.answer) {
                    Navigator.pop(context);
                  } else {
                    setState(() {
                      _checked = false;
                      _choice = null;
                      _hint = false;
                    });
                    _say();
                  }
                },
                child: Text(
                  _choice == question.answer
                      ? 'Volver al repaso'
                      : 'Intentar otra vez',
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class LabsScreen extends StatelessWidget {
  const LabsScreen({super.key, required this.store});
  final AcademyStore store;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('Laboratorio offline')),
      body: PageBody(
        maxWidth: 900,
        children: [
          const NeonHeader(
            title: 'Decide. Observa. Ajusta.',
            description: 'Cuatro simulaciones guiadas con datos ficticios. Cada una tiene tres etapas y explica el efecto de tus decisiones.',
            icon: Icons.science_outlined,
          ),
          const SizedBox(height: 24),
          for (final lab in offlineLabs)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(20),
                  leading: Icon(
                    store.completedLabs.contains(lab.id)
                        ? Icons.verified_outlined
                        : Icons.science_outlined,
                  ),
                  title: Text(lab.title),
                  subtitle: Text(
                    '${lab.description}\n${store.completedLabs.contains(lab.id) ? 'Completado · Puedes repetir' : '3 etapas · A tu ritmo'}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LabScreen(lab: lab, store: store),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class LabScreen extends StatefulWidget {
  const LabScreen({super.key, required this.lab, required this.store});
  final OfflineLab lab;
  final AcademyStore store;
  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen> {
  int _stage = 0;
  int? _choice;
  bool _checked = false, _finished = false, _saving = false, _repeated = false;
  final _scroll = ScrollController();
  LabStage get stage => widget.lab.stages[_stage];
  bool get correct => _choice == stage.answer;
  AoiDialogue get dialogue => AoiDialogue(
    id:
        'lab-${widget.lab.id}-$_stage-${_finished
            ? 'complete'
            : _checked
            ? '$_choice-$_repeated'
            : 'question'}',
    lessonId: 'lab-${widget.lab.id}',
    stage: _finished
        ? AoiStage.result
        : _checked
        ? (correct ? AoiStage.correct : AoiStage.incorrect)
        : AoiStage.question,
    anchor: _stage,
    expression: _finished
        ? 'proud'
        : _checked
        ? (correct
              ? 'delighted'
              : _repeated
              ? 'exasperated'
              : 'disappointed')
        : 'explaining',
    text: _finished
        ? widget.lab.closure
        : _checked
        ? (correct
              ? stage.correct
              : _repeated
              ? stage.sharp
              : stage.soft)
        : stage.intro,
    explanation: _checked && !_finished ? stage.feedback[_choice!] : '',
  );
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    if (_choice == null || _checked || _saving) return;
    setState(() => _saving = true);
    _repeated = (widget.store.labMistakes['${widget.lab.id}:$_stage'] ?? 0) > 0;
    if (!correct) await widget.store.recordLabMistake(widget.lab.id, _stage);
    if (!mounted) return;
    setState(() {
      _checked = true;
      _saving = false;
    });
  }

  Future<void> _advance() async {
    if (_saving) return;
    if (correct && _stage == widget.lab.stages.length - 1) {
      setState(() => _saving = true);
      await widget.store.completeLab(widget.lab.id);
      if (!mounted) return;
      setState(() {
        _finished = true;
        _saving = false;
      });
    } else {
      setState(() {
        if (correct) _stage++;
        _choice = null;
        _checked = false;
        _repeated = false;
      });
    }
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Simulación con Aoi')),
    body: SafeArea(
      top: false,
      child: AoiClassroom(
        dialogue: dialogue,
        content: SingleChildScrollView(
          controller: _scroll,
          padding: const EdgeInsets.all(22),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AcademyBadge(
                    _finished
                        ? 'LABORATORIO COMPLETADO'
                        : 'ETAPA ${_stage + 1} / ${widget.lab.stages.length}',
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _finished ? widget.lab.title : stage.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  if (_finished) ...[
                    const Text(
                      'Resolviste las tres etapas. El logro queda guardado; tus notas y XP de los cursos se conservan.',
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Volver al laboratorio'),
                    ),
                  ] else ...[
                    LinearProgressIndicator(
                      value:
                          (_stage + (_checked && correct ? 1 : 0)) /
                          widget.lab.stages.length,
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Semantics(
                          label: stage.evidence,
                          excludeSemantics: true,
                          child: SelectableText(
                            stage.evidence,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              height: 1.7,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      stage.task,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 18),
                    for (final (i, option) in stage.options.indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: OutlinedButton.icon(
                          onPressed: _checked || _saving
                              ? null
                              : () => setState(() => _choice = i),
                          icon: Icon(
                            _choice == i
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                          ),
                          label: Text(option),
                        ),
                      ),
                    if (!_checked)
                      FilledButton(
                        onPressed: _choice == null || _saving ? null : _check,
                        child: Text(_saving ? 'Guardando…' : 'Probar decisión'),
                      )
                    else
                      FilledButton(
                        onPressed: _saving ? null : _advance,
                        child: Text(
                          _saving
                              ? 'Guardando…'
                              : correct
                              ? (_stage == widget.lab.stages.length - 1
                                    ? 'Terminar simulación'
                                    : 'Siguiente etapa')
                              : 'Revisar mi decisión',
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key, required this.store});
  final AcademyStore store;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final finishedCourses = courses
          .where((course) => store.courseProgress(course) == 1)
          .length;
      final knownLabs = offlineLabs
          .where((lab) => store.completedLabs.contains(lab.id))
          .length;
      final achievements = [
        ('Primer paso', 'Supera una lección.', store.completedLessons >= 1),
        (
          'Diez decisiones de estudio',
          'Supera diez lecciones.',
          store.completedLessons >= 10,
        ),
        (
          'Un curso completo',
          'Completa todas las lecciones de un curso.',
          finishedCourses >= 1,
        ),
        (
          'Tres cursos en tu mochila',
          'Completa tres cursos.',
          finishedCourses >= 3,
        ),
        (
          'Cien pasos con criterio',
          'Supera cien lecciones.',
          store.completedLessons >= 100,
        ),
        ('Manos al laboratorio', 'Completa una simulación.', knownLabs >= 1),
        (
          'Cuatro experimentos',
          'Completa las cuatro simulaciones.',
          knownLabs == offlineLabs.length,
        ),
        (
          'Aprender del tropiezo',
          'Resuelve cinco ejercicios en el repaso de errores.',
          store.reviewedMistakes.length >= 5,
        ),
      ];
      return Scaffold(
        appBar: AppBar(title: const Text('Logros')),
        body: PageBody(
          maxWidth: 900,
          children: [
            NeonHeader(
              title: 'Esto ya es tuyo.',
              description:
                  '${achievements.where((a) => a.$3).length} de ${achievements.length} logros. Se actualizan con tu progreso real, sin puntos extra por repetir.',
              icon: Icons.workspace_premium_outlined,
            ),
            const SizedBox(height: 24),
            for (final (title, description, unlocked) in achievements)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(18),
                    leading: Icon(
                      unlocked ? Icons.workspace_premium : Icons.lock_outline,
                      color: unlocked
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    title: Text(title),
                    subtitle: Text(description),
                    trailing: Text(unlocked ? 'Conseguido' : 'Pendiente'),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}
