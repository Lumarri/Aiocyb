enum AoiStage {
  intro,
  theory,
  procedure,
  scenario,
  question,
  hint,
  correct,
  incorrect,
  result,
  courseComplete;

  String get label => switch (this) {
    intro => 'Bienvenida',
    theory => 'Teoría',
    procedure => 'Paso a paso',
    scenario => 'Caso práctico',
    question => 'Antes de responder',
    hint => 'Pista',
    correct => 'Por qué acertaste',
    incorrect => 'Revisemos esa opción',
    result => 'Cierre',
    courseComplete => 'Curso completado',
  };
}

class AoiDialogue {
  const AoiDialogue({
    required this.id,
    required this.lessonId,
    required this.stage,
    required this.anchor,
    required this.expression,
    required this.text,
    required this.explanation,
    this.choiceIndex,
  });

  factory AoiDialogue.fromJson(Map<String, dynamic> json) => AoiDialogue(
    id: json['id'] as String,
    lessonId: json['lessonId'] as String,
    stage: AoiStage.values.byName(json['stage'] as String),
    anchor: json['anchor'] as int,
    expression: json['expression'] as String,
    text: json['text'] as String,
    explanation: json['explanation'] as String,
    choiceIndex: json['choiceIndex'] as int?,
  );

  final String id;
  final String lessonId;
  final AoiStage stage;
  final int anchor;
  final int? choiceIndex;
  final String expression;
  final String text;
  final String explanation;
}
