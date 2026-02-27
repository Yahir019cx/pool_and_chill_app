import 'package:flutter/material.dart';

class TerminosCondicionesScreen extends StatelessWidget {
  const TerminosCondicionesScreen({super.key});

  static const _primaryColor = Color(0xFF3CA2A2);

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'titulo': 'Términos de servicio',
        'descripcion':
            'Lee nuestros términos de uso para entender tus derechos y responsabilidades.',
        'icon': Icons.article_outlined,
        'contenido': TerminosCondicionesScreen.terminosServicio,
      },
      {
        'titulo': 'Política de privacidad',
        'descripcion':
            'Conoce cómo protegemos y utilizamos tu información personal.',
        'icon': Icons.lock_outline,
        'contenido': TerminosCondicionesScreen.politicaPrivacidad,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        centerTitle: true,
        title: Text(
          'Términos y condiciones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            children: [
              Text(
                'Comprometidos con tu confianza',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Consulta nuestros documentos legales de forma clara y transparente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              for (final item in items)
                _documentoItem(
                  context,
                  icon: item['icon'] as IconData,
                  titulo: item['titulo'] as String,
                  descripcion: item['descripcion'] as String,
                  contenido: item['contenido'] as String,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- ITEM DE LISTA ----------
  Widget _documentoItem(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required String descripcion,
    required String contenido,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: _primaryColor),
        title: Text(
          titulo,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            descripcion,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _mostrarDocumento(
          context,
          titulo: titulo,
          contenido: contenido,
        ),
      ),
    );
  }

  // ---------- MODAL DE TEXTO ----------
  void _mostrarDocumento(
    BuildContext context, {
    required String titulo,
    required String contenido,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Header con drag handle y botón cerrar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Título con botón cerrar
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Expanded(
                        child: Text(
                          titulo,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Spacer para centrar el título
                      const SizedBox(width: 24),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Text(
                  contenido,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- TEXTOS ----------
  static const String terminosServicio = '''
TÉRMINOS Y CONDICIONES DE USO DE LA PLATAFORMA DIGITAL POOL & CHILL

ÚLTIMA ACTUALIZACIÓN: Febrero 2026

I. PARTES Y OBJETO DEL CONTRATO

1.1. Los presentes Términos y Condiciones de Uso (en adelante, los "Términos") regulan la relación jurídica entre POOL & CHILL, sociedad mercantil constituida conforme a las leyes de los Estados Unidos Mexicanos (en adelante, "Pool & Chill", "la Plataforma" o "nosotros"), y las personas físicas o morales que utilicen la plataforma digital denominada "Pool & Chill" (en adelante, los "Usuarios", "Anfitriones", "Huéspedes" o "usted"), ya sea mediante aplicación móvil o sitio web.

1.2. La Plataforma Pool & Chill opera como un marketplace digital que facilita la intermediación tecnológica entre Anfitriones (propietarios o administradores de albercas e inmuebles) y Huéspedes (personas que desean reservar el uso temporal de dichos espacios).

1.3. Al acceder, registrarse o utilizar la Plataforma en cualquiera de sus modalidades, el Usuario acepta de manera expresa, irrevocable e incondicional estar sujeto a estos Términos, así como a la Política de Privacidad y demás políticas publicadas en la Plataforma. Si el Usuario no está de acuerdo con estos Términos, deberá abstenerse de utilizar la Plataforma.

1.4. Estos Términos constituyen un contrato de adhesión celebrado entre Pool & Chill y el Usuario, conforme a lo dispuesto en el Código Civil Federal, el Código de Comercio y la Ley Federal de Protección al Consumidor.

II. NATURALEZA DEL SERVICIO Y DESLINDE DE RESPONSABILIDADES

2.1. Pool & Chill actúa exclusivamente como intermediario tecnológico y facilitador de transacciones entre Anfitriones y Huéspedes. La Plataforma no es propietaria, administradora, arrendadora ni responsable directa de los inmuebles, albercas, instalaciones o servicios ofrecidos por los Anfitriones.

2.2. Pool & Chill no ejerce control alguno sobre la calidad, seguridad, condiciones físicas, legales o de cualquier otra índole de los inmuebles publicados en la Plataforma. La verificación de dichas condiciones es responsabilidad exclusiva del Anfitrión y del Huésped.

2.3. No existe relación laboral, de prestación de servicios profesionales, de sociedad, de mandato ni de representación entre Pool & Chill y los Anfitriones. Los Anfitriones actúan de manera independiente y autónoma, siendo responsables de cumplir con todas las obligaciones legales, fiscales y administrativas que les correspondan.

2.4. La relación contractual directa se establece entre el Anfitrión y el Huésped. Pool & Chill únicamente facilita la conexión tecnológica y el procesamiento de pagos, sin asumir responsabilidad alguna por el incumplimiento de las obligaciones derivadas de la relación contractual entre Anfitrión y Huésped.

2.5. Pool & Chill no garantiza la disponibilidad continua e ininterrumpida de la Plataforma, ni la ausencia de errores técnicos, fallas en el sistema, interrupciones o deficiencias en el servicio. El Usuario acepta que la Plataforma se proporciona "tal cual" y "según disponibilidad".

III. MODELO DE COMISIONES Y TARIFAS

3.1. Por la intermediación tecnológica y los servicios prestados, Pool & Chill percibe comisiones sobre el valor total de cada reservación confirmada, conforme a la siguiente estructura:

3.1.1. Comisión al Anfitrión: El Anfitrión pagará a Pool & Chill una comisión equivalente al cinco por ciento (5%) del valor total de la reservación, excluyendo impuestos.

3.1.2. Comisión al Huésped: El Huésped pagará a Pool & Chill una comisión equivalente al cinco por ciento (5%) del valor total de la reservación, excluyendo impuestos.

3.1.3. Comisión Total: La comisión total percibida por Pool & Chill es equivalente al diez por ciento (10%) del valor total de la reservación, excluyendo impuestos.

3.2. Procesamiento de Pagos mediante Stripe:

3.2.1. Los pagos se procesan mediante la plataforma de pagos Stripe, la cual retiene aproximadamente el tres punto siete por ciento (3.7%) del total procesado como comisión por el procesamiento de pagos.

3.2.2. Después de deducir la comisión de Stripe, Pool & Chill percibe el seis punto tres por ciento (6.3%) restante como comisión por sus servicios de intermediación tecnológica.

3.3. Las comisiones establecidas en esta cláusula pueden ser modificadas por Pool & Chill previa notificación a los Usuarios con al menos treinta (30) días de anticipación, mediante publicación en la Plataforma o comunicación directa al correo electrónico registrado. El uso continuado de la Plataforma después de dicha notificación constituye aceptación de las nuevas comisiones.

3.4. Todas las tarifas y comisiones están expresadas en pesos mexicanos (MXN) y son exclusivas de impuestos, salvo que se indique expresamente lo contrario.

IV. TARIFAS Y RESERVACIONES

4.1. Tarifas Base: Los Anfitriones establecerán libremente las tarifas base por el uso de sus inmuebles y albercas, las cuales deberán reflejarse con claridad en la Plataforma.

4.2. Tarifas Especiales: Los Anfitriones podrán establecer tarifas diferenciadas para temporada alta, días festivos, eventos especiales o cualquier otra circunstancia que consideren relevante, siempre que dichas tarifas se encuentren claramente especificadas en la publicación del inmueble.

4.3. Bloqueo de Fechas: Los Anfitriones tienen la facultad de bloquear fechas específicas en las que sus inmuebles no estarán disponibles para reservaciones. Una vez bloqueada una fecha, no podrá ser reservada por ningún Huésped hasta que el Anfitrión la desbloquee.

4.4. Confirmación Sujeta a Disponibilidad: Toda solicitud de reservación está sujeta a la disponibilidad real del inmueble al momento de la confirmación. Pool & Chill no garantiza la disponibilidad de ningún inmueble publicado en la Plataforma.

4.5. Horarios y Límites de Ocupación: Los Anfitriones establecerán los horarios de uso permitidos y los límites máximos de ocupación de sus inmuebles. El Huésped se obliga a respetar estrictamente dichos horarios y límites, bajo pena de incurrir en incumplimiento contractual y responsabilidad por daños y perjuicios.

4.6. Las reservaciones se consideran confirmadas únicamente cuando el Huésped haya completado el proceso de pago y recibido confirmación escrita por parte de la Plataforma o del Anfitrión.

V. POLÍTICA DE CANCELACIÓN Y REEMBOLSOS

5.1. El Usuario acepta que las siguientes políticas de cancelación y reembolso aplican a todas las reservaciones realizadas a través de la Plataforma:

5.2. Cancelación por parte del Huésped:

5.2.1. Cancelación con siete (7) días o más de anticipación a la fecha de inicio de la reservación: El Huésped tendrá derecho a un reembolso del cien por ciento (100%) del monto pagado, excluyendo las comisiones de Pool & Chill y los cargos por procesamiento de Stripe, los cuales no son reembolsables.

5.2.2. Cancelación con menos de siete (7) días pero con más de cuarenta y ocho (48) horas de anticipación a la fecha de inicio de la reservación: El Huésped tendrá derecho a un reembolso del setenta y cinco por ciento (75%) del monto pagado, excluyendo las comisiones de Pool & Chill y los cargos por procesamiento de Stripe.

5.2.3. Cancelación con menos de cuarenta y ocho (48) horas de anticipación a la fecha de inicio de la reservación: El Huésped tendrá derecho a un reembolso del cincuenta por ciento (50%) del monto pagado, excluyendo las comisiones de Pool & Chill y los cargos por procesamiento de Stripe.

5.2.4. No Show (ausencia sin cancelación previa): En caso de que el Huésped no se presente en la fecha y hora acordadas sin haber realizado cancelación previa, no tendrá derecho a reembolso alguno.

5.3. Cancelación por parte del Anfitrión:

5.3.1. Si el Anfitrión cancela una reservación confirmada, deberá reembolsar al Huésped el cien por ciento (100%) del monto pagado, y Pool & Chill podrá aplicar sanciones que incluyan, sin limitarse a, la suspensión temporal o permanente de la cuenta del Anfitrión.

5.4. Caso Fortuito o Fuerza Mayor:

5.4.1. En caso de que la reservación no pueda llevarse a cabo debido a circunstancias de caso fortuito o fuerza mayor debidamente acreditadas (incluyendo, sin limitarse a, desastres naturales, pandemias, restricciones gubernamentales, conflictos armados, actos de terrorismo, fallas en servicios públicos esenciales), el Huésped tendrá derecho a un reembolso del cien por ciento (100%) del monto pagado, o bien, a reprogramar la reservación para una fecha posterior, según lo acuerden las partes.

5.5. Los reembolsos se procesarán mediante el mismo método de pago utilizado para la reservación original, y podrán tardar entre cinco (5) y quince (15) días hábiles en reflejarse, dependiendo de las políticas del procesador de pagos.

VI. RESPONSABILIDAD Y EXENCIONES

6.1. Deslinde de Responsabilidad por Accidentes: Pool & Chill no será responsable, bajo ninguna circunstancia, por accidentes, lesiones, daños físicos, pérdidas materiales, enfermedades, fallecimientos o cualquier otro perjuicio que ocurra dentro de los inmuebles, albercas o instalaciones ofrecidas por los Anfitriones. La responsabilidad por dichos eventos recae exclusivamente en el Anfitrión y, en su caso, en el Huésped, según corresponda.

6.2. Responsabilidad del Anfitrión: El Anfitrión es el único responsable de garantizar que su inmueble, alberca e instalaciones cumplan con todas las normas de seguridad, construcción, salud pública, protección civil y cualquier otra normativa aplicable. El Anfitrión se obliga a mantener sus instalaciones en condiciones seguras y adecuadas para el uso público.

6.3. Responsabilidad del Huésped: El Huésped es responsable de utilizar el inmueble y las instalaciones de manera adecuada, respetando las reglas establecidas por el Anfitrión y asumiendo la responsabilidad por cualquier daño que cause a la propiedad del Anfitrión o a terceros durante su uso.

6.4. Limitación Cuantitativa de Responsabilidad de la Plataforma: En ningún caso la responsabilidad total de Pool & Chill hacia cualquier Usuario, ya sea por incumplimiento contractual, responsabilidad extracontractual, daños directos, indirectos, incidentales, consecuenciales, lucro cesante, pérdida de beneficios, pérdida de datos, daño moral o cualquier otro concepto, excederá el monto total de las comisiones efectivamente cobradas y percibidas por Pool & Chill en relación con la operación específica que dio origen al reclamo, sin que en ningún caso dicha responsabilidad pueda exceder el monto de las comisiones percibidas en la reservación específica objeto del reclamo.

6.5. Cláusula de Indemnización y Sacar en Paz y a Salvo: Los Usuarios, tanto Anfitriones como Huéspedes, se obligan expresamente a sacar en paz y a salvo, indemnizar, defender y mantener indemne a Pool & Chill, así como a sus directores, administradores, empleados, agentes, afiliados, subsidiarias, representantes, licenciantes y cualquier otra persona relacionada con Pool & Chill, de y contra cualquier reclamo, demanda, acción, procedimiento, pérdida, daño, responsabilidad, costo, gasto, sanción administrativa, multa, honorarios de abogados razonables y cualquier otro perjuicio que surja de o esté relacionado con: (i) el uso o mal uso de la Plataforma por parte del Usuario; (ii) el incumplimiento de estos Términos por parte del Usuario; (iii) la violación de cualquier ley, reglamento, ordenamiento jurídico o derecho de terceros por parte del Usuario; (iv) el contenido proporcionado por el Usuario, incluyendo información sobre inmuebles, fotografías, descripciones, reseñas y comentarios; (v) cualquier actividad realizada por el Usuario en relación con la Plataforma o con el uso del inmueble objeto de la reservación; (vi) accidentes, lesiones, daños físicos, pérdidas materiales, enfermedades, fallecimientos o cualquier otro perjuicio que ocurra dentro de los inmuebles, albercas o instalaciones ofrecidas por los Anfitriones; (vii) el incumplimiento de las obligaciones contractuales entre Anfitrión y Huésped; (viii) cualquier reclamación de terceros derivada del uso del inmueble por parte del Huésped; y (ix) cualquier otra situación derivada de la conducta del Usuario o del uso del inmueble, independientemente de que Pool & Chill haya sido notificado o no de la posibilidad de dichos daños. Esta obligación de indemnización y sacar en paz y a salvo subsistirá aún después de la terminación de la relación contractual entre el Usuario y Pool & Chill.

VII. CONDUCTAS PROHIBIDAS

7.1. Los Usuarios se obligan a no realizar, permitir o facilitar ninguna de las siguientes conductas prohibidas:

7.1.1. Eventos no autorizados: Realizar eventos, fiestas, reuniones masivas o cualquier actividad que no haya sido expresamente autorizada por el Anfitrión y que exceda el número máximo de personas permitidas.

7.1.2. Uso ilícito: Utilizar los inmuebles o la Plataforma para cualquier actividad ilegal, fraudulenta, engañosa o que viole cualquier ley, reglamento u ordenamiento jurídico aplicable.

7.1.3. Exceso de personas: Permitir que un número de personas mayor al establecido en la reservación acceda al inmueble, sin autorización previa y por escrito del Anfitrión.

7.1.4. Daños a propiedad: Causar daños intencionales o por negligencia a la propiedad del Anfitrión, incluyendo, sin limitarse a, muebles, instalaciones, equipamiento, alberca, áreas comunes o cualquier otro bien.

7.1.5. Actividades ilegales: Realizar, facilitar o permitir cualquier actividad que constituya un delito conforme a las leyes mexicanas o internacionales, incluyendo, sin limitarse a, tráfico de drogas, prostitución, apuestas ilegales, lavado de dinero, evasión fiscal o cualquier otra actividad delictiva.

7.2. La violación de cualquiera de las conductas prohibidas establecidas en esta cláusula dará lugar a la suspensión inmediata de la cuenta del Usuario, la cancelación de reservaciones activas sin derecho a reembolso, y la posibilidad de que Pool & Chill ejerza acciones legales en contra del Usuario infractor.

VIII. SUSPENSIÓN O CANCELACIÓN DE CUENTA

8.1. Pool & Chill se reserva el derecho de suspender o cancelar, de manera temporal o permanente, la cuenta de cualquier Usuario que incumpla estos Términos, las políticas de la Plataforma o cualquier ley aplicable.

8.2. Las causas que pueden dar lugar a la suspensión o cancelación de cuenta incluyen, sin limitarse a:

8.2.1. Incumplimiento de obligaciones contractuales establecidas en estos Términos.

8.2.2. Fraude, engaño, suplantación de identidad o cualquier actividad fraudulenta.

8.2.3. Conducta riesgosa que ponga en peligro la seguridad de otros Usuarios o de terceros.

8.2.4. Violación de las conductas prohibidas establecidas en la Cláusula VII.

8.2.5. Proporcionar información falsa, inexacta o engañosa durante el registro o uso de la Plataforma.

8.2.6. Intentar eludir o manipular el sistema de pagos, comisiones o cualquier otro mecanismo de la Plataforma.

8.3. La suspensión o cancelación de cuenta no exime al Usuario de cumplir con sus obligaciones pendientes, incluyendo el pago de comisiones, reembolsos o indemnizaciones que correspondan.

IX. PROPIEDAD INTELECTUAL

9.1. La marca "Pool & Chill", los logotipos, diseños, interfaces gráficas, código fuente, bases de datos, algoritmos y cualquier otro elemento de la Plataforma son propiedad exclusiva de Pool & Chill o de sus licenciantes, y están protegidos por las leyes mexicanas e internacionales de propiedad intelectual, incluyendo la Ley Federal del Derecho de Autor y la Ley de la Propiedad Industrial.

9.2. Los Usuarios no adquieren ningún derecho de propiedad sobre los elementos mencionados en la cláusula anterior, y se les prohíbe expresamente utilizar, reproducir, modificar, distribuir, transmitir, mostrar públicamente o crear obras derivadas de dichos elementos sin autorización previa y por escrito de Pool & Chill.

9.3. El contenido proporcionado por los Usuarios (incluyendo fotografías, descripciones, comentarios y reseñas) podrá ser utilizado por Pool & Chill para los fines de operación, promoción y mejora de la Plataforma, sin que ello genere obligación alguna de pago o reconocimiento a favor del Usuario.

X. PROTECCIÓN DE MENORES

10.1. La Plataforma está dirigida a personas mayores de edad (18 años) con capacidad legal para contratar conforme a las leyes mexicanas.

10.2. Los menores de edad solo podrán utilizar la Plataforma bajo la supervisión y responsabilidad de sus padres, tutores o representantes legales, quienes serán responsables de todas las acciones realizadas por los menores a su cargo.

10.3. Pool & Chill no será responsable por el uso de la Plataforma por parte de menores de edad sin la supervisión adecuada de sus representantes legales.

XI. CONSUMO DE ALCOHOL Y SUSTANCIAS

11.1. El consumo de alcohol y sustancias dentro de los inmuebles ofrecidos en la Plataforma está sujeto a las reglas y restricciones establecidas por cada Anfitrión, así como a la legislación aplicable en materia de consumo de alcohol y sustancias controladas.

11.2. Los Usuarios son responsables de cumplir con todas las leyes y regulaciones aplicables al consumo de alcohol y sustancias, incluyendo las restricciones de edad y las normas de seguridad.

11.3. Pool & Chill no será responsable por los daños, accidentes o consecuencias derivadas del consumo de alcohol o sustancias dentro de los inmuebles, siendo esta responsabilidad exclusiva del Anfitrión y del Huésped.

XII. PREVENCIÓN DE LAVADO DE DINERO

12.1. Pool & Chill se compromete a cumplir con todas las disposiciones legales aplicables en materia de prevención de lavado de dinero y financiamiento al terrorismo, conforme a la Ley para la Transparencia y Ordenamiento de los Servicios Financieros y demás normativa aplicable.

12.2. Los Usuarios se obligan a proporcionar información veraz, completa y actualizada cuando así se les solicite, y a colaborar con Pool & Chill en cualquier procedimiento de verificación de identidad o debido proceso de conocimiento del cliente que sea requerido por la ley.

12.3. Pool & Chill se reserva el derecho de suspender o cancelar cualquier transacción que considere sospechosa o que pueda estar relacionada con actividades de lavado de dinero o financiamiento al terrorismo, y de reportar dichas actividades a las autoridades competentes cuando sea requerido por la ley.

XIII. PAGOS Y PROCESAMIENTO

13.1. Los pagos se procesan mediante la plataforma de pagos Stripe, la cual cumple con los más altos estándares de seguridad en el procesamiento de transacciones financieras.

13.2. La verificación de identidad de los Usuarios se realiza mediante el servicio de Didit, el cual permite validar la identidad de los usuarios de manera segura y conforme a la normativa aplicable.

13.3. La infraestructura tecnológica de la Plataforma se encuentra alojada en Firebase, que proporciona medidas de seguridad avanzadas para la protección de datos.

13.4. Todos los datos se encuentran cifrados tanto en tránsito (mediante protocolos TLS/SSL) como en reposo, garantizando la protección de la información sensible de los Usuarios.

13.5. Pool & Chill no almacena datos bancarios completos de los Usuarios. La información de tarjetas de crédito y débito es procesada y almacenada exclusivamente por Stripe, conforme a sus políticas de seguridad y cumplimiento normativo (PCI DSS).

13.6. Pool & Chill cumple con los estándares de seguridad establecidos por la industria y las autoridades regulatorias mexicanas en materia de protección de datos financieros.

13.7. Aclaración sobre el Flujo de Pagos y Custodia de Fondos:

13.7.1. Los pagos realizados a través de la Plataforma son procesados exclusivamente por Stripe, plataforma de pagos autorizada y regulada conforme a la legislación aplicable.

13.7.2. Stripe es la entidad que retiene temporalmente los fondos correspondientes a las reservaciones, actuando como procesador de pagos y custodio de los recursos financieros durante el período de retención establecido en sus términos de servicio.

13.7.3. Pool & Chill no custodia directamente los recursos financieros de los Usuarios. Pool & Chill únicamente actúa como intermediario tecnológico que facilita la conexión entre Anfitriones y Huéspedes, y proporciona instrucciones programadas a Stripe para la liberación de pagos (payouts) conforme a los términos acordados entre las partes.

13.7.4. Pool & Chill no opera como institución de crédito, institución financiera, entidad de custodia, casa de bolsa, sociedad financiera de objeto múltiple, ni como ninguna otra entidad sujeta a la supervisión de la Comisión Nacional Bancaria y de Valores, la Comisión Nacional para la Protección y Defensa de los Usuarios de Servicios Financieros, o cualquier otra autoridad financiera mexicana o extranjera.

13.7.5. Pool & Chill no capta recursos del público en el sentido previsto por la Ley para la Transparencia y Ordenamiento de los Servicios Financieros ni por la Ley de Instituciones de Crédito, limitándose exclusivamente a percibir comisiones por la intermediación tecnológica prestada, las cuales son procesadas y transferidas mediante Stripe conforme a los términos contractuales establecidos.

XIV. JURISDICCIÓN Y COMPETENCIA

14.1. Estos Términos se rigen por las leyes de los Estados Unidos Mexicanos, sin dar efecto a cualquier principio de conflictos de leyes.

14.2. Para cualquier controversia, conflicto o diferencia que surja de o esté relacionada con estos Términos, el uso de la Plataforma o cualquier transacción realizada a través de ella, las partes se someten expresamente a la jurisdicción y competencia de los tribunales competentes de la Ciudad de México, Distrito Federal, renunciando a cualquier otro fuero que pudiera corresponderles por razón de sus domicilios presentes o futuros o por cualquier otra causa.

14.3. En caso de que alguna disposición de estos Términos sea declarada nula, inválida o inaplicable por autoridad competente, el resto de las disposiciones permanecerán en pleno vigor y efecto.

XV. MODIFICACIONES A LOS TÉRMINOS

15.1. Pool & Chill se reserva el derecho de modificar estos Términos en cualquier momento, previa notificación a los Usuarios mediante publicación en la Plataforma o comunicación al correo electrónico registrado, con al menos treinta (30) días de anticipación.

15.2. El uso continuado de la Plataforma después de la entrada en vigor de las modificaciones constituye aceptación de los Términos modificados. Si el Usuario no está de acuerdo con las modificaciones, deberá cesar inmediatamente el uso de la Plataforma y solicitar la cancelación de su cuenta.

XVI. CONTACTO

16.1. Para cualquier consulta, aclaración o notificación relacionada con estos Términos, los Usuarios podrán contactar a Pool & Chill a través de los medios de contacto proporcionados en la Plataforma.

16.2. Todas las notificaciones y comunicaciones oficiales entre Pool & Chill y los Usuarios se realizarán mediante correo electrónico a la dirección registrada en la cuenta del Usuario o mediante publicación en la Plataforma.

Al utilizar la Plataforma Pool & Chill, usted reconoce haber leído, entendido y aceptado estos Términos y Condiciones de Uso en su totalidad.
''';

  static const String politicaPrivacidad = '''
AVISO DE PRIVACIDAD INTEGRAL DE POOL & CHILL

ÚLTIMA ACTUALIZACIÓN: Febrero 2026

I. IDENTIDAD Y DOMICILIO DEL RESPONSABLE

En cumplimiento con lo dispuesto en la Ley Federal de Protección de Datos Personales en Posesión de los Particulares (en adelante, la "LFPDPPP") y su Reglamento, POOL & CHILL, sociedad mercantil constituida conforme a las leyes de los Estados Unidos Mexicanos (en adelante, "Pool & Chill", "nosotros" o "el Responsable"), con domicilio ubicado en Ensarta, 100, entre calle carretera a valladolid y calle carretera a comunidad el maguey, 20900, Jesús María, Aguascalientes, México, es responsable del tratamiento de sus datos personales.

Para efectos de este Aviso de Privacidad, Pool & Chill actúa como Responsable del tratamiento de los datos personales que usted proporcione a través de la plataforma digital "Pool & Chill", ya sea mediante aplicación móvil o sitio web.

II. DATOS PERSONALES RECABADOS

Pool & Chill recaba los siguientes datos personales de los Usuarios de la Plataforma:

II.1. Datos de Identificación:

- Nombre completo
- Fecha de nacimiento
- Edad
- Nacionalidad
- Fotografía de identificación oficial
- Número de identificación oficial (INE, pasaporte u otro documento oficial)
- Firma electrónica o biométrica (cuando aplique)

II.2. Datos de Contacto:

- Correo electrónico
- Número telefónico (fijo y/o móvil)
- Dirección de residencia
- Código postal
- Ciudad y estado de residencia

II.3. Datos Financieros:

- Información de tarjetas de crédito o débito (procesada exclusivamente por Stripe, sin almacenamiento completo por parte de Pool & Chill)
- Información bancaria para recibir pagos (en el caso de Anfitriones)
- Historial de transacciones
- Comprobantes de pago
- Información fiscal (RFC, CURP, cuando sea requerido)

II.4. Datos de Verificación:

- Información proporcionada a través del servicio de verificación de identidad Didit
- Documentos de identificación oficial escaneados
- Información biométrica (cuando sea utilizada para verificación)

II.5. Datos de Uso de la Plataforma:

- Información de registro y acceso (usuario, contraseña encriptada)
- Historial de reservaciones
- Preferencias de búsqueda
- Comentarios y reseñas publicadas
- Fotografías y videos subidos a la Plataforma
- Ubicación geográfica (cuando sea proporcionada voluntariamente)
- Dirección IP
- Tipo de dispositivo utilizado
- Sistema operativo y versión del navegador
- Cookies y tecnologías similares

II.6. Datos del Inmueble (para Anfitriones):

- Dirección completa del inmueble
- Características físicas del inmueble y alberca
- Fotografías del inmueble
- Información de propiedad o autorización para ofrecer el inmueble
- Documentos legales relacionados con el inmueble (cuando sea requerido)

III. FINALIDADES PRIMARIAS DEL TRATAMIENTO

Los datos personales recabados serán utilizados para las siguientes finalidades primarias, que son necesarias para la prestación del servicio solicitado:

III.1. Gestión de la Cuenta de Usuario:

- Crear y administrar su cuenta en la Plataforma
- Verificar su identidad mediante el servicio de Didit
- Autenticar su acceso a la Plataforma
- Mantener su perfil de usuario actualizado

III.2. Procesamiento de Reservaciones:

- Facilitar la conexión entre Anfitriones y Huéspedes
- Procesar solicitudes de reservación
- Confirmar y gestionar reservaciones
- Comunicar información relevante sobre las reservaciones

III.3. Procesamiento de Pagos:

- Procesar pagos mediante la plataforma Stripe
- Gestionar comisiones y tarifas
- Procesar reembolsos cuando corresponda
- Emitir comprobantes fiscales
- Gestionar disputas relacionadas con pagos

III.4. Comunicación con Usuarios:

- Enviar notificaciones sobre reservaciones
- Responder a consultas y solicitudes de soporte
- Enviar información importante sobre cambios en los términos de servicio o políticas
- Comunicar actualizaciones de la Plataforma

III.5. Verificación y Seguridad:

- Verificar la identidad de los Usuarios
- Prevenir fraudes y actividades ilícitas
- Cumplir con obligaciones legales en materia de prevención de lavado de dinero
- Mantener la seguridad e integridad de la Plataforma

III.6. Publicación de Contenido:

- Publicar información de inmuebles (para Anfitriones)
- Mostrar reseñas y comentarios de Usuarios
- Compartir fotografías y descripciones de inmuebles

IV. FINALIDADES SECUNDARIAS DEL TRATAMIENTO

Adicionalmente, sus datos personales podrán ser utilizados para las siguientes finalidades secundarias, que no son necesarias para la prestación del servicio pero nos permiten brindarle una mejor experiencia:

IV.1. Marketing y Promociones:

- Enviar ofertas promocionales y descuentos
- Informar sobre nuevos servicios o funcionalidades
- Realizar estudios de mercado y análisis de preferencias
- Personalizar el contenido y las recomendaciones mostradas en la Plataforma

IV.2. Mejora de Servicios:

- Analizar el uso de la Plataforma para mejorar nuestros servicios
- Desarrollar nuevas funcionalidades
- Realizar estudios estadísticos y de comportamiento de usuarios
- Optimizar la experiencia del usuario

IV.3. Comunicaciones Comerciales:

- Enviar boletines informativos
- Invitar a participar en programas de fidelización
- Compartir contenido educativo relacionado con el uso de albercas y espacios recreativos

Si usted no desea que sus datos personales sean tratados para alguna o todas las finalidades secundarias, puede manifestar su oposición mediante el procedimiento establecido en la sección de Derechos ARCO de este Aviso.

V. TRANSFERENCIAS DE DATOS PERSONALES

Pool & Chill realiza las siguientes transferencias de datos personales a terceros, sin que se requiera su consentimiento adicional conforme a lo establecido en el artículo 37 de la LFPDPPP:

V.1. Transferencia a Stripe:

- Datos transferidos: Información de tarjetas de crédito/débito, información de transacciones, datos de identificación necesarios para el procesamiento de pagos.
- Finalidad: Procesamiento seguro de pagos y cumplimiento de obligaciones financieras.
- País de destino: Estados Unidos de América.
- Medidas de seguridad: Stripe cumple con los estándares PCI DSS y mantiene certificaciones internacionales de seguridad.

V.2. Transferencia a Didit:

Para efectos de la verificación de identidad y prevención de fraudes, Pool & Chill utiliza los servicios de Didit, una plataforma de verificación de identidad digital. Didit Identity, Inc., persona moral de derecho privado que provee los servicios de verificación de identidad, actúa como encargado del tratamiento de datos personales, procesando únicamente los datos que Pool & Chill le proporcione para cumplir con las finalidades de verificación de identidad y detección de fraude.

- Datos transferidos: Las transferencias de datos personales a Didit podrán incluir, en su caso y dependiendo del flujo de verificación: identificación oficial, selfies biométricos, fecha de nacimiento, fotografía, datos de verificación, metadatos asociados y cualquier otro dato estrictamente necesario para realizar la verificación de identidad y detección de fraude.

- Finalidad de la Transferencia: La transferencia tiene por finalidad permitir la verificación de identidad del Usuario en la plataforma, la prevención de dobles cuentas, bots, fraudes y actividades potencialmente ilegales, así como dar cumplimiento a las obligaciones contractuales de Pool & Chill.

- Domicilio y País de Operación: Didit Identity, Inc. tiene su sede principal en San Francisco, Estados Unidos de América. Al usar los servicios de Didit, algunos datos personales pueden ser transferidos y almacenados en servidores ubicados fuera de México, en particular en los Estados Unidos u otras jurisdicciones donde Didit opere o tenga infraestructura.

- Transferencias Internacionales: Dichas transferencias están cubiertas por las finalidades del tratamiento descritas en este aviso y se realizarán bajo los mecanismos de protección y seguridad aplicables conforme a la Ley Federal de Protección de Datos Personales en Posesión de los Particulares.

- Protección de Datos por Encargado: Didit, como encargado, se obliga a observar medidas de seguridad, técnicas, administrativas y físicas para proteger los datos personales, conforme a las mejores prácticas y políticas internas de seguridad, y únicamente los utilizará para las finalidades autorizadas por Pool & Chill y por el Usuario, sin fines propios.

V.3. Transferencia a Firebase (Google Cloud Platform):

- Datos transferidos: Todos los datos personales almacenados en la Plataforma, incluyendo información de perfil, reservaciones, comunicaciones y contenido generado por usuarios.
- Finalidad: Almacenamiento seguro de datos y provisión de infraestructura tecnológica para la Plataforma.
- País de destino: Estados Unidos de América (con posibilidad de replicación en otros países donde Google Cloud Platform tenga centros de datos).
- Medidas de seguridad: Firebase implementa medidas de seguridad de nivel empresarial, incluyendo cifrado en tránsito y en reposo, controles de acceso y monitoreo continuo.

V.4. Otras Transferencias:

Pool & Chill también puede transferir datos personales cuando sea requerido por ley, orden judicial o autoridad competente, o cuando sea necesario para proteger los derechos, propiedad o seguridad de Pool & Chill, sus usuarios o terceros.

VI. MEDIDAS DE SEGURIDAD

Pool & Chill implementa medidas de seguridad administrativas, técnicas y físicas para proteger sus datos personales contra daño, pérdida, alteración, destrucción o uso, acceso o tratamiento no autorizados:

VI.1. Medidas Administrativas:

- Políticas y procedimientos internos de protección de datos
- Capacitación periódica del personal en materia de protección de datos
- Controles de acceso basados en roles y responsabilidades
- Auditorías periódicas de seguridad

VI.2. Medidas Técnicas:

- Cifrado de datos en tránsito mediante protocolos TLS/SSL
- Cifrado de datos en reposo mediante algoritmos de cifrado avanzados
- Sistemas de autenticación de múltiples factores cuando sea aplicable
- Monitoreo continuo de la infraestructura tecnológica
- Firewalls y sistemas de detección de intrusiones
- Copias de seguridad periódicas y planes de recuperación ante desastres
- Actualizaciones regulares de software y parches de seguridad

VI.3. Medidas Físicas:

- Control de acceso físico a las instalaciones donde se almacenan los datos
- Sistemas de videovigilancia y control de acceso
- Destrucción segura de documentos físicos cuando sea aplicable

A pesar de las medidas de seguridad implementadas, ningún sistema de transmisión o almacenamiento de datos es completamente seguro. Pool & Chill no puede garantizar la seguridad absoluta de los datos personales, aunque se compromete a mantener los más altos estándares de seguridad disponibles en la industria.

VII. DERECHOS ARCO

Usted tiene derecho a conocer qué datos personales tenemos de usted, para qué los utilizamos y las condiciones de uso que les damos (Derecho de Acceso). Asimismo, es su derecho solicitar la corrección de sus datos personales en caso de que estén desactualizados, sean inexactos o incompletos (Derecho de Rectificación); que los eliminemos de nuestros registros o bases de datos cuando considere que no están siendo utilizados adecuadamente (Derecho de Cancelación); así como oponerse al tratamiento de sus datos personales para fines específicos (Derecho de Oposición). Estos derechos se conocen como derechos ARCO.

Para ejercer cualquiera de los derechos ARCO, usted deberá presentar la solicitud correspondiente mediante el siguiente procedimiento:

VII.1. Procedimiento para Ejercer Derechos ARCO:

1. Presentar su solicitud por escrito dirigida al Departamento de Protección de Datos Personales de Pool & Chill, a través del correo electrónico: team@poolandchill.com.mx

2. La solicitud deberá contener:
   - Nombre del titular de los datos personales
   - Correo electrónico registrado en la Plataforma
   - Descripción clara y precisa de los datos personales respecto de los que se busca ejercer algún derecho ARCO
   - Indicación del derecho que se desea ejercer (Acceso, Rectificación, Cancelación u Oposición)
   - Cualquier otro elemento que facilite la localización de los datos personales

3. Adjuntar copia de identificación oficial vigente (INE, pasaporte u otro documento oficial) para acreditar su identidad.

4. En caso de que la solicitud sea presentada por representante legal, deberá adjuntar el poder notarial o documento que acredite la representación.

VII.2. Plazos de Respuesta:

Pool & Chill responderá a su solicitud en un plazo máximo de veinte (20) días hábiles contados a partir de la fecha en que recibamos su solicitud completa. Dicho plazo podrá ser ampliado por una vez por un período igual, siempre que así lo justifiquen las circunstancias del caso, lo cual se le notificará mediante correo electrónico.

VII.3. Entrega de Información:

En caso de que su solicitud sea procedente, Pool & Chill hará efectiva la misma en un plazo máximo de quince (15) días hábiles contados a partir de la fecha en que comuniquemos la respuesta. La entrega de información se realizará mediante correo electrónico o, a solicitud del titular, mediante copia simple en formato digital.

VII.4. Revocación del Consentimiento:

Usted puede revocar el consentimiento que nos haya otorgado para el tratamiento de sus datos personales en cualquier momento. Sin embargo, es importante que tenga en cuenta que no en todos los casos podremos atender su solicitud o concluir el uso de forma inmediata, ya que es posible que por alguna obligación legal requiramos seguir tratando sus datos personales. Asimismo, debe considerar que para ciertos fines, la revocación de su consentimiento implicará que no podamos continuar prestando el servicio que nos solicitó.

La revocación del consentimiento deberá seguir el mismo procedimiento establecido para el ejercicio de derechos ARCO.

VIII. CONSERVACIÓN Y ELIMINACIÓN DE DATOS PERSONALES

VIII.1. Tiempo de Conservación:

Sus datos personales serán conservados durante el tiempo necesario para cumplir con las finalidades descritas en este Aviso de Privacidad y, posteriormente, durante los plazos establecidos por la legislación aplicable, incluyendo, sin limitarse a:

- Plazos de prescripción de acciones legales
- Obligaciones fiscales y contables (generalmente 5 años conforme a la legislación fiscal mexicana)
- Obligaciones en materia de prevención de lavado de dinero
- Cualquier otro plazo establecido por ley

VIII.2. Eliminación de Datos:

Una vez cumplidos los plazos de conservación establecidos, sus datos personales serán eliminados de nuestros sistemas de manera segura e irreversible, utilizando métodos que garanticen que la información no pueda ser recuperada ni reconstruida.

VIII.3. Excepciones:

Pool & Chill podrá conservar ciertos datos personales por períodos adicionales cuando sea necesario para:
- Cumplir con obligaciones legales
- Resolver disputas
- Hacer cumplir nuestros acuerdos
- Proteger los derechos, propiedad o seguridad de Pool & Chill, sus usuarios o terceros

IX. USO DE COOKIES Y TECNOLOGÍAS SIMILARES

IX.1. Cookies:

La Plataforma utiliza cookies y tecnologías similares para mejorar su experiencia de usuario, analizar el uso de la Plataforma y personalizar el contenido mostrado.

IX.2. Tipos de Cookies Utilizadas:

- Cookies técnicas: Necesarias para el funcionamiento básico de la Plataforma
- Cookies de rendimiento: Permiten analizar cómo los usuarios interactúan con la Plataforma
- Cookies de funcionalidad: Permiten recordar sus preferencias y personalizar su experiencia
- Cookies de marketing: Utilizadas para mostrar contenido relevante y realizar análisis de marketing

IX.3. Control de Cookies:

Usted puede controlar y gestionar las cookies a través de la configuración de su navegador. Sin embargo, tenga en cuenta que deshabilitar ciertas cookies puede afectar la funcionalidad de la Plataforma.

IX.4. Tecnologías de Seguimiento:

La Plataforma también puede utilizar tecnologías de seguimiento como píxeles de seguimiento, web beacons y tecnologías similares para recopilar información sobre su uso de la Plataforma.

X. MODIFICACIONES AL AVISO DE PRIVACIDAD

Pool & Chill se reserva el derecho de modificar este Aviso de Privacidad en cualquier momento. Las modificaciones serán publicadas en la Plataforma y, cuando sean sustanciales, se le notificará mediante correo electrónico o mediante un aviso destacado en la Plataforma.

Se recomienda revisar periódicamente este Aviso de Privacidad para estar informado sobre cómo protegemos sus datos personales.

XI. CONSENTIMIENTO

Al proporcionar sus datos personales a través de la Plataforma Pool & Chill, usted otorga su consentimiento expreso para el tratamiento de sus datos personales conforme a los términos establecidos en este Aviso de Privacidad.

XII. AUTORIDAD DE CONTROL

Si considera que sus derechos de protección de datos personales han sido vulnerados, usted tiene derecho a presentar una denuncia ante el Instituto Nacional de Transparencia, Acceso a la Información y Protección de Datos Personales (INAI), que es la autoridad encargada de vigilar el cumplimiento de la LFPDPPP en México.

Para más información, puede visitar el sitio web del INAI: www.inai.org.mx

XIII. CONTACTO

Para cualquier duda, aclaración o ejercicio de derechos ARCO relacionado con este Aviso de Privacidad, puede contactarnos a través de:

Correo electrónico: team@poolandchill.com.mx
Dirección: Ensarta, 100, entre calle carretera a valladolid y calle carretera a comunidad el maguey, 20900, Jesús María, Aguascalientes, México

Este Aviso de Privacidad está disponible en todo momento en la Plataforma Pool & Chill para su consulta.
''';
}
