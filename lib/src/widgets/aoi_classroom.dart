import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/aoi_dialogue.dart';
import 'aoi_portrait.dart';

/// The tutor stays outside the lesson scroll area: a side rail on large
/// screens and a pinned conversation with her portrait alongside on phones.
class AoiClassroom extends StatelessWidget {
  const AoiClassroom({
    super.key,
    required this.content,
    required this.dialogue,
    this.loading = false,
    this.error,
    this.onRetry,
  });

  final Widget content;
  final AoiDialogue? dialogue;
  final bool loading;
  final String? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth >= 900 && constraints.maxHeight >= 450) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: content),
            SizedBox(
              width: 320,
              child: _desktopTutor(context, constraints.maxHeight),
            ),
          ],
        );
      }
      final panelHeight = math.min(250.0, constraints.maxHeight * .39);
      return Column(
        children: [
          Expanded(child: content),
          SizedBox(height: panelHeight, child: _mobileTutor(context)),
        ],
      );
    },
  );

  AoiExpression get _expression => dialogue == null
      ? AoiExpression.explaining
      : AoiExpression.values.byName(dialogue!.expression);

  Widget _speech(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(error!),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      );
    }
    if (dialogue == null) {
      return const Text(
        'Avanza a la siguiente etapa para continuar la explicación.',
      );
    }
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dialogue!.text,
            key: ValueKey(dialogue!.id),
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (dialogue!.explanation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              dialogue!.explanation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _heading(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'AOI BITE',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.6,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
      Text(
        dialogue?.stage.label ??
            (loading ? 'Preparando la clase' : 'Tu tutora sigue aquí'),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );

  Widget _desktopTutor(BuildContext context, double height) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(
        left: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .2),
        ),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: AoiPortrait(
            expression: _expression,
            width: 240,
            height: math.min(230, height * .3),
            closeUp: false,
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: SingleChildScrollView(
            key: ValueKey(dialogue?.id),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heading(context),
                const SizedBox(height: 16),
                _speech(context),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _mobileTutor(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    child: Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: .35),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Align(
              alignment: Alignment.topCenter,
              child: AoiPortrait(
                expression: _expression,
                width: 76,
                height: 108,
                closeUp: false,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heading(context),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    key: ValueKey(dialogue?.id),
                    child: _speech(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
