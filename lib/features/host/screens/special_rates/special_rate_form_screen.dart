import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:pool_and_chill_app/data/models/special_rate_model.dart';
import 'package:pool_and_chill_app/data/services/special_rate_service.dart';

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

  // ─── Sections ─────────────────────────────────────────────────

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
    final sameDay =
        hasDates && DateUtils.isSameDay(_startDate, _endDate);

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

  InputDecoration _inputDecoration(
      {required String hint, String? prefixText}) {
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

  // ─── Custom calendar bottom sheet ─────────────────────────────

  Future<void> _showRangePicker(BuildContext context) async {
    DateTime? tempStart = _startDate;
    DateTime? tempEnd = _endDate;
    DateTime focused = _startDate ?? DateTime.now();

    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, now.day);
    final lastDay = firstDay.add(const Duration(days: 730));

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final hasDates = tempStart != null && tempEnd != null;
          final hasStart = tempStart != null && tempEnd == null;

          bool isInRange(DateTime day) {
            if (tempStart == null || tempEnd == null) return false;
            return day.isAfter(
                    tempStart!.subtract(const Duration(days: 1))) &&
                day.isBefore(tempEnd!.add(const Duration(days: 1)));
          }

          Widget buildCell(DateTime day,
              {bool isToday = false,
              bool inRange = false,
              bool isStart = false,
              bool isEnd = false}) {
            final isEndpoint = isStart || isEnd;
            Color bg;
            Color fg;
            if (isEndpoint) {
              bg = _kPrimary;
              fg = Colors.white;
            } else if (inRange) {
              bg = _kPrimary.withValues(alpha: 0.12);
              fg = _kDark;
            } else {
              bg = Colors.transparent;
              fg = _kDark;
            }
            return Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 1, vertical: 2),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: isEndpoint
                    ? BorderRadius.circular(10)
                    : (inRange
                        ? BorderRadius.zero
                        : BorderRadius.circular(10)),
                border: isToday && !isEndpoint && !inRange
                    ? Border.all(color: _kPrimary, width: 1.5)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            );
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.82,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, scrollCtrl) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 12, bottom: 4),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Title row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Selecciona el rango',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _kDark,
                            ),
                          ),
                        ),
                        if (hasDates || hasStart)
                          GestureDetector(
                            onTap: () => setSheet(() {
                              tempStart = null;
                              tempEnd = null;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Limpiar',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Calendar
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollCtrl,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      child: TableCalendar<void>(
                        locale: 'es_ES',
                        firstDay: firstDay,
                        lastDay: lastDay,
                        focusedDay: focused,
                        calendarFormat: CalendarFormat.month,
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Mes'
                        },
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        headerStyle: const HeaderStyle(
                          titleCentered: true,
                          formatButtonVisible: false,
                          titleTextStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _kDark,
                          ),
                          leftChevronIcon: Icon(
                              Icons.chevron_left,
                              color: _kPrimary),
                          rightChevronIcon: Icon(
                              Icons.chevron_right,
                              color: _kPrimary),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400,
                          ),
                          weekendStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        calendarStyle: const CalendarStyle(
                          rangeHighlightColor: Colors.transparent,
                        ),
                        rangeStartDay: tempStart,
                        rangeEndDay: tempEnd,
                        rangeSelectionMode:
                            RangeSelectionMode.disabled,
                        enabledDayPredicate: (day) =>
                            !day.isBefore(firstDay),
                        onDaySelected: (selected, f) {
                          setSheet(() {
                            focused = f;
                            if (tempStart == null ||
                                tempEnd != null) {
                              tempStart = selected;
                              tempEnd = null;
                            } else {
                              if (!selected.isBefore(tempStart!)) {
                                tempEnd = selected;
                              } else {
                                tempStart = selected;
                                tempEnd = null;
                              }
                            }
                          });
                        },
                        onPageChanged: (f) =>
                            setSheet(() => focused = f),
                        rowHeight: 56,
                        calendarBuilders: CalendarBuilders<void>(
                          defaultBuilder: (_, day, _) => buildCell(
                              day,
                              inRange: isInRange(day),
                              isStart: isSameDay(day, tempStart),
                              isEnd: isSameDay(day, tempEnd)),
                          todayBuilder: (_, day, _) => buildCell(
                              day,
                              isToday: true,
                              inRange: isInRange(day),
                              isStart: isSameDay(day, tempStart),
                              isEnd: isSameDay(day, tempEnd)),
                          rangeStartBuilder: (_, day, _) =>
                              buildCell(day,
                                  inRange: true, isStart: true),
                          rangeEndBuilder: (_, day, _) =>
                              buildCell(day,
                                  inRange: true, isEnd: true),
                          withinRangeBuilder: (_, day, _) =>
                              buildCell(day, inRange: true),
                          disabledBuilder: (_, day, _) => Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 1, vertical: 2),
                            alignment: Alignment.center,
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade300),
                            ),
                          ),
                          outsideBuilder: (_, day, _) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),

                  // Confirm bar
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        20,
                        12,
                        20,
                        MediaQuery.of(ctx).padding.bottom + 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasDates) ...[
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                            children: [
                              _summaryItem(
                                  'Inicio', _fmtDate(tempStart!)),
                              Container(
                                  width: 1,
                                  height: 32,
                                  color: Colors.grey.shade200),
                              _summaryItem(
                                  'Fin', _fmtDate(tempEnd!)),
                              Container(
                                  width: 1,
                                  height: 32,
                                  color: Colors.grey.shade200),
                              _summaryItem(
                                'Días',
                                '${tempEnd!.difference(tempStart!).inDays + 1}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ] else
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 12),
                            child: Text(
                              hasStart
                                  ? 'Inicio: ${_fmtDate(tempStart!)} — selecciona el fin'
                                  : 'Toca el primer día y luego el último',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: hasDates
                                ? () {
                                    Navigator.pop(ctx);
                                    setState(() {
                                      _startDate = tempStart;
                                      _endDate = tempEnd;
                                    });
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kPrimary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              disabledBackgroundColor:
                                  Colors.grey.shade200,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(14)),
                              textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            child: const Text('Confirmar fechas'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
              fontSize: 14, color: _kDark, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  // ─── Submit ────────────────────────────────────────────────────

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

  // ─── Utilities ─────────────────────────────────────────────────

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
