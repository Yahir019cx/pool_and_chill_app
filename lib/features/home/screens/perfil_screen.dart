import 'package:flutter/material.dart';
import 'perfil/ayuda_screen.dart';
import 'perfil/mis_reservas_screen.dart';
import 'perfil/terminos_screen.dart';
import 'perfil/editar_perfil.dart';
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TÍTULO
              Text(
                'Mi perfil',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              /// CARD PERFIL
              _PerfilCard(),

              const SizedBox(height: 30),

              /// OPCIONES
              _PerfilItem(
                icon: Icons.person_outline,
                title: 'Modificar mis datos',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditarPerfil()),
                ),
              ),
              _PerfilItem(
                icon: Icons.calendar_month_outlined,
                title: 'Mis reservas',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MisReservasScreen()),
                ),
              ),
              _PerfilItem(
                icon: Icons.description_outlined,
                title: 'Términos y condiciones',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TerminosCondicionesScreen()),
                ),
              ),
              _PerfilItem(
                icon: Icons.help_outline,
                title: 'Ayuda',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AyudaScreen()),
                ),
              ),
              _PerfilItem(
                icon: Icons.logout,
                title: 'Cerrar sesión',
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PerfilCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(20, 60, 162, 162),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 42,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Nombre Apellido',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _PerfilStat(label: 'Reservas', value: '12'),
              _PerfilStat(label: 'Calificación', value: '4.8'),
            ],
          )
        ],
      ),
    );
  }
}

class _PerfilItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _PerfilItem({
    required this.icon,
    required this.title,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : Colors.black;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(color: color),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _PerfilStat extends StatelessWidget {
  final String label;
  final String value;

  const _PerfilStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
