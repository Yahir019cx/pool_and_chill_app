import 'dart:async';
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

import 'widget_details/detail_constants.dart';
import 'widget_details/detail_image_carousel.dart';
import 'widget_details/detail_specs_section.dart';
import 'widget_details/detail_check_times.dart';
import 'widget_details/detail_amenities_section.dart';
import 'widget_details/detail_rules_section.dart';
import 'widget_details/detail_favorite_toast.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  ConsumerState<PropertyDetailScreen> createState() =>
      _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
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

  void _onFavoriteTap(String propertyId, bool currentlyFavorite) {
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
    _showFavoriteOverlay(!currentlyFavorite);
  }

  void _showFavoriteOverlay(bool added) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => DetailFavoriteToast(
        added: added,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final asyncDetail = ref.watch(propertyDetailProvider(widget.propertyId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: asyncDetail.when(
        data: (data) => _buildContent(data),
        loading: () => const Center(
          child: CircularProgressIndicator(color: kDetailPrimary),
        ),
        error: (err, _) => _buildError(err),
      ),
    );
  }

  Widget _buildError(Object err) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'No se pudo cargar la propiedad',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kDetailDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                err.toString(),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: kDetailGrey),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () =>
                    ref.invalidate(propertyDetailProvider(widget.propertyId)),
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Reintentar'),
                style: TextButton.styleFrom(foregroundColor: kDetailPrimary),
              ),
            ],
          ),
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

    final priceRange = data.priceRange;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    // Build specs
    final allSpecs = _collectSpecs(data);
    // Build check times
    final checkTimes = _collectCheckTimes(data);

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // ─── Image Carousel ──────────────────────────────
            SliverToBoxAdapter(
              child: DetailImageCarousel(
                images: images,
                controller: _carouselController,
                currentIndex: _carouselIndex,
                overlayButtons: Stack(
                  children: [
                    Positioned(
                      top: topPadding + 8,
                      left: 16,
                      child: DetailActionButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Positioned(
                      top: topPadding + 8,
                      right: 16,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DetailActionButton(
                            icon: Icons.share_outlined,
                            onTap: () => _onShare(prop.propertyName),
                          ),
                          const SizedBox(width: 10),
                          DetailActionButton(
                            icon: isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            iconColor:
                                isFavorite ? Colors.redAccent : null,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _onFavoriteTap(prop.idProperty, isFavorite);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Body ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Name
                    Text(
                      prop.propertyName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: kDetailDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Type labels
                    _buildTypeLabels(prop),
                    const SizedBox(height: 14),
                    // Description
                    if (prop.description != null &&
                        prop.description!.isNotEmpty) ...[
                      Text(
                        prop.description!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.5,
                          color: kDetailGrey,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    _divider(),

                    // ─── Servicios ────────────────────────────
                    if (allSpecs.isNotEmpty) ...[
                      _sectionTitle('Servicios'),
                      const SizedBox(height: 16),
                      DetailSpecsSection(specs: allSpecs),
                      const SizedBox(height: 20),
                    ],

                    // ─── Check-in / Check-out ─────────────────
                    if (checkTimes.isNotEmpty) ...[
                      _divider(),
                      DetailCheckTimes(items: checkTimes),
                      const SizedBox(height: 20),
                    ],

                    if (allSpecs.isNotEmpty || checkTimes.isNotEmpty)
                      _divider(),

                    // ─── Amenidades ───────────────────────────
                    if (data.allAmenities.isNotEmpty) ...[
                      _sectionTitle('Amenidades'),
                      const SizedBox(height: 14),
                      DetailAmenitiesSection(amenities: data.allAmenities),
                      const SizedBox(height: 24),
                      _divider(),
                    ],

                    // ─── Reglas ───────────────────────────────
                    if (data.rules.isNotEmpty) ...[
                      _sectionTitle('Reglas'),
                      const SizedBox(height: 12),
                      DetailRulesSection(rules: data.rules),
                      const SizedBox(height: 24),
                      _divider(),
                    ],

                    // ─── Ubicación ────────────────────────────
                    if (prop.location != null &&
                        prop.location!.hasCoordinates) ...[
                      _sectionTitle('Ubicación'),
                      const SizedBox(height: 4),
                      Text(
                        prop.location!.formattedAddress ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: kDetailGreyLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 200,
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
                            zoomControlsEnabled: false,
                            scrollGesturesEnabled: false,
                            rotateGesturesEnabled: false,
                            tiltGesturesEnabled: false,
                            myLocationButtonEnabled: false,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    SizedBox(height: 80 + bottomPadding),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ─── Sticky bottom bar ──────────────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                if (priceRange != null) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '\$${formatPrice(priceRange.min)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: kDetailDark,
                                ),
                              ),
                              if (priceRange.min != priceRange.max)
                                TextSpan(
                                  text:
                                      ' - \$${formatPrice(priceRange.max)}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: kDetailGrey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Text(
                          'Sujeto a disponibilidad',
                          style: TextStyle(
                            fontSize: 12,
                            color: kDetailGreyLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else
                  const Spacer(),
                SizedBox(
                  height: 50,
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
                      backgroundColor: kDetailPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
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

  // ─── Helpers ────────────────────────────────────────────────────

  Widget _buildTypeLabels(PropertyDetailProperty prop) {
    final types = <String>[];
    if (prop.hasCabin) types.add('Cabaña');
    if (prop.hasPool) types.add('Alberca');
    if (prop.hasCamping) types.add('Camping');
    if (types.isEmpty) return const SizedBox.shrink();

    return Text(
      types.join(' · '),
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: kDetailPrimary,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: kDetailDark,
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Divider(color: Colors.grey.shade200, height: 1),
    );
  }

  List<SpecItem> _collectSpecs(PropertyDetailResponse data) {
    final specs = <SpecItem>[];
    for (final cabin in data.cabins) {
      if (cabin.maxGuests != null) {
        specs.add(SpecItem(Icons.people_outline, '${cabin.maxGuests}', 'Huéspedes'));
      }
      if (cabin.bedrooms != null && cabin.bedrooms! > 0) {
        specs.add(SpecItem(Icons.door_back_door_outlined, '${cabin.bedrooms}', 'Habitaciones'));
      }
      if (cabin.singleBeds != null && cabin.singleBeds! > 0) {
        specs.add(SpecItem(Icons.single_bed_outlined, '${cabin.singleBeds}', 'C. Individual'));
      }
      if (cabin.doubleBeds != null && cabin.doubleBeds! > 0) {
        specs.add(SpecItem(Icons.king_bed_outlined, '${cabin.doubleBeds}', 'C. Doble'));
      }
      if (cabin.fullBathrooms != null && cabin.fullBathrooms! > 0) {
        specs.add(SpecItem(Icons.bathtub_outlined, '${cabin.fullBathrooms}', 'Baño comp.'));
      }
      if (cabin.halfBathrooms != null && cabin.halfBathrooms! > 0) {
        specs.add(SpecItem(Icons.wash_outlined, '${cabin.halfBathrooms}', 'Medio baño'));
      }
    }
    for (final pool in data.pools) {
      if (pool.maxPersons != null) {
        specs.add(SpecItem(Icons.people_outline, '${pool.maxPersons}', 'Personas'));
      }
      if (pool.temperatureMin != null && pool.temperatureMax != null) {
        specs.add(SpecItem(Icons.thermostat_outlined, '${pool.temperatureMin}°-${pool.temperatureMax}°', 'Temp.'));
      }
      if (pool.minHours != null) {
        specs.add(SpecItem(Icons.timelapse_outlined, '${pool.minHours}h', 'Mín. horas'));
      }
      if (pool.maxHours != null) {
        specs.add(SpecItem(Icons.schedule_outlined, '${pool.maxHours}h', 'Máx. horas'));
      }
    }
    for (final camping in data.campingAreas) {
      if (camping.maxPersons != null) {
        specs.add(SpecItem(Icons.people_outline, '${camping.maxPersons}', 'Personas'));
      }
      if (camping.areaSquareMeters != null) {
        specs.add(SpecItem(Icons.straighten_outlined, '${camping.areaSquareMeters} m²', 'Área'));
      }
      if (camping.approxTents != null) {
        specs.add(SpecItem(Icons.holiday_village_outlined, '${camping.approxTents}', 'Casas'));
      }
    }
    return specs;
  }

  List<InfoPair> _collectCheckTimes(PropertyDetailResponse data) {
    final checkInfo = <InfoPair>[];
    for (final cabin in data.cabins) {
      if (cabin.checkInTime != null) {
        checkInfo.add(InfoPair('Check-in', cabin.formattedCheckIn));
      }
      if (cabin.checkOutTime != null) {
        checkInfo.add(InfoPair('Check-out', cabin.formattedCheckOut));
      }
    }
    for (final pool in data.pools) {
      if (pool.checkInTime != null) {
        checkInfo.add(InfoPair('Entrada', pool.formattedCheckIn));
      }
      if (pool.checkOutTime != null) {
        checkInfo.add(InfoPair('Salida', pool.formattedCheckOut));
      }
    }
    for (final camping in data.campingAreas) {
      if (camping.checkInTime != null) {
        checkInfo.add(InfoPair('Check-in', camping.formattedCheckIn));
      }
      if (camping.checkOutTime != null) {
        checkInfo.add(InfoPair('Check-out', camping.formattedCheckOut));
      }
    }
    // Deduplicate (keep first 2 unique labels)
    final unique = <InfoPair>[];
    final seen = <String>{};
    for (final info in checkInfo) {
      if (seen.add(info.label)) unique.add(info);
      if (unique.length >= 2) break;
    }
    return unique;
  }
}
