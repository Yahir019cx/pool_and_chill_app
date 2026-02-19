import 'package:flutter/material.dart';
import 'package:pool_and_chill_app/data/models/property/index.dart';

import 'host_amenity_section.dart';
import 'host_edit_shared.dart';
import 'host_edit_types.dart';

class HostEditAmenitiesTab extends StatelessWidget {
  final HostEditControllers ctrl;
  final PropertyDetailProperty prop;
  final List<AmenityModel> catalog;

  // Pool
  final List<HostAmenityEntry> poolAmenities;
  final void Function(HostAmenityEntry) onPoolAmenityAdded;
  final void Function(int) onPoolAmenityRemoved;
  final bool savingPool;
  final VoidCallback onSavePool;

  // Cabin
  final List<HostAmenityEntry> cabinAmenities;
  final void Function(HostAmenityEntry) onCabinAmenityAdded;
  final void Function(int) onCabinAmenityRemoved;
  final bool savingCabin;
  final VoidCallback onSaveCabin;

  // Camping
  final List<HostAmenityEntry> campingAmenities;
  final void Function(HostAmenityEntry) onCampingAmenityAdded;
  final void Function(int) onCampingAmenityRemoved;
  final bool savingCamping;
  final VoidCallback onSaveCamping;

  const HostEditAmenitiesTab({
    super.key,
    required this.ctrl,
    required this.prop,
    required this.catalog,
    required this.poolAmenities,
    required this.onPoolAmenityAdded,
    required this.onPoolAmenityRemoved,
    required this.savingPool,
    required this.onSavePool,
    required this.cabinAmenities,
    required this.onCabinAmenityAdded,
    required this.onCabinAmenityRemoved,
    required this.savingCabin,
    required this.onSaveCabin,
    required this.campingAmenities,
    required this.onCampingAmenityAdded,
    required this.onCampingAmenityRemoved,
    required this.savingCamping,
    required this.onSaveCamping,
  });

  @override
  Widget build(BuildContext context) {
    final hasSomething = prop.hasPool || prop.hasCabin || prop.hasCamping;
    if (!hasSomething) {
      return const Center(
        child: Text('Esta propiedad no tiene servicios con amenidades.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Alberca ──────────────────────────────────────────
          if (prop.hasPool) ...[
            HostAmenitySection(
              title: 'Alberca',
              icon: Icons.pool_outlined,
              fields: [
                HostEditNumField(
                    controller: ctrl.poolMaxP,
                    label: 'Capacidad (personas)',
                    isInt: true),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: HostEditNumField(
                          controller: ctrl.poolTempMin,
                          label: 'Temp. mín °C')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: HostEditNumField(
                          controller: ctrl.poolTempMax,
                          label: 'Temp. máx °C')),
                ]),
              ],
              amenities: poolAmenities,
              catalog: catalog
                  .where((c) => c.category.toLowerCase() == 'pool')
                  .toList(),
              onAddAmenity: onPoolAmenityAdded,
              onRemoveAmenity: onPoolAmenityRemoved,
              saveButton: HostEditSaveButton(
                label: 'Guardar amenidades de alberca',
                loading: savingPool,
                onPressed: onSavePool,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Cabaña ───────────────────────────────────────────
          if (prop.hasCabin) ...[
            HostAmenitySection(
              title: 'Cabaña',
              icon: Icons.cabin_outlined,
              fields: [
                Row(children: [
                  Expanded(
                      child: HostEditNumField(
                          controller: ctrl.cabinMaxG,
                          label: 'Huéspedes',
                          isInt: true)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: HostEditNumField(
                          controller: ctrl.cabinBed,
                          label: 'Habitaciones',
                          isInt: true)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: HostEditNumField(
                          controller: ctrl.cabinSingleB,
                          label: 'Camas ind.',
                          isInt: true)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: HostEditNumField(
                          controller: ctrl.cabinDoubleB,
                          label: 'Camas dobles',
                          isInt: true)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: HostEditNumField(
                          controller: ctrl.cabinFullBath,
                          label: 'Baños comp.',
                          isInt: true)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: HostEditNumField(
                          controller: ctrl.cabinHalfBath,
                          label: 'Medios baños',
                          isInt: true)),
                ]),
              ],
              amenities: cabinAmenities,
              catalog: catalog
                  .where((c) => c.category.toLowerCase() == 'cabin')
                  .toList(),
              onAddAmenity: onCabinAmenityAdded,
              onRemoveAmenity: onCabinAmenityRemoved,
              saveButton: HostEditSaveButton(
                label: 'Guardar amenidades de cabaña',
                loading: savingCabin,
                onPressed: onSaveCabin,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Camping ──────────────────────────────────────────
          if (prop.hasCamping) ...[
            HostAmenitySection(
              title: 'Camping',
              icon: Icons.holiday_village_outlined,
              fields: [
                HostEditNumField(
                    controller: ctrl.campMaxP,
                    label: 'Capacidad (personas)',
                    isInt: true),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: HostEditNumField(
                          controller: ctrl.campArea,
                          label: 'Área (m²)')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: HostEditNumField(
                          controller: ctrl.campTents,
                          label: 'N° tiendas',
                          isInt: true)),
                ]),
              ],
              amenities: campingAmenities,
              catalog: catalog
                  .where((c) => c.category.toLowerCase() == 'camping')
                  .toList(),
              onAddAmenity: onCampingAmenityAdded,
              onRemoveAmenity: onCampingAmenityRemoved,
              saveButton: HostEditSaveButton(
                label: 'Guardar amenidades de camping',
                loading: savingCamping,
                onPressed: onSaveCamping,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
