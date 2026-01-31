import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pool_and_chill_app/data/models/property/index.dart';
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

  Future<void> _onTapMap(LatLng location) async {
    _moveToLocation(location);
    final notifier = ref.read(propertyRegistrationProvider.notifier);

    // Guardar coordenadas
    notifier.setLocation(location.latitude, location.longitude);

    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        notifier.setAddressData(AddressData(
          calle: p.thoroughfare ?? '',
          numero: p.subThoroughfare ?? '',
          colonia: p.subLocality ?? '',
          cp: p.postalCode ?? '',
          ciudad: p.locality ?? '',
          estado: p.administrativeArea ?? '',
          lat: location.latitude,
          lng: location.longitude,
        ));
      } else {
        notifier.setAddressData(AddressData(
          lat: location.latitude,
          lng: location.longitude,
        ));
      }
    } catch (e) {
      debugPrint('Error geocoding: $e');
      if (mounted) {
        notifier.setAddressData(AddressData(
          lat: location.latitude,
          lng: location.longitude,
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
    final hasLocation = _selectedLocation != null || state.addressData?.lat != null;

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

class _AddressForm extends StatefulWidget {
  final AddressData? initialData;
  final Function(AddressData data) onConfirm;

  const _AddressForm({required this.onConfirm, this.initialData});

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _calleCtrl;
  late final TextEditingController _numeroCtrl;
  late final TextEditingController _coloniaCtrl;
  late final TextEditingController _cpCtrl;
  late final TextEditingController _ciudadCtrl;
  late final TextEditingController _estadoCtrl;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _calleCtrl = TextEditingController(text: d?.calle ?? '');
    _numeroCtrl = TextEditingController(text: d?.numero ?? '');
    _coloniaCtrl = TextEditingController(text: d?.colonia ?? '');
    _cpCtrl = TextEditingController(text: d?.cp ?? '');
    _ciudadCtrl = TextEditingController(text: d?.ciudad ?? '');
    _estadoCtrl = TextEditingController(text: d?.estado ?? '');
  }

  @override
  Widget build(BuildContext context) {
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
              _field(_ciudadCtrl, 'Ciudad / Municipio'),
              _field(_estadoCtrl, 'Estado'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onConfirm(
                        AddressData(
                          calle: _calleCtrl.text,
                          numero: _numeroCtrl.text,
                          colonia: _coloniaCtrl.text,
                          cp: _cpCtrl.text,
                          ciudad: _ciudadCtrl.text,
                          estado: _estadoCtrl.text,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3CA2A2),
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
        validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
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
