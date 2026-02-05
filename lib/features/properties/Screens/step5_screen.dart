import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import '../widgets/step_navigation_buttons.dart';
import '../widgets/rule_item.dart';

class Step5Screen extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const Step5Screen({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  ConsumerState<Step5Screen> createState() => _Step5ScreenState();
}

class _Step5ScreenState extends ConsumerState<Step5Screen> {
  final _newRuleController = TextEditingController();
  static const Color mainColor = Color(0xFF3CA2A2);

  @override
  void dispose() {
    _newRuleController.dispose();
    super.dispose();
  }

  void _addRule() {
    final text = _newRuleController.text.trim();
    if (text.isEmpty) return;

    ref.read(propertyRegistrationProvider.notifier).addRegla(text);
    _newRuleController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final reglas = ref.watch(propertyRegistrationProvider).reglas;
    final notifier = ref.read(propertyRegistrationProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          const Text(
            'Paso 5 de 8',
            style: TextStyle(fontSize: 13, color: Colors.black45),
          ),
          const SizedBox(height: 8),
          const Text(
            'Reglas del establecimiento',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Define las normas que los huéspedes deben seguir',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          // Input para nueva regla
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newRuleController,
                  maxLength: 100,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Escribe una regla...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: mainColor, width: 1.5),
                    ),
                  ),
                  onSubmitted: (_) => _addRule(),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _addRule,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Lista de reglas
          Expanded(
            child: reglas.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: reglas.length,
                    itemBuilder: (context, index) {
                      return RuleItem(
                        value: reglas[index],
                        index: index,
                        onChanged: (v) => notifier.updateRegla(index, v),
                        onDelete: () => notifier.removeRegla(index),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          StepNavigationButtons(
            onPrevious: widget.onPrevious,
            onNext: widget.onNext,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rule_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Aún no hay reglas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega reglas como: "No fumar", "No mascotas",\n"Respetar horarios de silencio", etc.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
