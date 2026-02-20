import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pool_and_chill_app/data/models/special_rate_model.dart';
import 'package:pool_and_chill_app/data/services/special_rate_service.dart';

class SpecialRateFormScreen extends ConsumerStatefulWidget {
  final String propertyId;
  final String propertyTitle;
  final String coverImageUrl;
  final List<String> availableTypes; // ['pool', 'cabin', 'camping']

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

class _SpecialRateFormScreenState extends ConsumerState<SpecialRateFormScreen> {
  static const _kPrimary = Color(0xFF3CA2A2);
  static const _kDark = Color(0xFF1A1A2E);

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

  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;

  final _priceCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.availableTypes.isNotEmpty) {
      _selectedType = widget.availableTypes.first;
    }
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _reasonCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _kDark,
        title: const Text(
          'Nueva tarifa especial',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
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
            _section(
              'Motivo (opcional)',
              _buildTextField(
                _reasonCtrl,
                hint: 'Ej. Semana Santa',
                maxLength: 200,
              ),
            ),
            const SizedBox(height: 20),
            _section(
              'Descripción adicional (opcional)',
              _buildTextField(
                _descCtrl,
                hint: 'Detalle de la tarifa...',
                maxLines: 3,
                maxLength: 500,
              ),
            ),
            const SizedBox(height: 28),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // ─── Secciones UI ─────────────────────────────────────────────

  Widget _section(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildPropertyHeader() {
    return Container(
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
                Text(
                  widget.propertyTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: _kDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Propiedad seleccionada',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Wrap(
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
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _typeIcons[type] ?? Icons.pool_rounded,
                  size: 17,
                  color: selected ? _kPrimary : Colors.grey.shade500,
                ),
                const SizedBox(width: 7),
                Text(
                  _typeLabels[type] ?? type,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? _kPrimary : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateCard() {
    final hasDates = _startDate != null && _endDate != null;
    final sameDay = hasDates &&
        DateUtils.isSameDay(_startDate, _endDate);

    return GestureDetector(
      onTap: _pickDateRange,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            Icon(
              Icons.calendar_month_rounded,
              size: 20,
              color: hasDates ? _kPrimary : Colors.grey.shade400,
            ),
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
                            color: _kDark,
                          ),
                        ),
                        if (!sameDay) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${_endDate!.difference(_startDate!).inDays + 1} días',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500),
                          ),
                        ],
                      ],
                    )
                  : Text(
                      'Selecciona el rango de fechas',
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade400),
                    ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade300, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceField() {
    return TextField(
      controller: _priceCtrl,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      style:
          const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: _inputDecoration(hint: '0.00', prefixText: '\$ '),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl, {
    required String hint,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(fontSize: 14),
      decoration: _inputDecoration(hint: hint),
    );
  }

  InputDecoration _inputDecoration({required String hint, String? prefixText}) {
    return InputDecoration(
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
  }

  Widget _buildSaveButton() {
    return SizedBox(
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
            : const Text(
                'Guardar tarifa',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15),
              ),
      ),
    );
  }

  // ─── Acciones ─────────────────────────────────────────────────

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final result = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 730)),
      initialDateRange: (_startDate != null && _endDate != null)
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _kPrimary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: _kDark,
          ),
          textButtonTheme: TextButtonThemeData(
            style:
                TextButton.styleFrom(foregroundColor: _kPrimary),
          ),
        ),
        child: child!,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _startDate = result.start;
        _endDate = result.end;
      });
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

    setState(() => _saving = true);
    try {
      final service = ref.read(specialRateServiceProvider);
      await service.createSpecialRate(CreateSpecialRateRequest(
        idProperty: widget.propertyId,
        propertyType: _selectedType!,
        startDate: _apiDate(_startDate!),
        endDate: _apiDate(_endDate!),
        specialPrice: price,
        reason: _reasonCtrl.text.trim(),
        description: _descCtrl.text.trim(),
      ));
      if (mounted) {
        _snack('Tarifa especial creada', success: true);
        Navigator.pop(context);
      }
    } catch (e) {
      _snack(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ─── Utilidades ───────────────────────────────────────────────

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
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Widget _imgPlaceholder() => Container(
        color: Colors.grey.shade100,
        child: Icon(Icons.villa_outlined,
            color: Colors.grey.shade300, size: 24),
      );
}
