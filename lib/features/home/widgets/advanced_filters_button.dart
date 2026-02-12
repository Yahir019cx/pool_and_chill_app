import 'package:flutter/material.dart';

/// Valores de los filtros avanzados aplicados.
class AdvancedFilterValues {
  final double? minPrice;
  final double? maxPrice;

  const AdvancedFilterValues({this.minPrice, this.maxPrice});

  bool get hasActiveFilters => minPrice != null || maxPrice != null;

  static const empty = AdvancedFilterValues();
}

class AdvancedFiltersButton extends StatelessWidget {
  final AdvancedFilterValues currentFilters;
  final ValueChanged<AdvancedFilterValues> onApply;
  final VoidCallback onClear;
  final bool hasActiveFilters;

  const AdvancedFiltersButton({
    super.key,
    this.currentFilters = AdvancedFilterValues.empty,
    required this.onApply,
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
        currentFilters: currentFilters,
        onApply: (values) {
          Navigator.pop(context);
          onApply(values);
        },
        onClear: () {
          Navigator.pop(context);
          onClear();
        },
      ),
    );
  }
}

// ─── Bottom Sheet de filtros avanzados ──────────────────────────────

class _FiltersSheet extends StatefulWidget {
  final AdvancedFilterValues currentFilters;
  final ValueChanged<AdvancedFilterValues> onApply;
  final VoidCallback onClear;

  const _FiltersSheet({
    required this.currentFilters,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.currentFilters.minPrice != null) {
      _minPriceController.text =
          widget.currentFilters.minPrice!.toStringAsFixed(0);
    }
    if (widget.currentFilters.maxPrice != null) {
      _maxPriceController.text =
          widget.currentFilters.maxPrice!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  bool get _hasFilters =>
      _minPriceController.text.isNotEmpty ||
      _maxPriceController.text.isNotEmpty;

  void _clearAll() {
    setState(() {
      _minPriceController.clear();
      _maxPriceController.clear();
    });
    widget.onClear();
  }

  void _apply() {
    final minPrice = double.tryParse(_minPriceController.text);
    final maxPrice = double.tryParse(_maxPriceController.text);

    widget.onApply(AdvancedFilterValues(
      minPrice: minPrice,
      maxPrice: maxPrice,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
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
              if (_hasFilters)
                TextButton(
                  onPressed: _clearAll,
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
          const SizedBox(height: 20),

          // ── Rango de precios ──
          const Text(
            'Rango de precios',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Mínimo',
                    prefixText: '\$ ',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFF3CA2A2)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _maxPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Máximo',
                    prefixText: '\$ ',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFF3CA2A2)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Botón Aplicar ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3CA2A2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Aplicar filtros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
