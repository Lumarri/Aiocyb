import 'package:flutter/material.dart';

import '../data/curriculum.dart';
import '../models/aoi_dialogue.dart';
import '../models/course.dart';
import '../state/academy_store.dart';
import '../widgets/common.dart';
import 'aoi_session_state.dart';

enum _LessonPart { intro, theory, procedure, scenario }

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lesson, required this.store});
  final Lesson lesson;
  final AcademyStore store;
  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with AoiSessionState<LessonScreen> {
  _LessonPart _part = _LessonPart.intro;
  int _section = 0;
  int _step = 0;
  int _case = 0;
  final _scroll = ScrollController();
  @override
  AcademyStore get tutorStore => widget.store;
  @override
  String get tutorLessonId => widget.lesson.id;
  @override
  void onAoiReady() => _speakCurrent();

  void _speakCurrent() => speak(
    switch (_part) {
      _LessonPart.intro => AoiStage.intro,
      _LessonPart.theory => AoiStage.theory,
      _LessonPart.procedure => AoiStage.procedure,
      _LessonPart.scenario => AoiStage.scenario,
    },
    switch (_part) {
      _LessonPart.theory => _section,
      _LessonPart.procedure => _step,
      _LessonPart.scenario => _case,
      _ => 0,
    },
  );

  void _selectPart(_LessonPart value) {
    setState(() => _part = value);
    _speakCurrent();
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final course = courses.firstWhere(
      (course) => course.lessons.contains(lesson),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu aula con Aoi'),
        actions: [
          IconButton(
            tooltip: 'Temario del curso',
            icon: const Icon(Icons.format_list_bulleted_rounded),
            onPressed: () => _openSyllabus(course),
          ),
          ListenableBuilder(
            listenable: widget.store,
            builder: (context, _) => IconButton(
              tooltip: widget.store.favoriteLessons.contains(lesson.id)
                  ? 'Quitar de favoritos'
                  : 'Guardar en biblioteca',
              onPressed: () => widget.store.toggleFavorite(lesson.id),
              icon: Icon(
                widget.store.favoriteLessons.contains(lesson.id)
                    ? Icons.bookmark
                    : Icons.bookmark_border,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: classroom(
          SingleChildScrollView(
            controller: _scroll,
            padding: EdgeInsets.all(
              MediaQuery.sizeOf(context).width < 600 ? 20 : 32,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AcademyBadge(
                      'LECCIÓN ${course.lessons.indexOf(lesson) + 1} DE ${course.lessons.length} · ${lesson.minutes} min',
                      icon: Icons.auto_stories_outlined,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      lesson.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final part in _LessonPart.values)
                          ChoiceChip(
                            avatar: Icon(switch (part) {
                              _LessonPart.intro => Icons.flag_outlined,
                              _LessonPart.theory => Icons.menu_book_outlined,
                              _LessonPart.procedure => Icons.checklist,
                              _LessonPart.scenario => Icons.manage_search,
                            }, size: 17),
                            label: Text(switch (part) {
                              _LessonPart.intro => 'Inicio',
                              _LessonPart.theory => 'Teoría',
                              _LessonPart.procedure => 'Pasos',
                              _LessonPart.scenario =>
                                lesson.cases.isEmpty ? 'Caso' : 'Casos',
                            }),
                            selected: _part == part,
                            onSelected: (_) {
                              if (_part != part) _selectPart(part);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    switch (_part) {
                      _LessonPart.intro => _introduction(context),
                      _LessonPart.theory => _theory(context),
                      _LessonPart.procedure => _procedure(context),
                      _LessonPart.scenario => _scenario(context),
                    },
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          await Navigator.push<int>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(
                                title: lesson.title,
                                lessonId: lesson.id,
                                store: widget.store,
                                questions: lesson.questions,
                                scenario: lesson.scenario,
                                passingScore: widget.store.passingScore(lesson),
                                onComplete: (score) =>
                                    widget.store.recordScore(lesson, score),
                              ),
                            ),
                          );
                          if (mounted) setState(() {});
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(
                          'Practicar · ${lesson.questions.length} ${lesson.questions.length == 1 ? 'ejercicio' : 'ejercicios'}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Supera la lección con ${widget.store.passingScore(lesson)} de ${lesson.questions.length} aciertos. Puedes repetir la práctica.',
                    ),
                    if (widget.store.isComplete(lesson)) ...[
                      const SizedBox(height: 12),
                      AcademyBadge(
                        'Lección superada · ${widget.store.scores[lesson.id]}/${lesson.questions.length}',
                        icon: Icons.check_circle_outline,
                      ),
                    ],
                    const SizedBox(height: 20),
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: const Text('Fuentes de esta lección'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: SourceList(ids: lesson.sourceIds),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openSyllabus(Course course) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 760),
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * .8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 12, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      course.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar temario',
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: course.lessons.length,
                itemBuilder: (_, index) {
                  final target = course.lessons[index];
                  return ListTile(
                    selected: target.id == widget.lesson.id,
                    selectedTileColor: Theme.of(context).colorScheme.primary
                        .withValues(alpha: .08),
                    leading: Icon(
                      widget.store.isComplete(target)
                          ? Icons.check_circle_outline
                          : target.id == widget.lesson.id
                          ? Icons.play_circle_outline
                          : Icons.article_outlined,
                    ),
                    title: Text(target.title),
                    subtitle: Text(
                      'Lección ${index + 1} · ${target.minutes} min',
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      if (target.id == widget.lesson.id) return;
                      widget.store.openLesson(target);
                      Navigator.of(context).pushReplacement<void, void>(
                        MaterialPageRoute(
                          builder: (_) =>
                              LessonScreen(lesson: target, store: widget.store),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _introduction(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Lo que vamos a resolver',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 12),
      Text(
        widget.lesson.cases.isEmpty
            ? 'Aoi te acompaña por los conceptos, el procedimiento y un caso ficticio. Su conversación permanece visible mientras estudias.'
            : 'Estudia los ${widget.lesson.sections.length} conceptos, revisa los ${widget.lesson.cases.length} casos ficticios resueltos y practica con ${widget.lesson.questions.length} ejercicios. Aoi te acompaña en cada etapa.',
      ),
      if (widget.lesson.cases.isNotEmpty) ...[
        const SizedBox(height: 14),
        AcademyBadge(
          'TEORÍA PROFUNDA · ${widget.lesson.theoryWordCount} palabras',
        ),
      ],
      const SizedBox(height: 18),
      for (final (index, section) in widget.lesson.sections.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 15,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(section.title)),
            ],
          ),
        ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: () => _selectPart(_LessonPart.theory),
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Empezar teoría'),
      ),
    ],
  );

  Widget _theory(BuildContext context) {
    final section = widget.lesson.sections[_section];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONCEPTO ${_section + 1} / ${widget.lesson.sections.length}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 11,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(section.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        Text(section.body, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 22),
        _pager(_section, widget.lesson.sections.length, (value) {
          setState(() => _section = value);
          _speakCurrent();
          if (_scroll.hasClients) _scroll.jumpTo(0);
        }),
        const SizedBox(height: 20),
        LearningDiagram(kind: widget.lesson.diagram),
      ],
    );
  }

  Widget _procedure(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'PASO ${_step + 1} / ${widget.lesson.steps.length}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 11,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 14),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Text(
            widget.lesson.steps[_step],
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
      const SizedBox(height: 20),
      _pager(_step, widget.lesson.steps.length, (value) {
        setState(() => _step = value);
        _speakCurrent();
        if (_scroll.hasClients) _scroll.jumpTo(0);
      }),
      const SizedBox(height: 18),
      const Text(
        'Realiza los pasos solo en tus propias cuentas o dispositivos. No introduzcas contraseñas reales en la academia.',
      ),
    ],
  );

  Widget _scenario(BuildContext context) {
    final cases = widget.lesson.cases;
    if (cases.isNotEmpty) {
      final studyCase = cases[_case];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AcademyBadge('CASO RESUELTO ${_case + 1} / ${cases.length}'),
          const SizedBox(height: 14),
          Text(studyCase.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Text(
                studyCase.scenario,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Qué haríamos y por qué',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Text(
            studyCase.explanation,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 22),
          _pager(_case, cases.length, (value) {
            setState(() => _case = value);
            _speakCurrent();
            if (_scroll.hasClients) _scroll.jumpTo(0);
          }),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tu turno de observar',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AcademyBadge(
                  'CASO FICTICIO',
                  icon: Icons.science_outlined,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.lesson.scenario,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _pager(int index, int length, ValueChanged<int> onChange) => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: index > 0 ? () => onChange(index - 1) : null,
          child: const Text('Anterior'),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: OutlinedButton(
          onPressed: index < length - 1 ? () => onChange(index + 1) : null,
          child: const Text('Siguiente'),
        ),
      ),
    ],
  );
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.title,
    required this.questions,
    required this.onComplete,
    required this.store,
    this.lessonId = 'diagnostic',
    this.passingScore,
    this.scenario,
    this.isReinforcement = false,
  });
  final String title;
  final List<Question> questions;
  final Future<void> Function(int score) onComplete;
  final AcademyStore store;
  final String lessonId;
  final int? passingScore;
  final String? scenario;
  final bool isReinforcement;
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with AoiSessionState<QuizScreen> {
  int _index = 0;
  int? _selected;
  bool _checked = false;
  bool _finished = false;
  bool _allowExit = false;
  bool _saving = false;
  bool _hintUsed = false;
  bool _repeatedMistake = false;
  bool _justCompletedCourse = false;
  final List<int> _answers = [];
  final _scroll = ScrollController();
  int get _score => [
    for (var i = 0; i < _answers.length; i++)
      if (_answers[i] == widget.questions[i].answer) i,
  ].length;
  bool get _passed => widget.passingScore == null
      ? _score >= 3
      : _score >= widget.passingScore!;
  Course? get _course {
    for (final course in courses) {
      if (course.lessons.any((lesson) => lesson.id == widget.lessonId)) {
        return course;
      }
    }
    return null;
  }

  void _explainResult() => speak(
    _justCompletedCourse ? AoiStage.courseComplete : AoiStage.result,
    _justCompletedCourse || _passed ? 0 : 1,
  );
  @override
  AcademyStore get tutorStore => widget.store;
  @override
  String get tutorLessonId => widget.lessonId;
  @override
  void onAoiReady() {
    if (_finished) {
      _explainResult();
    } else if (_checked) {
      _explainAnswer();
    } else if (_hintUsed) {
      speak(AoiStage.hint, _index);
    } else {
      speak(AoiStage.question, _index);
    }
  }

  void _explainAnswer() => speak(
    _selected == widget.questions[_index].answer
        ? AoiStage.correct
        : AoiStage.incorrect,
    _index,
    choiceIndex: _selected,
    repeatedMistake: _repeatedMistake,
  );

  Future<void> _next() async {
    if (_saving || !_checked) return;
    if (_index < widget.questions.length - 1) {
      setState(() {
        _index++;
        _selected = null;
        _checked = false;
        _hintUsed = false;
        _repeatedMistake = false;
      });
      speak(AoiStage.question, _index);
      _scroll.jumpTo(0);
    } else {
      setState(() => _saving = true);
      final course = _course;
      final wasComplete =
          course != null && course.lessons.every(widget.store.isComplete);
      await widget.onComplete(_score);
      if (!mounted) return;
      setState(() {
        _finished = true;
        _saving = false;
        _justCompletedCourse =
            _passed &&
            !wasComplete &&
            course != null &&
            course.lessons.every(widget.store.isComplete);
      });
      _explainResult();
      _scroll.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope<int>(
    canPop: _allowExit || _finished || _answers.isEmpty,
    onPopInvokedWithResult: (didPop, result) async {
      if (didPop || _saving) return;
      final leave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Salir de la práctica?'),
          content: const Text(
            'La nota de este intento no se guardará hasta que termines. Tu mejor nota anterior se conserva.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Seguir practicando'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Salir'),
            ),
          ],
        ),
      );
      if (leave == true && mounted) {
        setState(() => _allowExit = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.pop(context);
        });
      }
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isReinforcement
              ? 'Refuerzo con Aoi'
              : widget.passingScore == null
              ? 'Diagnóstico con Aoi'
              : 'Tu práctica',
        ),
      ),
      body: SafeArea(
        top: false,
        child: classroom(
          SingleChildScrollView(
            controller: _scroll,
            padding: const EdgeInsets.all(22),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: _finished ? _result(context) : _question(context),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _question(BuildContext context) {
    final question = widget.questions[_index];
    final scenario = question.scenario ?? widget.scenario;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AcademyBadge(
          'EJERCICIO ${_index + 1} DE ${widget.questions.length}',
          icon: Icons.quiz_outlined,
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: (_index + (_checked ? 1 : 0)) / widget.questions.length,
        ),
        const SizedBox(height: 22),
        if (scenario != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.scenario == null
                        ? 'Caso de la lección'
                        : 'Caso del ejercicio',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(scenario),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          question.prompt,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        const Text(
          'Observa el caso y elige una respuesta. Aoi te dará una explicación para la opción que elijas.',
        ),
        const SizedBox(height: 20),
        for (final (index, option) in question.options.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Semantics(
              selected: _selected == index,
              button: true,
              excludeSemantics: true,
              label: option,
              onTap: _checked ? null : () => setState(() => _selected = index),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: _checked && index == question.answer
                        ? Theme.of(context).colorScheme.primary
                        : _checked && _selected == index
                        ? Theme.of(context).colorScheme.error
                        : _selected == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    width:
                        _selected == index ||
                            (_checked && index == question.answer)
                        ? 2
                        : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: _checked
                      ? null
                      : () => setState(() => _selected = index),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Icon(
                          _checked && index == question.answer
                              ? Icons.check_circle_outline
                              : _checked && _selected == index
                              ? Icons.cancel_outlined
                              : _selected == index
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color:
                              _checked &&
                                  _selected == index &&
                                  index != question.answer
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            option,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        if (_checked) ...[
          Text(
            _selected == question.answer
                ? 'Respuesta correcta'
                : 'Respuesta para revisar',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text('La opción correcta es: ${question.options[question.answer]}'),
          const SizedBox(height: 8),
          const Text(
            'Aoi explica tu elección en su panel. Revisa el razonamiento antes de continuar.',
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saving ? null : _next,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(
                _saving
                    ? 'Guardando…'
                    : _index == widget.questions.length - 1
                    ? 'Ver mi resultado'
                    : 'Siguiente ejercicio',
              ),
            ),
          ),
        ] else ...[
          OutlinedButton.icon(
            onPressed: _hintUsed || conversation == null
                ? null
                : () {
                    setState(() => _hintUsed = true);
                    speak(AoiStage.hint, _index);
                  },
            icon: const Icon(Icons.lightbulb_outline),
            label: const Text('Dame una pista'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selected == null
                  ? null
                  : () {
                      if (_checked) return;
                      setState(() {
                        _checked = true;
                        _answers.add(_selected!);
                        if (_selected != question.answer) {
                          _repeatedMistake =
                              widget.store.mistakeCount(
                                widget.lessonId,
                                _index,
                              ) >
                              0;
                          widget.store.recordMistake(widget.lessonId, _index);
                        }
                      });
                      _explainAnswer();
                    },
              child: const Text('Comprobar respuesta'),
            ),
          ),
        ],
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _result(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 20),
      Icon(
        _passed ? Icons.verified_outlined : Icons.school_outlined,
        size: 60,
        color: Theme.of(context).colorScheme.primary,
      ),
      const SizedBox(height: 20),
      Text(
        '$_score / ${widget.questions.length}',
        style: Theme.of(context).textTheme.displaySmall,
      ),
      const SizedBox(height: 12),
      Text(
        widget.passingScore == null
            ? 'Ya tienes un punto de partida.'
            : _passed
            ? _justCompletedCourse
                  ? '¡Curso completado!'
                  : widget.isReinforcement
                  ? '¡Refuerzo superado!'
                  : '¡Lección superada!'
            : 'Un repaso y otra oportunidad.',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 16),
      Text(
        widget.isReinforcement
            ? 'Conservamos tu mejor nota de refuerzo por separado. Esta práctica no cambia las aprobaciones ni añade XP de lección.'
            : widget.passingScore == null
            ? 'El diagnóstico no bloquea los cursos.'
            : 'Conservamos tu mejor resultado. Cada lección superada por primera vez suma 50 XP.',
      ),
      const SectionTitle('Tus decisiones'),
      for (final (index, question) in widget.questions.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _answers[index] == question.answer
                    ? Icons.check_circle_outline
                    : Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.prompt,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text('Elegiste: ${question.options[_answers[index]]}'),
                    Text('Respuesta: ${question.options[question.answer]}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 22),
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => Navigator.pop(context, _score),
          child: Text(
            widget.passingScore == null
                ? 'Volver a mi academia'
                : widget.isReinforcement
                ? 'Volver a los refuerzos'
                : 'Volver a la lección',
          ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              _index = 0;
              _selected = null;
              _checked = false;
              _finished = false;
              _hintUsed = false;
              _repeatedMistake = false;
              _justCompletedCourse = false;
              _answers.clear();
            });
            speak(AoiStage.question, 0);
            _scroll.jumpTo(0);
          },
          child: const Text('Volver a practicar'),
        ),
      ),
      const SizedBox(height: 30),
    ],
  );
}
