import 'dart:async';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pool_and_chill_app/core/widgets/top_chip.dart';
import 'package:pool_and_chill_app/data/models/property/search_property_model.dart';
import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/data/providers/favorites_provider.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'package:pool_and_chill_app/data/providers/property_search_provider.dart';
import 'package:pool_and_chill_app/data/providers/results_search_provider.dart';
import 'package:pool_and_chill_app/features/properties/Screens/property_detail_screen.dart';
import 'package:pool_and_chill_app/features/search/screens/search_flow_screen.dart';
import 'package:provider/provider.dart' as provider_pkg;

// ─── Estilo de mapa (marca Pool & Chill) ─────────────────────────
const _kMapStyle = '''[
  {"featureType":"water","elementType":"geometry",
   "stylers":[{"color":"#b8dada"}]},
  {"featureType":"water","elementType":"labels.text",
   "stylers":[{"visibility":"off"}]},
  {"featureType":"landscape","elementType":"geometry",
   "stylers":[{"color":"#f5f5f5"}]},
  {"featureType":"poi","elementType":"geometry",
   "stylers":[{"color":"#eeeeee"}]},
  {"featureType":"poi","elementType":"labels",
   "stylers":[{"visibility":"off"}]},
  {"featureType":"poi.park","elementType":"geometry",
   "stylers":[{"color":"#d4ede8"}]},
  {"featureType":"road","elementType":"geometry",
   "stylers":[{"color":"#ffffff"}]},
  {"featureType":"road.highway","elementType":"geometry",
   "stylers":[{"color":"#ebebeb"}]},
  {"featureType":"road","elementType":"labels.text.fill",
   "stylers":[{"color":"#9e9e9e"}]},
  {"featureType":"road.highway","elementType":"labels",
   "stylers":[{"visibility":"off"}]},
  {"featureType":"road.arterial","elementType":"labels",
   "stylers":[{"visibility":"off"}]},
  {"featureType":"transit","elementType":"all",
   "stylers":[{"visibility":"off"}]},
  {"featureType":"administrative","elementType":"geometry",
   "stylers":[{"visibility":"off"}]},
  {"featureType":"administrative.land_parcel","elementType":"labels",
   "stylers":[{"visibility":"off"}]}
]''';

const _primary = Color(0xFF3CA2A2);
const _kDefaultCenter = LatLng(23.6345, -102.5528);

// ─── Pantalla de resultados ───────────────────────────────────────

class ResultsScreen extends ConsumerStatefulWidget {
  final SearchParams params;

  const ResultsScreen({super.key, required this.params});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  late SearchParams _params;

  final Completer<GoogleMapController> _mapCompleter = Completer();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final ScrollController _listScrollController = ScrollController();

  String? _selectedPropertyId;
  Set<Marker> _markers = {};

  // Coordenadas cargadas via getPropertyById (igual que detail screen).
  final Map<String, LatLng> _coords = {};
  // Caché de iconos para no re-generar en cada rebuild.
  final Map<String, BitmapDescriptor> _iconNormal = {};
  final Map<String, BitmapDescriptor> _iconSelected = {};

  // Contador de generación para cancelar cargas obsoletas.
  int _gen = 0;

  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _params = widget.params;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _search();
      _loadUserLocation();
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  // ── Ubicación del usuario ─────────────────────────────────────────

  Future<void> _loadUserLocation() async {
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) return;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      if (mounted) setState(() => _userPosition = position);
    } catch (_) {}
  }

  String? _distanceTo(String propertyId) {
    if (_userPosition == null) return null;
    final coord = _coords[propertyId];
    if (coord == null) return null;
    final meters = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      coord.latitude,
      coord.longitude,
    );
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  // ── Búsqueda ──────────────────────────────────────────────────────

  void _search() {
    ref.read(resultsSearchProvider.notifier).applyAdvancedFilters(
          hasPool: _params.hasPool ? true : null,
          hasCabin: _params.hasCabin ? true : null,
          hasCamping: _params.hasCamping ? true : null,
          checkInDate: _params.checkInFormatted,
          checkOutDate: _params.checkOutFormatted,
        );
  }

  void _resetAndSearch(SearchParams params) {
    setState(() {
      _params = params;
      _selectedPropertyId = null;
      _markers = {};
      _coords.clear();
      _iconNormal.clear();
      _iconSelected.clear();
      _gen++;
    });
    _search();
  }

  // ── Coordenadas (mismo patrón que property_detail_screen.dart) ────

  Future<void> _loadCoords(
      List<SearchPropertyModel> props, int generation) async {
    final service = ref.read(propertyServiceProvider);

    // Paso 1: usar coords del modelo si ya las tiene (si el backend las devuelve).
    for (final p in props) {
      if (p.hasCoordinates && !_coords.containsKey(p.propertyId)) {
        _coords[p.propertyId] = LatLng(p.latitude!, p.longitude!);
      }
    }

    // Actualizar marcadores con lo que ya tenemos.
    if (_coords.isNotEmpty && mounted) await _rebuildMarkers(props);

    // Paso 2: para las que no tienen coordenadas, hacer POST /properties/by-id
    // igual que lo hace property_detail_screen.dart.
    final needed = props
        .where((p) => !_coords.containsKey(p.propertyId))
        .toList();

    const batchSize = 6;
    for (var i = 0; i < needed.length; i += batchSize) {
      if (!mounted || generation != _gen) return;
      final batch = needed.skip(i).take(batchSize);

      await Future.wait(batch.map((p) async {
        try {
          final detail = await service.getPropertyById(p.propertyId);
          final loc = detail.property.location;
          if (loc != null && loc.hasCoordinates) {
            _coords[p.propertyId] = LatLng(loc.latitude!, loc.longitude!);
          }
        } catch (_) {}
      }));

      if (mounted && generation == _gen) await _rebuildMarkers(props);
    }

    // Centrar mapa en el primer marcador.
    if (_coords.isNotEmpty && mounted && _mapCompleter.isCompleted) {
      final ctrl = await _mapCompleter.future;
      ctrl.animateCamera(
        CameraUpdate.newLatLngZoom(_coords.values.first, 12),
      );
    }
  }

  // ── Marcadores ────────────────────────────────────────────────────

  Future<void> _rebuildMarkers(List<SearchPropertyModel> props) async {
    if (!mounted) return;
    final newMarkers = <Marker>{};

    for (final p in props) {
      final coord = _coords[p.propertyId];
      if (coord == null) continue;

      final sel = p.propertyId == _selectedPropertyId;
      if (sel) {
        _iconSelected[p.propertyId] ??=
            await _buildPinIcon(p.priceFrom, selected: true);
      } else {
        _iconNormal[p.propertyId] ??=
            await _buildPinIcon(p.priceFrom, selected: false);
      }

      final icon =
          sel ? _iconSelected[p.propertyId]! : _iconNormal[p.propertyId]!;

      newMarkers.add(Marker(
        markerId: MarkerId(p.propertyId),
        position: coord,
        icon: icon,
        anchor: const Offset(0.5, 0.5),
        zIndexInt: sel ? 1 : 0,
        onTap: () => _onMarkerTap(p, props),
      ));
    }

    if (mounted) setState(() => _markers = newMarkers);
  }

  // ── Dibuja un pin de precio con Canvas ────────────────────────────

  Future<BitmapDescriptor> _buildPinIcon(double price,
      {required bool selected}) async {
    final label =
        '\$${NumberFormat('#,##0', 'es_MX').format(price)}';

    const ph = 10.0;
    const pv = 7.0;
    const fs = 13.0;

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: fs,
          fontWeight: FontWeight.w800,
          color: selected ? Colors.white : const Color(0xFF1A1A2E),
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final w = tp.width + ph * 2;
    const h = fs + pv * 2;
    const scale = 2.5;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(scale, scale);

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, w - 2, h - 2),
      const Radius.circular(16),
    );

    final shadow = Path()..addRRect(rect);
    canvas.drawShadow(
        shadow, Colors.black.withValues(alpha: selected ? 0.35 : 0.2),
        selected ? 4 : 2, false);

    canvas.drawRRect(
        rect, Paint()..color = selected ? _primary : Colors.white);

    if (!selected) {
      canvas.drawRRect(
          rect,
          Paint()
            ..color = Colors.black.withValues(alpha: 0.08)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8);
    }

    tp.paint(canvas, Offset(ph, pv));

    final pic = recorder.endRecording();
    final img = await pic.toImage((w * scale).ceil(), (h * scale).ceil());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(
      data!.buffer.asUint8List(),
      width: w,
      height: h,
    );
  }

  // ── Interacciones ─────────────────────────────────────────────────

  void _onMarkerTap(SearchPropertyModel prop, List<SearchPropertyModel> all) {
    HapticFeedback.selectionClick();
    setState(() => _selectedPropertyId = prop.propertyId);
    _rebuildMarkers(all);
    // Colapsar el sheet para que solo se vea la card flotante
    if (_sheetController.isAttached) {
      _sheetController.animateTo(0.08,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _onDeselectPin(List<SearchPropertyModel> all) {
    setState(() => _selectedPropertyId = null);
    _rebuildMarkers(all);
    // Restaurar el sheet a su posición normal
    if (_sheetController.isAttached) {
      _sheetController.animateTo(0.42,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _onCardSelect(SearchPropertyModel prop) {
    HapticFeedback.selectionClick();
    setState(() => _selectedPropertyId = prop.propertyId);
    _rebuildMarkers(ref.read(resultsSearchProvider).properties);
    final coord = _coords[prop.propertyId];
    if (coord != null) _animateCamera(coord, 14);
  }

  void _onCardTap(SearchPropertyModel prop) {
    _onCardSelect(prop);
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => PropertyDetailScreen(propertyId: prop.propertyId),
    ));
  }

  void _onFavoriteToggle(String id) {
    final auth =
        provider_pkg.Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) {
      TopChip.showInfo(context, 'Inicia sesión para guardar favoritos');
      return;
    }
    ref.read(favoritesProvider.notifier).toggleFavorite(id);
  }

  Future<void> _animateCamera(LatLng target, double zoom) async {
    if (!_mapCompleter.isCompleted) return;
    final ctrl = await _mapCompleter.future;
    ctrl.animateCamera(CameraUpdate.newLatLngZoom(target, zoom));
  }

  void _editSearch() async {
    final result = await SearchSheet.show(context);
    if (result != null && mounted) _resetAndSearch(result);
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    ref.listen<PropertySearchState>(resultsSearchProvider, (prev, next) {
      final newProps = next.properties;
      if (newProps.isNotEmpty && prev?.properties != newProps) {
        _loadCoords(newProps, _gen);
      }
    });

    final state = ref.watch(resultsSearchProvider);
    final favState = ref.watch(favoritesProvider);

    return Scaffold(
      body: Column(
        children: [
          // ── Header fijo (nunca tapado por el sheet) ──
          _buildHeader(topPad, state),

          // ── Área de mapa + sheet: el sheet jamás puede subir al header ──
          Expanded(
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final areaH = constraints.maxHeight;
                return Stack(
                  children: [
                    // ── Mapa ──
                    AnimatedBuilder(
                      animation: _sheetController,
                      builder: (_, _) {
                        final fraction = _sheetController.isAttached
                            ? _sheetController.size
                            : 0.42;
                        final mapBottom = _selectedPropertyId != null
                            ? 0.0
                            : (fraction * areaH - 20).clamp(0.0, areaH);
                        return Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: mapBottom,
                          child: _GoogleMapLayer(
                            markers: _markers,
                            onCreated: (c) {
                              if (!_mapCompleter.isCompleted) {
                                _mapCompleter.complete(c);
                              }
                            },
                            onTap: (_) {
                              if (_selectedPropertyId != null) {
                                _onDeselectPin(state.properties);
                              }
                            },
                          ),
                        );
                      },
                    ),

                    // ── Panel de resultados ──
                    DraggableScrollableSheet(
                      controller: _sheetController,
                      initialChildSize: 0.42,
                      minChildSize: 0.08,
                      maxChildSize: 0.92,
                      snap: true,
                      snapSizes: const [0.08, 0.42, 0.92],
                      builder: (_, scrollController) =>
                          _buildSheet(scrollController, state, favState),
                    ),

                    // ── Card flotante al seleccionar un pin ──
                    if (_selectedPropertyId != null)
                      _buildFloatingCard(state, favState),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Card flotante (pin seleccionado) ─────────────────────────────

  Widget _buildFloatingCard(PropertySearchState state, FavoritesState favState) {
    final props = state.properties.where((p) => p.propertyId == _selectedPropertyId);
    if (props.isEmpty) return const SizedBox.shrink();
    final prop = props.first;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomPad + 12,
      child: _ResultsPropertyCard(
        key: ValueKey(prop.propertyId),
        property: prop,
        isSelected: true,
        isFavorite: favState.favoriteIds.contains(prop.propertyId),
        nights: _params.nights,
        distance: _distanceTo(prop.propertyId),
        onTap: () => _onCardTap(prop),
        onSelect: () {},
        onFavoriteToggle: () => _onFavoriteToggle(prop.propertyId),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────

  Widget _buildHeader(double topPad, PropertySearchState state) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: topPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Color(0xFF1A1A2E)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _editSearch,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Propiedades en tu zona',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            _params.datesSummary,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          if (state.isLoading)
            LinearProgressIndicator(
              minHeight: 2,
              color: _primary,
              backgroundColor: _primary.withValues(alpha: 0.1),
            ),
          Divider(height: 1, color: Colors.grey.shade100),
        ],
      ),
    );
  }

  // ── Panel de resultados ───────────────────────────────────────────

  Widget _buildSheet(
    ScrollController scrollController,
    PropertySearchState state,
    FavoritesState favState,
  ) {
    return Material(
      color: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      elevation: 8,
      child: Column(
        children: [
          // Attach the sheet's scrollController only to the header so that
          // dragging the handle/count area expands or collapses the sheet.
          SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHandle(),
                _buildCount(state),
              ],
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n is ScrollEndNotification &&
                    n.metrics.pixels >= n.metrics.maxScrollExtent - 200 &&
                    state.hasMore &&
                    !state.isLoadingMore) {
                  ref.read(resultsSearchProvider.notifier).loadMore();
                }
                return false;
              },
              child: CustomScrollView(
                controller: _listScrollController,
                slivers: [
                  _buildContent(state, favState),
                  SliverToBoxAdapter(
                    child: SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 24),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildCount(PropertySearchState state) {
    if (_selectedPropertyId != null) return const SizedBox.shrink();

    final count = state.totalCount;
    final label = state.isLoading && count == 0
        ? 'Buscando propiedades...'
        : '$count ${count == 1 ? "propiedad disponible" : "propiedades disponibles"}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1A1A2E),
        ),
      ),
    );
  }

  Widget _buildContent(PropertySearchState state, FavoritesState favState) {
    if (_selectedPropertyId != null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    if (state.isLoading && state.properties.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: CircularProgressIndicator(color: _primary, strokeWidth: 2),
        ),
      );
    }

    if (!state.isLoading && state.properties.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pool_rounded, color: Colors.grey.shade300, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'Sin disponibilidad',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E2E3E)),
                ),
                const SizedBox(height: 8),
                Text(
                  'No hay propiedades disponibles\npara las fechas seleccionadas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      height: 1.5),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList.builder(
      itemCount:
          state.properties.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == state.properties.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(
                  color: _primary, strokeWidth: 2),
            ),
          );
        }
        final prop = state.properties[i];
        return _ResultsPropertyCard(
          key: ValueKey(prop.propertyId),
          property: prop,
          isSelected: prop.propertyId == _selectedPropertyId,
          isFavorite: favState.favoriteIds.contains(prop.propertyId),
          nights: _params.nights,
          distance: _distanceTo(prop.propertyId),
          onTap: () => _onCardTap(prop),
          onSelect: () => _onCardSelect(prop),
          onFavoriteToggle: () => _onFavoriteToggle(prop.propertyId),
        );
      },
    );
  }
}

// ─── Capa del mapa (widget separado para estabilidad) ─────────────

class _GoogleMapLayer extends StatelessWidget {
  final Set<Marker> markers;
  final Function(GoogleMapController) onCreated;
  final Function(LatLng) onTap;

  const _GoogleMapLayer({
    required this.markers,
    required this.onCreated,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: _kDefaultCenter,
        zoom: 11,
      ),
      markers: markers,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      style: _kMapStyle,
      // Empuja el logo de Google 28px hacia arriba para que no quede
      // oculto bajo el borde redondeado del sheet (overlap de 20px).
      padding: const EdgeInsets.only(bottom: 28),
      onMapCreated: onCreated,
      onTap: onTap,
    );
  }
}

// ─── Card de propiedad — layout vertical con carrusel ────────────

class _ResultsPropertyCard extends StatefulWidget {
  final SearchPropertyModel property;
  final bool isSelected;
  final bool isFavorite;
  final int nights;
  final String? distance;
  final VoidCallback onTap;
  final VoidCallback onSelect;
  final VoidCallback onFavoriteToggle;

  const _ResultsPropertyCard({
    super.key,
    required this.property,
    required this.isSelected,
    required this.isFavorite,
    required this.nights,
    this.distance,
    required this.onTap,
    required this.onSelect,
    required this.onFavoriteToggle,
  });

  @override
  State<_ResultsPropertyCard> createState() => _ResultsPropertyCardState();
}

class _ResultsPropertyCardState extends State<_ResultsPropertyCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final fmt = NumberFormat('#,##0', 'es_MX');
    final priceNight = fmt.format(property.priceFrom);
    final priceTotal = widget.nights > 1 ? fmt.format(property.priceFrom * widget.nights) : null;
    final isNight = property.hasCabin || property.hasCamping;
    final unit = isNight ? '/noche' : '/día';
    final ratingStr = property.rating == 'Nuevo'
        ? 'Nuevo'
        : double.tryParse(property.rating)?.toStringAsFixed(1) ?? property.rating;
    final images = property.imageUrls;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: widget.isSelected
                  ? _primary.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.07),
              blurRadius: widget.isSelected ? 16 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Carrusel de imágenes ───────────────────────────────
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: images.isEmpty
                        ? Container(
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.image,
                                color: Colors.grey, size: 40),
                          )
                        : PageView.builder(
                            controller: _pageController,
                            itemCount: images.length,
                            onPageChanged: (i) =>
                                setState(() => _currentPage = i),
                            itemBuilder: (_, i) => CachedNetworkImage(
                              imageUrl: images[i],
                              fit: BoxFit.cover,
                              memCacheWidth: 700,
                              placeholder: (_, _) =>
                                  Container(color: Colors.grey.shade100),
                              errorWidget: (_, _, _) => Container(
                                color: Colors.grey.shade100,
                                child: const Icon(Icons.image,
                                    color: Colors.grey, size: 40),
                              ),
                            ),
                          ),
                  ),

                  // Dots indicator
                  if (images.length > 1)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (i) {
                          final active = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: active ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ),

                  // Corazón
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: widget.onFavoriteToggle,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.28),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.isFavorite ? Colors.red : Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Info ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre + rating
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            property.propertyName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Icon(
                              property.rating == 'Nuevo'
                                  ? Icons.star_border
                                  : Icons.star_rounded,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              ratingStr,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A2E)),
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (property.location.isNotEmpty || widget.distance != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        [
                          if (property.location.isNotEmpty) property.location,
                          if (widget.distance != null) widget.distance!,
                        ].join(' · '),
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    if (property.tiposDisplay.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        property.tiposDisplay,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ],

                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: '\$${priceTotal ?? priceNight} MXN',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _primary,
                          ),
                        ),
                        TextSpan(
                          text: priceTotal != null ? ' en total' : ' $unit',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

