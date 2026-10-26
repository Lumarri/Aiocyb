import 'package:flutter/material.dart';

import '../data/curriculum.dart';
import '../models/course.dart';
import '../state/academy_store.dart';
import '../theme.dart';
import 'aoi_portrait.dart';
import 'course_visuals.dart';

class Brand extends StatelessWidget {
  const Brand({super.key, this.small = false});
  final bool small;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.security_rounded, color: ink, size: 24),
      ),
      const SizedBox(width: 11),
      Flexible(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'aiocyb',
            style: TextStyle(
              fontSize: small ? 23 : 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
        ),
      ),
    ],
  );
}

class AcademyBadge extends StatelessWidget {
  const AcademyBadge(this.label, {super.key, this.icon, this.color});
  final String label;
  final IconData? icon;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: tint),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: tint,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.maxWidth = 1100});
  final List<Widget> children;
  final double maxWidth;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 20 : 36),
    child: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 28, bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

class TutorMessage extends StatelessWidget {
  const TutorMessage(
    this.message, {
    super.key,
    this.action,
    this.expression = AoiExpression.smirk,
  });
  final String message;
  final Widget? action;
  final AoiExpression expression;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: .06),
      border: Border.all(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: .2),
      ),
      borderRadius: BorderRadius.circular(22),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final portrait = AoiPortrait(expression: expression);
        final name = Text(
          'AOI BITE · TU TUTORA',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
        final dialogue = [
          Text(message),
          if (action != null) ...[const SizedBox(height: 8), action!],
        ];
        // Let the dialogue use the full card width on small phones and with
        // larger text, instead of squeezing it beside the portrait.
        final compact =
            constraints.maxWidth < 360 ||
            MediaQuery.textScalerOf(context).scale(14) > 18;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  portrait,
                  const SizedBox(width: 14),
                  Expanded(child: name),
                ],
              ),
              const SizedBox(height: 14),
              ...dialogue,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            portrait,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [name, const SizedBox(height: 7), ...dialogue],
              ),
            ),
          ],
        );
      },
    ),
  );
}

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.store,
    required this.onTap,
  });
  final Course course;
  final AcademyStore store;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) =>
      CourseLibraryCard(course: course, store: store, onTap: onTap);
}

class SourceList extends StatelessWidget {
  const SourceList({super.key, this.ids});
  final List<String>? ids;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final source in sources.where(
        (source) => ids == null || ids!.contains(source.id),
      ))
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                source.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(source.note),
              const SizedBox(height: 4),
              SelectableText(
                source.url,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      const Text(
        'Referencias revisadas en octubre de 2026. Las lecciones están incluidas en la app; consultar las páginas de referencia requiere conexión.',
        style: TextStyle(fontSize: 12),
      ),
    ],
  );
}

class LearningDiagram extends StatelessWidget {
  const LearningDiagram({super.key, required this.kind});
  final String kind;
  @override
  Widget build(BuildContext context) {
    final phishing = kind == 'phishing';
    final (title, nodes, note) = switch (kind) {
      'network' => (
        'Cómo viaja una petición',
        [
          ('laptop.jpg', 'Equipo'),
          ('router.jpg', 'Router'),
          ('file server.jpg', 'Servidor'),
        ],
        'Esquema simplificado: los enlaces unen equipos y el router comunica redes. El recorrido real puede incluir switches, puntos de acceso y varios routers.',
      ),
      'dns' => (
        'Del nombre a una dirección',
        [
          ('laptop.jpg', 'Cliente'),
          ('file server.jpg', 'Resolutor'),
          ('file server.jpg', 'Autoritativo'),
        ],
        'El resolutor puede responder desde caché o consultar la jerarquía DNS. Es un esquema simplificado: resolver un nombre no demuestra que su sitio sea honesto ni cifra la navegación.',
      ),
      'wifi' => (
        'Dos protecciones con alcances distintos',
        [
          ('laptop.jpg', 'Dispositivo'),
          ('router.jpg', 'Router / AP'),
          ('file server.jpg', 'Servicio'),
        ],
        'La protección Wi-Fi cubre el enlace inalámbrico local. HTTPS protege la comunicación con el servicio; ninguno de los dos garantiza por sí solo la honestidad del destino.',
      ),
      'browsing' => (
        'Conexión y destino se comprueban',
        [
          ('laptop.jpg', 'Navegador'),
          ('router.jpg', 'Red'),
          ('file server.jpg', 'Sitio web'),
        ],
        'HTTPS protege el transporte hasta el sitio. Revisa también el dominio y lo que te pide: un destino fraudulento puede tener una conexión cifrada.',
      ),
      'privacy' => (
        'Dónde quedan tus datos',
        [
          ('laptop.jpg', 'Datos locales'),
          ('router.jpg', 'Tránsito'),
          ('file server.jpg', 'Servicio'),
        ],
        'Borrar datos del navegador no borra los registros que conserva un servicio. Incógnito limita rastros locales y no vuelve invisible la actividad ante sitios o administradores de red.',
      ),
      _ => (
        phishing
            ? 'La pausa que corta el engaño'
            : kind == 'identity'
            ? 'Tu cuenta tiene varias puertas'
            : 'Una defensa por capas',
        [
          ('laptop.jpg', phishing ? 'Mensaje' : 'Tu equipo'),
          ('firewall.jpg', phishing ? 'Verifica' : 'Protección'),
          ('file server.jpg', phishing ? 'Datos a salvo' : 'Tus datos'),
        ],
        phishing
            ? 'No sigas el enlace: comprueba la petición por el canal oficial.'
            : 'El diagrama es conceptual: el icono de firewall representa una capa de defensa. No sustituye claves, MFA ni copias.',
      ),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            Row(
              children: [
                _node(nodes[0].$1, nodes[0].$2),
                const Expanded(
                  child: Icon(Icons.arrow_forward_rounded, size: 18),
                ),
                _node(nodes[1].$1, nodes[1].$2),
                const Expanded(
                  child: Icon(Icons.arrow_forward_rounded, size: 18),
                ),
                _node(nodes[2].$1, nodes[2].$2),
              ],
            ),
            const SizedBox(height: 16),
            Text(note),
            const SizedBox(height: 12),
            const Text(
              'Iconos de topología: Cisco Systems, Inc. Usados sin modificar. Diagrama educativo de Aiocyb; sin afiliación con Cisco.',
              style: TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _node(String asset, String label) => Flexible(
    flex: 3,
    child: Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ColoredBox(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/cisco/$asset',
                height: 58,
                width: 72,
                fit: BoxFit.contain,
                semanticLabel: label,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}
