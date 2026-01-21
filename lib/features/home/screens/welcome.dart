import 'package:flutter/material.dart';
import '../widgets/nav_bottom.dart';
import 'inicio_screen.dart';
import 'rentas_screen.dart';
import 'favoritos_screen.dart';
import 'perfil_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFab(),
      bottomNavigationBar: NavBottom(
        selectedIndex: selectedNavIndex,
        onNavTap: (i) => setState(() => selectedNavIndex = i),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: selectedNavIndex,
          children: const [
            InicioScreen(),
            RentasScreen(),
            FavoritosScreen(),
            PerfilScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return Container(
      height: 64,
      width: 64,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: const Icon(
        Icons.add,
        size: 32,
        color: Color(0xFF3CA2A2),
      ),
    );
  }
}
