import 'package:flutter/material.dart';
import 'legal_webview_screen.dart';

/// Pantalla que da acceso a Términos y Aviso de privacidad vía WebView (URLs web).
class TerminosCondicionesScreen extends StatelessWidget {
  const TerminosCondicionesScreen({super.key});

  static const _primaryColor = Color(0xFF3CA2A2);

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'titulo': 'Términos y condiciones',
        'descripcion': 'Consulta los términos de uso del servicio.',
        'icon': Icons.article_outlined,
        'url': LegalUrls.terminos,
      },
      {
        'titulo': 'Aviso de privacidad',
        'descripcion': 'Conoce cómo protegemos y utilizamos tu información.',
        'icon': Icons.lock_outline,
        'url': LegalUrls.privacidad,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        centerTitle: true,
        title: const Text(
          'Términos y privacidad',
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
              const Text(
                'Documentos legales',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Consulta los documentos oficiales en nuestra web.',
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
                  url: item['url'] as String,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _documentoItem(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required String descripcion,
    required String url,
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
          style: const TextStyle(
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LegalWebViewScreen(
                url: url,
                title: titulo,
              ),
            ),
          );
        },
      ),
    );
  }
}
