import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SeguridadScreen extends StatelessWidget {
  const SeguridadScreen({super.key});

  static const _primaryColor = Color(0xFF3CA2A2);
  static const _supportEmail = 'poolandchill_support@gmail.com';
  static const _whatsappPhone = '+5214491025278';

  // ---- ENVIAR REPORTE POR CORREO ----
  Future<void> _enviarReporte(String body) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {
        'subject': 'Reporte de seguridad',
        'body': body,
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // ---- MODAL DE CONTACTO ----
  void _mostrarModalContacto(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dragHandle(),
            Text(
              '¿Cómo deseas contactar al equipo de seguridad?',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            _opcionContacto(
              icon: Icons.chat_bubble_outline,
              color: _primaryColor,
              texto: 'Abrir chat de soporte',
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            _opcionContacto(
              icon: Icons.email_outlined,
              color: Colors.teal,
              texto: 'Enviar correo a seguridad',
              onTap: () async {
                Navigator.pop(context);
                final uri = Uri(
                  scheme: 'mailto',
                  path: _supportEmail,
                  queryParameters: {
                    'subject': 'Reporte de seguridad',
                  },
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
            const SizedBox(height: 12),
            _opcionContacto(
              icon: FontAwesomeIcons.whatsapp,
              color: Colors.green,
              texto: 'Contactar por WhatsApp',
              onTap: () async {
                Navigator.pop(context);
                final uri = Uri.parse(
                  'https://wa.me/$_whatsappPhone?text=${Uri.encodeComponent(
                    'Hola! Necesito reportar un problema de seguridad en Pool&Chill',
                  )}',
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri,
                      mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> opciones = [
      {
        'titulo': 'Reportar comportamiento sospechoso',
        'descripcion':
            'Cuéntanos si un anfitrión o arrendatario se comportó de forma inadecuada.',
        'body': 'Hola, quiero reportar comportamiento sospechoso...'
      },
      {
        'titulo': 'Alguien me pidió pagar fuera de la app',
        'descripcion':
            'Nunca realices pagos por fuera de Pool&Chill. Repórtalo aquí.',
        'body': 'Hola, alguien me pidió pagar fuera de la app.'
      },
      {
        'titulo': 'Me sentí inseguro en una propiedad',
        'descripcion':
            'Describe lo ocurrido para ayudarte y tomar medidas.',
        'body':
            'Hola, me sentí inseguro en una propiedad. Esto fue lo que pasó:'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        centerTitle: true,
        title: Text(
          'Seguridad y Reportes',
          style: GoogleFonts.poppins(
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
                'Tu seguridad es nuestra prioridad',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Si has tenido una situación sospechosa o incómoda, repórtala de inmediato. Nuestro equipo revisará tu caso de forma confidencial y prioritaria.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              for (final opcion in opciones)
                _opcionReporte(
                  titulo: opcion['titulo']!,
                  descripcion: opcion['descripcion']!,
                  onTap: () => _enviarReporte(opcion['body']!),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primaryColor,
        icon: const Icon(Icons.security_rounded, color: Colors.white),
        label: Text(
          'Contactar al equipo de seguridad',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        onPressed: () => _mostrarModalContacto(context),
      ),
    );
  }

  // ---- UI REUTILIZABLE ----

  Widget _opcionReporte({
    required String titulo,
    required String descripcion,
    required VoidCallback onTap,
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
        title: Text(
          titulo,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            descripcion,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _opcionContacto({
    required IconData icon,
    required Color color,
    required String texto,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.grey.shade100,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              texto,
              style: GoogleFonts.poppins(fontSize: 14.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
