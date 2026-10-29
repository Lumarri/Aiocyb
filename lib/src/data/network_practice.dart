import '../models/course.dart';

/// Keeps every original lesson object and grade threshold unchanged.
Course withNetworkPractice(Course course, Map<String, Question> questions) =>
    Course(
      id: course.id,
      title: course.title,
      description: course.description,
      category: course.category,
      symbol: course.symbol,
      color: course.color,
      lessons: course.lessons,
      completionTutor: course.completionTutor,
      completionExplanation: course.completionExplanation,
      practiceLessons: [
        for (final lesson in course.lessons)
          if (questions[lesson.id] case final question?)
            Lesson(
              id: '${lesson.id}-reinforcement',
              title: 'Refuerzo · ${lesson.title}',
              minutes: 4,
              intro: question.scenario ?? lesson.scenario,
              sections: lesson.sections,
              steps: lesson.steps,
              scenario: question.scenario ?? lesson.scenario,
              questions: [question],
              sourceIds: lesson.sourceIds,
              diagram: lesson.diagram,
              tutor: {
                'pass': question.tutor['pass']!,
                'review': question.tutor['review']!,
              },
            ),
      ],
    );
