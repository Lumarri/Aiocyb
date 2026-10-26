import 'package:flutter/material.dart';

import '../data/course_presentation.dart';
import '../models/course.dart';
import '../models/learning_overview.dart';
import '../state/academy_store.dart';
import 'learning_link.dart';

class CourseCover extends StatelessWidget {
  const CourseCover({super.key, required this.course, this.height = 160});
  final Course course;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/artwork/${trackFor(course).cover}-v1.png',
          fit: BoxFit.cover,
          excludeFromSemantics: true,
          cacheWidth: 900,
        ),
        Positioned(
          top: 14,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xE60B1427),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white24),
            ),
            child: const Text(
              'CURSO · OFFLINE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class CourseLibraryCard extends StatelessWidget {
  const CourseLibraryCard({
    super.key,
    required this.course,
    required this.store,
    required this.onTap,
  });
  final Course course;
  final AcademyStore store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final track = trackFor(course);
    final progress = store.courseProgress(course);
    final started = LearningOverview(store).started(course);
    final profile = courseProfiles[course.id]!;
    return LearningLink(
      label: 'Curso: ${course.title}',
      value:
          '${LearningOverview(store).status(course)}. ${course.lessons.length} lecciones. '
          '${course.exerciseCount} ejercicios. ${(progress * 100).round()} por ciento completado.',
      hint: course.description,
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colors.outlineVariant.withValues(alpha: .6)),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CourseCover(course: course),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(track.icon, size: 16, color: colors.primary),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            track.label,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 9),
                    Text(
                      course.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      profile.skills.take(2).join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.primary, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 5,
                      children: [
                        CourseFact(
                          Icons.menu_book_outlined,
                          '${course.lessons.length} lecciones',
                        ),
                        CourseFact(
                          Icons.schedule,
                          courseDuration(course.minutes),
                        ),
                        CourseFact(
                          Icons.task_alt,
                          '${course.exerciseCount} ejercicios',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (progress > 0 || started) ...[
                      LinearProgressIndicator(value: progress),
                      const SizedBox(height: 10),
                    ] else ...[
                      Divider(
                        height: 1,
                        color: colors.outlineVariant.withValues(alpha: .5),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            progress == 1
                                ? 'Completado · Repasar'
                                : progress > 0
                                ? '${(progress * 100).round()}% completado'
                                : started
                                ? 'En curso · 0% completado'
                                : 'Desde cero · A tu ritmo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: progress > 0
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Icon(
                          progress == 1
                              ? Icons.check_circle_outline
                              : Icons.arrow_forward,
                          size: 19,
                          color: colors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CourseFact extends StatelessWidget {
  const CourseFact(this.icon, this.label, {super.key});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 15,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 5),
      Flexible(child: Text(label, style: const TextStyle(fontSize: 12))),
    ],
  );
}
