import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class Step2Screen extends StatefulWidget {
  const Step2Screen({super.key});

  @override
  State<Step2Screen> createState() => _Step2ScreenState();
}

class _Step2ScreenState extends State<Step2Screen> {
  GoogleMapController? _mapController;

  LatLng _center = const LatLng(21.9944, -102.2826);
  LatLng? _selectedLocation;
  AddressData? _addressData;

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

    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        setState(() {
          _addressData = AddressData(
            calle: p.thoroughfare ?? '',
            numero: p.subThoroughfare ?? '',
            colonia: p.subLocality ?? '',
            cp: p.postalCode ?? '',
            ciudad: p.locality ?? '',
            estado: p.administrativeArea ?? '',
          );
        });
      }
    } catch (_) {}
  }

  void _openAddressSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddressForm(
        initialData: _addressData,
        onConfirm: (data) async {
          try {
            final results =
                await locationFromAddress(data.toGeocodingString());

            if (!mounted) return;

            if (results.isNotEmpty) {
              setState(() => _addressData = data);
              _moveToLocation(
                LatLng(
                  results.first.latitude,
                  results.first.longitude,
                ),
              );
            }
          } catch (_) {
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo encontrar la dirección'),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Registrar espacio',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.location_on, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Ingresar o editar dirección',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 250,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: GoogleMap(
                    onMapCreated: (c) => _mapController = c,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 14,
                    ),
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
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      _selectedLocation == null || _addressData == null
                          ? null
                          : () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3CA2A2),
                    disabledBackgroundColor:
                        const Color(0xFF3CA2A2).withOpacity(0.4),
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
            ],
          ),
        ),
      ),
    );
  }
}

class AddressData {
  final String calle;
  final String numero;
  final String colonia;
  final String cp;
  final String ciudad;
  final String estado;

  const AddressData({
    required this.calle,
    required this.numero,
    required this.colonia,
    required this.cp,
    required this.ciudad,
    required this.estado,
  });

  String toGeocodingString() {
    return '$calle $numero, $colonia, $cp, $ciudad, $estado';
  }
}

class _AddressForm extends StatefulWidget {
  final AddressData? initialData;
  final Function(AddressData data) onConfirm;

  const _AddressForm({
    required this.onConfirm,
    this.initialData,
  });

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
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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
        keyboardType:
            isNumber ? TextInputType.number : TextInputType.text,
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
