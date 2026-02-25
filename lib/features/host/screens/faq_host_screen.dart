import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pool_and_chill_app/data/providers/auth_provider.dart';

class FAQHostScreen extends StatelessWidget {
  const FAQHostScreen({super.key});

  static const _accentColor = Color(0xFF2D9D91);
  static const _supportEmail = 'team@poolandchill.com.mx';
  static const _whatsappPhone = '524493629233';

  Future<void> _launchEmail({String subject = '', String body = ''}) async {
    final query = [
      if (subject.isNotEmpty) 'subject=${Uri.encodeComponent(subject)}',
      if (body.isNotEmpty) 'body=${Uri.encodeComponent(body)}',
    ].join('&');

    final uri =
        Uri.parse('mailto:$_supportEmail${query.isNotEmpty ? '?$query' : ''}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _launchWhatsApp(String message) async {
    final uri = Uri.parse(
      'https://wa.me/$_whatsappPhone?text=${Uri.encodeComponent(message)}',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.read<AuthProvider>().profile;
    final userName = profile?.displayName ??
        '${profile?.firstName ?? ''} ${profile?.lastName ?? ''}'.trim();
    final userEmail = profile?.email ?? '';

    final preguntas = [
      {
        'q': '¿Cómo publico una propiedad?',
        'a':
            'Ve a la sección "Mis espacios" y pulsa el botón para agregar un nuevo espacio. Sigue los pasos del asistente de publicación: fotos, descripción, reglas y precio.',
      },
      {
        'q': '¿Cuándo y cómo recibo mis pagos?',
        'a':
            'Los pagos se procesan automáticamente y el monto se deposita en tu cuenta bancaria registrada 48 horas después del checkout del huésped.',
      },
      {
        'q': '¿Cómo bloqueo fechas en mi calendario?',
        'a':
            'En el menú de administración ve a "Bloquear fechas" para marcar los días en que tu espacio no estará disponible. Los huéspedes no podrán reservar esas fechas.',
      },
      {
        'q': '¿Puedo establecer tarifas especiales por fecha?',
        'a':
            'Sí. Desde "Tarifas especiales" puedes definir precios distintos para fechas o rangos específicos, como fines de semana, días festivos o temporada alta.',
      },
      {
        'q': '¿Cómo gestiono o cancelo una reserva?',
        'a':
            'En la sección "Reservas" puedes ver el detalle de cada reserva activa. Contacta a soporte si necesitas gestionar una cancelación fuera de política.',
      },
      {
        'q': '¿Qué comisión cobra Pool&Chill?',
        'a':
            'Pool&Chill cobra una comisión por servicio sobre cada reserva completada. Puedes consultar el porcentaje vigente en los términos y condiciones del anfitrión.',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.4,
        centerTitle: true,
        title: const Text(
          'Preguntas frecuentes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 120),
              itemCount: preguntas.length,
              itemBuilder: (context, index) {
                final item = preguntas[index];
                return _FAQCard(
                  pregunta: item['q']!,
                  respuesta: item['a']!,
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _accentColor,
        icon: const Icon(Icons.headset_mic_rounded, color: Colors.white),
        label: const Text(
          '¿Necesitas ayuda?',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        onPressed: () => _mostrarModalAyuda(context, userName, userEmail),
      ),
    );
  }

  void _mostrarModalAyuda(
      BuildContext context, String userName, String userEmail) {
    final emailBody = 'Hola equipo de Pool&Chill,\n\n'
        'Soy anfitrión en la plataforma y necesito ayuda.\n\n'
        'Nombre: $userName\n'
        'Correo de cuenta: $userEmail\n\n'
        '[Describe aquí tu consulta]\n\nGracias.';

    final whatsAppMsg =
        'Hola! Soy anfitrión en Pool&Chill: $userName ($userEmail) y necesito ayuda.';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                '¿Cómo deseas contactarnos?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              _ContactoItem(
                icon: Icons.email_outlined,
                color: Colors.teal,
                label: 'Enviar correo a soporte',
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  await _launchEmail(
                    subject: 'Ayuda anfitrión – Pool&Chill',
                    body: emailBody,
                  );
                },
              ),
              const SizedBox(height: 12),
              _ContactoItem(
                icon: FontAwesomeIcons.whatsapp,
                color: Colors.green,
                label: 'Contactar por WhatsApp',
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  await _launchWhatsApp(whatsAppMsg);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FAQCard extends StatelessWidget {
  final String pregunta;
  final String respuesta;

  const _FAQCard({required this.pregunta, required this.respuesta});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            pregunta,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          iconColor: const Color(0xFF2D9D91),
          collapsedIconColor: Colors.grey,
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          children: [
            Text(
              respuesta,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactoItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ContactoItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.grey.shade100,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
