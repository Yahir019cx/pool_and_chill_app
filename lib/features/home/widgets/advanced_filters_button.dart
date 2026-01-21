import 'package:flutter/material.dart';

class AdvancedFiltersButton extends StatelessWidget {
  final VoidCallback onClear;
  final bool hasActiveFilters;

  const AdvancedFiltersButton({
    super.key,
    required this.onClear,
    this.hasActiveFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF3CA2A2),
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: hasActiveFilters
                ? const Color(0xFF3CA2A2)
                : Colors.grey.shade300,
          ),
        ),
      ),
      onPressed: () => _showFiltersSheet(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.tune, size: 20),
          const SizedBox(width: 8),
          const Text('Filtros avanzados'),
          if (hasActiveFilters) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF3CA2A2),
                shape: BoxShape.circle,
              ),
              child: const Text(
                '!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFiltersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FiltersSheet(
        onClear: onClear,
        hasActiveFilters: hasActiveFilters,
      ),
    );
  }
}

class _FiltersSheet extends StatefulWidget {
  final VoidCallback onClear;
  final bool hasActiveFilters;

  const _FiltersSheet({
    required this.onClear,
    required this.hasActiveFilters,
  });

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  final Set<String> _selectedFilters = {};

  static const _filters = [
    'Día completo',
    'Por horas',
    'Menor a \$3,000',
    '\$3,000 - \$5,000',
    'Más de \$5,000',
    'Con alberca',
    'Pet friendly',
    'Estacionamiento',
  ];

  @override
  Widget build(BuildContext context) {
    final hasFilters = _selectedFilters.isNotEmpty || widget.hasActiveFilters;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtros avanzados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasFilters)
                TextButton(
                  onPressed: () {
                    setState(() => _selectedFilters.clear());
                    widget.onClear();
                  },
                  child: const Text(
                    'Limpiar todo',
                    style: TextStyle(
                      color: Color(0xFF3CA2A2),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Filter chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _filters.map((filter) {
              final isSelected = _selectedFilters.contains(filter);
              return FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedFilters.add(filter);
                    } else {
                      _selectedFilters.remove(filter);
                    }
                  });
                },
                selectedColor: const Color(0xFF3CA2A2).withValues(alpha: 0.2),
                checkmarkColor: const Color(0xFF3CA2A2),
                labelStyle: TextStyle(
                  color: isSelected
                      ? const Color(0xFF3CA2A2)
                      : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF3CA2A2)
                        : Colors.grey.shade300,
                  ),
                ),
                backgroundColor: Colors.white,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3CA2A2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _selectedFilters.isEmpty
                    ? 'Aplicar filtros'
                    : 'Aplicar ${_selectedFilters.length} filtros',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
