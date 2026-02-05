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

    final isValid = info.nombre.trim().isNotEmpty &&
        info.descripcion.trim().isNotEmpty &&
        info.precioLunesJueves > 0 &&
        info.precioViernesDomingo > 0;

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
