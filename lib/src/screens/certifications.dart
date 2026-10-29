import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/certification_guides.dart';
import '../data/curriculum.dart';
import '../state/academy_store.dart';
import '../widgets/aoi_portrait.dart';
import '../widgets/common.dart';
import '../widgets/learning_link.dart';
import 'course_overview.dart';

void openCertifications(BuildContext context, AcademyStore store) =>
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => CertificationsScreen(store: store)),
    );

class CertificationsScreen extends StatelessWidget {
  const CertificationsScreen({super.key, required this.store});
  final AcademyStore store;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Guía de certificaciones')),
    body: PageBody(
      maxWidth: 1000,
      children: [
        const AcademyBadge(
          'ELIGE TU SIGUIENTE META',
          icon: Icons.workspace_premium_outlined,
        ),
        const SizedBox(height: 20),
        Text(
          'Una ruta con propósito.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        const Text(
          'Empieza por redes o seguridad según tu interés. CCST Cybersecurity e ISC2 CC son alternativas iniciales; CCNA es una posible profundización en redes. No necesitas conseguir todas.',
        ),
        const SizedBox(height: 20),
        const TutorMessage(
          'Elegimos una meta que te sirva, cariño, y comprobamos qué falta para ella. Las certificaciones las otorgan sus entidades; yo te ayudo a estudiar con criterio.',
        ),
        const SizedBox(height: 20),
        for (final guide in certificationGuides)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                title: Text(guide.title),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(guide.stage),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) =>
                        CertificationDetailScreen(guide: guide, store: store),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        const Text(
          'La guía se consulta offline. Los sitios oficiales requieren conexión; puedes copiar sus enlaces. Verificación editorial: $certificationVerifiedDate.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    ),
  );
}

class CertificationDetailScreen extends StatelessWidget {
  const CertificationDetailScreen({
    super.key,
    required this.guide,
    required this.store,
  });
  final CertificationGuide guide;
  final AcademyStore store;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final related = courses
          .where((course) => guide.courseIds.contains(course.id))
          .toList();
      final lessons = related.expand((course) => course.lessons).toList();
      final complete = lessons.where(store.isComplete).length;
      return Scaffold(
        appBar: AppBar(title: Text(guide.entity)),
        body: PageBody(
          maxWidth: 900,
          children: [
            AcademyBadge(guide.stage, icon: Icons.flag_outlined),
            const SizedBox(height: 18),
            Text(
              guide.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SectionTitle('Para quién sirve'),
            Text(guide.audience),
            const SectionTitle('Conocimientos previos'),
            Text(guide.prerequisites),
            const SectionTitle('Qué trabajar'),
            for (final goal in guide.goals) _GuidePoint(goal),
            const SizedBox(height: 20),
            TutorMessage(guide.aoi, expression: AoiExpression.explaining),
            const SectionTitle(
              'Bases estudiadas en Aiocyb',
              subtitle:
                  'Cursos relacionados de forma orientativa con esta meta.',
            ),
            Text(
              '$complete de ${lessons.length} lecciones superadas en esta selección',
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: lessons.isEmpty ? 0 : complete / lessons.length,
            ),
            const SizedBox(height: 10),
            const Text(
              'Este avance cuenta lecciones locales. No mide preparación para el examen ni acredita una certificación.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            for (final course in related)
              Builder(
                builder: (context) {
                  final value =
                      '${course.lessons.where(store.isComplete).length}/${course.lessons.length} lecciones superadas';
                  void open() => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) =>
                          CourseScreen(course: course, store: store),
                    ),
                  );
                  return LearningLink(
                    label: course.title,
                    value: value,
                    hint: 'Abrir curso relacionado',
                    onTap: open,
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(course.title),
                        subtitle: Text(value),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: open,
                      ),
                    ),
                  );
                },
              ),
            const SectionTitle('Qué falta completar'),
            for (final gap in guide.gaps) _GuidePoint(gap),
            const SectionTitle('Tu siguiente decisión'),
            Text(guide.nextStep),
            const SectionTitle(
              'Enlaces oficiales',
              subtitle: 'Consulta la entidad antes de inscribirte. Necesitan conexión.',
            ),
            for (final link in guide.links)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        link.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      SelectableText(link.url),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: link.url),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enlace oficial copiado'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy_outlined),
                        label: const Text('Copiar enlace oficial'),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Orientación independiente de Aiocyb. Cisco e ISC2 otorgan sus credenciales según sus propios procesos. Fuentes verificadas el $certificationVerifiedDate.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    },
  );
}

class _GuidePoint extends StatelessWidget {
  const _GuidePoint(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
