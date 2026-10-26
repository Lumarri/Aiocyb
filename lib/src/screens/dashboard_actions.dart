import 'package:flutter/material.dart';

import '../data/curriculum.dart';
import '../state/academy_store.dart';
import '../widgets/aoi_portrait.dart';
import '../widgets/common.dart';
import 'lesson_screens.dart';

Future<void> startDiagnostic(BuildContext context, AcademyStore store) async {
  await Navigator.push<int>(
    context,
    MaterialPageRoute(
      builder: (_) => QuizScreen(
        title: 'Tu punto de partida',
        store: store,
        questions: diagnosticQuestions,
        onComplete: store.recordDiagnostic,
      ),
    ),
  );
}

void showStudyGuide(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Un minuto con Aoi Bite',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            for (final item in [
              (
                '¿Cómo estudio?',
                'Abre un curso y recorre la teoría, los pasos y los casos antes de practicar. Cada lección indica cuántos ejercicios incluye y los aciertos necesarios para superarla.',
              ),
              (
                '¿Necesito internet?',
                'No para estudiar. El contenido, las imágenes y los ejercicios están incluidos. Tu progreso se guarda en este dispositivo.',
              ),
              (
                '¿Puedo repetir?',
                'Todas las veces que quieras. Aquí repetir no cuesta vidas, gemas ni tu paciencia. Conservamos tu mejor resultado.',
              ),
            ])
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(item.$1),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TutorMessage(
                      item.$2,
                      expression: AoiExpression.explaining,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            const Text(
              'No introduzcas contraseñas ni datos sensibles. Usamos situaciones ficticias para practicar.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}
