import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:pool_and_chill_app/data/models/property/index.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'package:pool_and_chill_app/features/properties/Screens/widget_details/detail_constants.dart';
import 'package:pool_and_chill_app/features/properties/Screens/widget_details/detail_image_carousel.dart';
import 'package:pool_and_chill_app/features/properties/Screens/widget_details/detail_specs_section.dart';
import 'package:pool_and_chill_app/features/properties/Screens/widget_details/detail_check_times.dart';
import 'package:pool_and_chill_app/features/properties/Screens/widget_details/detail_amenities_section.dart';
import 'package:pool_and_chill_app/features/properties/Screens/widget_details/detail_rules_section.dart';

import 'host_property_edit_screen.dart';

class HostPropertyDetailScreen extends ConsumerStatefulWidget {
  final String propertyId;

  /// Estado inicial conocido desde la lista (evita esperar al provider).
  final bool? initialIsActive;

  const HostPropertyDetailScreen({
    super.key,
    required this.propertyId,
    this.initialIsActive,
  });

  @override
  ConsumerState<HostPropertyDetailScreen> createState() =>
      _HostPropertyDetailScreenState();
}

class _HostPropertyDetailScreenState
    extends ConsumerState<HostPropertyDetailScreen> {
  late final PageController _carouselController;
  Timer? _carouselTimer;
  int _carouselIndex = 0;

  // null → usa initialIsActive o dato del servidor; non-null → override del usuario
  bool? _isActive;
  bool _togglingStatus = false;

  @override
  void initState() {
    super.initState();
    _isActive = widget.initialIsActive;
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
      if (mounted) setState(() => _carouselIndex = next);
    });
  }

  Future<void> _toggleStatus(String propertyId, bool currentlyActive) async {
    // Optimistic: muestra el nuevo estado inmediatamente
    setState(() {
      _togglingStatus = true;
      _isActive = !currentlyActive;
    });
    try {
      final service = ref.read(propertyServiceProvider);
      await service.updatePropertyStatus(
        propertyId: propertyId,
        status: currentlyActive ? 4 : 3,
      );
      // Éxito: dejamos _isActive como override hasta que el provider refresque
    } catch (e) {
      // Revertir al estado anterior
      if (mounted) {
        setState(() => _isActive = currentlyActive);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _togglingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncDetail = ref.watch(propertyDetailProvider(widget.propertyId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: asyncDetail.when(
        data: (data) => _buildContent(data),
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
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

    // _isActive es null hasta que el usuario toque el botón.
    // Mientras sea null, leemos el estado real del servidor.
    final serverActive =
        prop.status?.statusCode?.toUpperCase() == 'ACTIVE' ||
        prop.status?.statusCode?.toUpperCase() == 'ACTIVA' ||
        prop.status?.idStatus == 3;
    final isActive = _isActive ?? serverActive;

    if (images.isNotEmpty && _carouselTimer == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startCarouselTimer(images.length);
      });
    }

    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final topPadding = MediaQuery.paddingOf(context).top;
    final allSpecs = _collectSpecs(data);
    final checkTimes = _collectCheckTimes(data);

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // ─── Carrusel de imágenes ────────────────────────
            SliverToBoxAdapter(
              child: DetailImageCarousel(
                images: images,
                controller: _carouselController,
                currentIndex: _carouselIndex,
                overlayButtons: Stack(
                  children: [
                    // Botón regresar
                    Positioned(
                      top: topPadding + 8,
                      left: 16,
                      child: DetailActionButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    // Botón editar
                    Positioned(
                      top: topPadding + 8,
                      right: 16,
                      child: DetailActionButton(
                        icon: Icons.edit_outlined,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => HostPropertyEditScreen(
                                propertyId: widget.propertyId,
                              ),
                            ),
                          ).then((_) {
                            // Refrescar datos al volver del editor
                            ref.invalidate(
                                propertyDetailProvider(widget.propertyId));
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Cuerpo ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                    _buildTypeLabels(prop),
                    const SizedBox(height: 14),
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

                    if (allSpecs.isNotEmpty) ...[
                      _sectionTitle('Servicios'),
                      const SizedBox(height: 16),
                      DetailSpecsSection(specs: allSpecs),
                      const SizedBox(height: 20),
                    ],

                    if (checkTimes.isNotEmpty) ...[
                      _divider(),
                      DetailCheckTimes(items: checkTimes),
                      const SizedBox(height: 20),
                    ],

                    if (allSpecs.isNotEmpty || checkTimes.isNotEmpty)
                      _divider(),

                    if (data.allAmenities.isNotEmpty) ...[
                      _sectionTitle('Amenidades'),
                      const SizedBox(height: 14),
                      DetailAmenitiesSection(amenities: data.allAmenities),
                      const SizedBox(height: 24),
                      _divider(),
                    ],

                    if (data.rules.isNotEmpty) ...[
                      _sectionTitle('Reglas'),
                      const SizedBox(height: 12),
                      DetailRulesSection(rules: data.rules),
                      const SizedBox(height: 24),
                      _divider(),
                    ],

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

                    // Espacio para el FAB
                    SizedBox(height: 90 + bottomPadding),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ─── FAB Pause / Play ────────────────────────────────
        Positioned(
          left: 20,
          right: 20,
          bottom: 16 + bottomPadding,
          child: _buildStatusButton(prop.idProperty, isActive),
        ),
      ],
    );
  }

  Widget _buildStatusButton(String propertyId, bool isActive) {
    const activeColor = Color(0xFFE8920A);
    const pausedColor = kDetailPrimary;

    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _togglingStatus
            ? null
            : () {
                HapticFeedback.mediumImpact();
                _toggleStatus(propertyId, isActive);
              },
        icon: _togglingStatus
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                isActive
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                size: 22,
              ),
        label: Text(
          _togglingStatus
              ? 'Actualizando...'
              : isActive
                  ? 'Pausar propiedad'
                  : 'Activar propiedad',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? activeColor : pausedColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ─── Helpers (igual que PropertyDetailScreen) ────────────────

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
        specs.add(SpecItem(Icons.thermostat_outlined,
            '${pool.temperatureMin}°-${pool.temperatureMax}°', 'Temp.'));
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
        specs.add(SpecItem(Icons.straighten_outlined,
            '${camping.areaSquareMeters} m²', 'Área'));
      }
      if (camping.approxTents != null) {
        specs.add(SpecItem(Icons.holiday_village_outlined,
            '${camping.approxTents}', 'Casas de campaña'));
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
    final unique = <InfoPair>[];
    final seen = <String>{};
    for (final info in checkInfo) {
      if (seen.add(info.label)) {
        unique.add(info);
      }
      if (unique.length >= 2) {
        break;
      }
    }
    return unique;
  }
}
