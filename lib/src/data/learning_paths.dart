class LearningPath {
  const LearningPath(this.id, this.title, this.description, this.courseIds);
  final String id, title, description;
  final List<String> courseIds;
}

const learningPaths = [
  LearningPath(
    'start',
    'Tu primera defensa',
    'Empieza por tus datos, tus cuentas y las decisiones que evitan engaños.',
    ['foundations', 'identity', 'phishing'],
  ),
  LearningPath(
    'networks',
    'Conecta con criterio',
    'Comprende la red y después protege tu Wi-Fi, la navegación y tu privacidad.',
    [
      'networks-basics',
      'ip-dns',
      'home-wifi',
      'public-networks',
      'safe-browsing',
      'web-privacy',
    ],
  ),
  LearningPath(
    'recovery',
    'Prevenir, responder y recuperar',
    'Reconoce amenazas, prepara copias y practica una vuelta segura a la actividad.',
    [
      'malware-basics',
      'device-prevention',
      'ransomware-defense',
      'incident-response',
      'backup-recovery',
      'resilient-return',
    ],
  ),
  LearningPath(
    'build',
    'Construye seguridad',
    'Distingue las herramientas criptográficas y aplica controles en la web y el código.',
    ['crypto-foundations', 'keys-data', 'web-security', 'secure-coding'],
  ),
  LearningPath(
    'linux',
    'Linux: observa, comprende e investiga',
    'Aprende terminal, permisos y servicios; interpreta registros y resuelve un caso defensivo con Aoi.',
    [
      'linux-start',
      'terminal-tools',
      'linux-access',
      'linux-operations',
      'log-analysis',
      'linux-investigation',
    ],
  ),
  LearningPath(
    'advanced-networks',
    'Redes prácticas y ciberdefensa',
    'Planifica direcciones, conecta segmentos, investiga fallos y valida defensas con evidencias.',
    [
      'ipv4-subnetting',
      'ipv6-foundations',
      'switching-routing',
      'network-diagnostics',
      'network-defense',
      'security-operations',
    ],
  ),
];
