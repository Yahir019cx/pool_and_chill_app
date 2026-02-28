import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pool_and_chill_app/data/models/catalog_model.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';

/// Valores de los filtros avanzados: ubicación, precio, orden y fechas.
class AdvancedFilterValues {
  final int? stateId;
  final int? cityId;
  final double? minPrice;
  final double? maxPrice;
  /// sortBy: 'price_asc' | 'price_desc' | 'rating'
  final String? sortBy;
  /// Fecha de entrada en formato YYYY-MM-DD (opcional).
  final String? checkInDate;
  /// Fecha de salida en formato YYYY-MM-DD (opcional).
  final String? checkOutDate;

  const AdvancedFilterValues({
    this.stateId,
    this.cityId,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
    this.checkInDate,
    this.checkOutDate,
  });

  bool get hasActiveFilters =>
      stateId != null ||
      cityId != null ||
      minPrice != null ||
      maxPrice != null ||
      (sortBy != null && sortBy!.isNotEmpty) ||
      (checkInDate != null && checkInDate!.isNotEmpty) ||
      (checkOutDate != null && checkOutDate!.isNotEmpty);

  static const empty = AdvancedFilterValues();
}

class AdvancedFiltersButton extends ConsumerStatefulWidget {
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
  ConsumerState<AdvancedFiltersButton> createState() =>
      _AdvancedFiltersButtonState();
}

class _AdvancedFiltersButtonState extends ConsumerState<AdvancedFiltersButton> {
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
            color: widget.hasActiveFilters
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
          if (widget.hasActiveFilters) ...[
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
        ref: ref,
        currentFilters: widget.currentFilters,
        onApply: (values) {
          Navigator.pop(context);
          widget.onApply(values);
        },
        onClear: () {
          Navigator.pop(context);
          widget.onClear();
        },
      ),
    );
  }
}

// ─── Bottom Sheet de filtros avanzados ──────────────────────────────

class _FiltersSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final AdvancedFilterValues currentFilters;
  final ValueChanged<AdvancedFilterValues> onApply;
  final VoidCallback onClear;

  const _FiltersSheet({
    required this.ref,
    required this.currentFilters,
    required this.onApply,
    required this.onClear,
  });

  @override
  ConsumerState<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<_FiltersSheet> {
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  int? _selectedStateId;
  int? _selectedCityId;
  String? _sortBy;
  /// Fechas en formato YYYY-MM-DD para mostrar en el sheet y enviar al API.
  String? _checkInDate;
  String? _checkOutDate;

  static const _primary = Color(0xFF3CA2A2);

  static String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _selectedStateId = widget.currentFilters.stateId;
    _selectedCityId = widget.currentFilters.cityId;
    _sortBy = widget.currentFilters.sortBy;
    _checkInDate = widget.currentFilters.checkInDate;
    _checkOutDate = widget.currentFilters.checkOutDate;
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
      _selectedStateId != null ||
      _selectedCityId != null ||
      _minPriceController.text.isNotEmpty ||
      _maxPriceController.text.isNotEmpty ||
      (_sortBy != null && _sortBy!.isNotEmpty) ||
      (_checkInDate != null && _checkInDate!.isNotEmpty) ||
      (_checkOutDate != null && _checkOutDate!.isNotEmpty);

  void _clearAll() {
    setState(() {
      _selectedStateId = null;
      _selectedCityId = null;
      _sortBy = null;
      _checkInDate = null;
      _checkOutDate = null;
      _minPriceController.clear();
      _maxPriceController.clear();
    });
    widget.onClear();
  }

  Future<void> _pickCheckIn() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final maxDate = today.add(const Duration(days: 180));
    final initial = _checkInDate != null
        ? DateTime.tryParse(_checkInDate!) ?? today
        : today;
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (ctx) => _FilterDatePickerDialog(
        title: 'Check-in',
        initialDate: initial.isBefore(today) ? today : initial,
        firstDate: today,
        lastDate: maxDate,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _checkInDate = _formatDate(picked);
        if (_checkOutDate != null) {
          final out = DateTime.tryParse(_checkOutDate!);
          if (out != null && !out.isAfter(picked)) _checkOutDate = null;
        }
      });
    }
  }

  Future<void> _pickCheckOut() async {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final maxDate = today.add(const Duration(days: 180));
    final checkIn = _checkInDate != null ? DateTime.tryParse(_checkInDate!) : null;
    final dayAfterCheckIn = checkIn != null ? checkIn.add(const Duration(days: 1)) : today;
    final firstDate = dayAfterCheckIn.isBefore(today) ? today : dayAfterCheckIn;
    final lastDate = maxDate.isBefore(firstDate) ? firstDate : maxDate;
    final initialRaw = _checkOutDate != null ? DateTime.tryParse(_checkOutDate!) : null;
    final initial = (initialRaw != null &&
            !initialRaw.isBefore(firstDate) &&
            !initialRaw.isAfter(lastDate))
        ? initialRaw
        : firstDate;
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (ctx) => _FilterDatePickerDialog(
        title: 'Check-out',
        initialDate: initial,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _checkOutDate = _formatDate(picked));
    }
  }

  void _apply() {
    if (_checkInDate != null &&
        _checkOutDate != null &&
        _checkOutDate!.compareTo(_checkInDate!) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La fecha de salida debe ser posterior a la de entrada.',
          ),
          backgroundColor: Color(0xFF3CA2A2),
        ),
      );
      return;
    }
    final minPrice = double.tryParse(_minPriceController.text);
    final maxPrice = double.tryParse(_maxPriceController.text);
    widget.onApply(AdvancedFilterValues(
      stateId: _selectedStateId,
      cityId: _selectedCityId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortBy: _sortBy,
      checkInDate: _checkInDate,
      checkOutDate: _checkOutDate,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final statesAsync = widget.ref.watch(statesCatalogProvider);
    final citiesAsync = _selectedStateId != null
        ? widget.ref.watch(citiesCatalogProvider(_selectedStateId!))
        : const AsyncValue<List<CityCatalogItem>>.data([]);

    return SingleChildScrollView(
      child: Padding(
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

            // ── Estado ──
            const Text(
              'Estado',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            statesAsync.when(
              data: (states) {
                StateCatalogItem? selected;
                if (_selectedStateId != null && states.isNotEmpty) {
                  try {
                    selected = states.firstWhere(
                        (s) => s.id == _selectedStateId);
                  } catch (_) {}
                }
                return DropdownButtonFormField<StateCatalogItem?>(
                  value: selected,
                  decoration: _inputDecoration(),
                  isExpanded: true,
                  hint: const Text('Todos los estados'),
                  items: [
                    const DropdownMenuItem<StateCatalogItem?>(
                      value: null,
                      child: Text('Todos los estados'),
                    ),
                    ...states.map((s) => DropdownMenuItem<StateCatalogItem?>(
                          value: s,
                          child: Text(s.name),
                        )),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _selectedStateId = v?.id;
                      _selectedCityId = null;
                    });
                  },
                );
              },
              loading: () => SizedBox(
                height: 48,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _primary,
                  ),
                ),
              ),
              error: (_, __) => const Text('No se pudieron cargar los estados'),
            ),
            const SizedBox(height: 16),

            // ── Ciudad ──
            const Text(
              'Ciudad',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _selectedStateId == null
                ? Container(
                    height: 48,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Selecciona un estado primero',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                : citiesAsync.when(
                    data: (cities) {
                      CityCatalogItem? selected;
                      if (_selectedCityId != null && cities.isNotEmpty) {
                        try {
                          selected = cities.firstWhere(
                              (c) => c.id == _selectedCityId);
                        } catch (_) {}
                      }
                      return DropdownButtonFormField<CityCatalogItem?>(
                        value: selected,
                        decoration: _inputDecoration(),
                        isExpanded: true,
                        hint: const Text('Todas las ciudades'),
                        items: [
                          const DropdownMenuItem<CityCatalogItem?>(
                            value: null,
                            child: Text('Todas las ciudades'),
                          ),
                          ...cities.map((c) => DropdownMenuItem<CityCatalogItem?>(
                                value: c,
                                child: Text(c.name),
                              )),
                        ],
                        onChanged: (v) {
                          setState(() => _selectedCityId = v?.id);
                        },
                      );
                    },
                    loading: () => SizedBox(
                      height: 48,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _primary,
                        ),
                      ),
                    ),
                    error: (_, __) =>
                        const Text('No se pudieron cargar las ciudades'),
                  ),
            const SizedBox(height: 20),

            // ── Ordenar por ──
            const Text(
              'Ordenar por',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _sortChip('Más baratos', 'price_asc'),
                const SizedBox(width: 8),
                _sortChip('Más caros', 'price_desc'),
                const SizedBox(width: 8),
                _sortChip('Mejor rating', 'rating'),
              ],
            ),
            const SizedBox(height: 20),

            // ── Fechas (opcionales) ──
            const Text(
              'Fechas de estancia',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickCheckIn,
                    borderRadius: BorderRadius.circular(10),
                    child: InputDecorator(
                      decoration: _inputDecoration(labelText: 'Check-in (opcional)'),
                      child: Text(
                        _checkInDate ?? 'Seleccionar',
                        style: TextStyle(
                          fontSize: 14,
                          color: _checkInDate != null
                              ? Colors.black87
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickCheckOut,
                    borderRadius: BorderRadius.circular(10),
                    child: InputDecorator(
                      decoration: _inputDecoration(labelText: 'Check-out (opcional)'),
                      child: Text(
                        _checkOutDate ?? 'Seleccionar',
                        style: TextStyle(
                          fontSize: 14,
                          color: _checkOutDate != null
                              ? Colors.black87
                              : Colors.grey.shade600,
                        ),
                      ),
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
                    decoration: _inputDecoration(labelText: 'Mínimo', prefix: '\$ '),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(labelText: 'Máximo', prefix: '\$ '),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
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
      ),
    );
  }

  InputDecoration _inputDecoration({String? labelText, String? prefix}) {
    return InputDecoration(
      labelText: labelText,
      prefixText: prefix,
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
        borderSide: const BorderSide(color: _primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _sortChip(String label, String value) {
    final selected = _sortBy == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (v) => setState(() => _sortBy = v ? value : null),
      selectedColor: _primary.withValues(alpha: 0.2),
      checkmarkColor: _primary,
    );
  }
}

// ─── Diálogo de calendario para filtros (cuadrados, estilo refinado) ─────

class _FilterDatePickerDialog extends StatefulWidget {
  final String title;
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _FilterDatePickerDialog({
    required this.title,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_FilterDatePickerDialog> createState() => _FilterDatePickerDialogState();
}

class _FilterDatePickerDialogState extends State<_FilterDatePickerDialog> {
  static const _primary = Color(0xFF3CA2A2);
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate;
    _selectedDay = widget.initialDate;
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    setState(() {
      _selectedDay = selected;
      _focusedDay = focused;
    });
    Navigator.of(context).pop(DateTime(selected.year, selected.month, selected.day));
  }

  @override
  Widget build(BuildContext context) {
    final first = DateTime(widget.firstDate.year, widget.firstDate.month, widget.firstDate.day);
    final lastFixed = DateTime(widget.lastDate.year, widget.lastDate.month, widget.lastDate.day);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TableCalendar<void>(
              locale: 'es_ES',
              firstDay: first,
              lastDay: lastFixed,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: _onDaySelected,
              onPageChanged: (focused) => setState(() => _focusedDay = focused),
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                leftChevronIcon: const Icon(Icons.chevron_left, color: _primary),
                rightChevronIcon: const Icon(Icons.chevron_right, color: _primary),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
                weekendStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              calendarStyle: CalendarStyle(
                cellMargin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                defaultTextStyle: const TextStyle(fontSize: 14, color: Colors.black87),
                weekendTextStyle: const TextStyle(fontSize: 14, color: Colors.black87),
                outsideTextStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                selectedDecoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                selectedTextStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                todayDecoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                todayTextStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
