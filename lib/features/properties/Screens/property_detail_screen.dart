import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:share_plus/share_plus.dart';

import 'package:pool_and_chill_app/data/models/property/index.dart';
import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/data/providers/favorites_provider.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  ConsumerState<PropertyDetailScreen> createState() =>
      _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  static const Color primary = Color(0xFF3CA2A2);
  late final PageController _carouselController;
  Timer? _carouselTimer;
  int _carouselIndex = 0;

  @override
  void initState() {
    super.initState();
    _carouselController = PageController();
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _carouselController.dispose();
    super.dispose();
  }

  void _startCarouselTimer(int length) {
    if (length <= 1) return;
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_carouselController.hasClients) return;
      final next = (_carouselIndex + 1) % length;
      _carouselController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _onShare(String propertyName) async {
    try {
      await Share.share(
        '$propertyName - Pool & Chill\nhttps://poolandchill.app',
        subject: propertyName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo compartir')),
        );
      }
    }
  }

  void _onFavoriteTap(String propertyId) {
    final auth =
        provider_pkg.Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inicia sesión para guardar favoritos'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    ref.read(favoritesProvider.notifier).toggleFavorite(propertyId);
  }

  @override
  Widget build(BuildContext context) {
    final asyncDetail = ref.watch(propertyDetailProvider(widget.propertyId));

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: asyncDetail.when(
          data: (data) => _buildContent(data),
          loading: () => const Center(
            child: CircularProgressIndicator(color: primary),
          ),
          error: (err, _) => _buildError(err),
        ),
      ),
    );
  }

  Widget _buildError(Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No se pudo cargar la propiedad',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              err.toString(),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () =>
                  ref.invalidate(propertyDetailProvider(widget.propertyId)),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Reintentar'),
              style: TextButton.styleFrom(foregroundColor: primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(PropertyDetailResponse data) {
    final prop = data.property;
    final images = data.sortedImages;
    final favState = ref.watch(favoritesProvider);
    final isFavorite = favState.isFavorite(prop.idProperty);

    if (images.isNotEmpty && _carouselTimer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startCarouselTimer(images.length);
      });
    }

    final maxPersonas = data.maxCapacityOverall;
    final banos = data.totalBathrooms;
    final habitaciones = data.totalBedrooms;

    final padding = MediaQuery.of(context).padding;

    return CustomScrollView(
      slivers: [
        // Hero: carousel + overlay buttons
        SliverToBoxAdapter(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                height: 320,
                width: double.infinity,
                child: images.isEmpty
                    ? Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 64,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : PageView.builder(
                        controller: _carouselController,
                        itemCount: images.length,
                        onPageChanged: (i) {
                          setState(() => _carouselIndex = i);
                          _startCarouselTimer(images.length);
                        },
                        itemBuilder: (_, i) {
                          return CachedNetworkImage(
                            imageUrl: images[i].imageURL,
                            fit: BoxFit.cover,
                            memCacheWidth: 800,
                            placeholder: (_, __) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.image, color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Positioned(
                top: 12,
                left: 16 + padding.left,
                child: _CircleButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              Positioned(
                top: 12,
                right: 16 + padding.right,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CircleButton(
                      icon: Icons.share_outlined,
                      onTap: () => _onShare(prop.propertyName),
                    ),
                    const SizedBox(width: 12),
                    _CircleButton(
                      icon:
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                      iconColor: isFavorite ? Colors.red : null,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _onFavoriteTap(prop.idProperty);
                      },
                    ),
                  ],
                ),
              ),
              if (images.length > 1)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _carouselIndex == i ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _carouselIndex == i
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Card superpuesta: nombre, tipo (sin icono), descripción, datos clave
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20 + padding.left,
              0,
              20 + padding.right,
              0,
            ),
            child: Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      prop.propertyName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Tipo plano (solo texto, sin icono)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        if (prop.hasCabin)
                          _TypeChipPlain(label: 'Cabaña'),
                        if (prop.hasPool)
                          _TypeChipPlain(label: 'Alberca'),
                        if (prop.hasCamping)
                          _TypeChipPlain(label: 'Camping'),
                      ],
                    ),
                    if (prop.description != null &&
                        prop.description!.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Text(
                        prop.description!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.55,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Datos clave: personas, baños, habitaciones (siempre visibles)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _KeyDataChip(
                          icon: Icons.people_outlined,
                          label: maxPersonas != null
                              ? '$maxPersonas huéspedes'
                              : '—',
                        ),
                        const SizedBox(width: 28),
                        _KeyDataChip(
                          icon: Icons.bathroom_outlined,
                          label: (banos != null && banos > 0)
                              ? '$banos baños'
                              : '—',
                        ),
                        const SizedBox(width: 28),
                        _KeyDataChip(
                          icon: Icons.bed_outlined,
                          label: (habitaciones != null && habitaciones > 0)
                              ? '$habitaciones hab.'
                              : '—',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20 + padding.left,
              32,
              20 + padding.right,
              24 + padding.bottom,
            ),
            child: Column(
              children: [
                // Amenidades en chips con iconos
                if (data.allAmenities.isNotEmpty) ...[
                  _SectionCard(
                    title: 'Amenidades',
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: data.allAmenities.map((a) {
                        return _AmenityChip(
                          label: a.amenityName ?? a.amenityCode ?? '',
                          icon: _iconForAmenity(a.amenityCode),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // Reglas
                if (data.rules.isNotEmpty) ...[
                  _SectionCard(
                    title: 'Reglas de la propiedad',
                    child: Column(
                      children: (List<PropertyRule>.from(data.rules)
                            ..sort((a, b) =>
                                a.displayOrder.compareTo(b.displayOrder)))
                          .map((r) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '• ',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        r.ruleText,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // Mapa
                if (prop.location != null && prop.location!.hasCoordinates) ...[
                  _SectionCard(
                    title: 'Ubicación',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        height: 220,
                        width: double.infinity,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              prop.location!.latitude!,
                              prop.location!.longitude!,
                            ),
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('property'),
                              position: LatLng(
                                prop.location!.latitude!,
                                prop.location!.longitude!,
                              ),
                            ),
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reservar — Próximamente'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Reservar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static IconData _iconForAmenity(String? code) {
    if (code == null) return Icons.check_circle_outline;
    final c = code.toLowerCase();
    if (c.contains('wifi')) return Icons.wifi;
    if (c.contains('pool') || c.contains('alberca')) return Icons.pool;
    if (c.contains('parking') || c.contains('estacionamiento'))
      return Icons.local_parking;
    if (c.contains('aire') || c.contains('ac')) return Icons.ac_unit;
    if (c.contains('tv')) return Icons.tv;
    if (c.contains('cocina')) return Icons.kitchen;
    if (c.contains('bbq') || c.contains('asador')) return Icons.outdoor_grill;
    if (c.contains('jardin') || c.contains('garden')) return Icons.yard;
    if (c.contains('seguridad')) return Icons.security;
    if (c.contains('mascota') || c.contains('pet')) return Icons.pets;
    return Icons.check_circle_outline;
  }
}

/// Botón circular con área de toque mínima 48dp (Android) / 44pt (iOS).
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  static const double _minTouchTarget = 48;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_minTouchTarget / 2),
        child: Container(
          width: _minTouchTarget,
          height: _minTouchTarget,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor ?? Colors.white, size: 24),
        ),
      ),
    );
  }
}

class _TypeChipPlain extends StatelessWidget {
  final String label;

  const _TypeChipPlain({required this.label});

  static const Color primary = Color(0xFF3CA2A2);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D9D91),
        ),
      ),
    );
  }
}

class _KeyDataChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _KeyDataChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

const Color primary = Color(0xFF3CA2A2);

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

/// Chip con área de toque adecuada para accesibilidad.
class _AmenityChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _AmenityChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: primary),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D9D91),
            ),
          ),
        ],
      ),
    );
  }
}
