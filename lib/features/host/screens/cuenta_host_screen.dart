import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'package:pool_and_chill_app/features/home/screens/perfil/editar_perfil.dart';
import 'package:pool_and_chill_app/features/home/screens/perfil/seguridad_screen.dart';
import 'package:pool_and_chill_app/features/home/screens/perfil/delete_account.dart';
// import 'package:pool_and_chill_app/features/home/screens/perfil/notificaciones_screen.dart';
import 'package:pool_and_chill_app/features/home/screens/perfil/legal_webview_screen.dart';
import 'package:pool_and_chill_app/features/host/screens/ayuda_host_screen.dart';
import 'package:pool_and_chill_app/features/host/screens/stripe_update_webview_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CuentaHostScreen extends ConsumerStatefulWidget {
  const CuentaHostScreen({super.key});

  @override
  ConsumerState<CuentaHostScreen> createState() => _CuentaHostScreenState();
}

class _CuentaHostScreenState extends ConsumerState<CuentaHostScreen> {
  static const Color primary = Color(0xFF2D9D91);
  static const _supportEmail = 'team@poolandchill.com.mx';
  static const _whatsappPhone = '524493629233';
  bool _loadingStripe = false;

  void _showReportSheet(BuildContext context, AuthProvider auth) {
    final profile = auth.profile;
    final userName = profile?.displayName ??
        '${profile?.firstName ?? ''} ${profile?.lastName ?? ''}'.trim();
    final userEmail = profile?.email ?? '';

    final emailBody = 'Hola equipo de Pool&Chill,\n\n'
        'Quiero reportar un problema.\n\n'
        'Nombre: $userName\n'
        'Correo de cuenta: $userEmail\n\n'
        '[Describe aquí el problema]\n\nGracias.';

    final whatsAppMsg =
        'Hola! Soy $userName ($userEmail) y quiero reportar un problema en Pool&Chill.';

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
            _reportTile(
              icon: Icons.email_outlined,
              color: primary,
              label: 'Correo electrónico',
              subtitle: _supportEmail,
              onTap: () async {
                Navigator.pop(sheetCtx);
                final query = [
                  'subject=${Uri.encodeComponent('Reporte de problema – Pool&Chill')}',
                  'body=${Uri.encodeComponent(emailBody)}',
                ].join('&');
                final uri = Uri.parse('mailto:$_supportEmail?$query');
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (_) {}
              },
            ),
            const SizedBox(height: 12),
            _reportTile(
              icon: FontAwesomeIcons.whatsapp,
              color: const Color(0xFF25D366),
              label: 'WhatsApp',
              subtitle: 'Respuesta rápida · disponible 9–18 h',
              onTap: () async {
                Navigator.pop(sheetCtx);
                final uri = Uri.parse(
                  'https://wa.me/$_whatsappPhone?text=${Uri.encodeComponent(whatsAppMsg)}',
                );
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (_) {}
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget _reportTile({
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

  void _showTopChip(String msg, {bool success = false}) {
    late OverlayEntry entry;
    final controller = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 300),
    );
    final offset = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(ctx).padding.top + 12,
        left: 0,
        right: 0,
        child: Center(
          child: SlideTransition(
            position: offset,
            child: Material(
              color: Colors.transparent,
              child: Chip(
                avatar: Icon(
                  success ? Icons.check_circle_rounded : Icons.info_outline,
                  size: 18,
                  color: success ? Colors.white : Colors.white70,
                ),
                label: Text(
                  msg,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: success ? primary : Colors.red.shade400,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(entry);
    controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      controller.reverse().then((_) {
        entry.remove();
        controller.dispose();
      });
    });
  }

  Future<void> _openDatosBancarios() async {
    if (_loadingStripe) return;
    setState(() => _loadingStripe = true);

    // Mostrar indicador de carga mientras se obtiene el enlace del backend.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(28),
            child: CircularProgressIndicator(color: primary),
          ),
        ),
      ),
    );

    try {
      final service = ref.read(stripeServiceProvider);
      final url = await service.getAccountUpdateLink();
      if (!mounted) return;

      Navigator.of(context).pop(); // Cerrar diálogo de carga.

      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => StripeUpdateWebviewScreen(url: url),
          fullscreenDialog: true,
        ),
      );

      if (!mounted) return;

      if (result == true) {
        _showTopChip('Datos actualizados correctamente', success: true);
      } else if (result == false) {
        _showTopChip('El enlace expiró; intenta de nuevo');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Cerrar diálogo de carga.
      final message = e.toString().replaceFirst('Exception: ', '');
      _showTopChip(message);
    } finally {
      if (mounted) setState(() => _loadingStripe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthProvider>().profile;
    final displayName = profile?.displayName ?? 'Anfitrión';
    final imageUrl = profile?.profileImageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final isVerified = profile?.isIdentityVerified == true; 
    final bio = profile?.bio;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Perfil
              Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: primary.withValues(alpha: 0.1),
                    backgroundImage: hasImage
                        ? NetworkImage(imageUrl)
                        : null,
                    child: !hasImage
                        ? (profile?.initials.isNotEmpty == true
                            ? Text(
                                profile!.initials,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                ),
                              )
                            : const Icon(
                                Icons.person_rounded,
                                color: primary,
                                size: 45,
                              ))
                        : null,
                  ),
                  if (isVerified)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified,
                          color: primary,
                          size: 22,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (bio != null && bio.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  bio,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Opciones
              _MenuSection(
                title: 'Cuenta',
                items: [
                  _MenuItem(
                    icon: Icons.person_outline,
                    label: 'Editar perfil',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditarPerfil(),
                        ),
                      );
                    },
                  ),
                  _MenuItem(
                    icon: Icons.account_balance_outlined,
                    label: 'Datos bancarios',
                    onTap: _openDatosBancarios,
                  ),
                  // _MenuItem(
                  //   icon: Icons.notifications_outlined,
                  //   label: 'Notificaciones',
                  //   onTap: () => Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (_) => const NotificacionesScreen(),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 24),
              _MenuSection(
                title: 'Configuración',
                items: [
                  _MenuItem(
                    icon: Icons.lock_outline,
                    label: 'Seguridad',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SeguridadScreen(),
                      ),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.help_outline,
                    label: 'Centro de ayuda',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AyudaHostScreen()),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.report_problem_outlined,
                    label: 'Reportar un problema',
                    onTap: () => _showReportSheet(context, context.read<AuthProvider>()),
                  ),
                  _MenuItem(
                    icon: Icons.article_outlined,
                    label: 'Términos y condiciones',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LegalWebViewScreen(
                          url: LegalUrls.terminos,
                          title: 'Términos y condiciones',
                        ),
                      ),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.lock_outline,
                    label: 'Aviso de privacidad',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LegalWebViewScreen(
                          url: LegalUrls.privacidad,
                          title: 'Aviso de privacidad',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _MenuSection(
                title: 'Acciones',
                items: [
                  _MenuItem(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Cambiar a modo huésped',
                    onTap: () {
                      // Activa el modo huésped en AuthProvider para que AuthGate
                      // muestre WelcomeScreen sin cerrar sesión ni eliminar AuthGate
                      // del árbol (lo que rompería el logout y otros flujos).
                      context.read<AuthProvider>().switchToGuestMode();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    showBadge: true,
                  ),
                  _MenuItem(
                    icon: Icons.logout_rounded,
                    label: 'Cerrar sesión',
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Cerrar sesión'),
                          content: const Text(
                            '¿Seguro que deseas cerrar sesión?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey,
                              ),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: primary,
                              ),
                              child: const Text('Cerrar sesión'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                      }
                    },
                    isDestructive: true,
                  ),
                  _MenuItem(
                    icon: Icons.person_off_rounded,
                    label: 'Eliminar cuenta',
                    isDestructive: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DeleteAccountScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: Colors.grey.shade200,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showBadge;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.showBadge = false,
  });

  static const Color primary = Color(0xFF2D9D91);

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red.shade400 : Colors.grey.shade700;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withValues(alpha: 0.1)
                    : primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red.shade400 : primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            if (showBadge)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Nuevo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
