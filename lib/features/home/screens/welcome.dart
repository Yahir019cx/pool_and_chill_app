import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/data/providers/favorites_provider.dart';
import 'package:pool_and_chill_app/data/providers/rentas_provider.dart';
import '../widgets/nav_bottom.dart';
import 'inicio_screen.dart';
import 'rentas_screen.dart';
import 'favoritos_screen.dart';
import 'perfil_screen.dart';
import '../../properties/screens/publish.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int selectedNavIndex = 0;

  void _onNavTap(int i) {
    setState(() => selectedNavIndex = i);

    final auth = provider_pkg.Provider.of<AuthProvider>(context, listen: false);
    final container = ProviderScope.containerOf(context);

    // Al entrar al tab de Rentas (índice 1), recargar siempre.
    if (i == 1 && auth.isAuthenticated) {
      container.read(rentasProvider.notifier).load();
    }

    // Al entrar al tab de Favoritos (índice 2), recargar la lista.
    if (i == 2 && auth.isAuthenticated) {
      container.read(favoritesProvider.notifier).loadFavorites();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: false,
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFab(context),
      bottomNavigationBar: NavBottom(
        selectedIndex: selectedNavIndex,
        onNavTap: _onNavTap,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: selectedNavIndex,
          children: [
            const InicioScreen(),
            const RentasScreen(),
            const FavoritosScreen(),
            PerfilScreen(onNavigateToTab: _onNavTap),
          ],
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PublishScreen()),
        );
      },
      child: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, size: 32, color: Color(0xFF3CA2A2)),
      ),
    );
  }
}
