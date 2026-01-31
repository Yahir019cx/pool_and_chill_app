import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pool_and_chill_app/data/models/property/index.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';

/// Mapeo de amenidades a iconos
IconData _getAmenityIcon(String name) {
  final lower = name.toLowerCase();
  return switch (lower) {
    // Cabaña
    'wifi' => FontAwesomeIcons.wifi,
    'tv' => FontAwesomeIcons.tv,
    'cocina' => FontAwesomeIcons.kitchenSet,
    'lavadora' => FontAwesomeIcons.shirt,
    'refrigerador' => FontAwesomeIcons.snowflake,
    'aire acondicionado' => FontAwesomeIcons.wind,
    'calefacción' => FontAwesomeIcons.temperatureHigh,
    'estacionamiento' => FontAwesomeIcons.squareParking,
    'sala equipada' => FontAwesomeIcons.couch,
    'comedor' => FontAwesomeIcons.utensils,
    'utensilios' => FontAwesomeIcons.spoon,
    'chimenea' => FontAwesomeIcons.fire,
    'bocina' => FontAwesomeIcons.volumeHigh,
    // Alberca
    'camastros' => FontAwesomeIcons.bed,
    'sombrillas' => FontAwesomeIcons.umbrellaBeach,
    'mesas' => FontAwesomeIcons.table,
    'asador' => FontAwesomeIcons.fireBurner,
    'regaderas' => FontAwesomeIcons.shower,
    'vestidores' => FontAwesomeIcons.personBooth,
    'palapa' => FontAwesomeIcons.tent,
    'hieleras' => FontAwesomeIcons.boxOpen,
    // Camping
    'área techada' => FontAwesomeIcons.warehouse,
    'fogatero' => FontAwesomeIcons.campground,
    'baños portátiles' => FontAwesomeIcons.restroom,
    'mesas picnic' => FontAwesomeIcons.tableColumns,
    'electricidad' => FontAwesomeIcons.bolt,
    'iluminación' => FontAwesomeIcons.lightbulb,
    // Default
    _ => FontAwesomeIcons.check,
  };
}

class Step3Screen extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const Step3Screen({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  static const Color mainColor = Color(0xFF3CA2A2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(propertyRegistrationProvider);
    final tipos = state.tiposEspacioSeleccionados;
    final categoriesQuery = state.categoriasQuery;

    // Obtener amenidades del API
    final amenitiesAsync = ref.watch(amenitiesProvider(categoriesQuery));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          const Text(
            'Paso 3 de 4',
            style: TextStyle(fontSize: 13, color: Colors.black45),
          ),
          const SizedBox(height: 8),
          const Text(
            'Detalles del espacio',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: amenitiesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildOfflineContent(ref, tipos),
              data: (amenities) => _buildContent(ref, tipos, amenities),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onPrevious,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: mainColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Anterior',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: mainColor,
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
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
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

  Widget _buildContent(WidgetRef ref, Set<String> tipos, List<AmenityModel> amenities) {
    final amenitiesByCategory = AmenitiesByCategory.fromList(amenities);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tipos.contains('Cabaña')) ...[
            _CabanaSection(amenities: amenitiesByCategory.forCategory('cabin')),
            const Divider(height: 32),
          ],
          if (tipos.contains('Alberca')) ...[
            _AlbercaSection(amenities: amenitiesByCategory.forCategory('pool')),
            const Divider(height: 32),
          ],
          if (tipos.contains('Camping')) ...[
            _CampingSection(amenities: amenitiesByCategory.forCategory('camping')),
          ],
        ],
      ),
    );
  }

  // Fallback cuando no hay conexión - usa amenidades hardcodeadas
  Widget _buildOfflineContent(WidgetRef ref, Set<String> tipos) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Sin conexión - Usando amenidades básicas',
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ),
          if (tipos.contains('Cabaña')) ...[
            const _CabanaSection(amenities: []),
            const Divider(height: 32),
          ],
          if (tipos.contains('Alberca')) ...[
            const _AlbercaSection(amenities: []),
            const Divider(height: 32),
          ],
          if (tipos.contains('Camping')) ...[
            const _CampingSection(amenities: []),
          ],
        ],
      ),
    );
  }
}

// ============ CABAÑA SECTION ============
class _CabanaSection extends ConsumerWidget {
  final List<AmenityModel> amenities;

  const _CabanaSection({required this.amenities});

  static const _defaultAmenities = [
    'WiFi', 'TV', 'Cocina', 'Lavadora', 'Refrigerador',
    'Aire acondicionado', 'Calefacción', 'Estacionamiento',
    'Sala equipada', 'Comedor', 'Utensilios', 'Chimenea', 'Bocina'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(propertyRegistrationProvider);
    final notifier = ref.read(propertyRegistrationProvider.notifier);
    final specs = state.cabana;

    final amenityNames = amenities.isNotEmpty
        ? amenities.map((a) => a.name).toList()
        : _defaultAmenities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Características de la Cabaña'),
        _Counter(
          label: 'Huéspedes',
          value: specs.huespedes,
          onChanged: (v) => notifier.updateCabanaCounter('huespedes', v),
        ),
        _Counter(
          label: 'Recámaras',
          value: specs.recamaras,
          onChanged: (v) => notifier.updateCabanaCounter('recamaras', v),
        ),
        _Counter(
          label: 'Camas individuales',
          value: specs.camasIndividuales,
          onChanged: (v) => notifier.updateCabanaCounter('camasIndividuales', v),
        ),
        _Counter(
          label: 'Camas matrimoniales',
          value: specs.camasMatrimoniales,
          onChanged: (v) => notifier.updateCabanaCounter('camasMatrimoniales', v),
        ),
        _Counter(
          label: 'Baños completos',
          value: specs.banosCompletos,
          onChanged: (v) => notifier.updateCabanaCounter('banosCompletos', v),
        ),
        _Counter(
          label: 'Medios baños',
          value: specs.mediosBanos,
          onChanged: (v) => notifier.updateCabanaCounter('mediosBanos', v),
        ),
        const SizedBox(height: 16),
        const _SectionTitle('Amenidades'),
        _AmenityChips(
          items: amenityNames,
          selected: specs.amenidades,
          onToggle: notifier.toggleCabanaAmenidad,
        ),
      ],
    );
  }
}

// ============ ALBERCA SECTION ============
class _AlbercaSection extends ConsumerWidget {
  final List<AmenityModel> amenities;

  const _AlbercaSection({required this.amenities});

  static const _defaultAmenities = [
    'Camastros', 'Sombrillas', 'Mesas', 'Asador', 'Regaderas',
    'Vestidores', 'Palapa', 'Hieleras', 'Estacionamiento', 'Bocina'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(propertyRegistrationProvider);
    final notifier = ref.read(propertyRegistrationProvider.notifier);
    final specs = state.alberca;

    final amenityNames = amenities.isNotEmpty
        ? amenities.map((a) => a.name).toList()
        : _defaultAmenities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Características de la Alberca'),
        _Counter(
          label: 'Capacidad máxima de personas',
          value: specs.capacidad,
          onChanged: (v) => notifier.updateAlbercaCounter('capacidad', v),
        ),
        _Counter(
          label: 'Baños exteriores',
          value: specs.banos,
          onChanged: (v) => notifier.updateAlbercaCounter('banos', v),
        ),
        const SizedBox(height: 16),
        const _SectionTitle('Rango de temperatura del agua'),
        _TemperatureRange(
          minValue: specs.temperaturaMin,
          maxValue: specs.temperaturaMax,
          onMinChanged: (v) => notifier.updateAlbercaCounter('temperaturaMin', v),
          onMaxChanged: (v) => notifier.updateAlbercaCounter('temperaturaMax', v),
        ),
        const SizedBox(height: 16),
        const _SectionTitle('Amenidades'),
        _AmenityChips(
          items: amenityNames,
          selected: specs.amenidades,
          onToggle: notifier.toggleAlbercaAmenidad,
        ),
      ],
    );
  }
}

// ============ CAMPING SECTION ============
class _CampingSection extends ConsumerWidget {
  final List<AmenityModel> amenities;

  const _CampingSection({required this.amenities});

  static const _defaultAmenities = [
    'Área techada', 'Fogatero', 'Baños portátiles', 'Mesas picnic',
    'Electricidad', 'Iluminación', 'Estacionamiento', 'Bocina'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(propertyRegistrationProvider);
    final notifier = ref.read(propertyRegistrationProvider.notifier);
    final specs = state.camping;

    final amenityNames = amenities.isNotEmpty
        ? amenities.map((a) => a.name).toList()
        : _defaultAmenities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Características del Camping'),
        _Counter(
          label: 'Capacidad máxima de personas',
          value: specs.capacidadPersonas,
          onChanged: (v) => notifier.updateCampingCounter('capacidadPersonas', v),
        ),
        _Counter(
          label: 'm² de espacio',
          value: specs.metrosCuadrados,
          onChanged: (v) => notifier.updateCampingCounter('metrosCuadrados', v),
        ),
        _Counter(
          label: 'Casas de campaña aproximadas',
          value: specs.casasCampanaAprox,
          onChanged: (v) => notifier.updateCampingCounter('casasCampanaAprox', v),
        ),
        const SizedBox(height: 16),
        const _SectionTitle('Amenidades'),
        _AmenityChips(
          items: amenityNames,
          selected: specs.amenidades,
          onToggle: notifier.toggleCampingAmenidad,
        ),
      ],
    );
  }
}

// ============ SHARED WIDGETS ============
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _Counter({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: Step3Screen.mainColor),
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
              ),
              SizedBox(
                width: 32,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: Step3Screen.mainColor),
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmenityChips extends StatelessWidget {
  final List<String> items;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  const _AmenityChips({
    required this.items,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        final isSelected = selected.contains(item);
        return FilterChip(
          avatar: FaIcon(
            _getAmenityIcon(item),
            size: 14,
            color: isSelected ? Step3Screen.mainColor : Colors.grey.shade600,
          ),
          label: Text(item),
          selected: isSelected,
          selectedColor: Step3Screen.mainColor.withValues(alpha: 0.2),
          checkmarkColor: Step3Screen.mainColor,
          showCheckmark: false,
          onSelected: (_) => onToggle(item),
        );
      }).toList(),
    );
  }
}

class _TemperatureRange extends StatelessWidget {
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onMinChanged;
  final ValueChanged<int> onMaxChanged;

  const _TemperatureRange({
    required this.minValue,
    required this.maxValue,
    required this.onMinChanged,
    required this.onMaxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _tempControl('Mín', minValue, onMinChanged),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '$minValue° - $maxValue°',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Step3Screen.mainColor,
              ),
            ),
          ),
          _tempControl('Máx', maxValue, onMaxChanged),
        ],
      ),
    );
  }

  Widget _tempControl(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          children: [
            GestureDetector(
              onTap: value > 10 ? () => onChanged(value - 1) : null,
              child: Icon(
                Icons.remove_circle_outline,
                color: value > 10 ? Step3Screen.mainColor : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: value < 40 ? () => onChanged(value + 1) : null,
              child: Icon(
                Icons.add_circle_outline,
                color: value < 40 ? Step3Screen.mainColor : Colors.grey,
                size: 28,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
