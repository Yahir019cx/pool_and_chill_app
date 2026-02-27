import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/core/widgets/top_chip.dart';
import 'package:pool_and_chill_app/data/providers/favorites_provider.dart';
import 'package:pool_and_chill_app/features/properties/Screens/property_detail_screen.dart';
import '../widgets/card_espacio.dart';

class FavoritosScreen extends ConsumerStatefulWidget {
  const FavoritosScreen({super.key});

  @override
  ConsumerState<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends ConsumerState<FavoritosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth =
          provider_pkg.Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAuthenticated) {
        ref.read(favoritesProvider.notifier).loadFavorites();
      }
    });
  }

  void _onFavoriteToggle(String propertyId) async {
    final ok = await ref.read(favoritesProvider.notifier).toggleFavorite(propertyId);
    if (!ok && mounted) {
      TopChip.showError(
        context,
        ref.read(favoritesProvider).error ?? 'No se pudo actualizar el favorito',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = provider_pkg.Provider.of<AuthProvider>(context);
    final favState = ref.watch(favoritesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Text(
            'Favoritos',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _buildContent(auth, favState),
        ),
      ],
    );
  }

  Widget _buildContent(AuthProvider auth, FavoritesState favState) {
    // Usuario no logueado.
    if (!auth.isAuthenticated) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.login, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Inicia sesión para ver tus favoritos',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Cargando.
    if (favState.isLoadingList) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3CA2A2),
        ),
      );
    }

    // Error.
    if (favState.error != null && favState.favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'Ocurrió un error al cargar tus favoritos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    ref.read(favoritesProvider.notifier).loadFavorites(),
                child: const Text(
                  'Reintentar',
                  style: TextStyle(color: Color(0xFF3CA2A2)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Vacío.
    if (favState.favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border,
                  size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Aún no tienes favoritos',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Guarda los espacios que más te gusten para encontrarlos fácilmente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Lista de favoritos.
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: favState.favorites.length,
      itemBuilder: (_, index) {
        final property = favState.favorites[index];
        return EspacioCard(
          property: property,
          isFavorite: favState.isFavorite(property.propertyId),
          onFavoriteToggle: _onFavoriteToggle,
          onTap: (id) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PropertyDetailScreen(propertyId: id),
              ),
            );
          },
        );
      },
    );
  }
}
