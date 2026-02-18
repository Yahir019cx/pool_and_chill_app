import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/features/host/screens/welcome_host.dart';
import 'package:pool_and_chill_app/features/host/screens/pending_approval_screen.dart';
import 'package:pool_and_chill_app/features/host/home_host.dart';
import 'package:pool_and_chill_app/features/properties/Screens/Publish.dart';
import 'perfil/ayuda_screen.dart';
import 'perfil/mis_reservas_screen.dart';
import 'perfil/terminos_screen.dart';
import 'perfil/editar_perfil.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  static const Color primary = Color(0xFF2D9D91);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;

    final displayName = profile?.displayName ?? '';
    final bio = profile?.bio ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Avatar
              CircleAvatar(
                radius: 45,
                backgroundColor: primary.withValues(alpha: 0.1),
                backgroundImage: profile?.profileImageUrl != null &&
                        profile!.profileImageUrl!.isNotEmpty
                    ? NetworkImage(profile.profileImageUrl!)
                    : null,
                child: profile?.profileImageUrl == null ||
                        profile!.profileImageUrl!.isEmpty
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
              const SizedBox(height: 16),

              // Display name
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),

              // Bio
              Text(
                bio.isNotEmpty
                    ? bio
                    : 'Aquí se mostrará tu biografía',
                style: TextStyle(
                  fontSize: 13,
                  color: bio.isNotEmpty
                      ? Colors.grey.shade600
                      : Colors.grey.shade400,
                  fontStyle:
                      bio.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                ),
              ),
              const SizedBox(height: 6),

              // Stats
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatItem(value: '12', label: 'Reservas'),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.shade200,
                    ),
                    _StatItem(value: '4.8', label: 'Calificación'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Cuenta
              _MenuSection(
                title: 'Cuenta',
                items: [
                  _MenuItem(
                    icon: Icons.person_outline,
                    label: 'Modificar mis datos',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditarPerfil()),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.calendar_month_outlined,
                    label: 'Mis reservas',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MisReservasScreen(),
                      ),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.favorite_outline,
                    label: 'Favoritos',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Configuración
              _MenuSection(
                title: 'Configuración',
                items: [
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notificaciones',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.lock_outline,
                    label: 'Seguridad',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Soporte
              _MenuSection(
                title: 'Soporte',
                items: [
                  _MenuItem(
                    icon: Icons.help_outline,
                    label: 'Ayuda',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AyudaScreen()),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.description_outlined,
                    label: 'Términos y condiciones',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TerminosCondicionesScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Acciones
              _MenuSection(
                title: '',
                items: [
                  _MenuItem(
                    icon: Icons.swap_horiz_rounded,
                    label: profile?.isHost == true
                        ? 'Panel de anfitrión'
                        : 'Cambiar a modo anfitrión',
                    onTap: () {
                      if (profile == null) return;

                      // Host con onboarding completo → Dashboard
                      if (profile.isHost && profile.isHostOnboarded == 2) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomeHostScreen(),
                          ),
                        );
                        return;
                      }

                      // Host en onboarding → Bienvenida host
                      if (profile.isHost && profile.isHostOnboarded == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WelcomeAnfitrionScreen(),
                          ),
                        );
                        return;
                      }

                      // Propiedad enviada pero aún no aprobada (guest + isHostOnboarded=0)
                      if (!profile.isHost && profile.isHostOnboarded == 0 && profile.roles.contains('guest')) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PendingApprovalScreen(),
                          ),
                        );
                        return;
                      }

                      // No es host → Publicar primera propiedad
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PublishScreen(),
                        ),
                      );
                    },
                    showBadge: profile?.isHost != true,
                  ),
                  _MenuItem(
                    icon: Icons.logout_rounded,
                    label: 'Cerrar sesión',
                    isDestructive: true,
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
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

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
                    Divider(height: 1, indent: 56, color: Colors.grey.shade200),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
          ],
        ),
      ),
    );
  }
}
