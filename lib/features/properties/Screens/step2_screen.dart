import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pool_and_chill_app/data/models/property/index.dart';
import 'package:pool_and_chill_app/data/models/catalog_model.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';

class Step2Screen extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const Step2Screen({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  ConsumerState<Step2Screen> createState() => _Step2ScreenState();
}

class _Step2ScreenState extends ConsumerState<Step2Screen> {
  GoogleMapController? _mapController;
  LatLng _center = const LatLng(21.9944, -102.2826);
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    // Restaurar estado previo si existe
    final state = ref.read(propertyRegistrationProvider);
    if (state.addressData?.lat != null && state.addressData?.lng != null) {
      _center = LatLng(state.addressData!.lat!, state.addressData!.lng!);
      _selectedLocation = _center;
    }
  }

  void _moveToLocation(LatLng location) {
    if (!mounted) return;

    setState(() {
      _center = location;
      _selectedLocation = location;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(location, 16),
    );
  }

  /// Normaliza texto para comparar con el catálogo (minúsculas, sin acentos).
  static String _normalize(String s) {
    const withAccents = 'áéíóúñüÁÉÍÓÚÑÜ';
    const withoutAccents = 'aeiounuAEIOUNU';
    var t = s.trim().toLowerCase();
    for (var i = 0; i < withAccents.length; i++) {
      t = t.replaceAll(withAccents[i], withoutAccents[i].toLowerCase());
    }
    return t;
  }

  /// Quita prefijos típicos de estado/municipio para mejorar el match con el catálogo.
  static String _cleanForMatch(String s) {
    var t = s.trim();
    const prefixes = [
      'Estado de ',
      'Estado ',
      'Edo. de ',
      'Edo. ',
      'Edo de ',
      'Municipio de ',
      'Municipio ',
      'Ciudad de ',
      'Cd. ',
      'Cd ',
    ];
    for (final prefix in prefixes) {
      if (t.toLowerCase().startsWith(prefix.toLowerCase())) {
        t = t.substring(prefix.length).trim();
        break;
      }
    }
    return t;
  }

  static bool _namesMatch(String catalogName, String placemarkName) {
    final a = _normalize(_cleanForMatch(catalogName));
    final b = _normalize(_cleanForMatch(placemarkName));
    if (a.isEmpty || b.isEmpty) return false;
    return a == b || a.contains(b) || b.contains(a);
  }

  /// Compara el placemark con el catálogo. En México: administrativeArea = estado,
  /// locality o subAdministrativeArea = ciudad/municipio. Prueba varios campos.
  Future<({int? stateId, int? cityId, String? stateName, String? cityName})> _matchCatalog(
    Placemark p,
  ) async {
    // Estado: en MX suele venir en administrativeArea; a veces en subAdministrativeArea
    final estadoCandidates = [
      p.administrativeArea,
      p.subAdministrativeArea,
    ].where((e) => e != null && e.toString().trim().isNotEmpty).map((e) => e!.trim()).toList();
    if (estadoCandidates.isEmpty) return (stateId: null, cityId: null, stateName: null, cityName: null);

    final states = await ref.read(statesCatalogProvider.future);
    StateCatalogItem? matchedState;
    for (final estadoStr in estadoCandidates) {
      for (final s in states) {
        if (_namesMatch(s.name, estadoStr)) {
          matchedState = s;
          break;
        }
      }
      if (matchedState != null) break;
    }
    if (matchedState == null) return (stateId: null, cityId: null, stateName: null, cityName: null);

    final cities = await ref.read(citiesCatalogProvider(matchedState.id).future);
    // Ciudad/municipio: locality = ciudad; subAdministrativeArea = municipio en MX; subLocality = colonia
    final ciudadCandidates = [
      p.locality,
      p.subAdministrativeArea,
      p.subLocality,
    ].where((c) => c != null && c.toString().trim().isNotEmpty).map((c) => c!.trim()).toList();
    CityCatalogItem? matchedCity;
    for (final ciudadStr in ciudadCandidates) {
      if (cities.isEmpty) break;
      for (final c in cities) {
        if (_namesMatch(c.name, ciudadStr)) {
          matchedCity = c;
          break;
        }
      }
      if (matchedCity != null) break;
    }
    return (
      stateId: matchedState.id,
      cityId: matchedCity?.id,
      stateName: matchedState.name,
      cityName: matchedCity?.name,
    );
  }

  Future<void> _onTapMap(LatLng location) async {
    _moveToLocation(location);
    final notifier = ref.read(propertyRegistrationProvider.notifier);

    notifier.setLocation(location.latitude, location.longitude);

    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (!mounted) return;

      // Probar cada placemark hasta que uno coincida con el catálogo (estado)
      ({int? stateId, int? cityId, String? stateName, String? cityName}) catalogMatch =
          (stateId: null, cityId: null, stateName: null, cityName: null);
      Placemark p = placemarks.first;
      for (final pm in placemarks) {
        final match = await _matchCatalog(pm);
        if (match.stateId != null) {
          catalogMatch = match;
          p = pm;
          break;
        }
      }

      if (!mounted) return;

      final current = ref.read(propertyRegistrationProvider).addressData;
      if (placemarks.isNotEmpty) {
        notifier.setAddressData(AddressData(
          calle: p.thoroughfare ?? '',
          numero: p.subThoroughfare ?? '',
          colonia: p.subLocality ?? '',
          cp: p.postalCode ?? '',
          ciudad: catalogMatch.cityName ?? p.locality ?? p.subAdministrativeArea ?? '',
          estado: catalogMatch.stateName ?? p.administrativeArea ?? p.subAdministrativeArea ?? '',
          lat: location.latitude,
          lng: location.longitude,
          stateId: catalogMatch.stateId ?? current?.stateId,
          cityId: catalogMatch.cityId ?? current?.cityId,
        ));
        if (mounted && (catalogMatch.stateId == null || catalogMatch.cityId == null)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                catalogMatch.stateId == null
                    ? 'No se encontró el estado en el catálogo. Selecciónalo en "Ingresar o editar dirección".'
                    : 'No se encontró la ciudad en el catálogo. Complétala en "Ingresar o editar dirección".',
              ),
              backgroundColor: Colors.orange.shade700,
            ),
          );
        }
      } else {
        notifier.setAddressData(AddressData(
          lat: location.latitude,
          lng: location.longitude,
          stateId: current?.stateId,
          cityId: current?.cityId,
        ));
      }
    } catch (e) {
      debugPrint('Error geocoding: $e');
      if (mounted) {
        final current = ref.read(propertyRegistrationProvider).addressData;
        notifier.setAddressData(AddressData(
          lat: location.latitude,
          lng: location.longitude,
          stateId: current?.stateId,
          cityId: current?.cityId,
        ));
      }
    }
  }

  void _openAddressSheet() {
    final currentData = ref.read(propertyRegistrationProvider).addressData;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddressForm(
        initialData: currentData,
        onConfirm: (data) async {
          final notifier = ref.read(propertyRegistrationProvider.notifier);

          try {
            final results = await locationFromAddress(data.toGeocodingString());

            if (!mounted) return;

            if (results.isNotEmpty) {
              final loc = results.first;
              notifier.setAddressData(data.copyWith(
                lat: loc.latitude,
                lng: loc.longitude,
              ));
              _moveToLocation(LatLng(loc.latitude, loc.longitude));
            } else {
              notifier.setAddressData(data);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dirección guardada, pero no se encontró en el mapa'),
                ),
              );
            }
          } catch (e) {
            debugPrint('Error buscando dirección: $e');
            if (!mounted) return;

            notifier.setAddressData(data);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo encontrar la dirección en el mapa'),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(propertyRegistrationProvider);
    final addr = state.addressData;
    final hasLocation = (_selectedLocation != null || addr?.lat != null) &&
        addr?.stateId != null &&
        addr?.cityId != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          const Text(
            'Paso 2 de 4',
            style: TextStyle(fontSize: 13, color: Colors.black45),
          ),
          const SizedBox(height: 8),
          const Text(
            '¿Dónde se encuentra tu espacio?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _openAddressSheet,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_on, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Ingresar o editar dirección',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: GoogleMap(
                onMapCreated: (c) => _mapController = c,
                initialCameraPosition: CameraPosition(target: _center, zoom: 14),
                onTap: _onTapMap,
                markers: _selectedLocation == null
                    ? {}
                    : {
                        Marker(
                          markerId: const MarkerId('selected'),
                          position: _selectedLocation!,
                        ),
                      },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: widget.onPrevious,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF3CA2A2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Anterior',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3CA2A2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: hasLocation ? widget.onNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3CA2A2),
                      disabledBackgroundColor:
                          const Color(0xFF3CA2A2).withValues(alpha: 0.4),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Siguiente',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddressForm extends ConsumerStatefulWidget {
  final AddressData? initialData;
  final Function(AddressData data) onConfirm;

  const _AddressForm({required this.onConfirm, this.initialData});

  @override
  ConsumerState<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<_AddressForm> {
  final _formKey = GlobalKey<FormState>();
  static const Color _mainColor = Color(0xFF3CA2A2);

  late final TextEditingController _calleCtrl;
  late final TextEditingController _numeroCtrl;
  late final TextEditingController _coloniaCtrl;
  late final TextEditingController _cpCtrl;

  StateCatalogItem? _selectedState;
  CityCatalogItem? _selectedCity;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _calleCtrl = TextEditingController(text: d?.calle ?? '');
    _numeroCtrl = TextEditingController(text: d?.numero ?? '');
    _coloniaCtrl = TextEditingController(text: d?.colonia ?? '');
    _cpCtrl = TextEditingController(text: d?.cp ?? '');
  }

  @override
  void dispose() {
    _calleCtrl.dispose();
    _numeroCtrl.dispose();
    _coloniaCtrl.dispose();
    _cpCtrl.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedState == null || _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona estado y ciudad del catálogo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    widget.onConfirm(
      AddressData(
        calle: _calleCtrl.text.trim(),
        numero: _numeroCtrl.text.trim(),
        colonia: _coloniaCtrl.text.trim(),
        cp: _cpCtrl.text.trim(),
        ciudad: _selectedCity!.name,
        estado: _selectedState!.name,
        stateId: _selectedState!.id,
        cityId: _selectedCity!.id,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final statesAsync = ref.watch(statesCatalogProvider);
    final citiesAsync = _selectedState != null
        ? ref.watch(citiesCatalogProvider(_selectedState!.id))
        : const AsyncValue<List<CityCatalogItem>>.data([]);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Confirma la dirección',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _field(_calleCtrl, 'Calle'),
              _field(_numeroCtrl, 'Número', isNumber: true),
              _field(_coloniaCtrl, 'Colonia'),
              _field(_cpCtrl, 'Código Postal', isNumber: true),
              const SizedBox(height: 8),
              const Text('Estado', style: TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 4),
              statesAsync.when(
                data: (states) {
                  if (states.isEmpty) {
                    return const Text('No hay estados disponibles', style: TextStyle(color: Colors.orange));
                  }
                  StateCatalogItem? value = _selectedState;
                  if (value == null && widget.initialData?.stateId != null) {
                    try {
                      value = states.firstWhere((s) => s.id == widget.initialData!.stateId);
                    } catch (_) {}
                  }
                  if (value != null && _selectedState == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _selectedState == null) setState(() => _selectedState = value);
                    });
                  }
                  return DropdownButtonFormField<StateCatalogItem>(
                    value: value,
                    decoration: _dropdownDecoration(),
                    hint: const Text('Selecciona estado'),
                    items: states
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                        .toList(),
                    onChanged: (s) {
                      setState(() {
                        _selectedState = s;
                        _selectedCity = null;
                      });
                    },
                    validator: (v) => v == null ? 'Requerido' : null,
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                ),
                error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
              const SizedBox(height: 12),
              const Text('Ciudad / Municipio', style: TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 4),
              _selectedState == null
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Selecciona primero un estado',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    )
                  : citiesAsync.when(
                      data: (cities) {
                        if (cities.isEmpty) {
                          return const Text('No hay ciudades disponibles', style: TextStyle(color: Colors.orange));
                        }
                        CityCatalogItem? cityValue = _selectedCity;
                        if (cityValue == null && widget.initialData?.cityId != null) {
                          try {
                            cityValue = cities.firstWhere((c) => c.id == widget.initialData!.cityId);
                          } catch (_) {}
                        }
                        if (cityValue != null && _selectedCity == null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && _selectedCity == null) setState(() => _selectedCity = cityValue);
                          });
                        }
                        return DropdownButtonFormField<CityCatalogItem>(
                          value: cityValue,
                          decoration: _dropdownDecoration(),
                          hint: const Text('Selecciona ciudad'),
                          items: cities
                              .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                              .toList(),
                          onChanged: (c) => setState(() => _selectedCity = c),
                          validator: (v) => v == null ? 'Requerido' : null,
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
                      ),
                      error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mainColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Buscar en el mapa',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (v) => v == null || v.toString().trim().isEmpty ? 'Requerido' : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
