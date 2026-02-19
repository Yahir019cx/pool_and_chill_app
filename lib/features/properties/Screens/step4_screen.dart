import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import '../widgets/step_navigation_buttons.dart';
import '../widgets/styled_text_field.dart';
import '../widgets/time_selector.dart';
import '../widgets/price_input.dart';

class Step4Screen extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const Step4Screen({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  static const _checkInOptions = ['10:00 AM', '12:00 PM', '2:00 PM', '3:00 PM'];
  static const _checkOutOptions = ['6:00 PM', '8:00 PM', '10:00 PM', '12:00 AM'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(propertyRegistrationProvider);
    final notifier = ref.read(propertyRegistrationProvider.notifier);
    final info = state.basicInfo;

    final hasCabin = state.tiposEspacioSeleccionados.contains('Cabaña');
    final hasCamping = state.tiposEspacioSeleccionados.contains('Camping');
    final showNights = hasCabin || hasCamping;

    final nightsValid = info.minNights == null ||
        info.maxNights == null ||
        info.maxNights! >= info.minNights!;

    final isValid = info.nombre.trim().isNotEmpty &&
        info.descripcion.trim().isNotEmpty &&
        info.precioLunesJueves > 0 &&
        info.precioViernesDomingo > 0 &&
        nightsValid;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          const Text(
            'Paso 4 de 8',
            style: TextStyle(fontSize: 13, color: Colors.black45),
          ),
          const SizedBox(height: 8),
          const Text(
            'Información básica',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StyledTextField(
                    label: 'Nombre del lugar',
                    hint: 'Ej: Villa Paraíso, Cabaña del Bosque...',
                    value: info.nombre,
                    maxLength: 50,
                    onChanged: (v) => notifier.updateBasicInfoField('nombre', v),
                  ),
                  const SizedBox(height: 20),
                  StyledTextField(
                    label: 'Descripción',
                    hint: 'Describe tu espacio: qué lo hace especial, qué pueden esperar los huéspedes, características únicas...',
                    value: info.descripcion,
                    maxLines: 5,
                    maxLength: 500,
                    onChanged: (v) => notifier.updateBasicInfoField('descripcion', v),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 20),
                  TimeSelector(
                    label: 'Hora de Check-in',
                    selectedTime: info.checkIn,
                    options: _checkInOptions,
                    onChanged: (v) => notifier.updateBasicInfoField('checkIn', v),
                  ),
                  const SizedBox(height: 20),
                  TimeSelector(
                    label: 'Hora de Check-out',
                    selectedTime: info.checkOut,
                    options: _checkOutOptions,
                    onChanged: (v) => notifier.updateBasicInfoField('checkOut', v),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 20),

                  // ── Noches mínimas / máximas (cabaña o camping) ──────────
                  if (showNights) ...[
                    const Text(
                      'Estancia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Opcional. Define cuántas noches mínimas o máximas puede reservar un huésped.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _NightsCounter(
                      label: 'Noches mínimas',
                      value: info.minNights,
                      onChanged: (v) => notifier.updateBasicInfoField('minNights', v),
                    ),
                    const SizedBox(height: 12),
                    _NightsCounter(
                      label: 'Noches máximas',
                      value: info.maxNights,
                      onChanged: (v) => notifier.updateBasicInfoField('maxNights', v),
                    ),
                    if (!nightsValid) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.error_outline,
                              size: 14, color: Colors.red.shade600),
                          const SizedBox(width: 4),
                          Text(
                            'Las noches máximas deben ser ≥ a las mínimas',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 20),
                  ],

                  const Text(
                    'Precios por renta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  PriceInput(
                    label: 'Lunes a Jueves',
                    sublabel: '(Entre semana)',
                    value: info.precioLunesJueves,
                    onChanged: (v) => notifier.updateBasicInfoField('precioLunesJueves', v),
                  ),
                  const SizedBox(height: 16),
                  PriceInput(
                    label: 'Viernes a Domingo',
                    sublabel: '(Fin de semana)',
                    value: info.precioViernesDomingo,
                    onChanged: (v) => notifier.updateBasicInfoField('precioViernesDomingo', v),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          StepNavigationButtons(
            onPrevious: onPrevious,
            onNext: onNext,
            isNextEnabled: isValid,
          ),
        ],
      ),
    );
  }
}

// ── Widget de contador de noches ─────────────────────────────────────────────

class _NightsCounter extends StatelessWidget {
  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;

  static const Color _primary = Color(0xFF3CA2A2);

  const _NightsCounter({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          // Botón −
          _CounterButton(
            icon: Icons.remove,
            enabled: (value ?? 1) > 1,
            onTap: () => onChanged((value ?? 1) - 1),
          ),
          // Valor
          SizedBox(
            width: 80,
            child: Text(
              '${value ?? 1} ${(value ?? 1) == 1 ? 'noche' : 'noches'}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _primary,
              ),
            ),
          ),
          // Botón +
          _CounterButton(
            icon: Icons.add,
            enabled: true,
            onTap: () => onChanged((value ?? 1) + 1),
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  static const Color _primary = Color(0xFF3CA2A2);

  const _CounterButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? _primary.withValues(alpha: 0.1) : Colors.grey.shade100,
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? _primary : Colors.grey.shade300,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? _primary : Colors.grey.shade400,
        ),
      ),
    );
  }
}
