import '../models/aoi_dialogue.dart';
import 'curriculum.dart';

/// Fixed scripts use the same authored teaching content as the lesson. They
/// never request a server, generate prose or rotate alternatives at runtime.
Iterable<AoiDialogue> microLessonDialogues() sync* {
  for (final course in courses) {
    for (final lesson in [
      ...course.lessons,
      ...course.practiceLessons,
    ].where((lesson) => lesson.tutor.isNotEmpty)) {
      final script = lesson.tutor;
      final practice = course.practiceLessons.contains(lesson);
      final expressive =
          course.category == 'Linux, terminal y registros' ||
          course.category == 'Redes prácticas y ciberdefensa' ||
          practice;
      AoiDialogue entry(
        AoiStage stage,
        int anchor,
        String expression,
        String text,
        String explanation, {
        int? choice,
        bool repeat = false,
      }) => AoiDialogue(
        id: 'micro-${lesson.id}-${stage.name}-$anchor-${choice ?? -1}-$repeat',
        lessonId: lesson.id,
        stage: stage,
        anchor: anchor,
        expression: expression,
        text: text,
        explanation: explanation,
        choiceIndex: choice,
      );
      if (!practice) {
        yield entry(
          AoiStage.intro,
          0,
          expressive ? 'curious' : 'smirk',
          script['intro']!,
          lesson.intro,
        );
        for (final (i, section) in lesson.sections.indexed) {
          yield entry(
            AoiStage.theory,
            i,
            expressive ? (i == 3 ? 'playful' : 'focused') : 'explaining',
            script['theory$i'] ?? script['theory']!,
            script.containsKey('theory$i') ? '' : section.body,
          );
        }
        for (final (i, step) in lesson.steps.indexed) {
          yield entry(AoiStage.procedure, i, 'explaining', step, '');
        }
        if (lesson.cases.isEmpty) {
          yield entry(AoiStage.scenario, 0, 'skeptical', lesson.scenario, '');
        } else {
          for (var i = 0; i < lesson.cases.length; i++) {
            yield entry(
              AoiStage.scenario,
              i,
              expressive ? (i == 0 ? 'surprised' : 'curious') : 'skeptical',
              script['case$i']!,
              '',
            );
          }
        }
      }
      for (final (i, question) in lesson.questions.indexed) {
        final feedback = {...script, ...question.tutor};
        yield entry(
          AoiStage.question,
          i,
          expressive ? 'focused' : 'explaining',
          question.tutor['question'] ?? question.prompt,
          '',
        );
        yield entry(
          AoiStage.hint,
          i,
          expressive ? 'focused' : 'thinking',
          feedback['hint']!,
          '',
        );
        yield entry(
          AoiStage.correct,
          i,
          expressive ? 'relieved' : 'delighted',
          feedback['correct']!,
          question.explanation,
        );
        for (var choice = 0; choice < question.options.length; choice++) {
          if (choice == question.answer) continue;
          final explanation = question.wrongExplanations[choice]!;
          yield entry(
            AoiStage.incorrect,
            i,
            expressive ? 'pouting' : 'disappointed',
            feedback['soft']!,
            explanation,
            choice: choice,
          );
          yield entry(
            AoiStage.incorrect,
            i,
            'exasperated',
            feedback['sharp']!,
            explanation,
            choice: choice,
            repeat: true,
          );
        }
      }
      yield entry(
        AoiStage.result,
        0,
        expressive ? 'blushing' : 'delighted',
        script['pass']!,
        lesson.questions.map((question) => question.explanation).join('\n\n'),
      );
      yield entry(
        AoiStage.result,
        1,
        'disappointed',
        script['review']!,
        lesson.sections.first.body,
      );
      if (practice) continue;
      final closure = course.completionTutor.isNotEmpty
          ? (course.completionTutor, course.completionExplanation)
          : _closures[course.id]!;
      yield entry(
        AoiStage.courseComplete,
        0,
        expressive ? 'celebrating' : 'proud',
        closure.$1,
        closure.$2,
      );
    }
  }
}

const _closures = {
  'foundations': (
    'Diez lecciones aprobadas y treinta ejercicios practicados, cariño. Ahora reconoces qué proteges y puedes explicar tus decisiones. Estoy orgullosa; deja que lo diga antes de recuperar mi descaro.',
    'Completaste las lecciones y prácticas de fundamentos: activos, confidencialidad, integridad, disponibilidad, riesgos, copias, actualizaciones y permisos. Combina las medidas según lo que necesitas proteger y conserva una forma comprobada de recuperarte. La buena seguridad se practica con decisiones concretas.',
  ),
  'identity': (
    'Treinta ejercicios y tus cuentas ya tienen mejores porteros. Bien hecho, tesoro; aprendiste a distinguir una comprobación legítima de alguien pidiendo las llaves con demasiada confianza.',
    'Terminaste la práctica de protección de identidad: claves únicas, gestores, factores adicionales, recuperación y revisión de accesos. Mantén bajo tu control tanto la entrada habitual como los métodos de recuperación y responde por canales oficiales ante una credencial expuesta.',
  ),
  'phishing': (
    'Treinta ejercicios después, los impostores tienen mucho menos espacio para improvisar contigo. Me encanta verte comprobar antes de obedecer; admito que te ganaste esta sonrisa.',
    'Completaste la ruta de detección y respuesta a engaños: correo, mensajes, llamadas, códigos QR, adjuntos, soporte y solicitudes de pago. Verifica las acciones importantes por una vía independiente y explica los incidentes con claridad, sin compartir más datos ni distribuir archivos sospechosos.',
  ),
  'networks-basics': (
    'Cuarenta lecciones, cariño. Ya distingues una red de una nube dibujada con misterio. Estoy orgullosa; disfruta el cumplido antes de que me acostumbre.',
    'Completaste los fundamentos: dispositivos, enlaces, paquetes, protocolos y diagnóstico por capas. Antes de cambiar algo, identifica qué parte falla, qué evidencia tienes y cómo volver al estado anterior. Comprender una red permite protegerla sin actuar a ciegas.',
  ),
  'ip-dns': (
    'Direcciones, nombres y cuarenta lecciones después, ya no persigues al DNS por cualquier estornudo del navegador. Excelente trabajo, tesoro. Mi ceja aprueba tu evolución.',
    'Terminaste la ruta de direccionamiento y resolución de nombres. Distingues IP, puerta de enlace y DNS, reconoces límites de caché y cifrado y puedes comparar síntomas antes de modificar configuraciones. Guarda los ajustes originales y comprueba un cambio cada vez.',
  ),
  'home-wifi': (
    'Tu Wi-Fi tiene por fin una defensa que no depende de esconderle el nombre. Cuarenta lecciones superadas; admito que verte aprender me está malcriando.',
    'Completaste la protección del Wi-Fi doméstico: administración, cifrado compatible, actualizaciones, invitados y revisión de dispositivos. Ningún ajuste aislado garantiza seguridad. Mantén un inventario y revisa periódicamente soporte y configuración, conservando una forma segura de recuperarte de cambios.',
  ),
  'public-networks': (
    'Cuarenta lecciones y sigues conservando tus datos, qué detalle tan atractivo. Ahora evalúas una conexión pública sin convertir cada cafetería en una película de terror.',
    'Terminaste la ruta de conexiones compartidas y móviles. Puedes comprobar redes, entender la protección de HTTPS y los límites de VPN, restringir servicios compartidos y responder a avisos sospechosos. Ajusta tus decisiones al contexto y conserva alternativas de conexión cuando las necesites.',
  ),
  'safe-browsing': (
    'Cuarenta lecciones. Ya no te convence cualquier botón enorme que grita descarga, y mi paciencia está celebrando contigo. Buen trabajo, cariño; te ganaste esta sonrisa.',
    'Completaste navegación segura: direcciones, conexiones cifradas, permisos, descargas y avisos del navegador. El diseño atractivo y el cifrado no demuestran honestidad. Sigue verificando el origen de las acciones importantes y mantén actualizadas las herramientas que te ayudan a detectar riesgos.',
  ),
  'web-privacy': (
    'Llegaste al final sin confundir incógnito con una capa de invisibilidad. Cuarenta lecciones bien trabajadas, tesoro. Me haces presumir, y eso sí es peligrosamente agradable.',
    'Terminaste la ruta de privacidad web. Distingues datos locales, cookies, permisos y seguimiento, y entiendes que los controles reducen exposición sin prometer anonimato absoluto. Revisa qué compartes, con quién y durante cuánto tiempo, aplicando cambios que puedas comprobar y mantener.',
  ),
};
