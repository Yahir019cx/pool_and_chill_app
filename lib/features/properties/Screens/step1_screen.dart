import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';

class Step1Screen extends ConsumerWidget {
  final VoidCallback onNext;

  const Step1Screen({super.key, required this.onNext});

  static const _options = [
    {'name': 'Cabaña', 'icon': Icons.cabin},
    {'name': 'Alberca', 'icon': Icons.pool},
    {'name': 'Camping', 'icon': Icons.terrain},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(propertyRegistrationProvider).tiposEspacioSeleccionados;
    final notifier = ref.read(propertyRegistrationProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          const Text(
            'Paso 1 de 4',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          const Text(
            '¿Qué tipo de espacio vas a rentar?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 28),
          Row(
            children: _options.map((opt) {
              final name = opt['name'] as String;
              final isSelected = selected.contains(name);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: GestureDetector(
                    onTap: () => notifier.toggleTipoEspacio(name),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF3CA2A2).withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF3CA2A2)
                              : Colors.grey.shade300,
                          width: 1.4,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            opt['icon'] as IconData,
                            size: 32,
                            color: isSelected
                                ? const Color(0xFF3CA2A2)
                                : Colors.black87,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: selected.isEmpty ? null : onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3CA2A2),
                elevation: 0,
                disabledBackgroundColor:
                    const Color(0xFF3CA2A2).withValues(alpha: 0.4),
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
    );
  }
}
