import 'package:aiocyb/src/data/aoi_library.dart';
import 'package:aiocyb/src/data/certification_guides.dart';
import 'package:aiocyb/src/data/curriculum.dart';
import 'package:aiocyb/src/screens/certifications.dart';
import 'package:aiocyb/src/screens/course_overview.dart';
import 'package:aiocyb/src/state/academy_store.dart';
import 'package:aiocyb/src/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

Future<void> showGuide(
  WidgetTester tester,
  Widget page, {
  bool compact = false,
}) async {
  final size = compact ? const Size(320, 740) : const Size(390, 844);
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      key: UniqueKey(),
      theme: academyTheme(!compact, palette: NeonTheme.violet),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(compact ? 1.4 : 1)),
        child: child!,
      ),
      home: page,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapGuideLabel(WidgetTester tester, String label) async {
  final target = find.text(label).first;
  await Scrollable.ensureVisible(tester.element(target), alignment: .3);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  setUp(
    () => SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty(),
  );
  setUpAll(() async {
    await AoiLibrary.load();
  });

  test('Four independent goals use official HTTPS sources and describe preparation gaps', () {
    expect(certificationGuides.map((g) => g.id), [
      'ccst-networking',
      'ccst-cybersecurity',
      'isc2-cc',
      'ccna',
    ]);
    for (final guide in certificationGuides) {
      expect(guide.goals, hasLength(3));
      expect(guide.gaps, hasLength(3));
      expect(guide.courseIds.toSet().length, guide.courseIds.length);
      expect(guide.prerequisites, isNotEmpty);
      for (final link in guide.links) {
        final uri = Uri.parse(link.url);
        expect(uri.scheme, 'https');
        expect(['www.cisco.com', 'www.isc2.org'], contains(uri.host));
      }
    }
    final cc = certificationGuides.singleWhere((g) => g.id == 'isc2-cc');
    expect(cc.gaps.join(' '), contains('1 de septiembre de 2026'));
    expect(certificationGuides.last.prerequisites, contains('no exige'));
    expect(
      certificationGuides.last.links.single.url,
      contains('/enterprise/ccna/'),
    );
  });

  testWidgets(
    'Guide opens a goal and a related course without changing grades',
    (tester) async {
      final store = AcademyStore();
      await showGuide(tester, CertificationsScreen(store: store));
      await tapGuideLabel(tester, 'Cisco CCST Networking');
      expect(find.byType(CertificationDetailScreen), findsOneWidget);
      expect(find.text('Conocimientos previos'), findsOneWidget);
      expect(
        find.text(
          'Este avance cuenta lecciones locales. No mide preparación para el examen ni acredita una certificación.',
        ),
        findsOneWidget,
      );
      await tapGuideLabel(
        tester,
        courses.firstWhere((c) => c.id == 'networks-basics').title,
      );
      expect(find.byType(CourseScreen), findsOneWidget);
      expect(store.scores, isEmpty);
      expect(store.xp, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Related progress counts local lessons and an official link can be copied',
    (tester) async {
      final guide = certificationGuides.first;
      final related = courses.where((c) => guide.courseIds.contains(c.id));
      final count = related.expand((c) => c.lessons).length;
      final lesson = related.first.lessons.first;
      final store = AcademyStore()..scores[lesson.id] = lesson.questions.length;
      Object? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') copied = call.arguments;
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await showGuide(
        tester,
        CertificationDetailScreen(guide: guide, store: store),
      );
      expect(
        find.text('1 de $count lecciones superadas en esta selección'),
        findsOneWidget,
      );
      await tapGuideLabel(tester, 'Copiar enlace oficial');
      expect(copied, {'text': guide.links.single.url});
      expect(find.text('Enlace oficial copiado'), findsOneWidget);
      expect(store.scores, {lesson.id: lesson.questions.length});
    },
  );

  testWidgets('Every detail fits 320px in light mode with larger text', (
    tester,
  ) async {
    for (final guide in certificationGuides) {
      await showGuide(
        tester,
        CertificationDetailScreen(guide: guide, store: AcademyStore()),
        compact: true,
      );
      expect(tester.takeException(), isNull, reason: guide.id);
      await Scrollable.ensureVisible(
        tester.element(find.text('Copiar enlace oficial').last),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: guide.id);
    }
  });
}
