import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pool_and_chill_app/data/models/property/index.dart';
import 'package:pool_and_chill_app/features/properties/Screens/widget_details/detail_constants.dart';

import 'host_edit_types.dart';

// ─── Mapeo de nombre de amenidad → ícono ──────────────────────────

IconData _amenityIcon(String name) {
  return switch (name.toLowerCase()) {
    // Cabaña
    'wifi' => FontAwesomeIcons.wifi,
    'tv' => FontAwesomeIcons.tv,
    'cocina' => FontAwesomeIcons.kitchenSet,
    'lavadora' => FontAwesomeIcons.shirt,
    'refrigerador' => FontAwesomeIcons.snowflake,
    'aire acondicionado' => FontAwesomeIcons.wind,
    'calefacción' => FontAwesomeIcons.temperatureHigh,
    'estacionamiento' => FontAwesomeIcons.squareParking,
    'sillones' => FontAwesomeIcons.couch,
    'microondas' => FontAwesomeIcons.plateWheat,
    'comedor' => FontAwesomeIcons.utensils,
    'utensilios de cocina' => FontAwesomeIcons.spoon,
    'chimenea' => FontAwesomeIcons.fire,
    'bocina(s)' => FontAwesomeIcons.volumeHigh,
    'toallas' => FontAwesomeIcons.layerGroup,
    // Alberca
    'camastros' => FontAwesomeIcons.chair,
    'sombrillas' => FontAwesomeIcons.umbrellaBeach,
    'mesas' => FontAwesomeIcons.table,
    'asador' => FontAwesomeIcons.fireBurner,
    'regaderas' => FontAwesomeIcons.shower,
    'vestidores' => FontAwesomeIcons.personBooth,
    'baños' => FontAwesomeIcons.restroom,
    'palapa / sombra' => FontAwesomeIcons.tent,
    'hielera' => FontAwesomeIcons.boxOpen,
    'barra' => FontAwesomeIcons.martiniGlass,
    'flotadores' => FontAwesomeIcons.lifeRing,
    'sillas' => FontAwesomeIcons.chair,
    // Camping
    'fogata' => FontAwesomeIcons.fire,
    'leña' => FontAwesomeIcons.tree,
    'área techada' => FontAwesomeIcons.warehouse,
    'baños portátiles' => FontAwesomeIcons.restroom,
    'mesas picnic' => FontAwesomeIcons.tableColumns,
    'electricidad' => FontAwesomeIcons.bolt,
    'iluminación' => FontAwesomeIcons.lightbulb,
    _ => FontAwesomeIcons.check,
  };
}

// ─── Sección de amenidades con chips ──────────────────────────────

class HostAmenitySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> fields;
  final List<HostAmenityEntry> amenities;
  final List<AmenityModel> catalog;
  final void Function(HostAmenityEntry) onAddAmenity;
  final void Function(int) onRemoveAmenity;
  final Widget saveButton;

  const HostAmenitySection({
    super.key,
    required this.title,
    required this.icon,
    required this.fields,
    required this.amenities,
    required this.catalog,
    required this.onAddAmenity,
    required this.onRemoveAmenity,
    required this.saveButton,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Título de sección ───────────────────────────
            Row(
              children: [
                Icon(icon, color: kDetailPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kDetailDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Campos numéricos específicos del servicio ───
            ...fields,
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),

            // ── Título amenidades ───────────────────────────
            const Text(
              'Amenidades',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: kDetailDark,
              ),
            ),
            const SizedBox(height: 10),

            // ── Chips (igual que step3_screen) ─────────────
            if (catalog.isEmpty)
              Text(
                'Sin amenidades disponibles',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: catalog.map((am) {
                  final idx = amenities
                      .indexWhere((a) => a.catalogId == am.id);
                  final isSelected = idx != -1;

                  return FilterChip(
                    avatar: FaIcon(
                      _amenityIcon(am.name),
                      size: 13,
                      color: isSelected
                          ? kDetailPrimary
                          : Colors.grey.shade600,
                    ),
                    label: Text(
                      am.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? kDetailPrimary : kDetailDark,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: kDetailPrimary.withValues(alpha: 0.15),
                    checkmarkColor: kDetailPrimary,
                    showCheckmark: false,
                    side: BorderSide(
                      color: isSelected
                          ? kDetailPrimary
                          : Colors.grey.shade300,
                    ),
                    backgroundColor: Colors.white,
                    onSelected: (_) {
                      if (isSelected) {
                        onRemoveAmenity(idx);
                      } else {
                        onAddAmenity(HostAmenityEntry(
                          catalogId: am.id,
                          name: am.name,
                        ));
                      }
                    },
                  );
                }).toList(),
              ),

            const SizedBox(height: 16),
            saveButton,
          ],
        ),
      ),
    );
  }
}
