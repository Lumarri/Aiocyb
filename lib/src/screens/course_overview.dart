import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../data/course_presentation.dart';
import '../models/course.dart';
import '../models/learning_overview.dart';
import '../state/academy_store.dart';
import '../widgets/aoi_portrait.dart';
import '../widgets/common.dart';
import '../widgets/course_visuals.dart';
import 'lesson_navigation.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key, required this.course, required this.store});
  final Course course;
  final AcademyStore store;
  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final _about = GlobalKey(), _syllabus = GlobalKey(), _concepts = GlobalKey();
  int _selected = 0;
  Course get course => widget.course;
  AcademyStore get store => widget.store;
  Lesson get _next {
    final last = course.lessons.where(
      (lesson) => lesson.id == store.lastLessonId,
    );
    if (last.isNotEmpty && !store.isComplete(last.first)) return last.first;
    return course.lessons.firstWhere(
      (lesson) => !store.isComplete(lesson),
      orElse: () => course.lessons.first,
    );
  }

  void _jump(int index) {
    setState(() => _selected = index);
    Scrollable.ensureVisible(
      [_about, _syllabus, _concepts][index].currentContext!,
      alignment: .15,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final wide = MediaQuery.sizeOf(context).width >= 1000;
      final colors = Theme.of(context).colorScheme;
      final profile = courseProfiles[course.id]!;
      final completed = course.lessons.where(store.isComplete).length;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tu curso'),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 18),
              child: Tooltip(
                message: 'Incluido offline',
                child: Icon(Icons.offline_pin_outlined),
              ),
            ),
          ],
        ),
        bottomNavigationBar: wide ? null : _continueBar(context, completed),
        body: CustomScrollView(
          // Lay out the three sections immediately so anchors and accessibility
          // can reach the complete outline before its first manual scroll.
          scrollCacheExtent: const ScrollCacheExtent.pixels(10000),
          slivers: [
            SliverToBoxAdapter(child: _hero(context)),
            SliverPersistentHeader(
              pinned: true,
              delegate: _CourseNav(
                selected: _selected,
                onSelect: _jump,
                background: colors.surface,
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: EdgeInsets.all(wide ? 36 : 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lo que vas a aprender',
                                key: _about,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              for (final outcome in profile.outcomes)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        size: 21,
                                        color: colors.primary,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(child: Text(outcome)),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 10),
                              Text(
                                'Habilidades que practicarás',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final skill in profile.skills)
                                    Chip(
                                      label: Text(skill),
                                      backgroundColor: colors.primary
                                          .withValues(alpha: .07),
                                      side: BorderSide(
                                        color: colors.primary.withValues(
                                          alpha: .2,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _tutor(context),
                              const SizedBox(height: 36),
                              Text(
                                'Contenido del curso',
                                key: _syllabus,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${course.lessons.length} lecciones · ${course.exerciseCount} ejercicios · '
                                '${courseDuration(course.minutes)} de estudio estimado',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: store.courseProgress(course),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$completed de ${course.lessons.length} lecciones superadas',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 20),
                              for (
                                var start = 0;
                                start < course.lessons.length;
                                start += _moduleSize
                              )
                                _module(context, start),
                              const SizedBox(height: 32),
                              Text(
                                'Conceptos clave',
                                key: _concepts,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Una primera mirada a la teoría. Abre un concepto para leerlo completo.',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 18),
                              for (final concept in courseConcepts(course))
                                _concept(
                                  context,
                                  concept.lesson,
                                  concept.section,
                                ),
                              const SizedBox(height: 26),
                              ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                leading: const Icon(Icons.info_outline),
                                title: const Text('Cómo se estudia este curso'),
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 20),
                                    child: Text(
                                      'Lee la teoría, revisa los pasos y analiza los casos antes de practicar. '
                                      'Cada lección indica los aciertos necesarios para superarla. Puedes repetirla '
                                      'y conservas tu mejor resultado. La duración es orientativa. '
                                      'La app registra tu progreso local y no emite una certificación profesional.',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                        if (wide) ...[
                          const SizedBox(width: 40),
                          SizedBox(
                            width: 285,
                            child: _studyCard(context, completed),
                          ),
                        ],
                      ],
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

  int get _moduleSize => course.lessons.length > 10 ? 10 : 4;

  Widget _hero(BuildContext context) => ColoredBox(
    color: const Color(0xFF101E36),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 800;
            final copy = Padding(
              padding: EdgeInsets.all(wide ? 36 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURSOS  /  ${trackFor(course).label.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.3,
                      color: Color(0xFFADBDD5),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    course.title,
                    style: TextStyle(
                      fontSize: wide ? 36 : 28,
                      fontWeight: FontWeight.w800,
                      height: 1.18,
                      letterSpacing: -.8,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    course.description,
                    style: const TextStyle(
                      color: Color(0xFFD0DBEA),
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Wrap(
                    spacing: 18,
                    runSpacing: 10,
                    children: [
                      _HeroFact(
                        Icons.signal_cellular_alt,
                        'Nivel principiante',
                      ),
                      _HeroFact(Icons.language, 'Español'),
                      _HeroFact(Icons.all_inclusive, 'A tu ritmo'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'AIOCYB ACADEMY',
                    style: TextStyle(
                      color: Color(0xFFBDF3E6),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            );
            final image = ClipRRect(
              borderRadius: BorderRadius.circular(wide ? 18 : 0),
              child: CourseCover(course: course, height: wide ? 285 : 170),
            );
            return wide
                ? Row(
                    children: [
                      Expanded(flex: 6, child: copy),
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 36),
                          child: image,
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [image, copy],
                  );
          },
        ),
      ),
    ),
  );

  String get _continueLabel => store.courseProgress(course) == 1
      ? 'Repasar el curso'
      : LearningOverview(store).started(course)
      ? 'Continuar curso'
      : 'Empezar curso';

  Widget _continueBar(BuildContext context, int completed) => Material(
    color: Theme.of(context).colorScheme.surface,
    elevation: 8,
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final progress = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(store.courseProgress(course) * 100).round()}% completado',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '$completed / ${course.lessons.length} lecciones',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            );
            final button = FilledButton.icon(
              onPressed: () => openLesson(context, _next, store),
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: Text(_continueLabel),
            );
            return constraints.maxWidth < 310 ||
                    MediaQuery.textScalerOf(context).scale(1) > 1.2
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [progress, const SizedBox(height: 8), button],
                  )
                : Row(
                    children: [
                      Expanded(child: progress),
                      const SizedBox(width: 12),
                      button,
                    ],
                  );
          },
        ),
      ),
    ),
  );

  Widget _studyCard(BuildContext context, int completed) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AcademyBadge('TU PLAN DE ESTUDIO', icon: Icons.school_outlined),
          const SizedBox(height: 22),
          Text(
            courseDuration(course.minutes),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Text('de estudio estimado · sin límite de tiempo'),
          const SizedBox(height: 22),
          for (final fact in [
            (
              Icons.menu_book_outlined,
              '${course.lessons.length} lecciones guiadas',
            ),
            (
              Icons.task_alt,
              '${course.exerciseCount} ejercicios con explicación',
            ),
            (Icons.psychology_outlined, 'Aoi te acompaña paso a paso'),
            (Icons.offline_pin_outlined, 'Contenido incluido sin conexión'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(fact.$1, size: 19),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(fact.$2, style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          const Divider(height: 28),
          LinearProgressIndicator(value: store.courseProgress(course)),
          const SizedBox(height: 10),
          Text('$completed de ${course.lessons.length} superadas'),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => openLesson(context, _next, store),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(_continueLabel),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Siguiente: ${_next.title}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    ),
  );

  Widget _tutor(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AoiPortrait(
          expression: AoiExpression.curious,
          width: 52,
          height: 64,
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tu guía: Aoi Bite',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 5),
              Text(
                '«Primero entiendes, luego practicas. Coleccionar títulos no te protege de una metida de pata, cariño.»',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _module(BuildContext context, int start) {
    final lessons = course.lessons.skip(start).take(_moduleSize).toList();
    final completed = lessons.where(store.isComplete).length;
    final next = course.lessons.indexOf(_next);
    final number = start ~/ _moduleSize + 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          key: PageStorageKey('${course.id}:module:$start'),
          initiallyExpanded: next >= start && next < start + lessons.length,
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          leading: CircleAvatar(
            radius: 19,
            child: completed == lessons.length
                ? const Icon(Icons.check, size: 19)
                : Text('$number', style: const TextStyle(fontSize: 14)),
          ),
          title: Text(
            'Módulo $number · ${lessons.first.title}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              'Lecciones ${start + 1}–${start + lessons.length} · $completed/${lessons.length} superadas',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          children: [
            const Divider(height: 1),
            for (final (offset, lesson) in lessons.indexed)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Icon(
                  store.isComplete(lesson)
                      ? Icons.check_circle
                      : Icons.article_outlined,
                  size: 20,
                  color: store.isComplete(lesson)
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(
                  lesson.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Lección ${start + offset + 1} · ${lesson.minutes} min · '
                  '${lesson.questions.length} ${lesson.questions.length == 1 ? 'ejercicio' : 'ejercicios'}'
                  '${store.scores.containsKey(lesson.id) ? ' · Mejor: ${store.scores[lesson.id]}/${lesson.questions.length}' : ''}',
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => openLesson(context, lesson, store),
              ),
          ],
        ),
      ),
    );
  }

  Widget _concept(BuildContext context, Lesson lesson, TheorySection section) {
    final colors = Theme.of(context).colorScheme;
    final preview = section.body.split(RegExp(r'(?<=[.!?])\s+')).first;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _readConcept(context, lesson, section),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: colors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        section.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(preview, maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 14),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'Leer concepto',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 15, color: colors.primary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _readConcept(
    BuildContext context,
    Lesson lesson,
    TheorySection section,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 760),
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * .78,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'CONCEPTO DEL CURSO',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cerrar concepto',
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      section.body,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'De la lección: ${lesson.title}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    SourceList(ids: lesson.sourceIds),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      openLesson(context, lesson, store);
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Estudiar esta lección'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroFact extends StatelessWidget {
  const _HeroFact(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: const Color(0xFFBDF3E6)),
      const SizedBox(width: 7),
      Flexible(
        child: Text(
          text,
          style: const TextStyle(color: Color(0xFFD0DBEA), fontSize: 12),
        ),
      ),
    ],
  );
}

class _CourseNav extends SliverPersistentHeaderDelegate {
  _CourseNav({
    required this.selected,
    required this.onSelect,
    required this.background,
  });
  final int selected;
  final ValueChanged<int> onSelect;
  final Color background;
  @override
  double get minExtent => 64;
  @override
  double get maxExtent => 64;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Material(
    color: background,
    elevation: overlapsContent ? 2 : 0,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                for (final (index, label) in [
                  'Acerca del curso',
                  'Temario',
                  'Conceptos',
                ].indexed)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton(
                      onPressed: () => onSelect(index),
                      style: TextButton.styleFrom(
                        foregroundColor: selected == index
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        backgroundColor: selected == index
                            ? Theme.of(context).colorScheme.primary
                                  .withValues(alpha: .08)
                            : null,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      child: Text(label),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  @override
  bool shouldRebuild(covariant _CourseNav oldDelegate) =>
      selected != oldDelegate.selected || background != oldDelegate.background;
}
