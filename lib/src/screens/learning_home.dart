import 'package:flutter/material.dart';

import '../data/course_presentation.dart';
import '../data/curriculum.dart';
import '../models/learning_overview.dart';
import '../state/academy_store.dart';
import '../widgets/common.dart';
import '../widgets/learning_dashboard.dart';
import 'dashboard_actions.dart';
import 'explore_screens.dart';
import 'lesson_screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.store, required this.onCourses});
  final AcademyStore store;
  final VoidCallback onCourses;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final overview = LearningOverview(store);
      final lesson = store.resumeLesson;
      final course = overview.resumeCourse;
      final finished = store.completedLessons == allLessons.length;
      return PageBody(
        maxWidth: 1280,
        children: [
          const AcademyBadge(
            'TU ESPACIO PARA APRENDER',
            icon: Icons.school_outlined,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'Hola, ${store.name.isEmpty ? 'mente curiosa' : store.name}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.waving_hand_outlined,
                size: 25,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Tu siguiente paso está aquí. Aprende, practica y vuelve cuando quieras.',
          ),
          const SizedBox(height: 24),
          LearningHero(
            eyebrow: finished
                ? 'TU ACADEMIA / RECORRIDO COMPLETADO'
                : 'CONTINÚA EN / ${trackFor(course).label.toUpperCase()}',
            title: finished
                ? 'Lo aprendido también se practica.'
                : lesson.title,
            description: finished
                ? 'Superaste las ${allLessons.length} lecciones. Elige qué quieres reforzar.'
                : '${course.title}\nLección ${course.lessons.indexOf(lesson) + 1} de ${course.lessons.length} · '
                      '${lesson.minutes} min · ${lesson.questions.length} ${lesson.questions.length == 1 ? 'ejercicio' : 'ejercicios'}',
            cover: trackFor(course).cover,
            actions: [
              FilledButton.icon(
                onPressed: () => openLesson(context, lesson, store),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFBDF3E6),
                  foregroundColor: const Color(0xFF0D2530),
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(
                  finished
                      ? 'Volver a practicar'
                      : store.lastLessonId == null && store.scores.isEmpty
                      ? 'Empezar lección'
                      : 'Continuar aprendiendo',
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => CourseScreen(course: course, store: store),
                  ),
                ),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                icon: const Icon(Icons.menu_book_outlined, size: 19),
                label: const Text('Ver mi curso'),
              ),
            ],
            footer: Text(
              '${course.lessons.where(store.isComplete).length}/${course.lessons.length} '
              'lecciones superadas en este curso',
              style: const TextStyle(color: Color(0xFFADBDD5), fontSize: 12),
            ),
          ),
          const SizedBox(height: 22),
          DashboardGrid(
            minWidth: 150,
            maxColumns: 4,
            spacing: 12,
            children: [
              DashboardMetric(
                value: '${store.completedLessons}',
                label: 'Lecciones superadas',
                caption: 'de ${allLessons.length} en la academia',
                icon: Icons.task_alt,
              ),
              DashboardMetric(
                value: '${overview.completedCourses}',
                label: 'Cursos completados',
                caption: 'de ${courses.length} disponibles',
                icon: Icons.school_outlined,
              ),
              DashboardMetric(
                value: '${store.xp}',
                label: 'XP ganados',
                caption: '50 por primera aprobación',
                icon: Icons.bolt_outlined,
              ),
              DashboardMetric(
                value: '${overview.pendingReviews}',
                label: 'Ejercicios por repasar',
                caption: 'Aprende de tus errores',
                icon: Icons.psychology_outlined,
              ),
            ],
          ),
          const SectionTitle(
            'A mano para seguir',
            subtitle: 'Tus herramientas de estudio, sin conexión.',
          ),
          DashboardGrid(
            minWidth: 225,
            maxColumns: 4,
            spacing: 12,
            children: [
              DashboardShortcut(
                title: 'Mis rutas',
                subtitle: 'Cinco caminos para elegir',
                icon: Icons.route_outlined,
                onTap: () => openExploreSection(context, 0, store),
              ),
              DashboardShortcut(
                title: 'Repasar errores',
                subtitle:
                    '${overview.pendingReviews} ${overview.pendingReviews == 1 ? 'ejercicio pendiente' : 'ejercicios pendientes'}',
                icon: Icons.psychology_outlined,
                onTap: () => openExploreSection(context, 3, store),
              ),
              DashboardShortcut(
                title: 'Biblioteca',
                subtitle:
                    '${store.favoriteLessons.length} ${store.favoriteLessons.length == 1 ? 'lección guardada' : 'lecciones guardadas'}',
                icon: Icons.bookmarks_outlined,
                onTap: () => openExploreSection(context, 2, store),
              ),
              DashboardShortcut(
                title: 'Laboratorio offline',
                subtitle: 'Practica con simulaciones',
                icon: Icons.science_outlined,
                onTap: () => openExploreSection(context, 1, store),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TutorMessage(
            finished
                ? 'Te ganaste ese avance, cariño. Ahora toca usar el criterio: repasar una duda también es cosa de gente inteligente.'
                : overview.pendingReviews > 0
                ? 'Hay ${overview.pendingReviews} ${overview.pendingReviews == 1 ? 'ejercicio esperando' : 'ejercicios esperando'} otra mirada. Vamos a entender el tropiezo, cariño; barrerlo debajo del teclado no cuenta como defensa.'
                : 'Un concepto, una decisión, una explicación. Así se construye criterio, cariño. El botón de continuar no muerde; de eso me encargo yo.',
            action: TextButton.icon(
              onPressed: () => showStudyGuide(context),
              icon: const Icon(Icons.chat_bubble_outline, size: 16),
              label: const Text('Hablar con Aoi Bite'),
            ),
          ),
          SectionTitle(
            finished ? 'Para seguir practicando' : 'Tus siguientes cursos',
            subtitle: finished
                ? 'Puedes volver a cualquier curso.'
                : 'Sugerencias según el curso y la ruta que estás siguiendo.',
            trailing: IconButton(
              tooltip: 'Ver cursos',
              onPressed: onCourses,
              icon: const Icon(Icons.arrow_forward),
            ),
          ),
          DashboardGrid(
            minWidth: 280,
            children: [
              for (final suggestion in overview.recommendedCourses)
                CourseCard(
                  course: suggestion,
                  store: store,
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) =>
                          CourseScreen(course: suggestion, store: store),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: onCourses,
            icon: const Icon(Icons.apps_rounded),
            label: Text('Explorar los ${courses.length} cursos'),
          ),
          const SectionTitle('El camino que estás siguiendo'),
          DashboardShortcut(
            title: overview.activePath.path.title,
            subtitle:
                '${overview.activePath.completedLessons}/${overview.activePath.lessons.length} lecciones superadas',
            icon: Icons.route_outlined,
            onTap: () => openLearningPath(context, overview.activePath, store),
          ),
          const SectionTitle('Tu punto de partida'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AcademyBadge(
                    'DIAGNÓSTICO · 5 PREGUNTAS',
                    icon: Icons.quiz_outlined,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    store.diagnosticScore == null
                        ? 'Descubre qué conoces'
                        : 'Tu último diagnóstico: ${store.diagnosticScore}/5',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Una orientación para empezar. Todos los cursos siguen disponibles.',
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: () => startDiagnostic(context, store),
                    child: Text(
                      store.diagnosticScore == null
                          ? 'Hacer diagnóstico'
                          : 'Repetir diagnóstico',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      );
    },
  );
}
