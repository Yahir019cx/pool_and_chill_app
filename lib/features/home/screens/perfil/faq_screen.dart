import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pool_and_chill_app/data/providers/auth_provider.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  static const _accentColor = Color(0xFF3CA2A2);
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
        'q': '¿Cómo puedo reservar?',
        'a':
            'Selecciona el espacio que te interese, elige la fecha disponible y completa el proceso dentro de la app.',
      },
      {
        'q': '¿Qué métodos de pago aceptan?',
        'a':
            'Aceptamos tarjetas de débito, crédito y otros métodos digitales según tu región.',
      },
      {
        'q': '¿Puedo cancelar una reserva?',
        'a':
            'Puedes cancelar hasta 24 horas antes del inicio para recibir un reembolso completo, salvo excepciones del anfitrión.',
      },
      {
        'q': '¿Qué hago si el anfitrión no llega?',
        'a':
            'Contáctanos inmediatamente desde la app o por correo y te ayudaremos a resolverlo.',
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

  // ───────────────────────── MODAL DE AYUDA ─────────────────────────

  void _mostrarModalAyuda(
      BuildContext context, String userName, String userEmail) {
    final emailBody = 'Hola equipo de Pool&Chill,\n\n'
        'Necesito ayuda con la app.\n\n'
        'Nombre: $userName\n'
        'Correo de cuenta: $userEmail\n\n'
        '[Describe aquí tu problema]\n\nGracias.';

    final whatsAppMsg =
        'Hola! Soy $userName ($userEmail) y necesito ayuda con Pool&Chill.';

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
                    subject: 'Ayuda – Pool&Chill',
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

// ───────────────────────── COMPONENTES ─────────────────────────

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
          iconColor: const Color(0xFF3CA2A2),
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
