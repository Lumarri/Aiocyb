import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/curriculum.dart';
import '../models/course.dart';
import '../theme.dart';

class AcademyStore extends ChangeNotifier {
  AcademyStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();
  final SharedPreferencesAsync _preferences;
  static const storageKey = 'aiocyb.academy.v1';
  bool onboarded = false;
  String name = '';
  bool darkMode = true;
  bool largeText = false;
  NeonTheme neonTheme = NeonTheme.cyan;
  bool neonGlow = true;
  final Set<String> favoriteLessons = {};
  final Set<String> startedCourseIds = {};
  final Set<String> completedLabs = {};
  final Map<String, int> reviewedMistakes = {};
  final Map<String, int> labMistakes = {};
  int? diagnosticScore;
  String? lastLessonId;
  Map<String, int> scores = {};
  final Set<String> heardDialogueIds = {};
  final Map<String, int> mistakeCounts = {};
  String? storageError;
  Future<void> _pendingWrite = Future<void>.value();

  Future<void> load() async {
    try {
      final raw = await _preferences.getString(storageKey);
      if (raw == null) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      onboarded = data['onboarded'] == true;
      name = data['name'] is String ? data['name'] as String : '';
      darkMode = data['darkMode'] != false;
      largeText = data['largeText'] == true;
      neonTheme = data['neonTheme'] == 'violet'
          ? NeonTheme.violet
          : NeonTheme.cyan;
      neonGlow = data['neonGlow'] != false;
      final favorites = data['favoriteLessons'];
      if (favorites is List) {
        final valid = allLessons.map((lesson) => lesson.id).toSet();
        favoriteLessons.addAll(
          favorites.whereType<String>().where(valid.contains),
        );
      }
      final labs = data['completedLabs'];
      if (labs is List) completedLabs.addAll(labs.whereType<String>());
      final labErrors = data['labMistakes'];
      if (labErrors is Map) {
        for (final entry in labErrors.entries) {
          if (entry.key is String && entry.value is int && entry.value > 0) {
            labMistakes[entry.key as String] = entry.value as int;
          }
        }
      }
      diagnosticScore = data['diagnosticScore'] is int
          ? data['diagnosticScore'] as int
          : null;
      lastLessonId = data['lastLessonId'] is String
          ? data['lastLessonId'] as String
          : null;
      final savedScores = data['scores'];
      final heard = data['heardDialogueIds'];
      if (heard is List) {
        heardDialogueIds.addAll(heard.whereType<String>());
      }
      if (savedScores is Map) {
        for (final lesson in allAssessmentLessons) {
          final value = savedScores[lesson.id];
          if (value is int && value >= 0 && value <= lesson.questions.length) {
            scores[lesson.id] = value;
          }
        }
      }
      final started = data['startedCourseIds'];
      final validCourses = courses.map((course) => course.id).toSet();
      startedCourseIds.clear();
      if (started is List) {
        startedCourseIds.addAll(
          started.whereType<String>().where(validCourses.contains),
        );
      }
      // Older saves know grades and one last lesson. Preserve those known
      // starts; earlier unrecorded visits cannot be reconstructed.
      for (final course in courses) {
        if (course.lessons.any(
          (lesson) =>
              scores.containsKey(lesson.id) || lesson.id == lastLessonId,
        )) {
          startedCourseIds.add(course.id);
        }
      }
      final mistakes = data['mistakeCounts'];
      if (mistakes is Map) {
        final validKeys = {
          for (final lesson in allAssessmentLessons)
            for (var i = 0; i < lesson.questions.length; i++) '${lesson.id}:$i',
          for (var i = 0; i < diagnosticQuestions.length; i++) 'diagnostic:$i',
        };
        for (final key in validKeys) {
          final value = mistakes[key];
          if (value is int && value > 0) mistakeCounts[key] = value;
        }
      }
      final reviewed = data['reviewedMistakes'];
      if (reviewed is Map) {
        for (final entry in mistakeCounts.entries) {
          final value = reviewed[entry.key];
          if (value is int && value > 0 && value <= entry.value) {
            reviewedMistakes[entry.key] = value;
          }
        }
      }
    } catch (_) {
      storageError = 'No pudimos leer tus datos locales. Puedes continuar y volver a intentar guardar.';
    }
  }

  bool isComplete(Lesson lesson) =>
      (scores[lesson.id] ?? 0) >= passingScore(lesson);
  int passingScore(Lesson lesson) => (lesson.questions.length * 2 / 3).ceil();
  int get completedLessons => allLessons.where(isComplete).length;
  int get completedPractice => allPracticeLessons.where(isComplete).length;
  int get xp => completedLessons * 50;
  double courseProgress(Course course) =>
      course.lessons.where(isComplete).length / course.lessons.length;
  double get progress => completedLessons / allLessons.length;
  Lesson get nextLesson => allLessons.firstWhere(
    (lesson) => !isComplete(lesson),
    orElse: () => allLessons.first,
  );
  Lesson get resumeLesson => allLessons.firstWhere(
    (lesson) => lesson.id == lastLessonId && !isComplete(lesson),
    orElse: () => nextLesson,
  );

  Future<void> _save() {
    final snapshot = jsonEncode({
      'onboarded': onboarded,
      'name': name,
      'darkMode': darkMode,
      'largeText': largeText,
      'neonTheme': neonTheme.name,
      'neonGlow': neonGlow,
      'favoriteLessons': favoriteLessons.toList(),
      'startedCourseIds': startedCourseIds.toList(),
      'completedLabs': completedLabs.toList(),
      'labMistakes': labMistakes,
      'reviewedMistakes': reviewedMistakes,
      'diagnosticScore': diagnosticScore,
      'lastLessonId': lastLessonId,
      'scores': scores,
      'heardDialogueIds': heardDialogueIds.toList(),
      'mistakeCounts': mistakeCounts,
    });
    notifyListeners();
    _pendingWrite = _pendingWrite.then((_) async {
      try {
        await _preferences.setString(storageKey, snapshot);
        storageError = null;
      } catch (_) {
        storageError = 'No se guardaron los últimos cambios. Revisa el almacenamiento y pulsa Reintentar.';
      }
      notifyListeners();
    });
    return _pendingWrite;
  }

  Future<void> retrySave() => _save();
  int mistakeCount(String lessonId, int questionIndex) =>
      mistakeCounts['$lessonId:$questionIndex'] ?? 0;

  Future<void> recordMistake(String lessonId, int questionIndex) {
    final key = '$lessonId:$questionIndex';
    mistakeCounts[key] = mistakeCount(lessonId, questionIndex) + 1;
    return _save();
  }

  Future<void> rememberDialogue(String id) {
    heardDialogueIds.add(id);
    return _save();
  }

  Future<void> finishOnboarding(String displayName) {
    name = displayName.trim();
    onboarded = true;
    return _save();
  }

  Future<void> updateSettings({
    bool? dark,
    bool? biggerText,
    NeonTheme? palette,
    bool? glow,
  }) {
    darkMode = dark ?? darkMode;
    largeText = biggerText ?? largeText;
    neonTheme = palette ?? neonTheme;
    neonGlow = glow ?? neonGlow;
    return _save();
  }

  Future<void> toggleFavorite(String lessonId) {
    if (!allLessons.any((lesson) => lesson.id == lessonId)) {
      throw ArgumentError.value(lessonId, 'lessonId');
    }
    if (!favoriteLessons.remove(lessonId)) favoriteLessons.add(lessonId);
    return _save();
  }

  Future<void> completeLab(String id) {
    completedLabs.add(id);
    return _save();
  }

  Future<void> recordLabMistake(String id, int stage) {
    final key = '$id:$stage';
    labMistakes[key] = (labMistakes[key] ?? 0) + 1;
    return _save();
  }

  bool needsReview(String lessonId, int index) {
    final key = '$lessonId:$index';
    return (mistakeCounts[key] ?? 0) > (reviewedMistakes[key] ?? 0);
  }

  Future<void> markReviewed(String lessonId, int index) {
    final key = '$lessonId:$index';
    final count = mistakeCount(lessonId, index);
    if (count > 0) reviewedMistakes[key] = count;
    return _save();
  }

  Future<void> openLesson(Lesson lesson) {
    _rememberStartedCourse(lesson);
    lastLessonId = lesson.id;
    return _save();
  }

  Future<void> recordScore(Lesson lesson, int score) {
    if (score < 0 || score > lesson.questions.length) {
      throw ArgumentError.value(score, 'score');
    }
    final previous = scores[lesson.id] ?? 0;
    _rememberStartedCourse(lesson);
    if (score > previous || !scores.containsKey(lesson.id)) {
      scores[lesson.id] = score;
    }
    return _save();
  }

  void _rememberStartedCourse(Lesson lesson) {
    for (final course in courses) {
      if ([
        ...course.lessons,
        ...course.practiceLessons,
      ].any((entry) => entry.id == lesson.id)) {
        startedCourseIds.add(course.id);
        return;
      }
    }
  }

  Future<void> recordDiagnostic(int score) {
    diagnosticScore = score;
    return _save();
  }

  Future<void> resetProgress() {
    scores = {};
    diagnosticScore = null;
    lastLessonId = null;
    startedCourseIds.clear();
    mistakeCounts.clear();
    reviewedMistakes.clear();
    completedLabs.clear();
    labMistakes.clear();
    return _save();
  }
}
