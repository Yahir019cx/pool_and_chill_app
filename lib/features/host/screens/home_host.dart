import 'package:flutter/material.dart';
import 'inicio_host_screen.dart';
import 'mis_espacios_host_screen.dart';
import 'reservas_host_screen.dart';
import 'ganancias_host_screen.dart';
import 'cuenta_host_screen.dart';
import '../widgets/nav_bottom_host.dart';

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
