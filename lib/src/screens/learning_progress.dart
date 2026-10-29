import 'package:flutter/material.dart';

import '../data/course_presentation.dart';
import '../data/curriculum.dart';
import '../models/course.dart';
import '../models/learning_overview.dart';
import '../state/academy_store.dart';
import '../widgets/common.dart';
import '../widgets/learning_dashboard.dart';
import '../widgets/learning_link.dart';
import 'explore_screens.dart';
import 'lesson_screens.dart';

String _normalized(String value) {
  var result = value.toLowerCase();
  for (final pair in [
    ('á', 'a'),
    ('é', 'e'),
    ('í', 'i'),
    ('ó', 'o'),
    ('ú', 'u'),
    ('ü', 'u'),
  ]) {
    result = result.replaceAll(pair.$1, pair.$2);
  }
  return result;
}

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key, required this.store});
  final AcademyStore store;
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _search = TextEditingController();
  String _filter = 'Todos', _query = '';
  bool _matches(String text) =>
      _normalized(_query)
          .trim()
          .split(RegExp(r'\s+'))
          .every(_normalized(text).contains);
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final store = widget.store;
      final overview = LearningOverview(store);
      final filtered = courses
          .where(
            (course) =>
                (_filter == 'Todos' || overview.status(course) == _filter) &&
                (_matches('${course.title} ${course.category}') ||
                    course.lessons.any((lesson) => _matches(lesson.title))),
          )
          .toList();
      final colors = Theme.of(context).colorScheme;
      return PageBody(
        maxWidth: 1200,
        children: [
          const AcademyBadge(
            'TU APRENDIZAJE, EN PERSPECTIVA',
            icon: Icons.insights_outlined,
          ),
          const SizedBox(height: 18),
          Text(
            'Cada paso cuenta.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          const Text(
            'Tu avance se guarda en este dispositivo. Conservamos la mejor nota de cada lección.',
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final ring = Semantics(
                    label: 'Avance global',
                    value: '${(store.progress * 100).round()}%',
                    child: ExcludeSemantics(
                      child: SizedBox(
                        width: 118,
                        height: 118,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned.fill(
                              child: CircularProgressIndicator(
                                value: store.progress,
                                strokeWidth: 10,
                                backgroundColor: colors.primary.withValues(
                                  alpha: .12,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(18),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${(store.progress * 100).round()}%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                  final copy = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${store.completedLessons} de ${allLessons.length} lecciones superadas',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${allLessons.length - store.completedLessons} por explorar · '
                        '${overview.completedPaths} de ${overview.paths.length} rutas completas',
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Ganas 50 XP al superar cada lección por primera vez.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                  return constraints.maxWidth < 540
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [ring, const SizedBox(height: 24), copy],
                        )
                      : Row(
                          children: [
                            ring,
                            const SizedBox(width: 32),
                            Expanded(child: copy),
                          ],
                        );
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
          DashboardGrid(
            minWidth: 155,
            maxColumns: 4,
            spacing: 12,
            children: [
              DashboardMetric(
                value: '${store.xp}',
                label: 'XP ganados',
                icon: Icons.bolt_outlined,
              ),
              DashboardMetric(
                value: '${overview.completedCourses}',
                label: 'Cursos completados',
                caption: 'de ${courses.length} en total',
                icon: Icons.school_outlined,
              ),
              DashboardMetric(
                value: '${overview.attemptedLessons}',
                label: 'Lecciones con nota',
                caption: 'Incluye los intentos por superar',
                icon: Icons.fact_check_outlined,
              ),
              DashboardMetric(
                value: overview.bestAccuracy == null
                    ? '--'
                    : '${(overview.bestAccuracy! * 100).round()}%',
                label: 'Aciertos en mejores intentos',
                icon: Icons.track_changes,
                caption: overview.bestAccuracy == null
                    ? 'Sin intentos guardados'
                    : '${overview.bestCorrectAnswers} de ${overview.gradedQuestions} preguntas con nota',
              ),
              if (allPracticeLessons.isNotEmpty)
                DashboardMetric(
                  value: '${store.completedPractice}',
                  label: 'Refuerzos superados',
                  caption:
                      'de ${allPracticeLessons.length} · nota independiente, sin XP de lección',
                  icon: Icons.fitness_center_outlined,
                ),
            ],
          ),
          const SectionTitle('Un siguiente paso concreto'),
          DashboardGrid(
            minWidth: 290,
            maxColumns: 2,
            children: [
              DashboardShortcut(
                title: 'Continuar aprendiendo',
                subtitle: store.resumeLesson.title,
                icon: Icons.play_circle_outline,
                onTap: () => openLesson(context, store.resumeLesson, store),
              ),
              DashboardShortcut(
                title: 'Repasar errores',
                subtitle: overview.pendingReviews == 0
                    ? 'Sin ejercicios pendientes'
                    : '${overview.pendingReviews} ejercicios pendientes',
                icon: Icons.psychology_outlined,
                onTap: () => openExploreSection(context, 3, store),
              ),
            ],
          ),
          const SectionTitle(
            'Tu avance por ruta',
            subtitle:
                'Cada barra cuenta lecciones aprobadas dentro de ese camino.',
          ),
          for (final path in overview.paths)
            LearningLink(
              label: 'Ruta: ${path.path.title}',
              value:
                  '${path.completedLessons} de ${path.lessons.length} lecciones superadas. ${path.status}.',
              hint: 'Ver cursos de esta ruta',
              onTap: () => openLearningPath(context, path, store),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => openLearningPath(context, path, store),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                courseTracks
                                    .firstWhere((t) => t.id == path.path.id)
                                    .icon,
                                size: 20,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  path.path.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.chevron_right, size: 20),
                            ],
                          ),
                          const SizedBox(height: 14),
                          LinearProgressIndicator(value: path.progress),
                          const SizedBox(height: 10),
                          Text(
                            '${path.completedLessons}/${path.lessons.length} lecciones · '
                            '${(path.progress * 100).round()}% · ${path.status}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const SectionTitle(
            'Detalle por curso',
            subtitle:
                'Abre un curso para consultar sus lecciones y mejores notas.',
          ),
          TextField(
            controller: _search,
            decoration: InputDecoration(
              labelText: 'Buscar en mi progreso',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpiar búsqueda de progreso',
                      onPressed: () => setState(() {
                        _query = '';
                        _search.clear();
                      }),
                      icon: const Icon(Icons.close),
                    ),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final filter in [
                'Todos',
                'En curso',
                'Por comenzar',
                'Completados',
              ])
                ChoiceChip(
                  label: Text(filter),
                  selected: _filter == filter,
                  onSelected: (_) => setState(() => _filter = filter),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${filtered.length} ${filtered.length == 1 ? 'curso' : 'cursos'} en este estado',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No hay cursos que coincidan con estos filtros.',
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _filter = 'Todos';
                        _query = '';
                        _search.clear();
                      }),
                      child: const Text('Ver todo mi progreso'),
                    ),
                  ],
                ),
              ),
            ),
          for (final course in filtered)
            _courseDetails(context, course, overview),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => openExploreSection(context, 4, store),
            icon: const Icon(Icons.workspace_premium_outlined),
            label: const Text('Ver mis logros'),
          ),
          const SizedBox(height: 28),
        ],
      );
    },
  );

  Widget _courseDetails(
    BuildContext context,
    Course course,
    LearningOverview overview,
  ) {
    final store = widget.store;
    final matchingCourse = _matches('${course.title} ${course.category}');
    final lessons = _query.isEmpty || matchingCourse
        ? course.lessons
        : course.lessons.where((lesson) => _matches(lesson.title)).toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ExpansionTile(
          key: PageStorageKey('progress:${course.id}:$_query'),
          initiallyExpanded: _query.isNotEmpty,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Icon(
            store.courseProgress(course) == 1
                ? Icons.check_circle_outline
                : trackFor(course).icon,
            color: Theme.of(context).colorScheme.primary,
            size: 22,
          ),
          title: Text(
            course.title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          subtitle: Text(
            '${course.lessons.where(store.isComplete).length}/${course.lessons.length} superadas · '
            '${overview.status(course)}',
            style: const TextStyle(fontSize: 12),
          ),
          children: [
            const Divider(height: 1),
            for (final lesson in lessons)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                leading: Icon(
                  store.isComplete(lesson)
                      ? Icons.check_circle
                      : Icons.article_outlined,
                  size: 19,
                ),
                title: Text(lesson.title, style: const TextStyle(fontSize: 14)),
                subtitle: Text(
                  store.scores.containsKey(lesson.id)
                      ? 'Mejor resultado: ${store.scores[lesson.id]}/${lesson.questions.length}'
                      : 'Aún por explorar',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => openLesson(context, lesson, store),
              ),
          ],
        ),
      ),
    );
  }
}
