import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/aoi_dialogue.dart';
import 'micro_lesson_dialogues.dart';

/// Curated local conversations. There is no runtime text generation or network.
class AoiLibrary {
  AoiLibrary(Iterable<AoiDialogue> entries)
    : entries = List.unmodifiable(entries) {
    for (final entry in this.entries) {
      if (_byId.containsKey(entry.id)) {
        throw FormatException('Dialogue ID duplicated: ${entry.id}');
      }
      if (entry.text.trim().isEmpty ||
          (entry.stage == AoiStage.incorrect &&
              entry.explanation.trim().isEmpty)) {
        throw FormatException('Empty dialogue: ${entry.id}');
      }
      if (!const [
        'smirk',
        'explaining',
        'skeptical',
        'exasperated',
        'disappointed',
        'delighted',
        'proud',
        'thinking',
        'curious',
        'focused',
        'surprised',
        'relieved',
        'playful',
        'pouting',
        'blushing',
        'celebrating',
      ].contains(entry.expression)) {
        throw FormatException('Unknown expression: ${entry.id}');
      }
      _byId[entry.id] = entry;
    }
  }

  static const assetPaths = [
    'assets/dialogues/foundations.json',
    'assets/dialogues/identity.json',
    'assets/dialogues/phishing.json',
    'assets/dialogues/diagnostic.json',
    'assets/dialogues/celebrations.json',
    'assets/dialogues/diagnostic_retry.json',
  ];
  static Future<AoiLibrary>? _loading;
  static AoiLibrary? _cached;
  static Future<AoiLibrary> load({bool retry = false}) {
    if (retry) {
      _loading = null;
      _cached = null;
    }
    if (_cached != null) return Future.value(_cached!);
    return _loading ??= _readAssets();
  }

  static Future<AoiLibrary> _readAssets() async {
    final files = await Future.wait(assetPaths.map(rootBundle.loadString));
    final library = AoiLibrary([
      ...files.expand((raw) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return (decoded['dialogues'] as List).map(
          (value) =>
              AoiDialogue.fromJson(Map<String, dynamic>.from(value as Map)),
        );
      }),
      ...microLessonDialogues(),
    ]);
    _cached = library;
    return library;
  }

  final List<AoiDialogue> entries;
  final Map<String, AoiDialogue> _byId = {};
  AoiDialogue? byId(String id) => _byId[id];

  List<AoiDialogue> forContext(
    String lessonId,
    AoiStage stage,
    int anchor, {
    int? choiceIndex,
  }) => entries
      .where(
        (entry) =>
            entry.lessonId == lessonId &&
            entry.stage == stage &&
            entry.anchor == anchor &&
            (stage != AoiStage.incorrect || entry.choiceIndex == choiceIndex),
      )
      .toList(growable: false);
}

/// Each teaching situation has a fixed authored intervention. Rebuilding,
/// revisiting or restarting the app cannot rotate its explanation.
class AoiConversation {
  AoiConversation({
    required this.library,
    required this.seenIds,
    required this.onSeen,
  });
  final AoiLibrary library;
  final Set<String> seenIds;
  final void Function(String id) onSeen;
  AoiDialogue? current;

  AoiDialogue? open(
    String lessonId,
    AoiStage stage,
    int anchor, {
    int? choiceIndex,
    bool repeatedMistake = false,
  }) {
    final entries = library.forContext(
      lessonId,
      stage,
      anchor,
      choiceIndex: choiceIndex,
    );
    current = entries.isEmpty
        ? null
        : repeatedMistake && stage == AoiStage.incorrect
        ? entries.last
        : entries.first;
    if (current != null && seenIds.add(current!.id)) {
      onSeen(current!.id);
    }
    return current;
  }
}
