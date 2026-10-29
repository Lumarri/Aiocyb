import 'package:flutter/material.dart';

import '../models/course.dart';
import '../state/academy_store.dart';
import 'lesson_studio.dart';

class PracticeBankScreen extends StatelessWidget {
  const PracticeBankScreen({
    super.key,
    required this.course,
    required this.store,
  });
  final Course course;
  final AcademyStore store;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final completed = course.practiceLessons.where(store.isComplete).length;
      return Scaffold(
        appBar: AppBar(title: const Text('Refuerzos del curso')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      course.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Aplica lo aprendido a otros casos con Aoi. Cada refuerzo guarda su mejor nota por separado; tus aprobaciones y los XP de las lecciones se conservan.',
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '$completed de ${course.practiceLessons.length} refuerzos superados',
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: course.practiceLessons.isEmpty
                          ? 0
                          : completed / course.practiceLessons.length,
                    ),
                    const SizedBox(height: 22),
                    for (final (index, practice)
                        in course.practiceLessons.indexed)
                      Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Icon(
                            store.isComplete(practice)
                                ? Icons.check_circle_outline
                                : Icons.psychology_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text('${index + 1}. ${practice.title}'),
                          subtitle: Text(
                            store.scores.containsKey(practice.id)
                                ? 'Mejor nota: ${store.scores[practice.id]} / ${practice.questions.length}'
                                : 'Caso nuevo · ${practice.questions.length} ejercicio',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push<int>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(
                                title: practice.title,
                                questions: practice.questions,
                                scenario: practice.scenario,
                                lessonId: practice.id,
                                passingScore: store.passingScore(practice),
                                isReinforcement: true,
                                onComplete: (score) =>
                                    store.recordScore(practice, score),
                                store: store,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
