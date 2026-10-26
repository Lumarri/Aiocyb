import 'package:flutter/material.dart';

import '../data/course_presentation.dart';
import '../models/learning_overview.dart';
import '../state/academy_store.dart';
import '../widgets/common.dart';
import '../widgets/learning_dashboard.dart';
import '../widgets/learning_link.dart';
import 'lesson_screens.dart';

void openLearningPath(
  BuildContext context,
  PathProgress path,
  AcademyStore store,
) => Navigator.of(context).push<void>(
  MaterialPageRoute(
    builder: (_) => PathDetailScreen(pathId: path.path.id, store: store),
  ),
);

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key, required this.store});
  final AcademyStore store;
  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  String _filter = 'Todas';
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final overview = LearningOverview(widget.store);
      final paths = overview.paths
          .where((p) => _filter == 'Todas' || p.status == _filter)
          .toList();
      return Scaffold(
        appBar: AppBar(title: const Text('Rutas de aprendizaje')),
        body: PageBody(
          maxWidth: 1200,
          children: [
            const AcademyBadge(
              'CINCO CAMINOS · UN MISMO CRITERIO',
              icon: Icons.route_outlined,
            ),
            const SizedBox(height: 18),
            Text(
              'Elige por dónde seguir.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            const Text(
              'Cada ruta conecta cursos en un orden sugerido. Puedes abrir cualquiera y cambiar de camino cuando quieras.',
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in [
                  'Todas',
                  'En curso',
                  'Por comenzar',
                  'Completada',
                ])
                  ChoiceChip(
                    label: Text(value == 'Completada' ? 'Completadas' : value),
                    selected: _filter == value,
                    onSelected: (_) => setState(() => _filter = value),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '${paths.length} ${paths.length == 1 ? 'ruta disponible' : 'rutas disponibles'} · '
              '${overview.completedPaths} completadas',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 20),
            if (paths.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Todavía no hay rutas con este estado.'),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => setState(() => _filter = 'Todas'),
                        child: const Text('Ver todas las rutas'),
                      ),
                    ],
                  ),
                ),
              )
            else
              DashboardGrid(
                minWidth: 340,
                maxColumns: 2,
                children: [
                  for (final path in paths)
                    PathSummaryCard(
                      progress: path,
                      onTap: () =>
                          openLearningPath(context, path, widget.store),
                    ),
                ],
              ),
            const SizedBox(height: 28),
          ],
        ),
      );
    },
  );
}

class PathDetailScreen extends StatelessWidget {
  const PathDetailScreen({
    super.key,
    required this.pathId,
    required this.store,
  });
  final String pathId;
  final AcademyStore store;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final progress = LearningOverview(store).paths
          .firstWhere((p) => p.path.id == pathId);
      final track = courseTracks.firstWhere((track) => track.id == pathId);
      return Scaffold(
        appBar: AppBar(title: const Text('Tu ruta')),
        body: PageBody(
          maxWidth: 1100,
          children: [
            LearningHero(
              eyebrow: 'RUTA DE APRENDIZAJE / ${track.label.toUpperCase()}',
              title: progress.path.title,
              description: progress.path.description,
              cover: track.cover,
              actions: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFBDF3E6),
                    foregroundColor: const Color(0xFF0D2530),
                  ),
                  onPressed: () =>
                      openLesson(context, progress.nextLesson, store),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    progress.isComplete
                        ? 'Repasar ruta'
                        : progress.hasStarted
                        ? 'Continuar ruta'
                        : 'Empezar ruta',
                  ),
                ),
              ],
              footer: Text(
                '${progress.includedCourses.length} cursos · ${progress.lessons.length} lecciones · '
                '${progress.exercises} ejercicios · ${courseDuration(progress.minutes)}',
                style: const TextStyle(color: Color(0xFFADBDD5), fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
            DashboardGrid(
              minWidth: 200,
              maxColumns: 3,
              children: [
                DashboardMetric(
                  value: '${(progress.progress * 100).round()}%',
                  label: 'Avance de la ruta',
                  caption:
                      '${progress.completedLessons} de ${progress.lessons.length} lecciones superadas',
                  icon: Icons.donut_large,
                ),
                DashboardMetric(
                  value:
                      '${progress.completedCourses}/${progress.includedCourses.length}',
                  label: 'Cursos completados',
                  icon: Icons.school_outlined,
                ),
                DashboardMetric(
                  value: '${progress.completedLessons * 50}',
                  label: 'XP en esta ruta',
                  caption: 'Cada primera aprobación suma 50 XP',
                  icon: Icons.bolt_outlined,
                ),
              ],
            ),
            SectionTitle(
              'Tu recorrido, curso a curso',
              subtitle: progress.isComplete
                  ? 'Ruta completada. Puedes volver al curso que quieras repasar.'
                  : 'Siguiente lección: ${progress.nextLesson.title}',
            ),
            for (final (index, course) in progress.includedCourses.indexed)
              LearningLink(
                label: 'Curso: ${course.title}',
                value:
                    '${course.lessons.where(store.isComplete).length} de ${course.lessons.length} lecciones superadas. ${LearningOverview(store).status(course)}.',
                hint: course.description,
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => CourseScreen(course: course, store: store),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) =>
                              CourseScreen(course: course, store: store),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              child: store.courseProgress(course) == 1
                                  ? const Icon(Icons.check, size: 20)
                                  : Text('${index + 1}'),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!progress.isComplete &&
                                      course == progress.nextCourse) ...[
                                    Text(
                                      'SIGUIENTE PASO',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontSize: 10,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                  Text(
                                    course.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    course.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '${course.lessons.length} lecciones · ${course.exerciseCount} ejercicios · '
                                    '${courseDuration(course.minutes)}',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  const SizedBox(height: 14),
                                  LinearProgressIndicator(
                                    value: store.courseProgress(course),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${course.lessons.where(store.isComplete).length}/${course.lessons.length} superadas · '
                                    '${LearningOverview(store).status(course)}',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'El avance se calcula con las lecciones aprobadas. Todos los cursos están disponibles desde el principio.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 28),
          ],
        ),
      );
    },
  );
}
