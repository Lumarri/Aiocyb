class OfflineLab {
  const OfflineLab(
    this.id,
    this.title,
    this.description,
    this.stages,
    this.closure,
  );
  final String id, title, description, closure;
  final List<LabStage> stages;
}

class LabStage {
  const LabStage({
    required this.title,
    required this.evidence,
    required this.task,
    required this.options,
    required this.answer,
    required this.feedback,
    required this.intro,
    required this.correct,
    required this.soft,
    required this.sharp,
  });
  final String title, evidence, task, intro, correct, soft, sharp;
  final List<String> options, feedback;
  final int answer;
}

const offlineLabs = [
  OfflineLab(
    'protection',
    'Elige qué protección necesitas',
    'Ordena un pequeño intercambio de archivos: confidencialidad, integridad y autenticidad.',
    [
      LabStage(
        title: 'Un documento reservado',
        evidence: 'archivo: becas-ficticias.csv\nobjetivo: solo el equipo autorizado debe leerlo\nrecuperación: debe poder abrirse después',
        task: '¿Qué mecanismo corresponde al objetivo principal?',
        options: [
          'Codificar en Base64',
          'Cifrar con una herramienta mantenida y gestionar el acceso',
          'Publicar un hash junto al documento',
        ],
        answer: 1,
        feedback: [
          'Base64 cambia la representación y se revierte sin secreto; el documento seguiría expuesto.',
          'El cifrado permite recuperar el contenido con la clave adecuada. También necesitas permisos y un plan para conservar esa clave.',
          'El resumen sirve para comparar contenido, pero no oculta los datos que acompañan al archivo.',
        ],
        intro: 'Un archivo reservado pide confidencialidad, cariño. Elige una protección que cierre la puerta de verdad.',
        correct: 'Bien. Cerraste el sobre y te acordaste de quién puede abrirlo. Mi ceja concede una tregua.',
        soft: 'Tranquilo: primero decide si quieres ocultar el contenido o reconocer un cambio.',
        sharp: 'Otra vez decorando el sobre en vez de cerrarlo. Vamos, el secreto necesita una barrera real.',
      ),
      LabStage(
        title: 'Comparar una descarga',
        evidence: 'archivo: manual-ficticio.pdf\nreferencia: resumen publicado por un canal auténtico\npregunta: ¿cambiaron estos bytes?',
        task:
            '¿Qué comprobación permite comparar el archivo con esa referencia?',
        options: [
          'Calcular el resumen con el mismo algoritmo y compararlo',
          'Cambiar la extensión del archivo',
          'Comprobar que el icono es idéntico',
        ],
        answer: 0,
        feedback: [
          'La comparación detecta diferencias respecto de la referencia confiable. No demuestra por sí sola que el archivo sea inocuo.',
          'La extensión es un nombre; cambiarla no comprueba los bytes ni su procedencia.',
          'El icono puede coincidir aunque el contenido sea distinto. Necesitas comparar los datos mediante el resumen indicado.',
        ],
        intro: 'Ahora buscamos cambios en los bytes. El icono bonito puede esperar a su propio concurso.',
        correct: 'Comparación correcta. Una coincidencia habla de integridad respecto de la referencia, no concede santidad al archivo.',
        soft: 'Mira lo que se compara: el contenido necesita una referencia, no una impresión visual.',
        sharp: 'El icono no declara bajo juramento, tesoro. Comprueba el resumen y deja de interrogar al dibujo.',
      ),
      LabStage(
        title: 'Identificar al firmante',
        evidence: 'documento: comunicado-ficticio.pdf\nfirma: válida matemáticamente\nclave pública: recibida por un chat desconocido',
        task: '¿Qué falta antes de atribuir la firma a una persona concreta?',
        options: [
          'Guardar una captura de la firma',
          'Convertir el documento a texto',
          'Verificar la relación entre la clave y la identidad por una vía confiable',
        ],
        answer: 2,
        feedback: [
          'La captura conserva una imagen, pero no establece quién controla la clave usada para firmar.',
          'Cambiar el formato no autentica al titular y puede invalidar la firma sobre los bytes originales.',
          'La firma comprueba una relación con una clave. Atribuir esa clave a una persona requiere una cadena o comprobación de confianza.',
        ],
        intro: 'La firma puede cuadrar y el nombre ser un invento. Nos falta comprobar a quién pertenece la clave.',
        correct: 'Exacto. Ahora distingues una cuenta matemática de una identidad comprobada. Me estás malcriando.',
        soft: 'La duda está en la identidad del titular, no en el formato del documento.',
        sharp: 'La firma lleva un nombre escrito a lápiz, cariño. Verifica al titular antes de celebrar.',
      ),
    ],
    'Separaste confidencialidad, integridad e identidad. Tres objetivos distintos; mi paciencia agradece que ya no los metas en la misma caja.',
  ),
  OfflineLab(
    'web-session',
    'Protege una sesión web',
    'Revisa una conexión, una cookie y una petición de un portal completamente ficticio.',
    [
      LabStage(
        title: 'La conexión del portal',
        evidence: 'portal: https://aula.example\ncertificado: el navegador muestra un error\nacción prevista: iniciar sesión',
        task: '¿Cómo continúas con las credenciales?',
        options: [
          'Ignorar el error porque aparece el nombre del aula',
          'No enviarlas; verificar la dirección y consultar el canal oficial',
          'Mandarlas por la versión HTTP',
        ],
        answer: 1,
        feedback: [
          'El nombre visible no corrige una validación de conexión fallida. Evita introducir credenciales hasta aclararlo.',
          'Pausar el envío conserva las credenciales mientras se verifica el problema por una vía confiable.',
          'HTTP no ofrece la protección de transporte de HTTPS; cambiar a él no soluciona la autenticación del servidor.',
        ],
        intro: 'El portal protesta antes de recibir tu contraseña. Escuchémoslo antes de regalarle el secreto a cualquiera.',
        correct: 'Bien frenado. La urgencia del inicio de sesión no repara certificados, aunque ponga cara de importante.',
        soft: 'Antes de enviar una clave, resuelve si la conexión permite confiar en el servidor previsto.',
        sharp: 'Insistir no arregla el certificado, cielo. La contraseña sigue aquí hasta verificar esa conexión.',
      ),
      LabStage(
        title: 'Una cookie de sesión',
        evidence: 'sesión: identificador sensible\ncanal: HTTPS\nusos: el servidor identifica al usuario\nJavaScript: no necesita leerla',
        task: '¿Qué configuración encaja con este caso?',
        options: [
          'Secure y HttpOnly, con SameSite apropiado al flujo',
          'Publicar el valor en el registro de visitas',
          'Dar acceso a JavaScript por comodidad',
        ],
        answer: 0,
        feedback: [
          'Secure limita el envío a conexiones seguras y HttpOnly la lectura desde JavaScript. SameSite se elige según el flujo y no sustituye las demás defensas.',
          'Un identificador de sesión expuesto puede permitir suplantación. No debe aparecer en registros de visitas.',
          'Si la aplicación no necesita leerla desde JavaScript, ampliar ese acceso expone innecesariamente el identificador.',
        ],
        intro: 'La sesión es una llave temporal. Decide qué accesos necesita en vez de darle una copia al vecindario.',
        correct: 'Buena configuración y con contexto. Las banderitas ayudan cuando sabemos qué puerta controla cada una.',
        soft: 'Piensa en transporte y lectura desde scripts: son controles diferentes para el mismo secreto.',
        sharp: 'Volver a publicar una llave no la vuelve comunitaria por decreto. Reduce accesos, por favor.',
      ),
      LabStage(
        title: 'Cambiar un permiso',
        evidence: 'petición: cambiar el rol de una cuenta\ncliente: muestra un botón desactivado\nservidor: recibe usuario y rol solicitado',
        task: '¿Dónde debe comprobarse la autorización?',
        options: [
          'Solo en el color del botón',
          'Solo en el navegador del usuario',
          'En el servidor, para el usuario, recurso y acción concretos',
        ],
        answer: 2,
        feedback: [
          'El aspecto del botón informa a la persona; no impide que llegue una petición construida de otra forma.',
          'La interfaz del cliente puede alterarse y no constituye la autoridad del servicio.',
          'El servidor debe verificar la acción sobre ese recurso con una identidad válida, aunque la interfaz haya desactivado el botón.',
        ],
        intro: 'El botón tiene modales. El servidor necesita reglas, que es bastante más útil para proteger permisos.',
        correct: 'Así sí: la autoridad vive donde se ejecuta la acción. El botón puede volver a ser solo un botón.',
        soft: 'Busca el componente que realmente puede aceptar o rechazar el cambio, no quien lo dibuja.',
        sharp: 'Ese botón desactivado sigue sin ser un guardia, maldita sea. La comprobación va en el servidor.',
      ),
    ],
    'Conexión, sesión y permisos: revisaste tres fronteras del portal sin confundir una interfaz bonita con una autorización real.',
  ),
  OfflineLab(
    'code-review',
    'Una revisión de código pequeña',
    'Corrige decisiones de diseño con fragmentos ilustrativos. No se ejecuta código ni se conecta a servicios.',
    [
      LabStage(
        title: 'Buscar una ficha',
        evidence: 'Consulta ilustrativa:\nSELECT nombre FROM fichas WHERE id = ?\nParámetros separados: [idValidado]',
        task: '¿Qué propiedad conviene conservar al implementar esta consulta?',
        options: [
          'Separar los valores de la estructura mediante parámetros',
          'Concatenar el valor porque ya se comprobó el tipo',
          'Quitar espacios al dato antes de concatenarlo',
        ],
        answer: 0,
        feedback: [
          'El enlace de parámetros mantiene separados código y valores. La validación del tipo sigue siendo necesaria para las reglas del negocio.',
          'Una validación puede fallar o cambiar; no sustituye la separación estructural ofrecida por los parámetros.',
          'Eliminar espacios no convierte una concatenación en una consulta parametrizada ni protege todos los contextos de SQL.',
        ],
        intro: 'Esta consulta tiene una frontera útil: estructura por un lado y valores por otro. No la rompas por ahorrar una línea.',
        correct: 'Parámetros conservados. El dato se queda siendo dato; una relación mucho más sana que ese romance con concatenaciones.',
        soft: 'La defensa principal está en cómo se entrega el valor al motor, además de validar sus reglas.',
        sharp: 'Limpiar espacios otra vez no crea parámetros mágicos, tesoro. Separa la estructura del dato.',
      ),
      LabStage(
        title: 'Mostrar un comentario',
        evidence: 'comentario: texto aportado por una persona\ndestino: contenido de un elemento de la página\nrequisito: mostrarlo como texto',
        task: '¿Cómo debe mostrarse en ese contexto?',
        options: [
          'Interpretarlo directamente como HTML',
          'Usar una API de texto o el escape contextual del framework',
          'Confiar porque lo escribió una cuenta registrada',
        ],
        answer: 1,
        feedback: [
          'Interpretar el comentario como marcado le otorga un significado que el requisito no necesita y puede crear una vía de XSS.',
          'Una API de texto o el escape adecuado conserva el comentario como contenido. Otros destinos, como una URL, necesitan sus propias comprobaciones.',
          'Estar registrado no vuelve confiable cada texto: también puede haber cuentas comprometidas o entradas problemáticas accidentales.',
        ],
        intro: 'El usuario pidió comentar, no dirigir el navegador. Mantén sus palabras en el papel de texto.',
        correct: 'Perfecto: el comentario se lee y no toma el mando. Me gustan los límites bien puestos.',
        soft: 'Elige una forma de mostrar contenido que no lo convierta en instrucciones del navegador.',
        sharp: 'La cuenta tiene nombre, no inmunidad al XSS. Ese texto sigue sin merecer el volante.',
      ),
      LabStage(
        title: 'Un fallo al autenticar',
        evidence: 'excepción: token inválido\nregistro previsto: motivo, instante e ID de petición\nrespuesta pública: acceso no válido',
        task: '¿Qué dato debe excluirse del registro normal?',
        options: [
          'El identificador de petición',
          'El tipo de fallo',
          'El valor completo del token de acceso',
        ],
        answer: 2,
        feedback: [
          'Un identificador de petición permite correlacionar eventos sin necesidad de revelar el secreto de sesión.',
          'Un motivo controlado ayuda a diagnosticar; debe evitar detalles sensibles innecesarios, pero no necesita incluir el token.',
          'El token es un secreto utilizable. Registrar su valor completo crea otra copia expuesta y no es necesario para este diagnóstico.',
        ],
        intro: 'El registro necesita explicar el problema, no coleccionar llaves ajenas. Decide qué dato sobra.',
        correct: 'Buen recorte. Podemos seguir la petición sin convertir el registro en una piñata de credenciales.',
        soft: 'Distingue un identificador de seguimiento de un secreto que permite actuar como otra persona.',
        sharp: 'El token completo sigue siendo una llave aunque lo llames depuración. Sácalo del registro, cariño.',
      ),
    ],
    'Revisaste parámetros, salida y registros. Código más claro y menos secretos dando vueltas: admito que esta revisión me gustó.',
  ),
  OfflineLab(
    'key-lifecycle',
    'Una clave necesita un plan',
    'Prepara acceso, cambio y recuperación para un secreto ficticio sin usar credenciales reales.',
    [
      LabStage(
        title: 'Dónde vive el secreto',
        evidence: 'proyecto: aplicación compartida\nsecreto: credencial del servicio ficticio\nrepositorio: accesible al equipo completo',
        task: '¿Qué diseño reduce la exposición innecesaria?',
        options: [
          'Poner la credencial en una captura dentro del repositorio',
          'Usar almacenamiento de secretos con acceso mínimo y entrega controlada',
          'Cambiar su nombre a configuracion-invisible',
        ],
        answer: 1,
        feedback: [
          'Una captura también contiene información recuperable. No transforma un secreto expuesto en una protección.',
          'Un almacén apropiado permite limitar quién recibe el secreto y controlar su ciclo de vida; también hay que proteger el sistema que lo entrega.',
          'El nombre del archivo no controla el acceso ni impide que la credencial termine en copias o artefactos.',
        ],
        intro: 'Ese secreto no necesita conocer a todo el repositorio. Vamos a darle una casa con permisos reales.',
        correct: 'Mucho mejor. Ahora existe una política de acceso y no una carpeta confiando en pasar desapercibida.',
        soft: 'Busca un control de acceso efectivo, no una forma distinta de esconder el mismo valor.',
        sharp: 'Renombrar el secreto no le compra una cerradura, cielo. Necesita permisos y una entrega controlada.',
      ),
      LabStage(
        title: 'Se detecta una exposición',
        evidence: 'credencial: publicada accidentalmente\narchivo: ya retirado\ncopias: podrían existir\nservicio: permite revocar credenciales',
        task: '¿Qué acción aborda la credencial que ya salió del control del equipo?',
        options: [
          'Revocarla o rotarla y revisar su uso según el procedimiento',
          'Borrar solo el mensaje y seguir utilizándola',
          'Esperar a comprobar un abuso antes de actuar',
        ],
        answer: 0,
        feedback: [
          'La revocación o rotación reduce la utilidad de la credencial expuesta; revisar usos y dependencias permite contener el incidente sin improvisar.',
          'Retirar el mensaje no elimina las copias anteriores ni vuelve confiable el valor que ya se publicó.',
          'Una copia puede utilizarse antes de que aparezcan señales visibles. La exposición requiere una respuesta proporcionada sin esperar una confirmación de abuso.',
        ],
        intro: 'La captura ya pudo viajar. Nuestra tarea es quitar utilidad al secreto expuesto, no discutir con el botón de borrar.',
        correct: 'Eso atiende al secreto y a sus usos. Borrar el mensaje ayuda, pero la revocación hace el trabajo pendiente.',
        soft: 'La pregunta es si una copia antigua seguiría funcionando después de tu acción.',
        sharp: 'Borrarlo otra vez tampoco borra la memoria de medio mundo. Revoca el valor y revisa el alcance.',
      ),
      LabStage(
        title: 'Recuperar sin perder la llave',
        evidence: 'archivo: copia cifrada de datos ficticios\nprueba: restaurar en un entorno separado\nclave de recuperación: acceso restringido',
        task: '¿Qué debe comprobar el ensayo?',
        options: [
          'Solo que existe un archivo con nombre de copia',
          'Que la contraseña se recuerda hoy, sin abrir nada',
          'Que se recuperan datos y clave con permisos adecuados sin sobrescribir el original',
        ],
        answer: 2,
        feedback: [
          'La existencia del archivo no demuestra que el contenido sea completo, legible o recuperable.',
          'Recordar una contraseña no verifica todo el flujo ni garantiza el acceso futuro de las personas autorizadas.',
          'El ensayo comprueba contenido, claves y procedimiento de acceso, manteniendo una separación que protege el original.',
        ],
        intro: 'Una copia cifrada sin acceso recuperable es una caja muy convincente. Comprobemos que también sirve.',
        correct: 'Restauración comprobada sin sacrificar el original. Ven, te ganaste un cumplido peligrosamente sincero.',
        soft: 'El ensayo debe demostrar una recuperación real, incluyendo el acceso legítimo a la clave.',
        sharp: 'El nombre copia-final-ahora-si no es evidencia, tesoro. Abre una restauración de prueba con su llave.',
      ),
    ],
    'Un secreto tiene entrada, uso, cambio y recuperación. Ya estás cuidando el ciclo completo, y eso merece mi mejor sonrisa.',
  ),
];
