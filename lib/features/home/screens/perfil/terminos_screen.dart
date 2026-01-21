import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        'contenido': _terminosServicio,
      },
      {
        'titulo': 'Política de privacidad',
        'descripcion':
            'Conoce cómo protegemos y utilizamos tu información personal.',
        'icon': Icons.lock_outline,
        'contenido': _politicaPrivacidad,
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
                'Comprometidos con tu confianza',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Consulta nuestros documentos legales de forma clara y transparente.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
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
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            descripcion,
            style: GoogleFonts.poppins(
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
                          style: GoogleFonts.poppins(
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
                  style: GoogleFonts.poppins(
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
  static const String _terminosServicio = '''
Bienvenido a Pool&Chill.

Al utilizar nuestra aplicación aceptas cumplir con estos términos:
• Usar la plataforma de forma legal.
• No realizar pagos fuera de la app.
• Respetar a anfitriones y usuarios.
• Cumplir con horarios y reglas del espacio.

Pool&Chill se reserva el derecho de suspender cuentas que incumplan estas normas.
''';

  static const String _politicaPrivacidad = '''
En Pool&Chill protegemos tu información personal.

Recopilamos datos únicamente para:
• Gestionar reservas.
• Mejorar la experiencia del usuario.
• Garantizar seguridad y soporte.

Nunca compartimos tu información con terceros sin tu consentimiento.
''';
}
