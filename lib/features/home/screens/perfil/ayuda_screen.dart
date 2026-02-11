import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'faq_screen.dart' as faq;
import 'seguridad_screen.dart' as seg;

class AyudaScreen extends StatelessWidget {
  const AyudaScreen({super.key});

  // -------------------------------
  // Utils
  // -------------------------------
  Future<void> _launchEmail(String email, {String body = ''}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Soporte Pool&Chill&body=$body',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // -------------------------------
  // Modal contacto
  // -------------------------------
  void _showContactModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
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
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                '¿Cómo deseas contactarnos?',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),

              _contactOption(
                icon: Icons.chat_bubble_outline,
                color: const Color(0xFF3CA2A2),
                text: 'Abrir chat de soporte',
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),

              _contactOption(
                icon: Icons.email_outlined,
                color: Colors.teal,
                text: 'Enviar correo',
                onTap: () {
                  Navigator.pop(context);
                  _launchEmail('poolandchill_support@gmail.com');
                },
              ),
              const SizedBox(height: 12),

              _contactOption(
                icon: FontAwesomeIcons.whatsapp,
                color: Colors.green,
                text: 'WhatsApp',
                onTap: () {
                  Navigator.pop(context);
                  _launchUrl(
                    'https://wa.me/5214491025278?text=Hola!%20Necesito%20ayuda%20con%20Pool%26Chill',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------
  // UI
  // -------------------------------
  @override
  Widget build(BuildContext context) {
    final options = <_HelpOption>[
      _HelpOption(
        icon: Icons.question_answer_outlined,
        title: 'Preguntas frecuentes',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const faq.FAQScreen()),
        ),
      ),
      _HelpOption(
        icon: Icons.mail_outline,
        title: 'Contáctanos directamente',
        onTap: () =>
            _launchEmail('poolandchill_support@gmail.com'),
      ),
      _HelpOption(
        icon: Icons.report_problem_outlined,
        title: 'Reportar un problema',
        onTap: () => _launchEmail(
          'poolandchill_support@gmail.com',
          body: 'Hola, quiero reportar un problema con una renta...',
        ),
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
          MaterialPageRoute(builder: (_) => const seg.SeguridadScreen()),
        ),
      ),
      _HelpOption(
        icon: Icons.support_agent_outlined,
        title: 'Contactar a soporte técnico',
        onTap: () => _showContactModal(context),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.3,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Centro de ayuda',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 120),
            children: [
              Text(
                'Encuentra respuestas o contáctanos',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Estamos aquí para ayudarte con cualquier duda relacionada con Pool&Chill.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              for (final option in options)
                _helpTile(option),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------
  // Widgets privados
  // -------------------------------
  Widget _helpTile(_HelpOption option) {
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
        leading: Icon(option.icon, color: const Color(0xFF3CA2A2)),
        title: Text(
          option.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black45),
        onTap: option.onTap,
      ),
    );
  }

  Widget _contactOption({
    required IconData icon,
    required Color color,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.grey.shade100,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 14.5),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------
// Model UI interno
// -------------------------------
class _HelpOption {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _HelpOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
