import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_and_chill_app/data/providers/host_reservas_provider.dart';
import 'screens/inicio_host_screen.dart';
import 'screens/mis_espacios_host_screen.dart';
import 'screens/reservas_host_screen.dart';
import 'screens/cuenta_host_screen.dart';
import 'widgets/nav_bottom_host.dart';

class HomeHostScreen extends ConsumerStatefulWidget {
  const HomeHostScreen({super.key});

  @override
  ConsumerState<HomeHostScreen> createState() => _HomeHostScreenState();
}

class _HomeHostScreenState extends ConsumerState<HomeHostScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    InicioHostScreen(),
    MisEspaciosHostScreen(),
    ReservasHostScreen(),
    CuentaHostScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Recargar reservas del host al entrar al tab de Inicio (índice 0).
    if (index == 0) {
      ref.read(hostReservasProvider.notifier).load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavAnfitrion(
        selectedIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
