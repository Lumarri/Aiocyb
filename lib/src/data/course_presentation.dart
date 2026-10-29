import 'package:flutter/material.dart';

import '../models/course.dart';
import 'learning_paths.dart';

/// Presentation metadata only: course and lesson identifiers stay unchanged.
class CourseTrack {
  const CourseTrack(
    this.id,
    this.label,
    this.cover,
    this.icon,
    this.description,
  );
  final String id, label, cover, description;
  final IconData icon;
}

const courseTracks = [
  CourseTrack(
    'start',
    'Fundamentos',
    'defense',
    Icons.shield_outlined,
    'Protege tus datos, reconoce engaños y cuida tus cuentas.',
  ),
  CourseTrack(
    'networks',
    'Redes y Wi-Fi',
    'networks',
    Icons.hub_outlined,
    'Entiende las conexiones que usas todos los días.',
  ),
  CourseTrack(
    'recovery',
    'Malware y recuperación',
    'recovery',
    Icons.restore,
    'Prevén incidentes y aprende a recuperar con criterio.',
  ),
  CourseTrack(
    'build',
    'Desarrollo seguro',
    'secure-build',
    Icons.code_rounded,
    'Aplica criptografía y controles en la web y en el código.',
  ),
  CourseTrack(
    'linux',
    'Linux y registros',
    'linux',
    Icons.terminal_rounded,
    'Observa sistemas, interpreta evidencias y conecta las pistas.',
  ),
  CourseTrack(
    'advanced-networks',
    'Redes y defensa',
    'networks',
    Icons.router_outlined,
    'Practica direccionamiento, diagnóstico y controles de red con casos explicados.',
  ),
];

CourseTrack trackFor(Course course) {
  final path = learningPaths.firstWhere(
    (path) => path.courseIds.contains(course.id),
  );
  return courseTracks.firstWhere((track) => track.id == path.id);
}

String courseDuration(int minutes) => minutes < 60
    ? '$minutes min'
    : minutes % 60 == 0
    ? '${minutes ~/ 60} h'
    : '${minutes ~/ 60} h ${minutes % 60} min';

class CourseProfile {
  const CourseProfile(this.skills, this.outcomes);
  final List<String> skills, outcomes;
}

const courseProfiles = <String, CourseProfile>{
  'foundations': CourseProfile(
    ['Riesgo digital', 'Datos personales', 'Defensa por capas'],
    [
      'Reconocer qué datos necesitas proteger y por qué.',
      'Distinguir amenazas, vulnerabilidades y decisiones de riesgo.',
      'Preparar hábitos de defensa para tus dispositivos y tus cuentas.',
    ],
  ),
  'identity': CourseProfile(
    ['Contraseñas', 'MFA', 'Recuperación de cuentas'],
    [
      'Elegir contraseñas únicas y gestionar su almacenamiento.',
      'Entender qué añade un segundo factor y cuáles son sus límites.',
      'Preparar la recuperación de una cuenta sin exponer sus secretos.',
    ],
  ),
  'phishing': CourseProfile(
    ['Ingeniería social', 'Verificación', 'Mensajes sospechosos'],
    [
      'Detectar peticiones que usan urgencia, autoridad o recompensas.',
      'Comprobar un mensaje por un canal independiente.',
      'Responder ante un engaño sin agravar la exposición.',
    ],
  ),
  'networks-basics': CourseProfile(
    ['Red local', 'Router', 'Flujo de datos'],
    [
      'Diferenciar dispositivos, enlaces y funciones de una red.',
      'Seguir el recorrido simplificado de una comunicación.',
      'Relacionar cada protección con el tramo que cubre.',
    ],
  ),
  'ip-dns': CourseProfile(
    ['Direcciones IP', 'DNS', 'Resolución de nombres'],
    [
      'Distinguir una dirección de red de un nombre de dominio.',
      'Explicar cómo interviene DNS al visitar un servicio.',
      'Reconocer los límites de una resolución de nombres correcta.',
    ],
  ),
  'home-wifi': CourseProfile(
    ['Wi-Fi doméstico', 'Router', 'Red de invitados'],
    [
      'Revisar la configuración de seguridad de una red doméstica.',
      'Separar el acceso de invitados de los equipos de confianza.',
      'Priorizar cambios de administración y mantenimiento del router.',
    ],
  ),
  'public-networks': CourseProfile(
    ['Redes públicas', 'HTTPS', 'Acceso compartido'],
    [
      'Evaluar el contexto antes de usar una conexión compartida.',
      'Distinguir la protección del enlace de la del transporte.',
      'Elegir precauciones proporcionadas a la actividad que realizas.',
    ],
  ),
  'safe-browsing': CourseProfile(
    ['Navegador', 'Dominios', 'Descargas'],
    [
      'Comprobar el destino y las peticiones de una página.',
      'Entender lo que HTTPS protege y lo que no demuestra.',
      'Tomar decisiones seguras ante descargas, avisos y permisos.',
    ],
  ),
  'web-privacy': CourseProfile(
    ['Privacidad', 'Rastros locales', 'Permisos'],
    [
      'Diferenciar los datos guardados en tu equipo y en un servicio.',
      'Reconocer los límites de la navegación privada.',
      'Revisar permisos y reducir la exposición innecesaria de datos.',
    ],
  ),
  'malware-basics': CourseProfile(
    ['Malware', 'Señales', 'Vías de entrada'],
    [
      'Reconocer comportamientos sospechosos sin dar un diagnóstico precipitado.',
      'Distinguir las vías habituales de exposición a software malicioso.',
      'Relacionar una señal con una acción defensiva razonable.',
    ],
  ),
  'device-prevention': CourseProfile(
    ['Actualizaciones', 'Permisos', 'Protección del equipo'],
    [
      'Priorizar actualizaciones y software de procedencia verificable.',
      'Revisar privilegios y configuraciones que amplían el riesgo.',
      'Combinar controles preventivos sin confiar en una única herramienta.',
    ],
  ),
  'ransomware-defense': CourseProfile(
    ['Ransomware', 'Contención', 'Preparación'],
    [
      'Identificar el impacto del cifrado y de la posible exposición de datos.',
      'Preparar medidas que limiten el alcance de un incidente.',
      'Elegir prioridades de respuesta sin precipitar la recuperación.',
    ],
  ),
  'incident-response': CourseProfile(
    ['Respuesta a incidentes', 'Evidencias', 'Comunicación'],
    [
      'Organizar los primeros pasos ante una sospecha de compromiso.',
      'Separar observaciones comprobadas de hipótesis.',
      'Documentar decisiones y coordinar una respuesta proporcionada.',
    ],
  ),
  'backup-recovery': CourseProfile(
    ['Copias de seguridad', 'Restauración', 'Verificación'],
    [
      'Diseñar copias con separación y objetivos de recuperación claros.',
      'Comprobar que una copia permite una restauración útil.',
      'Planificar una recuperación sin reintroducir el problema original.',
    ],
  ),
  'resilient-return': CourseProfile(
    ['Retorno seguro', 'Monitorización', 'Lecciones aprendidas'],
    [
      'Definir condiciones para volver a operar tras un incidente.',
      'Comprobar sistemas, cuentas y datos antes del retorno.',
      'Convertir lo aprendido en mejoras verificables.',
    ],
  ),
  'crypto-foundations': CourseProfile(
    ['Cifrado', 'Hash', 'Firmas digitales'],
    [
      'Diferenciar confidencialidad, integridad y autenticidad.',
      'Elegir entre cifrado, funciones hash y firmas según el objetivo.',
      'Reconocer que la criptografía depende del manejo de las claves.',
    ],
  ),
  'keys-data': CourseProfile(
    ['Claves', 'Secretos', 'Ciclo de vida'],
    [
      'Relacionar los datos sensibles con sus necesidades de protección.',
      'Planificar almacenamiento, acceso, rotación y revocación de claves.',
      'Responder ante la exposición de un secreto.',
    ],
  ),
  'web-security': CourseProfile(
    ['Sesiones', 'Autorización', 'Controles web'],
    [
      'Distinguir autenticación, autorización y gestión de sesiones.',
      'Reconocer riesgos en entradas, peticiones y respuestas web.',
      'Relacionar cada control con la amenaza que ayuda a reducir.',
    ],
  ),
  'secure-coding': CourseProfile(
    ['Validación', 'Lógica de negocio', 'Revisión de código'],
    [
      'Revisar contratos de entrada, permisos y condiciones de fallo.',
      'Reconocer riesgos en dependencias, secretos y operaciones concurrentes.',
      'Justificar un cambio defensivo con un caso de abuso concreto.',
    ],
  ),
  'linux-start': CourseProfile(
    ['Sistema de archivos', 'Rutas', 'Entorno Linux'],
    [
      'Orientarte en un sistema Linux e interpretar rutas.',
      'Distinguir tu usuario, el entorno y los recursos del sistema.',
      'Observar antes de realizar cambios en un equipo.',
    ],
  ),
  'terminal-tools': CourseProfile(
    ['Terminal', 'Flujos de texto', 'Filtros'],
    [
      'Interpretar comandos, argumentos y resultados.',
      'Seguir el recorrido de datos entre herramientas de texto.',
      'Elegir operaciones de consulta acordes con una pregunta concreta.',
    ],
  ),
  'linux-access': CourseProfile(
    ['Permisos Linux', 'Usuarios', 'Mínimo privilegio'],
    [
      'Interpretar propietario, grupo y permisos de un recurso.',
      'Relacionar los privilegios con una necesidad de acceso real.',
      'Reconocer el alcance de un cambio antes de aplicarlo.',
    ],
  ),
  'linux-operations': CourseProfile(
    ['Procesos', 'Servicios', 'Estado del sistema'],
    [
      'Distinguir un proceso de un servicio administrado.',
      'Relacionar estados, recursos y mensajes de funcionamiento.',
      'Planificar una comprobación antes de intervenir en un servicio.',
    ],
  ),
  'log-analysis': CourseProfile(
    ['Registros', 'Líneas de tiempo', 'Correlación'],
    [
      'Interpretar campos, tiempos y contexto de un registro.',
      'Correlacionar eventos sin convertir una coincidencia en certeza.',
      'Documentar evidencias y límites de una conclusión.',
    ],
  ),
  'linux-investigation': CourseProfile(
    ['Investigación defensiva', 'Evidencias', 'Informe'],
    [
      'Organizar las evidencias del caso ficticio Aula Norte.',
      'Contrastar hipótesis con registros y estado del sistema.',
      'Proponer una respuesta y explicar lo que aún no está demostrado.',
    ],
  ),
  'ipv4-subnetting': CourseProfile(
    ['Prefijos IPv4', 'Subnetting y VLSM', 'Rutas y traducción'],
    [
      'Calcular bloques y repartir espacio de direcciones según las necesidades.',
      'Distinguir ámbitos, asignación y decisiones de encaminamiento IPv4.',
      'Contrastar máscaras, traducciones y agregaciones con ejemplos verificables.',
    ],
  ),
  'ipv6-foundations': CourseProfile(
    ['Direcciones IPv6', 'SLAAC y DHCPv6', 'Doble pila'],
    [
      'Interpretar notación, alcance y selección de direcciones IPv6.',
      'Relacionar anuncios, vecinos y asignación con la comunicación del enlace.',
      'Validar rutas, controles y despliegues sin extrapolar resultados de IPv4.',
    ],
  ),
  'switching-routing': CourseProfile(
    ['VLAN y troncales', 'Switching', 'Enrutamiento y ACL'],
    [
      'Seguir decisiones de enlace y límites entre VLAN en un diagrama de red.',
      'Interpretar rutas y restricciones para comunicar segmentos con el alcance previsto.',
      'Preparar cambios de conectividad con pruebas y recuperación documentadas.',
    ],
  ),
  'network-diagnostics': CourseProfile(
    ['Hipótesis y evidencias', 'Análisis de tráfico', 'Diagnóstico por capas'],
    [
      'Elegir pruebas acotadas que distingan causas posibles de un fallo.',
      'Interpretar observaciones de enlace, protocolos y servicios con sus límites.',
      'Explicar resultados en un informe reproducible sin atribuciones infundadas.',
    ],
  ),
  'network-defense': CourseProfile(
    ['Segmentación', 'Firewalls y VPN', 'Decisiones de acceso'],
    [
      'Traducir necesidades de comunicación en permisos y restricciones concretos.',
      'Relacionar controles de red y host con identidad, contexto y visibilidad.',
      'Validar flujos permitidos y prohibidos junto con la recuperación del cambio.',
    ],
  ),
  'security-operations': CourseProfile(
    ['Análisis de eventos', 'Respuesta defensiva', 'Continuidad operativa'],
    [
      'Organizar inventarios, referencias y registros para evaluar señales de seguridad.',
      'Priorizar investigación y respuesta según evidencia, alcance e impacto.',
      'Documentar recuperación y siguientes pasos de aprendizaje con objetivos realistas.',
    ],
  ),
};

/// A preview of actual course theory, rather than a second source of definitions.
List<({Lesson lesson, TheorySection section})> courseConcepts(Course course) =>
    [
      for (final index in {
        0,
        course.lessons.length ~/ 2,
        course.lessons.length - 1,
      })
        (
          lesson: course.lessons[index],
          section: course.lessons[index].sections.first,
        ),
    ];
