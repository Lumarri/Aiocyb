import 'package:flutter/material.dart';

enum AoiExpression {
  smirk,
  explaining,
  skeptical,
  exasperated,
  disappointed,
  delighted,
  proud,
  thinking,
  curious,
  focused,
  surprised,
  relieved,
  playful,
  pouting,
  blushing,
  celebrating,
}

extension on AoiExpression {
  String get asset => switch (this) {
    AoiExpression.smirk => 'assets/aoi/aoi-smirk-v1.png',
    AoiExpression.explaining => 'assets/aoi/aoi-explain-v1.png',
    AoiExpression.skeptical => 'assets/aoi/aoi-skeptic-v1.png',
    AoiExpression.exasperated => 'assets/aoi/aoi-exasperated-v1.png',
    AoiExpression.disappointed => 'assets/aoi/aoi-disappointed-v1.png',
    AoiExpression.delighted => 'assets/aoi/aoi-delighted-v1.png',
    AoiExpression.proud => 'assets/aoi/aoi-proud-v1.png',
    AoiExpression.thinking => 'assets/aoi/aoi-thinking-v1.png',
    AoiExpression.curious => 'assets/aoi/aoi-curious-v1.png',
    AoiExpression.focused => 'assets/aoi/aoi-focused-v1.png',
    AoiExpression.surprised => 'assets/aoi/aoi-surprised-v1.png',
    AoiExpression.relieved => 'assets/aoi/aoi-relieved-v1.png',
    AoiExpression.playful => 'assets/aoi/aoi-playful-v1.png',
    AoiExpression.pouting => 'assets/aoi/aoi-pouting-v1.png',
    AoiExpression.blushing => 'assets/aoi/aoi-blushing-v1.png',
    AoiExpression.celebrating => 'assets/aoi/aoi-celebrating-v1.png',
  };

  String get description => switch (this) {
    AoiExpression.smirk => 'con una sonrisa ladeada',
    AoiExpression.explaining => 'explicando con atención',
    AoiExpression.skeptical => 'con una ceja levantada y una mirada pícara',
    AoiExpression.exasperated => 'con un gesto de exasperación cómica',
    AoiExpression.disappointed => 'con decepción teatral y una mirada burlona',
    AoiExpression.delighted => 'sonriendo con alegría por tu acierto',
    AoiExpression.proud => 'orgullosa de que completaras el curso',
    AoiExpression.thinking => 'pensativa mientras te da una pista',
    AoiExpression.curious =>
      'curiosa, con la cabeza inclinada y una ceja alzada',
    AoiExpression.focused => 'concentrada, con un lápiz junto a la barbilla',
    AoiExpression.surprised =>
      'sorprendida por un descubrimiento, con los ojos abiertos',
    AoiExpression.relieved =>
      'aliviada, con una sonrisa suave y la mano en el pecho',
    AoiExpression.playful =>
      'retándote con una sonrisa traviesa y un gesto de mano',
    AoiExpression.pouting => 'haciendo un puchero teatral por tu primer error',
    AoiExpression.blushing => 'con rubor pícaro y una sonrisa por tu progreso',
    AoiExpression.celebrating =>
      'celebrando el curso con una sonrisa y el puño alzado',
  };
}

/// Local portraits keep Aoi present even when the device is offline.
class AoiPortrait extends StatelessWidget {
  const AoiPortrait({
    super.key,
    this.expression = AoiExpression.smirk,
    this.width = 64,
    this.height = 64,
    this.closeUp = true,
  });

  final AoiExpression expression;
  final double width;
  final double height;
  final bool closeUp;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final image = Image.asset(
      expression.asset,
      // Keep Aoi visible while the next local expression is decoding.
      gaplessPlayback: true,
      width: width,
      height: height,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      excludeFromSemantics: true,
    );
    return Semantics(
      image: true,
      label: 'Aoi Bite, tu tutora cíborg, ${expression.description}.',
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(closeUp ? 18 : 24),
          border: Border.all(color: colors.primary.withValues(alpha: .25)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.primary.withValues(alpha: .16), colors.surface],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: closeUp
            ? Transform.scale(
                // The original smile is a wider portrait. Frame the face here
                // without changing or duplicating the source illustration.
                scale: expression == AoiExpression.smirk ? 1.7 : 1.35,
                alignment: Alignment.topCenter,
                child: image,
              )
            : image,
      ),
    );
  }
}
