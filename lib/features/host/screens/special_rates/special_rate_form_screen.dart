import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pool_and_chill_app/data/models/special_rate_model.dart';
import 'package:pool_and_chill_app/data/models/property/index.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'package:pool_and_chill_app/data/services/special_rate_service.dart';
import 'widgets/sr_range_picker_sheet.dart';
import 'widgets/sr_deactivate_sheet.dart';

class SpecialRateFormScreen extends ConsumerStatefulWidget {
  final String propertyId;
  final String propertyTitle;
  final String coverImageUrl;
  final List<String> availableTypes;

  const SpecialRateFormScreen({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
    required this.coverImageUrl,
    required this.availableTypes,
  });

  @override
  ConsumerState<SpecialRateFormScreen> createState() =>
      _SpecialRateFormScreenState();
}

class _SpecialRateFormScreenState
    extends ConsumerState<SpecialRateFormScreen> {
  static const _kPrimary = Color(0xFF2D9D91);
  static const _kDark = Color(0xFF1A1A2E);
  static const _kSpecialRate = Color(0xFFD4A017);

  static const _typeLabels = {
    'pool': 'Alberca',
    'cabin': 'Cabaña',
    'camping': 'Camping',
  };
  static const _typeIcons = {
    'pool': Icons.pool_rounded,
    'cabin': Icons.cabin_rounded,
    'camping': Icons.forest_rounded,
  };

  /// Mutaciones confirmadas por API que sobreviven navegación.
  static final Map<String, List<_SrDateOverride>> _pendingOverrides = {};

  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;

  final _priceCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  bool _saving = false;
  bool _isLoadingCalendar = false;
  String? _calendarLoadError;
  Map<DateTime, CalendarDayModel> _calendarMap = {};
  int _calendarKey = 0;

  @override
  void initState() {
    super.initState();
    if (widget.availableTypes.isNotEmpty) {
      _selectedType = widget.availableTypes.first;
    }
    _loadCalendar();
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _reasonCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  CalendarDayModel? _dayModel(DateTime day) =>
      _calendarMap[DateTime.utc(day.year, day.month, day.day)];

  // ─── Calendar ──────────────────────────────────────────────────

  Future<void> _loadCalendar() async {
    setState(() {
      _isLoadingCalendar = true;
      _calendarLoadError = null;
    });
    try {
      final service = ref.read(propertyServiceProvider);
      final response = await service.getBookingCalendar(widget.propertyId);
      final map = <DateTime, CalendarDayModel>{};
      for (final day in response.data.calendar) {
        final dt = DateTime.parse(day.date);
        map[DateTime.utc(dt.year, dt.month, dt.day)] = day;
      }
      _applyPendingOverrides(map);
      if (!mounted) return;
      setState(() {
        _calendarMap = map;
        _calendarKey++;
        _isLoadingCalendar = false;
        _calendarLoadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingCalendar = false;
        _calendarLoadError = 'No se pudo cargar el calendario';
      });
      _snack('No se pudo cargar el calendario. Toca reintentar.');
    }
  }

  void _applyPendingOverrides(Map<DateTime, CalendarDayModel> map) {
    final overrides = _pendingOverrides[widget.propertyId];
    if (overrides == null || overrides.isEmpty) return;

    final now = DateTime.now();
    overrides.removeWhere((o) => now.difference(o.createdAt).inMinutes > 10);

    for (final override in overrides) {
      final existing = map[override.dateKey];
      if (existing != null) {
        map[override.dateKey] = override.updater(existing);
      }
    }
  }

  void _storeOverrides(
    DateTime start,
    DateTime end,
    CalendarDayModel Function(CalendarDayModel existing) updater,
  ) {
    final list = _pendingOverrides.putIfAbsent(widget.propertyId, () => []);
    final now = DateTime.now();
    var current = start;
    while (!current.isAfter(end)) {
      final key = DateTime.utc(current.year, current.month, current.day);
      list.removeWhere((o) => o.dateKey == key);
      list.add(_SrDateOverride(dateKey: key, updater: updater, createdAt: now));
      current = current.add(const Duration(days: 1));
    }
  }

  // ─── Actions ───────────────────────────────────────────────────

  Future<void> _deactivateSpecialRates(DateTime from, DateTime to) async {
    setState(() => _saving = true);
    try {
      final ids = <String>{};
      var cur = from;
      while (!cur.isAfter(to)) {
        final model = _dayModel(cur);
        if (model?.idSpecialRate != null) ids.add(model!.idSpecialRate!);
        cur = cur.add(const Duration(days: 1));
      }

      if (ids.isEmpty) {
        _snack('No se encontró el ID de la tarifa. Recarga e intenta de nuevo.');
        return;
      }

      final service = ref.read(specialRateServiceProvider);
      for (final id in ids) {
        await service.deactivateSpecialRate(id, propertyId: widget.propertyId);
      }

      if (!mounted) return;

      final deactivateUpdater = (CalendarDayModel d) => d.copyWith(
        priceSource: null,
        idSpecialRate: null,
        specialRateReason: null,
      );

      // Actualización optimista + guardar overrides para sobrevivir navegación
      final updated = Map<DateTime, CalendarDayModel>.from(_calendarMap);
      var current = from;
      while (!current.isAfter(to)) {
        final key = DateTime.utc(current.year, current.month, current.day);
        final model = updated[key];
        if (model != null && ids.contains(model.idSpecialRate)) {
          updated[key] = deactivateUpdater(model);
        }
        current = current.add(const Duration(days: 1));
      }
      _storeOverrides(from, to, deactivateUpdater);
      setState(() {
        _calendarMap = updated;
        _calendarKey++;
        _startDate = null;
        _endDate = null;
      });

      _snack('Tarifa especial desactivada', success: true);
    } catch (e) {
      if (mounted) _snack(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedType == null) {
      _snack('Selecciona el tipo de espacio');
      return;
    }
    if (_startDate == null || _endDate == null) {
      _snack('Selecciona el rango de fechas');
      return;
    }
    final price =
        double.tryParse(_priceCtrl.text.trim().replaceAll(',', '.'));
    if (price == null || price < 0.01) {
      _snack('Ingresa un precio válido (mín. \$0.01)');
      return;
    }

    final start = _startDate!;
    final end = _endDate!;
    setState(() => _saving = true);
    try {
      final service = ref.read(specialRateServiceProvider);
      await service.createSpecialRate(CreateSpecialRateRequest(
        idProperty: widget.propertyId,
        propertyType: _selectedType!,
        startDate: _apiDate(start),
        endDate: _apiDate(end),
        specialPrice: price,
        reason: _reasonCtrl.text.trim(),
        description: _descCtrl.text.trim(),
      ));
      if (!mounted) return;

      final createUpdater = (CalendarDayModel d) => d.copyWith(
        priceSource: 'specialRate',
        price: price,
      );

      // Actualización optimista + guardar overrides para sobrevivir navegación
      final updated = Map<DateTime, CalendarDayModel>.from(_calendarMap);
      var current = start;
      while (!current.isAfter(end)) {
        final key = DateTime.utc(current.year, current.month, current.day);
        final model = updated[key];
        if (model != null) {
          updated[key] = createUpdater(model);
        }
        current = current.add(const Duration(days: 1));
      }
      _storeOverrides(start, end, createUpdater);
      setState(() {
        _calendarMap = updated;
        _calendarKey++;
        _startDate = null;
        _endDate = null;
      });
      _priceCtrl.clear();
      _reasonCtrl.clear();
      _descCtrl.clear();

      _snack('Tarifa especial creada', success: true);
    } catch (e) {
      _snack(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ─── Sheet launchers ───────────────────────────────────────────

  Future<void> _showRangePicker(BuildContext context) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => SrRangePickerSheet(
          calendarMap: _calendarMap,
          calendarKey: _calendarKey,
          initialStart: _startDate,
          initialEnd: _endDate,
          shortPrice: _shortPrice,
          fmtDate: _fmtDate,
          onConfirm: (start, end) =>
              setState(() {
                _startDate = start;
                _endDate = end;
              }),
        ),
      );

  Future<void> _showDeactivateSheet(BuildContext context) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => SrDeactivateSheet(
          calendarMap: _calendarMap,
          calendarKey: _calendarKey,
          fmtDate: _fmtDate,
          onDeactivate: _deactivateSpecialRates,
        ),
      );

  // ─── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _kDark,
        title: const Text('Nueva tarifa especial',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _isLoadingCalendar
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5, color: _kPrimary),
                  )
                : _calendarLoadError != null
                    ? TextButton.icon(
                        onPressed: _loadCalendar,
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Reintentar',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent),
                      )
                    : TextButton.icon(
                        onPressed: () => _showDeactivateSheet(context),
                        icon: const Icon(Icons.remove_circle_outline, size: 16),
                        label: const Text('Eliminar tarifas',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        style: TextButton.styleFrom(
                            foregroundColor: _kSpecialRate),
                      ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildPropertyHeader(),
            const SizedBox(height: 24),
            _section('Tipo de espacio', _buildTypeSelector()),
            const SizedBox(height: 20),
            _section('Rango de fechas', _buildDateCard()),
            const SizedBox(height: 20),
            _section('Precio especial', _buildPriceField()),
            const SizedBox(height: 20),
            _section('Motivo (opcional)',
                _buildTextField(_reasonCtrl, hint: 'Ej. Semana Santa', maxLength: 200)),
            const SizedBox(height: 20),
            _section('Descripción adicional (opcional)',
                _buildTextField(_descCtrl,
                    hint: 'Detalle de la tarifa...', maxLines: 3, maxLength: 500)),
            const SizedBox(height: 28),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // ─── Sub-builders ──────────────────────────────────────────────

  Widget _section(String label, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700)),
          const SizedBox(height: 10),
          child,
        ],
      );

  Widget _buildPropertyHeader() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 50,
                height: 50,
                child: widget.coverImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.coverImageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (ctx, url, err) => _imgPlaceholder(),
                      )
                    : _imgPlaceholder(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.propertyTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: _kDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('Propiedad seleccionada',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildTypeSelector() => Wrap(
        spacing: 10,
        runSpacing: 8,
        children: widget.availableTypes.map((type) {
          final selected = _selectedType == type;
          return GestureDetector(
            onTap: () => setState(() => _selectedType = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? _kPrimary.withValues(alpha: 0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: selected ? _kPrimary : Colors.grey.shade200,
                    width: selected ? 1.5 : 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_typeIcons[type] ?? Icons.pool_rounded,
                      size: 17,
                      color: selected ? _kPrimary : Colors.grey.shade500),
                  const SizedBox(width: 7),
                  Text(_typeLabels[type] ?? type,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? _kPrimary : Colors.grey.shade600)),
                ],
              ),
            ),
          );
        }).toList(),
      );

  Widget _buildDateCard() {
    final hasDates = _startDate != null && _endDate != null;
    final sameDay = hasDates && DateUtils.isSameDay(_startDate, _endDate);
    return GestureDetector(
      onTap: () => _showRangePicker(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasDates
                ? _kPrimary.withValues(alpha: 0.5)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_rounded,
                size: 20,
                color: hasDates ? _kPrimary : Colors.grey.shade400),
            const SizedBox(width: 10),
            Expanded(
              child: hasDates
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sameDay
                              ? _fmtDate(_startDate!)
                              : '${_fmtDate(_startDate!)}  →  ${_fmtDate(_endDate!)}',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _kDark),
                        ),
                        if (!sameDay) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${_endDate!.difference(_startDate!).inDays + 1} días',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ],
                    )
                  : Text('Selecciona el rango de fechas',
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade400)),
            ),
            if (_isLoadingCalendar)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 1.5, color: Colors.grey.shade300),
              )
            else
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade300, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceField() => TextField(
        controller: _priceCtrl,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: _inputDecoration(hint: '0.00', prefixText: '\$ '),
      );

  Widget _buildTextField(TextEditingController ctrl,
          {required String hint, int maxLines = 1, int? maxLength}) =>
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        maxLength: maxLength,
        style: const TextStyle(fontSize: 14),
        decoration: _inputDecoration(hint: hint),
      );

  InputDecoration _inputDecoration({required String hint, String? prefixText}) =>
      InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kPrimary, width: 1.5),
        ),
      );

  Widget _buildSaveButton() => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _saving ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            disabledBackgroundColor: _kPrimary.withValues(alpha: 0.5),
          ),
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text('Guardar tarifa',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ),
      );

  // ─── Utilities ─────────────────────────────────────────────────

  String _shortPrice(double? price) {
    if (price == null) return '';
    if (price >= 1000) {
      final k = price / 1000;
      return '\$${k == k.truncateToDouble() ? k.toInt() : k.toStringAsFixed(1)}k';
    }
    return '\$${price.toInt()}';
  }

  String _fmtDate(DateTime d) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${d.day} ${months[d.month - 1]}, ${d.year}';
  }

  String _apiDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}'
      '-${d.day.toString().padLeft(2, '0')}';

  void _snack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? _kPrimary : Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Widget _imgPlaceholder() => Container(
        color: Colors.grey.shade100,
        child: Icon(Icons.villa_outlined,
            color: Colors.grey.shade300, size: 24),
      );
}

class _SrDateOverride {
  final DateTime dateKey;
  final CalendarDayModel Function(CalendarDayModel existing) updater;
  final DateTime createdAt;

  _SrDateOverride({
    required this.dateKey,
    required this.updater,
    required this.createdAt,
  });
}
