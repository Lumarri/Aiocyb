import 'package:flutter/material.dart';

import '../data/course_presentation.dart';
import '../data/curriculum.dart';
import '../models/course.dart';
import '../models/learning_overview.dart';
import '../state/academy_store.dart';
import '../widgets/common.dart';
import 'lesson_screens.dart';

String _searchable(String value) {
  var result = value.toLowerCase();
  for (final pair in [
    ('á', 'a'),
    ('é', 'e'),
    ('í', 'i'),
    ('ó', 'o'),
    ('ú', 'u'),
    ('ü', 'u'),
  ]) {
    result = result.replaceAll(pair.$1, pair.$2);
  }
  return result;
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, required this.store});
  final AcademyStore store;
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _search = TextEditingController();
  final _resultsKey = GlobalKey();
  String _query = '',
      _track = 'all',
      _status = 'Todos',
      _sort = 'Ruta sugerida';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matchesStatus(Course course) {
    return _status == 'Todos' ||
        LearningOverview(widget.store).status(course) == _status;
  }

  void _clear() => setState(() {
    _query = '';
    _track = 'all';
    _status = 'Todos';
    _search.clear();
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final terms = _searchable(_query).trim().split(RegExp(r'\s+'));
    final filtered = courses.where((course) {
      final text = _searchable(
        '${course.title} ${course.category} ${course.description} '
        '${courseProfiles[course.id]!.skills.join(' ')} '
        '${course.lessons.map((lesson) => lesson.title).join(' ')}',
      );
      return (_track == 'all' || trackFor(course).id == _track) &&
          _matchesStatus(course) &&
          terms.every(text.contains);
    }).toList();
    if (_sort == 'Menor duración') {
      filtered.sort((a, b) => a.minutes.compareTo(b.minutes));
    } else if (_sort == 'Nombre A–Z') {
      filtered.sort(
        (a, b) => _searchable(a.title).compareTo(_searchable(b.title)),
      );
    }
    final resume = widget.store.resumeLesson;
    final resumeCourse = courses.firstWhere(
      (course) => course.lessons.contains(resume),
    );
    return PageBody(
      maxWidth: 1280,
      children: [
        _CatalogHero(
          course: resumeCourse,
          onExplore: () => Scrollable.ensureVisible(
            _resultsKey.currentContext!,
            duration: const Duration(milliseconds: 350),
          ),
          onContinue: () => openLesson(context, resume, widget.store),
          hasProgress: widget.store.scores.isNotEmpty,
        ),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, constraints) {
            final sidebar = constraints.maxWidth >= 1000;
            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  key: _resultsKey,
                  children: [
                    Expanded(
                      child: Text(
                        'Encuentra tu próximo curso',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Elige un tema. Entiende el porqué. Ponlo a prueba.',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _search,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Buscar tema, curso o lección…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpiar búsqueda',
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() {
                              _query = '';
                              _search.clear();
                            }),
                          ),
                  ),
                ),
                if (!sidebar) ...[
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _trackChip(
                          'all',
                          'Todas las áreas',
                          Icons.apps_rounded,
                        ),
                        for (final track in courseTracks)
                          _trackChip(track.id, track.label, track.icon),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${filtered.length} ${filtered.length == 1 ? 'curso disponible' : 'cursos disponibles'}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (!sidebar) _statusMenu(),
                    PopupMenuButton<String>(
                      tooltip: 'Ordenar cursos',
                      initialValue: _sort,
                      onSelected: (value) => setState(() => _sort = value),
                      itemBuilder: (_) => [
                        for (final value in [
                          'Ruta sugerida',
                          'Menor duración',
                          'Nombre A–Z',
                        ])
                          CheckedPopupMenuItem(
                            value: value,
                            checked: value == _sort,
                            child: Text(value),
                          ),
                      ],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sort, size: 18),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _sort,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            const Icon(Icons.expand_more, size: 17),
                          ],
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty ||
                        _track != 'all' ||
                        _status != 'Todos')
                      TextButton.icon(
                        onPressed: _clear,
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Quitar filtros'),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 44,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          const Text('No encontramos cursos con esa búsqueda.'),
                          TextButton(
                            onPressed: _clear,
                            child: const Text('Ver todos los cursos'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, grid) {
                      final scale = MediaQuery.textScalerOf(context).scale(1);
                      final minWidth = scale > 1.2 ? 330.0 : 265.0;
                      final columns = ((grid.maxWidth + 20) / (minWidth + 20))
                          .floor()
                          .clamp(1, 3);
                      final width =
                          (grid.maxWidth - (columns - 1) * 20) / columns;
                      return Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          for (final course in filtered)
                            SizedBox(
                              width: width,
                              child: CourseCard(
                                course: course,
                                store: widget.store,
                                onTap: () => Navigator.of(context).push<void>(
                                  MaterialPageRoute(
                                    builder: (_) => CourseScreen(
                                      course: course,
                                      store: widget.store,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
              ],
            );
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sidebar) ...[
                  SizedBox(
                    width: 210,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ÁREAS DE APRENDIZAJE',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w800,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        for (final track in [null, ...courseTracks])
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: ListTile(
                              selected: _track == (track?.id ?? 'all'),
                              selectedTileColor: colors.primary.withValues(
                                alpha: .09,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              leading: Icon(
                                track?.icon ?? Icons.apps_rounded,
                                size: 19,
                              ),
                              title: Text(
                                track?.label ?? 'Todas las áreas',
                                style: const TextStyle(fontSize: 13),
                              ),
                              onTap: () =>
                                  setState(() => _track = track?.id ?? 'all'),
                            ),
                          ),
                        const Divider(height: 40),
                        const Text(
                          'MI APRENDIZAJE',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final status in [
                          'Todos',
                          'En curso',
                          'Por comenzar',
                          'Completados',
                        ])
                          CheckboxListTile(
                            value: _status == status,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(status),
                            onChanged: (_) => setState(() => _status = status),
                          ),
                        const Divider(height: 32),
                        const CourseFactLabel(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 30),
                ],
                Expanded(child: content),
              ],
            );
          },
        ),
        const SizedBox(height: 36),
      ],
    );
  }

  Widget _trackChip(String id, String label, IconData icon) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      avatar: Icon(icon, size: 17),
      label: Text(label),
      selected: _track == id,
      onSelected: (_) => setState(() => _track = id),
    ),
  );

  Widget _statusMenu() => PopupMenuButton<String>(
    tooltip: 'Filtrar por progreso',
    initialValue: _status,
    onSelected: (value) => setState(() => _status = value),
    itemBuilder: (_) => [
      for (final value in ['Todos', 'En curso', 'Por comenzar', 'Completados'])
        CheckedPopupMenuItem(
          value: value,
          checked: _status == value,
          child: Text(value),
        ),
    ],
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.filter_list, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Progreso: $_status',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const Icon(Icons.expand_more, size: 17),
        ],
      ),
    ),
  );
}

class CourseFactLabel extends StatelessWidget {
  const CourseFactLabel({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        Icons.offline_pin_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
      const SizedBox(height: 10),
      const Text(
        'Tu academia va contigo.',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 6),
      Text(
        'Teoría, casos y práctica incluidos en el dispositivo.',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}

class _CatalogHero extends StatelessWidget {
  const _CatalogHero({
    required this.course,
    required this.onExplore,
    required this.onContinue,
    required this.hasProgress,
  });
  final Course course;
  final VoidCallback onExplore, onContinue;
  final bool hasProgress;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(22),
    child: ColoredBox(
      color: const Color(0xFF101E36),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          final copy = Padding(
            padding: EdgeInsets.all(wide ? 36 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AIOCYB / ESCUELA DE CIBERSEGURIDAD',
                  style: TextStyle(
                    color: Color(0xFF9DB5D6),
                    fontSize: 10,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Aprende a defender\nlo que importa.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: wide ? 38 : 30,
                    fontWeight: FontWeight.w800,
                    height: 1.12,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'De tu primera contraseña a tu primera investigación.\nCon Aoi, a tu ritmo y sin conexión.',
                  style: TextStyle(color: Color(0xFFC3D0E4), height: 1.6),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    FilledButton(
                      onPressed: onExplore,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFBDF3E6),
                        foregroundColor: const Color(0xFF0D2530),
                      ),
                      child: const Text('Explorar catálogo'),
                    ),
                    TextButton.icon(
                      onPressed: onContinue,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.play_circle_outline, size: 20),
                      label: Text(
                        hasProgress
                            ? 'Continuar aprendizaje'
                            : 'Comenzar desde cero',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  '${courses.length} cursos  /  ${courseTracks.length} rutas  /  '
                  '${courses.fold(0, (sum, c) => sum + c.exerciseCount)} ejercicios',
                  style: const TextStyle(
                    color: Color(0xFF9DB5D6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
          final art = Image.asset(
            'assets/artwork/${trackFor(course).cover}-v1.png',
            width: double.infinity,
            height: wide ? 340 : 155,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
            cacheWidth: 1000,
          );
          return wide
              ? Row(
                  children: [
                    Expanded(flex: 6, child: copy),
                    Expanded(flex: 5, child: art),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [art, copy],
                );
        },
      ),
    ),
  );
}
