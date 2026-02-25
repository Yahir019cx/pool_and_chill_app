import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/features/host/screens/faq_host_screen.dart';
import 'package:pool_and_chill_app/features/home/screens/perfil/seguridad_screen.dart';

class AyudaHostScreen extends StatelessWidget {
  const AyudaHostScreen({super.key});

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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
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

  void _mostrarModalContacto(
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
      builder: (sheetCtx) => Padding(
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
            _contactTile(
              icon: Icons.email_outlined,
              color: const Color(0xFF3CA2A2),
              label: 'Correo electrónico',
              subtitle: _supportEmail,
              onTap: () async {
                Navigator.pop(sheetCtx);
                await _launchEmail(
                  subject: 'Ayuda anfitrión – Pool&Chill',
                  body: emailBody,
                );
              },
            ),
            const SizedBox(height: 12),
            _contactTile(
              icon: Icons.chat_rounded,
              color: const Color(0xFF25D366),
              label: 'WhatsApp',
              subtitle: 'Respuesta rápida · disponible 9–18 h',
              onTap: () async {
                Navigator.pop(sheetCtx);
                await _launchWhatsApp(whatsAppMsg);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarModalReporte(
      BuildContext context, String userName, String userEmail) {
    final emailBody = 'Hola equipo de Pool&Chill,\n\n'
        'Soy anfitrión y quiero reportar un problema.\n\n'
        'Nombre: $userName\n'
        'Correo de cuenta: $userEmail\n\n'
        '[Describe aquí el problema]\n\nGracias.';

    final whatsAppMsg =
        'Hola! Soy anfitrión en Pool&Chill: $userName ($userEmail) y quiero reportar un problema.';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
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
              'Reportar un problema',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Elige cómo prefieres enviarnos tu reporte.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 20),
            _contactTile(
              icon: Icons.email_outlined,
              color: const Color(0xFF3CA2A2),
              label: 'Correo electrónico',
              subtitle: _supportEmail,
              onTap: () async {
                Navigator.pop(sheetCtx);
                await _launchEmail(
                  subject: 'Reporte de problema (anfitrión) – Pool&Chill',
                  body: emailBody,
                );
              },
            ),
            const SizedBox(height: 12),
            _contactTile(
              icon: Icons.chat_rounded,
              color: const Color(0xFF25D366),
              label: 'WhatsApp',
              subtitle: 'Respuesta rápida · disponible 9–18 h',
              onTap: () async {
                Navigator.pop(sheetCtx);
                await _launchWhatsApp(whatsAppMsg);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.read<AuthProvider>().profile;
    final userName = profile?.displayName ??
        '${profile?.firstName ?? ''} ${profile?.lastName ?? ''}'.trim();
    final userEmail = profile?.email ?? '';

    final options = <_HelpOption>[
      _HelpOption(
        icon: Icons.question_answer_outlined,
        title: 'Preguntas frecuentes',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FAQHostScreen()),
        ),
      ),
      _HelpOption(
        icon: Icons.mail_outline,
        title: 'Contáctanos directamente',
        onTap: () => _mostrarModalContacto(context, userName, userEmail),
      ),
      _HelpOption(
        icon: Icons.report_problem_outlined,
        title: 'Reportar un problema',
        onTap: () => _mostrarModalReporte(context, userName, userEmail),
      ),
      _HelpOption(
        icon: Icons.star_rate_outlined,
        title: 'Calificar la app',
        onTap: () => _launchUrl(
          'https://play.google.com/store/apps/details?id=com.poolandchill.app',
        ),
      ),
      _HelpOption(
        icon: Icons.security_outlined,
        title: 'Problemas de seguridad',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SeguridadScreen()),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.3,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Centro de ayuda',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 120),
            children: [
              const Text(
                'Encuentra respuestas o contáctanos',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Estamos aquí para ayudarte con cualquier duda relacionada con tu actividad como anfitrión.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15, color: Colors.grey.shade700, height: 1.5),
              ),
              const SizedBox(height: 32),
              for (final option in options) _helpTile(option),
            ],
          ),
        ),
      ),
    );
  }

  Widget _helpTile(_HelpOption option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: ListTile(
        leading: Icon(option.icon, color: const Color(0xFF2D9D91)),
        title: Text(
          option.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black45),
        onTap: option.onTap,
      ),
    );
  }

  Widget _contactTile({
    required IconData icon,
    required Color color,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 1),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 13, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _HelpOption {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _HelpOption({required this.icon, required this.title, required this.onTap});
}
