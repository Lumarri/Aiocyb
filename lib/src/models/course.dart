class Question {
  const Question(
    this.prompt,
    this.options,
    this.answer,
    this.explanation, {
    this.wrongExplanations = const [],
    this.scenario,
    this.tutor = const {},
  });
  final String prompt;
  final List<String> options;
  final int answer;
  final String explanation;
  final List<String?> wrongExplanations;
  final String? scenario;
  final Map<String, String> tutor;
}

class TheorySection {
  const TheorySection(this.title, this.body);
  final String title;
  final String body;
}

class ExplainedCase {
  const ExplainedCase({
    required this.title,
    required this.scenario,
    required this.explanation,
  });
  final String title;
  final String scenario;
  final String explanation;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.minutes,
    required this.intro,
    required this.sections,
    required this.steps,
    required this.scenario,
    required this.questions,
    required this.sourceIds,
    this.diagram = 'defense',
    this.tutor = const {},
    this.cases = const [],
  });
  final String id;
  final String title;
  final int minutes;
  final String intro;
  final List<TheorySection> sections;
  final List<String> steps;
  final String scenario;
  final List<Question> questions;
  final List<String> sourceIds;
  final String diagram;
  final List<ExplainedCase> cases;
  int get theoryWordCount => sections.fold(
    0,
    (count, section) =>
        count + section.body.trim().split(RegExp(r'\s+')).length,
  );

  /// Individually authored lines for the fixed lesson script.
  final Map<String, String> tutor;
}

class Course {
  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.symbol,
    required this.color,
    required this.lessons,
    this.practiceLessons = const [],
    this.completionTutor = '',
    this.completionExplanation = '',
  });
  final String id;
  final String title;
  final String description;
  final String category;
  final String symbol;
  final int color;
  final List<Lesson> lessons;

  /// Additional practice has independent grades and does not revoke a lesson pass.
  final List<Lesson> practiceLessons;
  final String completionTutor;
  final String completionExplanation;
  int get minutes => lessons.fold(0, (sum, lesson) => sum + lesson.minutes);
  int get exerciseCount => [
    ...lessons,
    ...practiceLessons,
  ].fold(0, (sum, lesson) => sum + lesson.questions.length);
}

class LearningSource {
  const LearningSource(this.id, this.title, this.url, this.note);
  final String id;
  final String title;
  final String url;
  final String note;
}
