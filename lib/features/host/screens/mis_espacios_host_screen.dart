import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/features/properties/Screens/Publish.dart';
import '../widgets/card_espacio_host.dart';
import 'host_property_detail_screen.dart';
import 'host_property_edit_screen.dart';

class MisEspaciosHostScreen extends StatelessWidget {
  const MisEspaciosHostScreen({super.key});

  static const Color primary = Color(0xFF2D9D91);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    // Solo mostrar propiedades activas (status 3) y pausadas (status 4)
    final properties = authProvider.myProperties.where((p) {
      final id = p.status.id;
      if (id != null) return id == 3 || id == 4;
      final code = p.status.code.toUpperCase();
      return code == 'ACTIVE' || code == 'PAUSED';
    }).toList();
    final isLoading = authProvider.isLoadingProperties;
    final activos = properties.where((p) => p.isActive).length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Mis espacios',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PublishScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded, color: Colors.white, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Agregar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${properties.length} espacios',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$activos activos',
                    style: const TextStyle(
                      fontSize: 13,
                      color: primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de espacios
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primary),
                    )
                  : properties.isEmpty
                      ? _buildEmptyState(context)
                      : RefreshIndicator(
                          color: primary,
                          onRefresh: () => authProvider.fetchMyProperties(),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                            itemCount: properties.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final property = properties[index];
                              return EspacioHostCard(
                                nombre: property.title,
                                ubicacion: property.locationDisplay,
                                precioPorDia: property.priceFrom,
                                rating: property.rating,
                                totalReservas: property.totalReservations,
                                isActivo: property.isActive,
                                fotos: property.imageUrls,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HostPropertyDetailScreen(
                                        propertyId: property.id,
                                        initialIsActive: property.isActive,
                                      ),
                                    ),
                                  ).then((_) => authProvider.fetchMyProperties());
                                },
                                onEdit: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HostPropertyEditScreen(
                                        propertyId: property.id,
                                      ),
                                    ),
                                  ).then((_) => authProvider.fetchMyProperties());
                                },
                                onToggleStatus: (_) {
                                  // El toggle de status se maneja desde HostPropertyDetailScreen
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.villa_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Aún no tienes espacios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Publica tu primer espacio y comienza a recibir reservas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PublishScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              child: const Text(
                'Agregar espacio',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
