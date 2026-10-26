import 'package:flutter/material.dart';

import '../app_info.dart';
import '../data/curriculum.dart';
import '../models/course.dart';
import '../state/academy_store.dart';
import '../theme.dart';
import '../widgets/aoi_portrait.dart';
import '../widgets/common.dart';
import 'lesson_screens.dart';
import 'course_catalog.dart';
export 'course_catalog.dart';
import 'explore_screens.dart';
import 'learning_home.dart';
import 'learning_progress.dart';
export 'learning_home.dart';
export 'learning_progress.dart';

void openCourse(BuildContext context, Course course, AcademyStore store) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => CourseScreen(course: course, store: store),
    ),
  );
}

class PresentationScreen extends StatefulWidget {
  const PresentationScreen({
    super.key,
    required this.store,
    this.replay = false,
  });
  final AcademyStore store;
  final bool replay;
  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  final _name = TextEditingController();
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Brand(small: true)),
    body: PageBody(
      maxWidth: 760,
      children: [
        const SizedBox(height: 20),
        const AcademyBadge(
          'TU PRIMER PASO EN CIBERSEGURIDAD',
          icon: Icons.auto_awesome_outlined,
        ),
        const SizedBox(height: 24),
        Text(
          'Menos sustos.\nMás criterio digital.',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 18),
        const Text(
          'Aprende desde cero a proteger tus cuentas, reconocer engaños y cuidar tus datos. A tu ritmo y sin conexión.',
          style: TextStyle(fontSize: 17, height: 1.6),
        ),
        const SizedBox(height: 28),
        Center(
          child: Column(
            children: [
              const AoiPortrait(width: 240, height: 240, closeUp: false),
              const SizedBox(height: 14),
              Text('Aoi Bite', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Tu tutora cíborg de ciberseguridad',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const TutorMessage(
          'Hola, soy Aoi Bite. Primero entendemos la teoría, después practicamos con situaciones ficticias. Si fallas, te explico el porqué y puedes volver a intentarlo. Yo pongo las pistas; tú, el criterio. Sin vidas que se agoten, cariño.',
        ),
        const SectionTitle('Tu ruta de aprendizaje'),
        for (final (index, course) in courses.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary
                      .withValues(alpha: .12),
                  child: Text('${index + 1}'),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${course.lessons.length} lecciones · ${course.minutes} minutos',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 18),
        if (!widget.replay) ...[
          TextField(
            controller: _name,
            maxLength: 30,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: '¿Cómo te llamamos? (opcional)',
              hintText: 'Tu nombre o alias',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 14),
        ],
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () async {
              if (widget.replay) {
                Navigator.pop(context);
                return;
              }
              await widget.store.finishOnboarding(_name.text);
            },
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(
              widget.replay ? 'Volver a la academia' : 'Entrar a mi academia',
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Sin registro · Sin anuncios · Tu progreso se queda contigo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(height: 28),
      ],
    ),
  );
}

class AcademyShell extends StatefulWidget {
  const AcademyShell({super.key, required this.store});
  final AcademyStore store;
  @override
  State<AcademyShell> createState() => _AcademyShellState();
}

class _AcademyShellState extends State<AcademyShell> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 960;
    final pages = [
      HomeScreen(
        store: widget.store,
        onCourses: () => setState(() => _tab = 1),
      ),
      CatalogScreen(store: widget.store),
      ExploreScreen(store: widget.store),
      ProgressScreen(store: widget.store),
      SettingsScreen(store: widget.store),
    ];
    const labels = [
      'Inicio',
      'Cursos',
      'Explorar',
      'Mi progreso',
      'Configuración',
    ];
    const icons = [
      Icons.grid_view_rounded,
      Icons.auto_stories_outlined,
      Icons.explore_outlined,
      Icons.insights_outlined,
      Icons.tune_rounded,
    ];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: wide
            ? Text(labels[_tab], style: Theme.of(context).textTheme.titleMedium)
            : const Brand(small: true),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: AcademyBadge('Offline', icon: Icons.offline_bolt_outlined),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wide)
            Container(
              width: 224,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Theme.of(context).dividerColor
                        .withValues(alpha: .12),
                  ),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Brand(),
                    const SizedBox(height: 8),
                    const Text(
                      'TU ACADEMIA DIGITAL',
                      style: TextStyle(fontSize: 10, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 36),
                    for (var i = 0; i < labels.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          selected: _tab == i,
                          selectedTileColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: .1),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          leading: Icon(icons[i], size: 21),
                          title: Text(
                            labels[i],
                            style: const TextStyle(fontSize: 13),
                          ),
                          onTap: () => setState(() => _tab = i),
                        ),
                      ),
                    const SizedBox(height: 36),
                    const Icon(Icons.wifi_off_rounded, size: 26),
                    const SizedBox(height: 10),
                    const Text(
                      'Tu curiosidad no\nnecesita Wi-Fi.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'AIOCYB / V. $academyVersion',
                      style: TextStyle(fontSize: 10, letterSpacing: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(index: _tab, children: pages),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _tab,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              onDestinationSelected: (value) => setState(() => _tab = value),
              destinations: [
                for (var i = 0; i < labels.length; i++)
                  NavigationDestination(
                    icon: Icon(icons[i]),
                    label: i == 4 ? 'Ajustes' : labels[i],
                  ),
              ],
            ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.store});
  final AcademyStore store;
  @override
  Widget build(BuildContext context) => PageBody(
    maxWidth: 800,
    children: [
      Text('A tu manera.', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 10),
      const Text('Haz de esta academia un lugar cómodo para aprender.'),
      const SectionTitle('Tu experiencia'),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Temas neón', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text(
                'Cian o violeta, con acentos claros y brillo suave. Tu elección se guarda en este dispositivo.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  for (final palette in NeonTheme.values)
                    ChoiceChip(
                      avatar: CircleAvatar(
                        backgroundColor: palette == NeonTheme.cyan
                            ? const Color(0xFF67E8F9)
                            : const Color(0xFFC4B5FD),
                        radius: 8,
                      ),
                      label: Text(
                        palette == NeonTheme.cyan
                            ? 'Neón cian'
                            : 'Neón violeta',
                      ),
                      selected: store.neonTheme == palette,
                      onSelected: (_) => store.updateSettings(palette: palette),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      Card(
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Brillo suave'),
              subtitle: const Text(
                'Un halo discreto en las cabeceras, sin destellos.',
              ),
              value: store.neonGlow,
              onChanged: (value) => store.updateSettings(glow: value),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Tema oscuro'),
              subtitle: const Text('También puedes estudiar con fondo claro.'),
              value: store.darkMode,
              onChanged: (value) => store.updateSettings(dark: value),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Texto más grande'),
              subtitle: const Text('Aumenta el texto de toda la academia.'),
              value: store.largeText,
              onChanged: (value) => store.updateSettings(biggerText: value),
            ),
          ],
        ),
      ),
      const SectionTitle('Tu academia'),
      Card(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.waving_hand_outlined),
              title: const Text('Volver a la presentación'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PresentationScreen(store: store, replay: true),
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Fuentes y créditos'),
              subtitle: const Text('Referencias y origen de las imágenes'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const SourcesScreen()),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Licencias de software'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'Aiocyb',
                applicationVersion: academyVersion,
              ),
            ),
          ],
        ),
      ),
      const SectionTitle('Datos en este dispositivo'),
      const Text(
        'Sin cuenta ni sincronización. Se guardan tu alias, preferencias y resultados. Si borras los datos de la app o la desinstalas, puedes perder tu progreso.',
      ),
      const SizedBox(height: 18),
      OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('¿Reiniciar tu progreso?'),
              content: const Text(
                'Se borrarán las notas, los XP, el diagnóstico, los repasos y las simulaciones completadas. Tu alias, preferencias y favoritos se conservarán.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Conservar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Reiniciar'),
                ),
              ],
            ),
          );
          if (confirmed == true) await store.resetProgress();
        },
        icon: const Icon(Icons.restart_alt),
        label: const Text('Reiniciar progreso'),
      ),
      const SizedBox(height: 36),
      const Text(
        'Aiocyb $academyVersion · Aprende. Practica. Protégete.',
        style: TextStyle(fontSize: 12),
      ),
    ],
  );
}

class SourcesScreen extends StatelessWidget {
  const SourcesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Fuentes y créditos')),
    body: const PageBody(
      maxWidth: 800,
      children: [
        TutorMessage(
          'Las explicaciones y simulaciones están escritas para principiantes. Puedes estudiar todo el contenido incluido sin abrir las referencias.',
          expression: AoiExpression.explaining,
        ),
        SectionTitle('Referencias de aprendizaje'),
        SourceList(),
        SectionTitle('Imágenes de las etapas'),
        LearningDiagram(kind: 'defense'),
        SizedBox(height: 18),
        Text(
          'Iconos originales de la biblioteca Cisco Network Topology Icons: laptop.jpg, firewall.jpg y file server.jpg. Incluidos localmente sin modificar; no se descarga ninguna imagen al estudiar.',
        ),
        SizedBox(height: 12),
        SelectableText(
          'https://www.cisco.com/c/en/us/about/brand-center/network-topology-icons.html',
        ),
        SizedBox(height: 12),
        SelectableText(
          'https://www.cisco.com/c/en/us/about/brand-center/copyright-use.html',
        ),
        SizedBox(height: 16),
        Text(
          'Cisco permite el uso de sus iconos de topología sin modificarlos. © Cisco Systems, Inc. Aiocyb es un proyecto independiente y no ofrece certificaciones oficiales de Cisco.',
        ),
        SizedBox(height: 28),
      ],
    ),
  );
}
