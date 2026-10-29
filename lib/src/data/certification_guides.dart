/// Editorial orientation, independent of the entities and their examinations.
class CertificationGuide {
  const CertificationGuide({
    required this.id,
    required this.title,
    required this.entity,
    required this.stage,
    required this.audience,
    required this.prerequisites,
    required this.goals,
    required this.courseIds,
    required this.gaps,
    required this.nextStep,
    required this.aoi,
    required this.links,
  });
  final String id, title, entity, stage, audience, prerequisites, nextStep, aoi;
  final List<String> goals, courseIds, gaps;
  final List<({String title, String url})> links;
}

const certificationVerifiedDate = '28 de octubre de 2026';
const _ccstUrl =
    'https://www.cisco.com/site/us/en/learn/training-certifications/certifications/support-technician/index.html';

const certificationGuides = [
  CertificationGuide(
    id: 'ccst-networking',
    title: 'Cisco CCST Networking',
    entity: 'Cisco',
    stage: 'Inicio en redes',
    audience: 'Para quien quiere entender comunicaciones y explorar funciones iniciales de soporte de redes. Puede ser una primera meta antes de profundizar en administración de infraestructura.',
    prerequisites: 'Cisco no exige requisitos formales previos para CCST. Conviene manejar un dispositivo, reconocer su configuración básica y estudiar los objetivos oficiales antes de decidir una fecha de examen.',
    goals: [
      'Explicar cómo colaboran equipos, medios y protocolos para transportar una comunicación.',
      'Interpretar direccionamiento y distinguir funciones de enlace, encaminamiento y servicios.',
      'Investigar un problema con observaciones ordenadas y comunicar lo comprobado.',
    ],
    courseIds: [
      'networks-basics',
      'ip-dns',
      'home-wifi',
      'ipv4-subnetting',
      'ipv6-foundations',
      'switching-routing',
      'network-diagnostics',
    ],
    gaps: [
      'Practicar identificación de medios, conectores y condiciones físicas con material o simuladores adecuados.',
      'Contrastar cada objetivo de la versión vigente con una práctica independiente; las preguntas de Aiocyb son originales y no reproducen el examen.',
      'Consultar inscripción, condiciones, identificación, idiomas y políticas directamente en Cisco antes de reservar.',
    ],
    nextStep: 'Si te interesa administrar redes, puedes orientar el siguiente tramo hacia CCNA. CCST es una opción de entrada, no un requisito obligatorio para presentarte a CCNA.',
    aoi: 'Primero entiende quién entrega qué a quién, cariño. La credencial llega por el proceso oficial; aquí vamos construyendo el criterio para que no dependas de adivinar.',
    links: [(title: 'Ficha oficial de Cisco CCST', url: _ccstUrl)],
  ),
  CertificationGuide(
    id: 'ccst-cybersecurity',
    title: 'Cisco CCST Cybersecurity',
    entity: 'Cisco',
    stage: 'Inicio en defensa',
    audience: 'Para quien prefiere una entrada a ciberseguridad centrada en principios, equipos, redes y manejo inicial de incidentes. Puede elegirse como alternativa inicial a ISC2 CC según el objetivo de estudio.',
    prerequisites: 'No tiene requisitos formales previos de CCST. Es recomendable comprender cuentas, sistemas y redes básicas para relacionar controles con los riesgos que intentan reducir.',
    goals: [
      'Relacionar principios de seguridad con protección de redes y dispositivos finales.',
      'Distinguir evaluación de vulnerabilidades, tratamiento del riesgo y decisiones defensivas.',
      'Reconocer evidencias y seguir una respuesta a incidentes con alcance y responsabilidades definidos.',
    ],
    courseIds: [
      'foundations',
      'identity',
      'phishing',
      'device-prevention',
      'incident-response',
      'network-defense',
      'security-operations',
    ],
    gaps: [
      'Añadir práctica de herramientas defensivas y procedimientos de una organización en entornos autorizados.',
      'Revisar el temario oficial completo para detectar objetivos que requieran más profundidad que los cursos locales.',
      'Comprobar requisitos administrativos y las condiciones oficiales del examen y de mantenimiento de la credencial.',
    ],
    nextStep: 'Elige esta meta si su enfoque coincide con tu ruta. No necesitas obtener también ISC2 CC para que tu aprendizaje sea válido; puedes comparar ambas antes de invertir en una.',
    aoi: 'Defender no consiste en coleccionar insignias mientras ignoras una alerta, cielo. Vamos a entender redes, riesgo y respuesta; después eliges la meta que realmente te sirva.',
    links: [(title: 'Ficha oficial de Cisco CCST', url: _ccstUrl)],
  ),
  CertificationGuide(
    id: 'isc2-cc',
    title: 'ISC2 Certified in Cybersecurity (CC)',
    entity: 'ISC2',
    stage: 'Alternativa inicial en seguridad',
    audience: 'Para quien busca una base general de seguridad y contempla un puesto inicial o una transición de carrera. Ofrece otra orientación de entrada; no es un escalón obligatorio después de CCST.',
    prerequisites: 'ISC2 CC no requiere experiencia laboral previa en seguridad. Tener nociones de informática ayuda, pero la orientación es de entrada. Revisa el procedimiento oficial de examen y certificación antes de inscribirte.',
    goals: [
      'Conectar principios de seguridad y gobernanza con responsabilidades y decisiones de riesgo.',
      'Comprender identidad y acceso, junto con conceptos de seguridad de redes y nube.',
      'Relacionar operaciones de seguridad con detección, análisis y respuesta a incidentes.',
    ],
    courseIds: [
      'foundations',
      'identity',
      'web-privacy',
      'incident-response',
      'backup-recovery',
      'network-defense',
      'security-operations',
    ],
    gaps: [
      'Completar gobernanza, políticas, obligaciones y conceptos de nube con el temario y recursos oficiales; la relación local es orientativa, no una cobertura íntegra.',
      'Usar el esquema vigente desde el 1 de septiembre de 2026: principios, gobernanza, IAM, redes y nube, operaciones y respuesta.',
      'Revisar políticas de examen, pasos de certificación y compromisos de mantenimiento directamente en ISC2.',
    ],
    nextStep: 'Compara sus objetivos con CCST Cybersecurity y elige según el trabajo y la base que quieres desarrollar. Después refuerza las brechas detectadas con práctica y material oficial.',
    aoi: 'Aquí también cuentan políticas, identidades y responsabilidades, cariño. Una defensa elegante necesita algo más que puertos bien puestos; sí, incluso cuando los puertos te quedaron preciosos.',
    links: [
      (
        title: 'Ficha oficial de ISC2 CC',
        url: 'https://www.isc2.org/certifications/cc',
      ),
      (
        title: 'Temario oficial vigente y versiones por idioma',
        url: 'https://www.isc2.org/certifications/cc/cc-certification-exam-outline',
      ),
    ],
  ),
  CertificationGuide(
    id: 'ccna',
    title: 'Cisco CCNA',
    entity: 'Cisco',
    stage: 'Profundización posterior en redes',
    audience: 'Para quien quiere avanzar hacia administración de redes y dedicar más tiempo a configurar, verificar y resolver problemas de infraestructura. La orientación de Aiocyb introduce bases; esta meta requiere práctica adicional amplia.',
    prerequisites: 'Cisco no exige una certificación previa formal para CCNA. Dominar fundamentos y trabajar con topologías de laboratorio es una recomendación de aprendizaje, no una condición que obligue a comprar CCST.',
    goals: [
      'Profundizar fundamentos, acceso a red, conectividad IP y servicios IP.',
      'Aplicar fundamentos de seguridad al funcionamiento de la infraestructura.',
      'Ampliar automatización y programabilidad junto con la verificación práctica de equipos.',
    ],
    courseIds: [
      'ipv4-subnetting',
      'ipv6-foundations',
      'switching-routing',
      'network-diagnostics',
      'network-defense',
      'terminal-tools',
    ],
    gaps: [
      'Realizar laboratorios de configuración y diagnóstico en equipos o simuladores, incluyendo fallos y recuperación.',
      'Completar objetivos oficiales sobre tecnologías, servicios, acceso inalámbrico, automatización y programabilidad que aquí solo se introducen o no se cubren.',
      'Contrastar el temario vigente del examen asociado, las condiciones de inscripción y la política de renovación con Cisco.',
    ],
    nextStep: 'Usa los cursos relacionados para identificar qué bases ya trabajaste y prepara un plan aparte de laboratorio y objetivos oficiales. Terminar esta selección no acredita preparación completa ni garantiza aprobar.',
    aoi: 'Si quieres CCNA, cariño, toca ensuciarse las manos en el laboratorio y explicar cada resultado. Mis preguntas ayudan, pero no voy a venderte un título por una barra llena.',
    links: [
      (
        title: 'Ficha oficial de Cisco CCNA y acceso a sus objetivos',
        url: 'https://www.cisco.com/site/us/en/learn/training-certifications/certifications/enterprise/ccna/index.html',
      ),
    ],
  ),
];
