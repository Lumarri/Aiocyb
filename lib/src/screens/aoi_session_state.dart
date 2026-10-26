import 'package:flutter/material.dart';

import '../data/aoi_library.dart';
import '../models/aoi_dialogue.dart';
import '../state/academy_store.dart';
import '../widgets/aoi_classroom.dart';

mixin AoiSessionState<T extends StatefulWidget> on State<T> {
  AcademyStore get tutorStore;
  String get tutorLessonId;
  void onAoiReady();
  AoiConversation? conversation;
  String? conversationError;

  @override
  void initState() {
    super.initState();
    _loadConversation();
  }

  Future<void> _loadConversation({bool retry = false}) async {
    try {
      final library = await AoiLibrary.load(retry: retry);
      if (!mounted) return;
      conversation = AoiConversation(
        library: library,
        seenIds: tutorStore.heardDialogueIds,
        onSeen: (id) {
          tutorStore.rememberDialogue(id);
        },
      );
      conversationError = null;
      onAoiReady();
    } catch (_) {
      if (mounted) {
        setState(
          () => conversationError = 'No pudimos abrir las conversaciones locales. Vuelve a intentarlo.',
        );
      }
    }
  }

  void speak(
    AoiStage stage,
    int anchor, {
    int? choiceIndex,
    bool repeatedMistake = false,
  }) {
    if (conversation == null) return;
    setState(
      () => conversation!.open(
        tutorLessonId,
        stage,
        anchor,
        choiceIndex: choiceIndex,
        repeatedMistake: repeatedMistake,
      ),
    );
  }

  Widget classroom(Widget content) => AoiClassroom(
    content: content,
    dialogue: conversation?.current,
    loading: conversation == null && conversationError == null,
    error: conversationError,
    onRetry: () {
      setState(() => conversationError = null);
      _loadConversation(retry: true);
    },
  );
}
