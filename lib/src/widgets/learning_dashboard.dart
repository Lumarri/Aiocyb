import 'package:flutter/material.dart';

import '../data/course_presentation.dart';
import '../models/learning_overview.dart';
import '../widgets/common.dart';
import 'learning_link.dart';

class DashboardGrid extends StatelessWidget {
  const DashboardGrid({
    super.key,
    required this.children,
    this.minWidth = 280,
    this.maxColumns = 3,
    this.spacing = 18,
  });
  final List<Widget> children;
  final double minWidth, spacing;
  final int maxColumns;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final minimum = MediaQuery.textScalerOf(context).scale(1) > 1.2
          ? minWidth * 1.25
          : minWidth;
      final columns = ((constraints.maxWidth + spacing) / (minimum + spacing))
          .floor()
          .clamp(1, maxColumns);
      final width = (constraints.maxWidth - (columns - 1) * spacing) / columns;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

class DashboardMetric extends StatelessWidget {
  const DashboardMetric({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.caption,
  });
  final String value, label;
  final String? caption;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 21),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          if (caption != null) ...[
            const SizedBox(height: 5),
            Text(
              caption!,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

/// Shared visual language for the dashboard and path overview; image assets
/// belong to the original five offline course families.
class LearningHero extends StatelessWidget {
  const LearningHero({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.cover,
    required this.actions,
    this.footer,
  });
  final String eyebrow, title, description, cover;
  final List<Widget> actions;
  final Widget? footer;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(22),
    child: ColoredBox(
      color: const Color(0xFF101E36),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 780;
          final copy = Padding(
            padding: EdgeInsets.all(wide ? 32 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    color: Color(0xFFA9BED9),
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: wide ? 32 : 27,
                    height: 1.18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(color: Color(0xFFCFDCEE), height: 1.6),
                ),
                const SizedBox(height: 22),
                Wrap(spacing: 12, runSpacing: 10, children: actions),
                if (footer != null) ...[const SizedBox(height: 20), footer!],
              ],
            ),
          );
          final image = Image.asset(
            'assets/artwork/$cover-v1.png',
            height: wide ? 310 : 145,
            width: double.infinity,
            fit: BoxFit.cover,
            cacheWidth: 1000,
            excludeFromSemantics: true,
          );
          return wide
              ? Row(
                  children: [
                    Expanded(flex: 6, child: copy),
                    Expanded(flex: 5, child: image),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [image, copy],
                );
        },
      ),
    ),
  );
}

class PathSummaryCard extends StatelessWidget {
  const PathSummaryCard({
    super.key,
    required this.progress,
    required this.onTap,
  });
  final PathProgress progress;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final track = courseTracks.firstWhere(
      (track) => track.id == progress.path.id,
    );
    return LearningLink(
      label: 'Ruta: ${progress.path.title}',
      value:
          '${progress.status}. ${progress.completedLessons} de ${progress.lessons.length} lecciones superadas. '
          '${(progress.progress * 100).round()} por ciento. ${progress.includedCourses.length} cursos.',
      hint: 'Ver cursos. ${progress.path.description}',
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  'assets/artwork/${track.cover}-v1.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  cacheWidth: 900,
                  excludeFromSemantics: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AcademyBadge(track.label, icon: track.icon),
                    const SizedBox(height: 14),
                    Text(
                      progress.path.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      progress.path.description,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${progress.includedCourses.length} cursos · ${progress.exercises} ejercicios · ${courseDuration(progress.minutes)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 18),
                    LinearProgressIndicator(value: progress.progress),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${progress.completedLessons}/${progress.lessons.length} lecciones · '
                            '${(progress.progress * 100).round()}%',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 19,
                          color: colors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      progress.status,
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
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

class DashboardShortcut extends StatelessWidget {
  const DashboardShortcut({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    ),
  );
}
