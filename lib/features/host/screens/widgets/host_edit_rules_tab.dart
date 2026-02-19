import 'package:flutter/material.dart';
import 'package:pool_and_chill_app/features/properties/Screens/widget_details/detail_constants.dart';

import 'host_edit_shared.dart';
import 'host_edit_types.dart';

class HostEditRulesTab extends StatelessWidget {
  final List<HostEditableRule> rules;
  final VoidCallback onAddRule;
  final void Function(int) onRemoveRule;
  final void Function(int oldIdx, int newIdx) onReorder;
  final bool saving;
  final VoidCallback onSave;

  const HostEditRulesTab({
    super.key,
    required this.rules,
    required this.onAddRule,
    required this.onRemoveRule,
    required this.onReorder,
    required this.saving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Column(
      children: [
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            itemCount: rules.length,
            onReorder: onReorder,
            itemBuilder: (ctx, i) {
              // Use controller object as key — stable across reorders
              return Padding(
                key: ObjectKey(rules[i].ctrl),
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 14),
                      child: Icon(Icons.drag_handle,
                          color: Colors.grey, size: 22),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: rules[i].ctrl,
                        maxLines: 2,
                        maxLength: 500,
                        decoration:
                            hostEditInputDecoration('Regla ${i + 1}'),
                      ),
                    ),
                    if (rules.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent),
                          onPressed: () => onRemoveRule(i),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottomPad),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onAddRule,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar regla'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kDetailPrimary,
                    side: const BorderSide(color: kDetailPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              HostEditSaveButton(
                label: 'Guardar reglas',
                loading: saving,
                onPressed: onSave,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
