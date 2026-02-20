import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/features/auth/screens/login_screen.dart';
import 'package:pool_and_chill_app/features/auth/widgets/forgot_password_modal.dart';

class SeguridadScreen extends StatelessWidget {
  const SeguridadScreen({super.key});

  static const _primary = Color(0xFF3CA2A2);
  static const _supportEmail = 'team@poolandchill.com.mx';
  static const _whatsappPhone = '524493629233';

  Future<void> _launchEmail({String subject = '', String body = ''}) async {
    final query = [
      if (subject.isNotEmpty) 'subject=${Uri.encodeComponent(subject)}',
      if (body.isNotEmpty) 'body=${Uri.encodeComponent(body)}',
    ].join('&');

    final uri = Uri.parse('mailto:$_supportEmail${query.isNotEmpty ? '?$query' : ''}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // El dispositivo no tiene app de correo configurada
    }
  }

  Future<void> _launchWhatsApp(String message) async {
    final uri = Uri.parse(
      'https://wa.me/$_whatsappPhone?text=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _confirmarCerrarTodas(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cerrar todas las sesiones',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: const Text(
          '¿Seguro que quieres cerrar sesión en todos los dispositivos donde está activa tu cuenta?',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Cerrar sesión',
              style: TextStyle(
                  color: Colors.red.shade400, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    }
  }

  void _mostrarModalContacto(
      BuildContext context, String userName, String userEmail) {
    final emailBody =
        'Hola equipo de Pool&Chill,\n\nNecesito reportar un problema de seguridad.\n\n'
        'Nombre: $userName\n'
        'Correo de cuenta: $userEmail\n\n'
        '[Describe aquí lo ocurrido]\n\nGracias.';

    final whatsAppMsg =
        'Hola! Soy $userName ($userEmail) y necesito reportar un problema de seguridad en Pool&Chill.';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Contactar soporte',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
            const SizedBox(height: 4),
            Text(
              'Elige cómo prefieres comunicarte con nosotros.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 20),
            _contactTile(
              icon: Icons.email_outlined,
              iconColor: _primary,
              title: 'Correo electrónico',
              subtitle: _supportEmail,
              onTap: () async {
                Navigator.pop(sheetCtx);
                await _launchEmail(
                  subject: 'Reporte de seguridad – Pool&Chill',
                  body: emailBody,
                );
              },
            ),
            const SizedBox(height: 10),
            _contactTile(
              icon: FontAwesomeIcons.whatsapp,
              iconColor: const Color(0xFF25D366),
              title: 'WhatsApp',
              subtitle: 'Respuesta rápida · disponible 9–18 h',
              onTap: () async {
                Navigator.pop(sheetCtx);
                await _launchWhatsApp(whatsAppMsg);
              },
            ),
            const SizedBox(height: 8),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Seguridad',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          // ── Cuenta ───────────────────────────────────────────────────────
          _sectionLabel('Cuenta'),
          _card(children: [
            _actionRow(
              icon: Icons.lock_reset_rounded,
              title: 'Cambiar contraseña',
              subtitle: 'Te enviaremos un correo para restablecerla',
              onTap: () => ForgotPasswordModal.show(context),
            ),
            _divider(),
            _actionRow(
              icon: Icons.devices_rounded,
              title: 'Cerrar sesión en todos los dispositivos',
              subtitle: 'Sal de la app en todos tus equipos',
              titleColor: Colors.red.shade400,
              iconColor: Colors.red.shade400,
              iconBg: Colors.red.shade50,
              onTap: () => _confirmarCerrarTodas(context),
            ),
          ]),

          // ── Reportar un problema ─────────────────────────────────────────
          _sectionLabel('Reportar un problema'),
          _card(children: [
            _infoRow(
              icon: Icons.person_off_outlined,
              title: 'Comportamiento sospechoso',
              subtitle:
                  'Si un anfitrión o arrendatario se comportó de forma inadecuada, contáctanos.',
            ),
            _divider(),
            _infoRow(
              icon: Icons.money_off_rounded,
              title: 'Me pidieron pagar fuera de la app',
              subtitle:
                  'Nunca realices pagos externos a Pool&Chill. Repórtalo a través de contacto directo.',
            ),
            _divider(),
            _infoRow(
              icon: Icons.shield_outlined,
              title: 'Me sentí inseguro en una propiedad',
              subtitle:
                  'Tu seguridad es lo primero. Cuéntanos lo ocurrido para que podamos ayudarte.',
            ),
          ]),

          // ── Contacto directo ─────────────────────────────────────────────
          _sectionLabel('Contacto directo'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: () => _mostrarModalContacto(context, userName, userEmail),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _primary.withValues(alpha: 0.25)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F6F5),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Icon(Icons.headset_mic_rounded,
                            color: _primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Equipo de seguridad',
                              style: TextStyle(
                                color: Color(0xFF1A1A2E),
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Correo · WhatsApp',
                              style: TextStyle(
                                color: _primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: Colors.grey.shade400, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // Fila tappable (para Cuenta)
  Widget _actionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
    Color? iconBg,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg ?? const Color(0xFFE8F6F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: iconColor ?? _primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded,
                    size: 20, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  // Fila descriptiva (para Reportes — sin onTap)
  Widget _infoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: Colors.grey.shade500),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
        height: 1, indent: 72, endIndent: 16, color: Colors.grey.shade100);
  }

  Widget _contactTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
