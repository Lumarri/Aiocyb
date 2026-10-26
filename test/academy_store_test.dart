import 'package:aiocyb/src/data/curriculum.dart';
import 'package:aiocyb/src/state/academy_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

final class UnavailablePreferences extends InMemorySharedPreferencesAsync {
  UnavailablePreferences() : super.empty();
  bool unavailable = true;
  @override
  Future<bool> setString(
    String key,
    String value,
    SharedPreferencesOptions options,
  ) {
    if (unavailable) throw StateError('Storage unavailable');
    return super.setString(key, value, options);
  }
}

void main() {
  setUp(
    () => SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty(),
  );

  test('Progress, preferences and resume survive a fresh store', () async {
    final store = AcademyStore();
    await store.load();
    await store.finishOnboarding('  Alex  ');
    await store.updateSettings(dark: false, biggerText: true);
    await store.recordScore(allLessons.first, 2);
    await store.openLesson(allLessons[1]);
    await store.recordDiagnostic(4);
    await store.rememberDialogue('f-digital-life-intro-0-1');
    final restored = AcademyStore();
    await restored.load();
    expect(restored.name, 'Alex');
    expect(restored.onboarded, isTrue);
    expect(restored.darkMode, isFalse);
    expect(restored.largeText, isTrue);
    expect(restored.completedLessons, 1);
    expect(restored.xp, 50);
    expect(restored.resumeLesson.id, allLessons[1].id);
    expect(restored.diagnosticScore, 4);
    expect(restored.heardDialogueIds, contains('f-digital-life-intro-0-1'));
  });

  test('Retries keep the best score and never award duplicate XP', () async {
    final store = AcademyStore();
    await store.recordScore(allLessons.first, 1);
    expect(store.completedLessons, 0);
    await store.recordScore(allLessons.first, 3);
    await store.recordScore(allLessons.first, 0);
    await store.recordScore(allLessons.first, 3);
    expect(store.scores[allLessons.first.id], 3);
    expect(store.completedLessons, 1);
    expect(store.xp, 50);
    expect(() => store.recordScore(allLessons.first, 4), throwsArgumentError);
  });

  test(
    'Repeated mistakes persist per exercise and reset with learning data',
    () async {
      final store = AcademyStore();
      final lesson = allLessons.first;
      await store.recordMistake(lesson.id, 0);
      await store.recordMistake(lesson.id, 0);
      await store.recordMistake(lesson.id, 1);
      final restored = AcademyStore();
      await restored.load();
      expect(restored.mistakeCount(lesson.id, 0), 2);
      expect(restored.mistakeCount(lesson.id, 1), 1);
      expect(restored.mistakeCount(lesson.id, 2), 0);
      expect(restored.completedLessons, 0);
      await restored.resetProgress();
      final reset = AcademyStore();
      await reset.load();
      expect(reset.mistakeCounts, isEmpty);
    },
  );

  test(
    'Reset removes learning data while keeping profile and preferences',
    () async {
      final store = AcademyStore();
      await store.finishOnboarding('Alex');
      await store.updateSettings(biggerText: true);
      await store.recordScore(allLessons.first, 3);
      await store.recordDiagnostic(4);
      await store.openLesson(allLessons[1]);
      await store.rememberDialogue('already-seen');
      await store.resetProgress();
      final restored = AcademyStore();
      await restored.load();
      expect(restored.completedLessons, 0);
      expect(restored.diagnosticScore, isNull);
      expect(restored.lastLessonId, isNull);
      expect(restored.name, 'Alex');
      expect(restored.onboarded, isTrue);
      expect(restored.largeText, isTrue);
      expect(restored.heardDialogueIds, contains('already-seen'));
    },
  );

  test('Rapid changes persist in their original order', () async {
    final store = AcademyStore();
    await Future.wait([
      store.updateSettings(dark: false),
      store.updateSettings(biggerText: true),
      store.recordScore(allLessons.first, 3),
    ]);
    final restored = AcademyStore();
    await restored.load();
    expect(restored.darkMode, isFalse);
    expect(restored.largeText, isTrue);
    expect(restored.completedLessons, 1);
  });

  test(
    'Failed writes are visible and can be retried without losing progress',
    () async {
      final backend = UnavailablePreferences();
      SharedPreferencesAsyncPlatform.instance = backend;
      final store = AcademyStore();
      await store.recordScore(allLessons.first, 3);
      expect(store.storageError, isNotNull);
      backend.unavailable = false;
      await store.retrySave();
      expect(store.storageError, isNull);
      final restored = AcademyStore();
      await restored.load();
      expect(restored.completedLessons, 1);
    },
  );

  test('Corrupted local data does not prevent startup', () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({
          AcademyStore.storageKey: '{invalid',
        });
    final store = AcademyStore();
    await store.load();
    expect(store.storageError, isNotNull);
    expect(store.completedLessons, 0);
  });
}
