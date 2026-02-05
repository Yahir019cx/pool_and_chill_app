import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import '../widgets/step_navigation_buttons.dart';

class Step8Screen extends ConsumerStatefulWidget {
  final VoidCallback onPrevious;

  const Step8Screen({
    super.key,
    required this.onPrevious,
  });

  @override
  ConsumerState<Step8Screen> createState() => _Step8ScreenState();
}

class _Step8ScreenState extends ConsumerState<Step8Screen> {
  bool _isSubmitting = false;
  static const Color mainColor = Color(0xFF3CA2A2);

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    try {
      // TODO: Implementar envío al API
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al enviar. Intenta de nuevo.'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: mainColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: mainColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Enviado correctamente!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tu espacio está en revisión.\nTe notificaremos cuando sea aprobado.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                  ref.read(propertyRegistrationProvider.notifier).reset();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Entendido',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(propertyRegistrationProvider);
    final isReady = state.isReadyToSubmit;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          const Text(
            'Paso 8 de 8',
            style: TextStyle(fontSize: 13, color: Colors.black45),
          ),
          const SizedBox(height: 8),
          const Text(
            'Revisión final',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Verifica que toda la información sea correcta',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información básica
                  _SummarySection(
                    title: 'Información básica',
                    icon: Icons.info_outline,
                    isComplete: state.basicInfo.isValid,
                    children: [
                      _SummaryRow('Nombre', state.basicInfo.nombre),
                      _SummaryRow('Check-in', state.basicInfo.checkIn),
                      _SummaryRow('Check-out', state.basicInfo.checkOut),
                      _SummaryRow(
                        'Precio L-J',
                        '\$${state.basicInfo.precioLunesJueves.toStringAsFixed(0)} MXN',
                      ),
                      _SummaryRow(
                        'Precio V-D',
                        '\$${state.basicInfo.precioViernesDomingo.toStringAsFixed(0)} MXN',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Ubicación
                  _SummarySection(
                    title: 'Ubicación',
                    icon: Icons.location_on_outlined,
                    isComplete: state.addressData != null,
                    children: [
                      if (state.addressData != null) ...[
                        _SummaryRow('Calle', state.addressData!.calle),
                        _SummaryRow('Colonia', state.addressData!.colonia),
                        _SummaryRow('Ciudad', state.addressData!.ciudad),
                        _SummaryRow('Estado', state.addressData!.estado),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tipo de espacio
                  _SummarySection(
                    title: 'Tipo de espacio',
                    icon: Icons.category_outlined,
                    isComplete: state.tiposEspacioSeleccionados.isNotEmpty,
                    children: [
                      _SummaryRow(
                        'Tipos',
                        state.tiposEspacioSeleccionados.join(', '),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Reglas
                  _SummarySection(
                    title: 'Reglas',
                    icon: Icons.rule_outlined,
                    isComplete: true,
                    children: [
                      _SummaryRow(
                        'Total',
                        '${state.reglas.length} reglas definidas',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Fotos
                  _SummarySection(
                    title: 'Fotos',
                    icon: Icons.photo_library_outlined,
                    isComplete: state.photos.isValid,
                    children: [
                      _SummaryRow(
                        'Fotos subidas',
                        '${state.photos.photoPaths.length} imágenes',
                      ),
                    ],
                  ),
                  if (state.photos.photoPaths.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 70,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.photos.photoPaths.length.clamp(0, 5),
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(state.photos.photoPaths[index]),
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Verificación de identidad
                  _SummarySection(
                    title: 'Verificación de identidad',
                    icon: Icons.verified_user_outlined,
                    isComplete: state.identity.isComplete,
                    children: [
                      _SummaryRow(
                        'Estado',
                        state.identity.isComplete
                            ? 'Completado'
                            : 'Pendiente',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_isSubmitting)
            const SizedBox(
              height: 48,
              child: Center(
                child: CircularProgressIndicator(color: mainColor),
              ),
            )
          else
            StepNavigationButtons(
              onPrevious: widget.onPrevious,
              onNext: _submit,
              nextLabel: 'Enviar a revisión',
              isNextEnabled: isReady,
            ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isComplete;
  final List<Widget> children;

  static const Color mainColor = Color(0xFF3CA2A2);

  const _SummarySection({
    required this.title,
    required this.icon,
    required this.isComplete,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isComplete ? mainColor.withValues(alpha: 0.3) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: mainColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                isComplete ? Icons.check_circle : Icons.error_outline,
                color: isComplete ? mainColor : Colors.orange,
                size: 20,
              ),
            ],
          ),
          if (children.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...children,
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
