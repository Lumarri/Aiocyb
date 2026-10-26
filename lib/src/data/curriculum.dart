import '../models/course.dart';
import 'extended_curriculum.g.dart';
import 'linux_curriculum.g.dart';
import 'linux_sources.dart';
import 'malware_curriculum.g.dart';
import 'secure_curriculum.g.dart';
import 'starter_practice.g.dart';

const sources = [
  ...linuxSources,
  LearningSource(
    'code-review',
    'OWASP · Revisión de código seguro',
    'https://cheatsheetseries.owasp.org/cheatsheets/Secure_Code_Review_Cheat_Sheet.html',
    'Revisar contratos, flujos, permisos y condiciones de fallo.',
  ),
  LearningSource(
    'code-transactions',
    'PostgreSQL · Aislamiento de transacciones',
    'https://www.postgresql.org/docs/current/transaction-iso.html',
    'Efectos concurrentes y necesidad de garantías de coherencia apropiadas.',
  ),
  LearningSource(
    'code-business',
    'OWASP · Seguridad de lógica de negocio',
    'https://cheatsheetseries.owasp.org/cheatsheets/Business_Logic_Security_Cheat_Sheet.html',
    'Reglas, concurrencia, estados y efectos de operaciones.',
  ),
  LearningSource(
    'code-repository',
    'GitHub · Datos sensibles en un repositorio',
    'https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository',
    'Exposición, revocación y límites de retirar datos del historial.',
  ),
  LearningSource(
    'code-dependencies',
    'OWASP · Gestión de dependencias vulnerables',
    'https://cheatsheetseries.owasp.org/cheatsheets/Vulnerable_Dependency_Management_Cheat_Sheet.html',
    'Inventario, actualización y revisión de componentes.',
  ),
  LearningSource(
    'web-csp',
    'MDN · Content Security Policy',
    'https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CSP',
    'Políticas del navegador como defensa complementaria.',
  ),
  LearningSource(
    'crypto-store',
    'OWASP · Almacenamiento criptográfico',
    'https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html',
    'Objetivos, algoritmos mantenidos y límites del cifrado.',
  ),
  LearningSource(
    'crypto-passwords',
    'OWASP · Almacenamiento de contraseñas',
    'https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html',
    'Funciones adaptativas, sal y verificación de contraseñas.',
  ),
  LearningSource(
    'crypto-keys',
    'OWASP · Gestión de claves',
    'https://cheatsheetseries.owasp.org/cheatsheets/Key_Management_Cheat_Sheet.html',
    'Generación, distribución, almacenamiento y ciclo de vida.',
  ),
  LearningSource(
    'crypto-secrets',
    'OWASP · Gestión de secretos',
    'https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html',
    'Acceso mínimo, entrega, rotación y respuesta a exposición.',
  ),
  LearningSource(
    'crypto-api',
    'MDN · Web Crypto API',
    'https://developer.mozilla.org/en-US/docs/Web/API/Web_Crypto_API',
    'Primitivas criptográficas y precauciones de diseño.',
  ),
  LearningSource(
    'web-tls',
    'OWASP · Seguridad de transporte',
    'https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Security_Cheat_Sheet.html',
    'HTTPS, certificados y protección del canal.',
  ),
  LearningSource(
    'web-origin',
    'MDN · Política del mismo origen',
    'https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Same-origin_policy',
    'Esquema, host, puerto y límites entre orígenes.',
  ),
  LearningSource(
    'web-cookies',
    'MDN · Cookies HTTP',
    'https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Cookies',
    'Secure, HttpOnly, SameSite y alcance de las cookies.',
  ),
  LearningSource(
    'web-csrf',
    'OWASP · Prevención de CSRF',
    'https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html',
    'Protecciones de peticiones que cambian estado.',
  ),
  LearningSource(
    'web-xss',
    'OWASP · Prevención de XSS',
    'https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html',
    'Salida contextual, destinos seguros y límites de las defensas.',
  ),
  LearningSource(
    'web-authz',
    'OWASP · Autorización',
    'https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html',
    'Permisos por petición, recurso y acción.',
  ),
  LearningSource(
    'code-input',
    'OWASP · Validación de entradas',
    'https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html',
    'Tipos, límites, reglas del negocio y defensas complementarias.',
  ),
  LearningSource(
    'code-sql',
    'OWASP · Consultas SQL parametrizadas',
    'https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html',
    'Separar datos y estructura de consultas.',
  ),
  LearningSource(
    'code-errors',
    'OWASP · Manejo de errores',
    'https://cheatsheetseries.owasp.org/cheatsheets/Error_Handling_Cheat_Sheet.html',
    'Fallos controlados y respuestas que reducen exposición.',
  ),
  LearningSource(
    'code-logging',
    'OWASP · Registros de aplicación',
    'https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html',
    'Trazabilidad, acceso a registros y exclusión de secretos.',
  ),
  LearningSource(
    'code-upload',
    'OWASP · Subida de archivos',
    'https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html',
    'Límites, validación, almacenamiento y entrega de archivos.',
  ),
  LearningSource(
    'cisco-basics',
    'Cisco · What is cybersecurity?',
    'https://www.cisco.com/site/us/en/learn/topics/security/what-is-cybersecurity.html',
    'Referencia conceptual. Lecciones y ejercicios propios; no es un curso oficial de Cisco.',
  ),
  LearningSource(
    'cisco-phishing',
    'Cisco · What is phishing?',
    'https://www.cisco.com/site/us/en/learn/topics/security/what-is-phishing.html',
    'Referencia sobre engaños digitales. Los mensajes simulados son ficticios.',
  ),
  LearningSource(
    'cisa-habits',
    'CISA · Secure Our World',
    'https://www.cisa.gov/secure-our-world',
    'Material archivado de concienciación sobre claves, phishing y actualizaciones.',
  ),
  LearningSource(
    'cisa-mfa',
    'CISA · Four Cybersecurity Essentials',
    'https://www.cisa.gov/resources-tools/resources/four-cybersecurity-essentials-sltts',
    'Referencia sobre autenticación y solicitudes de acceso fraudulentas.',
  ),
  LearningSource(
    'cisco-networks',
    'Cisco · Networking basics',
    'https://www.cisco.com/site/us/en/learn/topics/small-business/networking-basics.html',
    'Redes, switches, routers y puntos de acceso. Consultado el 21 de octubre de 2026.',
  ),
  LearningSource(
    'cloudflare-dns',
    'Cloudflare · What is DNS?',
    'https://developers.cloudflare.com/learning-paths/cybersafe/concepts/what-is-dns/',
    'Resolución de nombres y servidores DNS. Ejemplos y ejercicios propios.',
  ),
  LearningSource(
    'mdn-doh',
    'MDN · DNS over HTTPS',
    'https://developer.mozilla.org/en-US/docs/Glossary/DNS_over_HTTPS',
    'Alcance y límites del cifrado de consultas DNS.',
  ),
  LearningSource(
    'wifi-apple',
    'Apple · Ajustes de routers y puntos de acceso Wi-Fi',
    'https://support.apple.com/en-in/102766',
    'WPA3, compatibilidad WPA2/AES y ajustes de red. Los menús varían según fabricante.',
  ),
  LearningSource(
    'nsa-home',
    'NSA · Best Practices for Securing Your Home Network',
    'https://media.defense.gov/2023/Feb/22/2003165170/-1/-1/0/CSI_BEST_PRACTICES_FOR_SECURING_YOUR_HOME_NETWORK.PDF',
    'Guía de 2023: actualizaciones, segmentación y protección del Wi-Fi doméstico.',
  ),
  LearningSource(
    'ftc-public',
    'FTC · Are Public Wi-Fi Networks Safe?',
    'https://consumer.ftc.gov/articles/are-public-wi-fi-networks-safe-what-you-need-know',
    'HTTPS protege la conexión; un sitio fraudulento también puede cifrarla. Guía de 2023.',
  ),
  LearningSource(
    'mozilla-privacy',
    'Mozilla · Firefox privacy and security features',
    'https://support.mozilla.org/en-US/kb/firefox-privacy-and-security-features',
    'Cookies, seguimiento y controles de privacidad del navegador.',
  ),
  LearningSource(
    'chrome-incognito',
    'Google · Navegación de incógnito y sus límites',
    'https://support.google.com/chrome/answer/95464?hl=en',
    'Privacidad local, archivos descargados y actividad visible para sitios y redes.',
  ),
  LearningSource(
    'chrome-browsing',
    'Google · Safe Browsing y privacidad',
    'https://support.google.com/chrome/answer/13844634?hl=en',
    'Avisos de sitios y descargas peligrosas, con sus límites y opciones de privacidad.',
  ),
  LearningSource(
    'android-wifi',
    'Google · Conexiones Wi-Fi en Android',
    'https://support.google.com/android/answer/9075847',
    'Redes guardadas, conexión automática y ajustes de Wi-Fi. Las opciones dependen de la versión y del fabricante.',
  ),
  LearningSource(
    'microsoft-wireless',
    'Microsoft · Be safer over wireless connections',
    'https://support.microsoft.com/en-gb/security/be-safer-over-wireless-connections',
    'Recomendaciones para conexiones públicas, VPN y puntos de acceso personales.',
  ),
  LearningSource(
    'iana-addresses',
    'IANA · Direcciones privadas',
    'https://www.iana.org/help/private-addresses',
    'Referencia oficial de los rangos de direcciones IPv4 de uso privado.',
  ),
  LearningSource(
    'iana-ipv4',
    'IANA · IPv4 Special-Purpose Address Space',
    'https://www.iana.org/assignments/iana-ipv4-special-registry',
    'Rangos IPv4 reservados, privados y dedicados a documentación.',
  ),
  LearningSource(
    'iana-ipv6',
    'IANA · IPv6 Special-Purpose Address Space',
    'https://www.iana.org/assignments/iana-ipv6-special-registry',
    'Rangos IPv6 de propósito especial y ejemplos de documentación.',
  ),
  LearningSource(
    'motorola-bluetooth',
    'Motorola · Uso seguro de Bluetooth',
    'https://en-gb.support.motorola.com/app/answers/detail/a_id/122350/~/using-bluetooth',
    'Emparejamiento, códigos de confirmación y permisos de contactos.',
  ),
  LearningSource(
    'android-nfc',
    'Android · Fundamentos de NFC',
    'https://developer.android.com/develop/connectivity/nfc/nfc',
    'Lectura de etiquetas y tratamiento de enlaces; las opciones varían según dispositivo y versión.',
  ),
  LearningSource(
    'android-share',
    'Android · Compartir por proximidad',
    'https://support.google.com/android/answer/17161144',
    'Revisión de contenido compartido y controles de recepción.',
  ),
  LearningSource(
    'cisa-malware',
    'CISA · Protecting Against Malicious Code',
    'https://www.cisa.gov/news-events/news/protecting-against-malicious-code',
    'Referencia sobre código malicioso y prevención. Los ejemplos de la academia son ficticios y propios.',
  ),
  LearningSource(
    'cisa-ransomware',
    'CISA · Guía StopRansomware',
    'https://www.cisa.gov/stopransomware/ransomware-guide',
    'Prevención, contención y recuperación. Los procedimientos reales dependen del dispositivo y del responsable.',
  ),
  LearningSource(
    'cisa-backups',
    'CISA · Proteger los datos de tus dispositivos',
    'https://www.cisa.gov/resources-tools/training/how-protect-data-stored-your-devices',
    'Separación de copias y protección de los datos almacenados.',
  ),
  LearningSource(
    'ms-malware',
    'Microsoft · Understanding malware',
    'https://learn.microsoft.com/en-us/defender-endpoint/malware/understanding-malware',
    'Conceptos y categorías de software malicioso. Los síntomas aislados no sustituyen un diagnóstico.',
  ),
  LearningSource(
    'ms-prevent',
    'Microsoft · Prevent malware infection',
    'https://learn.microsoft.com/en-us/defender-endpoint/malware/prevent-malware-infection',
    'Prevención en archivos, aplicaciones y dispositivos; menús y funciones sujetos a versión.',
  ),
  LearningSource(
    'ms-defender',
    'Microsoft · Protección contra virus y amenazas',
    'https://support.microsoft.com/en-us/windows/security/threat-malware-protection/virus-and-threat-protection-in-the-windows-security-app',
    'Alertas, análisis y protección de Seguridad de Windows, con sus límites.',
  ),
  LearningSource(
    'ms-recovery',
    'Microsoft · Copia, restauración y recuperación en Windows',
    'https://support.microsoft.com/en-us/windows/experience/backup-recovery/backup-restore-and-recovery-in-windows',
    'Diferencias entre respaldar archivos, restaurarlos y recuperar el sistema.',
  ),
  LearningSource(
    'ms-response',
    'Microsoft · Respuesta a incidentes de ransomware',
    'https://learn.microsoft.com/en-us/security/ransomware/incident-response-playbook-dart-ransomware-approach',
    'Referencia para el equipo responsable: contención, investigación y recuperación coordinadas.',
  ),
  LearningSource(
    'android-play-protect',
    'Google · Google Play Protect',
    'https://support.google.com/android/answer/2812853?hl=es',
    'Detección de aplicaciones dañinas, avisos y privacidad de sus análisis.',
  ),
  LearningSource(
    'android-malware',
    'Google · Quitar software malicioso o no seguro',
    'https://support.google.com/accounts/answer/9924802?co=GENIE.Platform%3DAndroid&hl=es',
    'Comprobaciones en Android y cuándo acudir al fabricante. Los ajustes varían según el teléfono.',
  ),
  LearningSource(
    'android-backups',
    'Google · Copias y restauración en Android',
    'https://support.google.com/android/answer/2819582?hl=es',
    'Alcance, compatibilidad y límites de las copias; no todas las apps permiten restaurar todos sus datos.',
  ),
  LearningSource(
    'ms-continuity',
    'Microsoft · Continuidad y recuperación ante desastres',
    'https://learn.microsoft.com/en-us/azure/reliability/concept-business-continuity-high-availability-disaster-recovery',
    'Definición de RPO y RTO, objetivos de pérdida de datos e interrupción tolerable.',
  ),
  LearningSource(
    'android-updates',
    'Google · Actualizaciones en dispositivos Pixel',
    'https://support.google.com/pixelphone/answer/7680439?hl=en',
    'Ejemplo oficial de soporte por modelo. Cada fabricante publica sus propias opciones y periodos.',
  ),
  LearningSource(
    'ms-lifecycle',
    'Microsoft · Fin de soporte de Windows 10',
    'https://support.microsoft.com/en-us/windows/deployment/updates-lifecycle/windows-10-support-has-ended-on-october-14-2025',
    'Distinguir versión, edición y programas de soporte; comprobar siempre las condiciones vigentes.',
  ),
  LearningSource(
    'chrome-permissions',
    'Google · Instalar y gestionar extensiones',
    'https://support.google.com/chrome_webstore/answer/186213?hl=es',
    'Alcance de acceso de las extensiones y revisión de permisos en Chrome.',
  ),
  LearningSource(
    'ms-app-control',
    'Microsoft · Control de aplicaciones y navegador',
    'https://support.microsoft.com/en-au/windows/security/windows-security/app-browser-control-in-the-windows-security-app',
    'Avisos y controles de reputación. Funciones y opciones sujetas a la configuración y versión.',
  ),
  LearningSource(
    'android-reset',
    'Google · Restablecer un dispositivo Android',
    'https://support.google.com/android/answer/6088915?hl=es',
    'Preparación, pérdida de datos y acceso a las cuentas antes de un restablecimiento autorizado.',
  ),
  LearningSource(
    'google-sessions',
    'Google · Dispositivos y sesiones de una cuenta',
    'https://support.google.com/accounts/answer/3067630?hl=es',
    'Revisión de sesiones propias y cierre de accesos. Una ubicación aproximada no identifica por sí sola a una persona.',
  ),
  LearningSource(
    'ms-reset-options',
    'Microsoft · Opciones de recuperación en Windows',
    'https://support.microsoft.com/en-us/windows/experience/backup-recovery/recovery-options-in-windows',
    'Comparar recuperación y reinstalación, efectos sobre los datos y preparación del acceso autorizado.',
  ),
];

const initialCourses = [
  Course(
    id: 'foundations',
    title: 'Tu primera línea de defensa',
    description: 'Entiende qué proteges y toma mejores decisiones digitales.',
    category: 'Fundamentos',
    symbol: '01',
    color: 0xFF57E5C0,
    lessons: [
      Lesson(
        id: 'digital-life',
        title: 'Tu vida digital también tiene puerta',
        minutes: 8,
        intro: 'Soy Aoi Bite, tu tutora. No uso capucha ni tecleo a oscuras. Hoy vamos a proteger algo más útil: tus cuentas y archivos.',
        sections: [
          TheorySection(
            'Lo que estás protegiendo',
            'Tus conversaciones, fotografías y cuentas son activos digitales. Protegerlos requiere hábitos, procesos y herramientas: por ejemplo, limitar quién accede a una carpeta y conservar una copia para recuperarla.',
          ),
          TheorySection(
            'Tres preguntas que ayudan',
            'Confidencialidad: ¿quién puede ver mis datos? Integridad: ¿fueron alterados sin permiso? Disponibilidad: ¿puedo acceder cuando los necesito? Un documento puede abrirse y aun así contener cambios no autorizados.',
          ),
          TheorySection(
            'Varias capas, menos sustos',
            'Una clave única, la verificación adicional y una copia resuelven problemas diferentes. Combinarlas reduce el daño si alguna protección falla.',
          ),
        ],
        steps: [
          'Elige una cuenta importante, sin escribir su clave aquí.',
          'Identifica qué perderías si otra persona entrara.',
          'Piensa en una medida para evitar el acceso y otra para recuperar tus datos.',
        ],
        scenario: 'Tu carpeta de tareas abre, pero alguien cambió las respuestas sin permiso. ¿Qué propiedad está afectada?',
        questions: [
          Question(
            'Alguien cambia tus tareas sin permiso. ¿Qué se afecta directamente?',
            ['Disponibilidad', 'Integridad', 'Velocidad de conexión'],
            1,
            'La integridad protege frente a cambios no autorizados. Abrir el archivo no asegura que sea correcto.',
          ),
          Question(
            '¿Cuál es un activo digital?',
            [
              'Una cuenta de correo con tus documentos',
              'Solo una computadora cara',
              'Únicamente las redes empresariales',
            ],
            0,
            'La información y las cuentas tienen valor, incluso si el dispositivo cuesta poco.',
          ),
          Question(
            '¿Qué combina varias capas de protección?',
            [
              'Usar solo antivirus',
              'Ocultar el icono del correo',
              'Clave única, MFA y copias de seguridad',
            ],
            2,
            'Cada capa aborda riesgos diferentes. El antivirus no sustituye la protección de las cuentas.',
          ),
        ],
        sourceIds: ['cisco-basics'],
      ),
      Lesson(
        id: 'risk-routine',
        title: 'El riesgo no lleva cartel de villano',
        minutes: 9,
        intro: 'Un botón que dice «premio gratis» no es un plan financiero. Reconozcamos riesgos sin sospechar hasta de la calculadora.',
        sections: [
          TheorySection(
            'Amenaza, debilidad y riesgo',
            'Una amenaza puede causar daño; una vulnerabilidad es una debilidad aprovechable. El riesgo depende de la posibilidad del incidente y sus consecuencias. Reutilizar una clave crea una debilidad aunque todavía nadie la haya robado.',
          ),
          TheorySection(
            'Los hábitos cuentan',
            'Las actualizaciones pueden corregir fallos de seguridad. Una copia separada del equipo permite recuperarte si pierdes el original. Comprueba que puedes restaurarla: una copia ilegible no ayuda mucho.',
          ),
          TheorySection(
            'Actuar con calma',
            'Si sospechas una infección, desconecta el equipo de la red y busca ayuda técnica. En un equipo de trabajo o estudio, avisa al responsable. Evita borrar evidencias por iniciativa propia.',
          ),
        ],
        steps: [
          'Localiza las actualizaciones del sistema.',
          'Identifica dónde guardarías una copia separada de tus trabajos.',
          'Define a quién avisarías ante señales de infección.',
        ],
        scenario: 'El equipo lleva meses sin actualizarse. La única copia del proyecto está en ese mismo equipo.',
        questions: [
          Question(
            '¿Qué es una vulnerabilidad?',
            [
              'Una debilidad que podría aprovecharse',
              'Cualquier archivo del equipo',
              'Una copia de seguridad probada',
            ],
            0,
            'Un sistema sin parches puede tener debilidades conocidas.',
          ),
          Question(
            '¿Cuál es una mejor copia de seguridad?',
            [
              'Otro archivo en la misma carpeta',
              'Una copia separada cuya restauración comprobaste',
              'Una captura del nombre del archivo',
            ],
            1,
            'Separarla reduce los fallos compartidos; restaurarla confirma que funciona.',
          ),
          Question(
            'Un equipo de trabajo parece infectado. ¿Qué haces?',
            [
              'Borrar los registros',
              'Enviar el archivo sospechoso a amigos',
              'Desconectarlo de la red y avisar al responsable',
            ],
            2,
            'Contener el incidente y avisar permite una respuesta organizada.',
          ),
        ],
        sourceIds: ['cisa-habits', 'cisco-basics'],
      ),
    ],
  ),
  Course(
    id: 'identity',
    title: 'Tus cuentas, bajo llave',
    description:
        'Contraseñas, verificación y recuperación sin malabares de memoria.',
    category: 'Protección personal',
    symbol: '02',
    color: 0xFFB8A0FF,
    lessons: [
      Lesson(
        id: 'passwords',
        title: 'Adiós, contraseña de cumpleaños',
        minutes: 8,
        intro: 'Si tu clave es el nombre de tu mascota, tu mascota ya trabaja en seguridad. Vamos a darle vacaciones.',
        sections: [
          TheorySection(
            'Una clave para cada cuenta',
            'Usa contraseñas largas, aleatorias y únicas. Reutilizar una clave permite que una filtración en un servicio afecte a otros. Cambiar solo una letra al final no ofrece una separación fiable.',
          ),
          TheorySection(
            'No memorices todo',
            'Un gestor genera y guarda claves distintas. Protege su acceso con una frase maestra robusta y verificación adicional si está disponible. Nunca introduzcas contraseñas reales en ejercicios educativos.',
          ),
          TheorySection(
            'Si una clave se filtra',
            'Desde un dispositivo de confianza, entra directamente al servicio y cambia la clave. Cambia también las cuentas donde la reutilizaste y revisa las sesiones y la recuperación.',
          ),
        ],
        steps: [
          'Elige una cuenta para revisar; no compartas su clave.',
          'Comprueba si reutilizas su contraseña.',
          'Planifica una clave única y revisa la recuperación.',
        ],
        scenario: 'Una tienda sufre una filtración. Usabas allí la misma clave que en tu correo.',
        questions: [
          Question(
            '¿Qué haces si reutilizabas una clave filtrada?',
            [
              'Cambiarla donde se repetía',
              'Cambiar la foto de perfil',
              'Esperar a que alguien entre',
            ],
            0,
            'La filtración puede poner en riesgo todas las cuentas que comparten la clave.',
          ),
          Question(
            '¿Para qué sirve un gestor de contraseñas?',
            [
              'Para publicar claves',
              'Para generar y guardar claves diferentes',
              'Para desactivar la autenticación',
            ],
            1,
            'Ayuda a mantener claves únicas. Su propio acceso también necesita protección.',
          ),
          Question(
            '¿Qué contraseña deberías introducir en esta app?',
            ['La de tu correo', 'La de tu banco', 'Ninguna contraseña real'],
            2,
            'Los ejercicios son ficticios. No necesitamos tus credenciales.',
          ),
        ],
        sourceIds: ['cisa-habits'],
        diagram: 'identity',
      ),
      Lesson(
        id: 'mfa',
        title: 'Una segunda puerta: MFA',
        minutes: 9,
        intro: 'Dos contraseñas no son dos factores. Sí, aquí también hay matemáticas. Te las explico sin examen sorpresa.',
        sections: [
          TheorySection(
            'Pruebas distintas',
            'MFA combina factores diferentes: algo que sabes, algo que tienes o algo que eres. Una clave y una llave de seguridad usan factores distintos. Dos contraseñas pertenecen al mismo tipo.',
          ),
          TheorySection(
            'Elige con criterio',
            'Activa MFA desde la configuración oficial. Si están disponibles, considera métodos resistentes al phishing, como llaves de seguridad o passkeys. Un SMS añade protección, pero no ofrece la misma resistencia al phishing.',
          ),
          TheorySection(
            'Visitas sorpresa',
            'Rechaza solicitudes de acceso que no iniciaste. No compartas códigos con supuestos técnicos. Guarda los códigos de recuperación en un lugar seguro separado del dispositivo.',
          ),
        ],
        steps: [
          'Abre la configuración oficial de seguridad.',
          'Busca «verificación en dos pasos» o «MFA».',
          'Elige un método y guarda sus opciones de recuperación.',
          'Rechaza solicitudes que tú no hayas iniciado.',
        ],
        scenario: 'Recibes «¿Autorizar inicio de sesión?» mientras estudias. Tú no estás intentando entrar.',
        questions: [
          Question(
            'Llega una solicitud MFA que no iniciaste. ¿Qué haces?',
            [
              'Aprobar para que no moleste',
              'Rechazar y revisar la seguridad',
              'Dar el código por teléfono',
            ],
            1,
            'Podría ser un intento ajeno. Recházalo y revisa la cuenta por el canal oficial.',
          ),
          Question(
            '¿Qué combinación usa factores distintos?',
            [
              'Contraseña y llave de seguridad',
              'Dos contraseñas',
              'Contraseña y pregunta secreta',
            ],
            0,
            'La clave es algo que sabes y la llave es algo que tienes.',
          ),
          Question(
            '¿Dónde guardar los códigos de recuperación?',
            [
              'En una publicación pública',
              'Solo en el teléfono que podrías perder',
              'En un lugar seguro separado del dispositivo',
            ],
            2,
            'Así conservas una alternativa si pierdes el teléfono.',
          ),
        ],
        sourceIds: ['cisa-mfa'],
        diagram: 'identity',
      ),
    ],
  ),
  Course(
    id: 'phishing',
    title: 'Que no te pesquen',
    description: 'Detecta mensajes trampa y practica antes de hacer ese clic.',
    category: 'Amenazas digitales',
    symbol: '03',
    color: 0xFFFFC078,
    lessons: [
      Lesson(
        id: 'phishing-signals',
        title: 'Un mensaje con demasiada prisa',
        minutes: 10,
        intro: '«Ganaste un premio, paga para recibirlo». Curioso premio: empieza cobrando. Saquemos la lupa y dejemos el botón tranquilo.',
        sections: [
          TheorySection(
            'El objetivo del engaño',
            'El phishing suplanta a una entidad para conseguir datos, dinero o una acción peligrosa. Puede llegar por correo, SMS o mensajería. Una apariencia profesional no demuestra autenticidad.',
          ),
          TheorySection(
            'Haz una pausa',
            'La urgencia, las peticiones inesperadas de claves y los dominios que no coinciden son alertas. Verifica por un canal que ya conocías; una buena ortografía tampoco demuestra que un mensaje sea legítimo.',
          ),
          TheorySection(
            'El destino real',
            'En cuentas.ejemplo.com el dominio principal es ejemplo.com. En ejemplo.com.otro.test pertenece a otro.test. HTTPS cifra la conexión; no certifica la honestidad del sitio.',
          ),
        ],
        steps: [
          'Lee la petición antes de abrir enlaces.',
          'Revisa el remitente completo y el dominio.',
          'Comprueba el aviso entrando por tu cuenta a la app oficial.',
          'Reporta y elimina el mensaje si confirmas el engaño.',
        ],
        scenario: 'SIMULACIÓN · soporte@becas-urgentes.test\n«Tu beca se cancela en 10 minutos. Confirma tu clave en academia.example.verificar.test».\nLos dominios .test y .example son ficticios.',
        questions: [
          Question(
            '¿Qué harías con el aviso de la beca?',
            [
              'Introducir mi clave enseguida',
              'Comprobarlo directamente en el portal oficial',
              'Reenviar el enlace a todos',
            ],
            1,
            'Verifica por un canal independiente del mensaje.',
          ),
          Question(
            '¿HTTPS garantiza que una web es honesta?',
            [
              'Sí, siempre',
              'Si tiene buen diseño',
              'No, indica una conexión cifrada',
            ],
            2,
            'Un sitio fraudulento también puede usar HTTPS.',
          ),
          Question(
            '¿Qué dominio controla academia.example.verificar.test?',
            [
              'verificar.test',
              'academia.example',
              'El nombre visible del remitente',
            ],
            0,
            'Lee el dominio de derecha a izquierda. Un nombre en un subdominio no demuestra pertenencia.',
          ),
        ],
        sourceIds: ['cisco-phishing'],
        diagram: 'phishing',
      ),
      Lesson(
        id: 'safe-response',
        title: 'Hice clic. ¿Y ahora qué?',
        minutes: 9,
        intro: 'Respira. Equivocarte no te convierte en el villano de la película. Toca actuar por pasos, sin pulsar veinte botones por pánico.',
        sections: [
          TheorySection(
            'Distingue qué ocurrió',
            'Abrir un enlace, entregar una clave y ejecutar un archivo tienen consecuencias distintas. Cierra la página sospechosa y no compartas más datos. Anota lo ocurrido para explicarlo al soporte.',
          ),
          TheorySection(
            'Si entregaste una clave',
            'Desde un dispositivo de confianza, entra al servicio oficial, cambia la clave y revisa sesiones y recuperación. Si diste datos financieros, contacta a tu entidad por su canal oficial.',
          ),
          TheorySection(
            'Si ejecutaste un archivo',
            'Ante sospecha de malware, desconecta el equipo de la red y pide ayuda técnica. En una organización, sigue su procedimiento. Evita reenviar el archivo o borrar evidencias por tu cuenta.',
          ),
        ],
        steps: [
          'Detén la interacción.',
          'Identifica si compartiste datos o ejecutaste algo.',
          'Protege la cuenta desde un dispositivo de confianza.',
          'Avisa al soporte oficial y explica lo ocurrido.',
        ],
        scenario: 'Escribiste tu clave de correo en una web falsa. Aún puedes entrar desde tu teléfono de confianza.',
        questions: [
          Question(
            'Entregaste tu clave en una web falsa. ¿Qué haces?',
            [
              'Esperar una semana',
              'Responder al estafador',
              'Cambiar la clave en el servicio oficial y revisar sesiones',
            ],
            2,
            'Actúa pronto y revisa también recuperación y MFA.',
          ),
          Question(
            '¿Qué información ayuda al soporte?',
            [
              'Qué ocurrió, cuándo y qué datos entregaste',
              'Tu contraseña completa',
              'El archivo sospechoso enviado a todos',
            ],
            0,
            'Una descripción clara ayuda. No compartas tu contraseña.',
          ),
          Question(
            '¿Un clic implica siempre perder todas tus cuentas?',
            [
              'Sí, sin excepción',
              'No; hay que evaluar las acciones y el contexto',
              'Un clic nunca tiene riesgos',
            ],
            1,
            'El impacto depende del sitio, el dispositivo y las acciones.',
          ),
        ],
        sourceIds: ['cisa-habits', 'cisco-basics'],
        diagram: 'phishing',
      ),
    ],
  ),
];

final List<Course> starterCourses = List.unmodifiable([
  for (final course in initialCourses)
    Course(
      id: course.id,
      title: course.title,
      description: course.description,
      category: course.category,
      symbol: course.symbol,
      color: course.color,
      lessons: List.unmodifiable([
        ...course.lessons,
        ...?starterPractice[course.id],
      ]),
    ),
]);

final List<Course> courses = List.unmodifiable([
  ...starterCourses,
  ...extendedCourses,
  ...malwareCourses,
  ...secureCourses,
  ...linuxCourses,
]);

final allLessons = courses
    .expand((course) => course.lessons)
    .toList(growable: false);

const diagnosticQuestions = [
  Question(
    'Un correo pide tu clave con urgencia. ¿Qué haces?',
    ['La envío', 'Verifico en el servicio oficial', 'Lo reenvío'],
    1,
    'Verifica por un canal independiente.',
  ),
  Question(
    '¿Qué protege mejor tus cuentas?',
    [
      'Una clave fácil compartida',
      'Claves distintas y MFA',
      'Cambiar el nombre de usuario',
    ],
    1,
    'Las claves únicas y MFA añaden capas de protección.',
  ),
  Question(
    '¿Por qué instalar actualizaciones?',
    [
      'Solo cambian colores',
      'Pueden corregir fallos de seguridad',
      'Sustituyen las copias',
    ],
    1,
    'Los parches corrigen vulnerabilidades; las copias siguen siendo necesarias.',
  ),
  Question(
    '¿Dónde conservar una copia de tu trabajo?',
    [
      'Solo en el mismo equipo',
      'En la papelera',
      'Separada y con restauración comprobada',
    ],
    2,
    'Debe ser recuperable aunque el original se pierda.',
  ),
  Question(
    'Una solicitud MFA que no iniciaste…',
    ['La rechazo y reviso la cuenta', 'La apruebo', 'Comparto el código'],
    0,
    'No autorices accesos que no reconoces.',
  ),
];
