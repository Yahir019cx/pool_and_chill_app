import 'package:flutter/material.dart';
import 'screens/inicio_host_screen.dart';
import 'screens/mis_espacios_host_screen.dart';
import 'screens/reservas_host_screen.dart';
import 'screens/ganancias_host_screen.dart';
import 'screens/cuenta_host_screen.dart';
import 'widgets/nav_bottom_host.dart';

class HomeHostScreen extends StatefulWidget {
  const HomeHostScreen({super.key});

  @override
  State<HomeHostScreen> createState() => _HomeHostScreenState();
}

class _HomeHostScreenState extends State<HomeHostScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    InicioHostScreen(),
    MisEspaciosHostScreen(),
    ReservasHostScreen(),
    GananciasHostScreen(),
    CuentaHostScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
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
