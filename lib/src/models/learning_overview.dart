import '../data/curriculum.dart';
import '../data/learning_paths.dart';
import '../models/course.dart';
import '../state/academy_store.dart';

/// Read-only projections of the existing local grades. Viewing a dashboard
/// never creates attempts, completions or extra XP.
class LearningOverview {
  LearningOverview(this.store);
  final AcademyStore store;

  bool started(Course course) =>
      store.startedCourseIds.contains(course.id) ||
      course.lessons.any(
        (lesson) =>
            store.scores.containsKey(lesson.id) ||
            store.lastLessonId == lesson.id,
      );
  String status(Course course) => store.courseProgress(course) == 1
      ? 'Completados'
      : started(course)
      ? 'En curso'
      : 'Por comenzar';

  int get completedCourses =>
      courses.where((c) => store.courseProgress(c) == 1).length;
  int get completedPaths => paths.where((path) => path.isComplete).length;
  int get attemptedLessons =>
      allLessons.where((l) => store.scores.containsKey(l.id)).length;
  int get gradedQuestions => allAssessmentLessons
      .where((l) => store.scores.containsKey(l.id))
      .fold(0, (sum, lesson) => sum + lesson.questions.length);
  int get bestCorrectAnswers =>
      allAssessmentLessons.fold(0, (sum, l) => sum + (store.scores[l.id] ?? 0));
  double? get bestAccuracy =>
      gradedQuestions == 0 ? null : bestCorrectAnswers / gradedQuestions;
  int get pendingReviews =>
      allAssessmentLessons.fold(
        0,
        (sum, lesson) =>
            sum +
            [
              for (var i = 0; i < lesson.questions.length; i++)
                if (store.needsReview(lesson.id, i)) i,
            ].length,
      ) +
      [
        for (var i = 0; i < diagnosticQuestions.length; i++)
          if (store.needsReview('diagnostic', i)) i,
      ].length;

  Course get resumeCourse =>
      courses.firstWhere((c) => c.lessons.contains(store.resumeLesson));
  List<PathProgress> get paths => [
    for (final path in learningPaths) PathProgress(path, store),
  ];
  PathProgress get activePath =>
      paths.firstWhere((p) => p.path.courseIds.contains(resumeCourse.id));

  List<Course> get recommendedCourses {
    if (store.completedLessons == allLessons.length) {
      return courses.take(3).toList();
    }
    final ordered = [resumeCourse, ...activePath.includedCourses, ...courses];
    final seen = <String>{};
    return ordered
        .where(
          (course) => store.courseProgress(course) < 1 && seen.add(course.id),
        )
        .take(3)
        .toList();
  }
}

class PathProgress {
  PathProgress(this.path, this.store);
  final LearningPath path;
  final AcademyStore store;
  List<Course> get includedCourses => [
    for (final id in path.courseIds)
      courses.firstWhere((course) => course.id == id),
  ];
  List<Lesson> get lessons =>
      includedCourses.expand((course) => course.lessons).toList();
  int get completedLessons => lessons.where(store.isComplete).length;
  int get completedCourses =>
      includedCourses.where((c) => store.courseProgress(c) == 1).length;
  int get exercises =>
      includedCourses.fold(0, (sum, c) => sum + c.exerciseCount);
  int get minutes => includedCourses.fold(0, (sum, c) => sum + c.minutes);
  double get progress =>
      lessons.isEmpty ? 0 : completedLessons / lessons.length;
  bool get isComplete =>
      lessons.isNotEmpty && completedLessons == lessons.length;
  bool get hasStarted => includedCourses.any(LearningOverview(store).started);
  String get status => isComplete
      ? 'Completada'
      : hasStarted
      ? 'En curso'
      : 'Por comenzar';
  Lesson get nextLesson {
    final opened = lessons.where(
      (lesson) => lesson.id == store.lastLessonId && !store.isComplete(lesson),
    );
    if (opened.isNotEmpty) return opened.first;
    return lessons.firstWhere(
      (l) => !store.isComplete(l),
      orElse: () => lessons.first,
    );
  }

  Course get nextCourse =>
      includedCourses.firstWhere((c) => c.lessons.contains(nextLesson));
}
