import 'package:flutter/material.dart';
import 'package:pool_and_chill_app/data/models/property/index.dart';

import 'host_edit_shared.dart';
import 'host_edit_types.dart';

class HostEditBasicTab extends StatelessWidget {
  final HostEditControllers ctrl;
  final PropertyDetailProperty prop;
  final HostEditTimes times;
  final void Function(void Function(HostEditTimes)) onTimesChanged;
  final bool saving;
  final VoidCallback onSave;

  static const _entryOptions  = ['10:00 AM', '11:00 AM', '12:00 PM'];
  static const _exitOptions   = ['8:00 PM',  '9:00 PM',  '10:00 PM'];

  const HostEditBasicTab({
    super.key,
    required this.ctrl,
    required this.prop,
    required this.times,
    required this.onTimesChanged,
    required this.saving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HostEditSectionHeader('Descripción'),
          const SizedBox(height: 10),
          TextFormField(
            controller: ctrl.desc,
            maxLines: 5,
            maxLength: 2000,
            decoration:
                hostEditInputDecoration('Descripción de la propiedad'),
          ),
          const SizedBox(height: 24),

          // ── Alberca ──────────────────────────────────────────
          if (prop.hasPool) ...[
            const HostEditSectionHeader('Alberca — Horarios y precios'),
            const SizedBox(height: 10),
            HostTimeSelector(
              label: 'Entrada',
              selectedTime: times.poolCheckIn ?? '',
              options: _entryOptions,
              onChanged: (v) => onTimesChanged((t) => t.poolCheckIn = v),
            ),
            const SizedBox(height: 16),
            HostTimeSelector(
              label: 'Salida',
              selectedTime: times.poolCheckOut ?? '',
              options: _exitOptions,
              onChanged: (v) => onTimesChanged((t) => t.poolCheckOut = v),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: HostEditNumField(
                      controller: ctrl.poolPriceWd,
                      label: 'Precio entre semana \$')),
              const SizedBox(width: 12),
              Expanded(
                  child: HostEditNumField(
                      controller: ctrl.poolPriceWe,
                      label: 'Precio fin de semana \$')),
            ]),
            const SizedBox(height: 20),
          ],

          // ── Cabaña ───────────────────────────────────────────
          if (prop.hasCabin) ...[
            const HostEditSectionHeader('Cabaña — Horarios y precios'),
            const SizedBox(height: 10),
            HostTimeSelector(
              label: 'Check-in',
              selectedTime: times.cabinCheckIn ?? '',
              options: _entryOptions,
              onChanged: (v) => onTimesChanged((t) => t.cabinCheckIn = v),
            ),
            const SizedBox(height: 16),
            HostTimeSelector(
              label: 'Check-out',
              selectedTime: times.cabinCheckOut ?? '',
              options: _exitOptions,
              onChanged: (v) => onTimesChanged((t) => t.cabinCheckOut = v),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: HostEditNumField(
                      controller: ctrl.cabinMinN,
                      label: 'Mín. noches (opcional)',
                      isInt: true)),
              const SizedBox(width: 12),
              Expanded(
                  child: HostEditNumField(
                      controller: ctrl.cabinMaxN,
                      label: 'Máx. noches (opcional)',
                      isInt: true)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: HostEditNumField(
                      controller: ctrl.cabinPriceWd,
                      label: 'Precio entre semana \$')),
              const SizedBox(width: 12),
              Expanded(
                  child: HostEditNumField(
                      controller: ctrl.cabinPriceWe,
                      label: 'Precio fin de semana \$')),
            ]),
            const SizedBox(height: 20),
          ],

          // ── Camping ──────────────────────────────────────────
          if (prop.hasCamping) ...[
            const HostEditSectionHeader('Camping — Horarios y precios'),
            const SizedBox(height: 10),
            HostTimeSelector(
              label: 'Check-in',
              selectedTime: times.campCheckIn ?? '',
              options: _entryOptions,
              onChanged: (v) => onTimesChanged((t) => t.campCheckIn = v),
            ),
            const SizedBox(height: 16),
            HostTimeSelector(
              label: 'Check-out',
              selectedTime: times.campCheckOut ?? '',
              options: _exitOptions,
              onChanged: (v) => onTimesChanged((t) => t.campCheckOut = v),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: HostEditNumField(
                      controller: ctrl.campMinN,
                      label: 'Mín. noches (opcional)',
                      isInt: true)),
              const SizedBox(width: 12),
              Expanded(
                  child: HostEditNumField(
                      controller: ctrl.campMaxN,
                      label: 'Máx. noches (opcional)',
                      isInt: true)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: HostEditNumField(
                      controller: ctrl.campPriceWd,
                      label: 'Precio entre semana \$')),
              const SizedBox(width: 12),
              Expanded(
                  child: HostEditNumField(
                      controller: ctrl.campPriceWe,
                      label: 'Precio fin de semana \$')),
            ]),
            const SizedBox(height: 20),
          ],

          HostEditSaveButton(
            label: 'Guardar información básica',
            loading: saving,
            onPressed: onSave,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
