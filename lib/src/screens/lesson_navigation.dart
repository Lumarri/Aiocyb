import 'package:flutter/material.dart';

import '../models/course.dart';
import '../state/academy_store.dart';
import 'lesson_studio.dart';

Future<void> openLesson(
  BuildContext context,
  Lesson lesson,
  AcademyStore store,
) async {
  store.openLesson(lesson);
  await Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => LessonScreen(lesson: lesson, store: store),
    ),
  );
}
