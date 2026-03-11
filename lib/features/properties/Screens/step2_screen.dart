import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pool_and_chill_app/data/models/property/index.dart';
import 'package:pool_and_chill_app/data/models/catalog_model.dart';
import 'package:pool_and_chill_app/core/widgets/top_chip.dart';
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
  LatLng _center = const LatLng(21.8818, -102.2916);
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

  void _onTapMap(LatLng location) {
    _moveToLocation(location);
    final notifier = ref.read(propertyRegistrationProvider.notifier);
    final current = ref.read(propertyRegistrationProvider).addressData;

    // Solo guardar coordenadas, sin tocar los datos de dirección del formulario
    notifier.setLocation(location.latitude, location.longitude);
    notifier.setAddressData((current ?? const AddressData()).copyWith(
      lat: location.latitude,
      lng: location.longitude,
    ));
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
        onConfirm: (data) {
          final notifier = ref.read(propertyRegistrationProvider.notifier);
          // Guardar dirección conservando las coordenadas actuales del pin
          final current = ref.read(propertyRegistrationProvider).addressData;
          notifier.setAddressData(data.copyWith(
            lat: current?.lat,
            lng: current?.lng,
          ));
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
          const SizedBox(height: 6),
          const Text(
            'Si tu propiedad está en un lugar remoto, usa el pin del mapa para ubicarla y completa solo estado y ciudad.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black38),
          ),
          const SizedBox(height: 14),
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
      TopChip.showWarning(context, 'Selecciona estado y ciudad del catálogo');
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
    TopChip.showSuccess(context, 'Dirección guardada');
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
              _field(_calleCtrl, 'Calle (opcional)', required: false),
              _field(_numeroCtrl, 'Número (opcional)', isNumber: true, required: false),
              _field(_coloniaCtrl, 'Colonia (opcional)', required: false),
              _field(_cpCtrl, 'Código Postal (opcional)', isNumber: true, required: false),
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
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: _mainColor),
                    ),
                  ),
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
                      loading: () => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: _mainColor),
                          ),
                        ),
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
                    'Guardar dirección',
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
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: required ? (v) => v == null || v.toString().trim().isEmpty ? 'Requerido' : null : null,
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
