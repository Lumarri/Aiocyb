import 'package:flutter/material.dart';

/// One accessible action for a whole card, including its progress information.
/// Embedded progress indicators must not split the card's navigation label.
class LearningLink extends StatelessWidget {
  const LearningLink({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    required this.child,
    this.hint,
  });
  final String label, value;
  final String? hint;
  final VoidCallback onTap;
  final Widget child;
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    excludeSemantics: true,
    button: true,
    label: label,
    value: value,
    hint: hint,
    onTap: onTap,
    child: child,
  );
}
