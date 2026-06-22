import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// Resultado de la selección de rango de fechas.
class DateRangeResult {
  final DateTime checkIn;
  final DateTime? checkOut;

  const DateRangeResult({required this.checkIn, this.checkOut});

  bool get isRange => checkOut != null;

  String get checkInFormatted => _fmt(checkIn);
  String get checkOutFormatted => checkOut != null ? _fmt(checkOut!) : '';

  /// Etiqueta compacta: "17–19 jun" o "17 jun"
  String get summaryLabel {
    if (checkOut == null) {
      return '${checkIn.day} ${_monthShort(checkIn.month)}';
    }
    if (checkIn.month == checkOut!.month) {
      return '${checkIn.day}–${checkOut!.day} ${_monthShort(checkIn.month)}';
    }
    return '${checkIn.day} ${_monthShort(checkIn.month)} – ${checkOut!.day} ${_monthShort(checkOut!.month)}';
  }

  int get nights => checkOut != null ? checkOut!.difference(checkIn).inDays : 1;

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _monthShort(int m) {
    const months = [
      '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return months[m];
  }
}

/// Bottom sheet de selección de rango de fechas.
/// Muestra un calendario completo con selección de inicio y fin.
/// Devuelve [DateRangeResult] vía [Navigator.pop] al confirmar.
class DateRangePickerSheet extends StatefulWidget {
  final DateRangeResult? initial;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DateRangePickerSheet({
    super.key,
    this.initial,
    this.firstDate,
    this.lastDate,
  });

  static Future<DateRangeResult?> show(
    BuildContext context, {
    DateRangeResult? initial,
  }) {
    return showModalBottomSheet<DateRangeResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DateRangePickerSheet(initial: initial),
    );
  }

  @override
  State<DateRangePickerSheet> createState() => _DateRangePickerSheetState();
}

class _DateRangePickerSheetState extends State<DateRangePickerSheet> {
  static const _primary = Color(0xFF3CA2A2);

  late DateTime _focusedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  final RangeSelectionMode _mode = RangeSelectionMode.toggledOn;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = widget.initial?.checkIn ?? now;
    _rangeStart = widget.initial?.checkIn;
    _rangeEnd = widget.initial?.checkOut;
  }

  DateTime get _firstDate {
    final now = DateTime.now();
    return widget.firstDate ?? DateTime(now.year, now.month, now.day);
  }

  DateTime get _lastDate {
    return widget.lastDate ?? _firstDate.add(const Duration(days: 365));
  }

  bool get _canConfirm => _rangeStart != null;

  String get _headerText {
    if (_rangeStart == null) return 'Selecciona la fecha de entrada';
    if (_rangeEnd == null) return 'Selecciona la fecha de salida';
    final result = DateRangeResult(checkIn: _rangeStart!, checkOut: _rangeEnd);
    return '${result.nights} ${result.nights == 1 ? 'noche' : 'noches'} seleccionadas';
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focused) {
    setState(() {
      _focusedDay = focused;
      _rangeStart = start;
      _rangeEnd = end;
    });
  }

  void _confirm() {
    if (_rangeStart == null) return;
    Navigator.of(context).pop(
      DateRangeResult(checkIn: _rangeStart!, checkOut: _rangeEnd),
    );
  }

  void _clear() {
    setState(() {
      _rangeStart = null;
      _rangeEnd = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildHeader(),
            _buildCalendar(),
            _buildLegend(),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fechas de estancia',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _headerText,
                    key: ValueKey(_headerText),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_rangeStart != null)
            TextButton(
              onPressed: _clear,
              child: const Text(
                'Limpiar',
                style: TextStyle(color: _primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar<void>(
      locale: 'es_ES',
      firstDay: _firstDate,
      lastDay: _lastDate,
      focusedDay: _focusedDay,
      rangeStartDay: _rangeStart,
      rangeEndDay: _rangeEnd,
      rangeSelectionMode: _mode,
      onRangeSelected: _onRangeSelected,
      onPageChanged: (focused) => setState(() => _focusedDay = focused),
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A2E),
        ),
        leftChevronIcon:
            const Icon(Icons.chevron_left_rounded, color: _primary, size: 28),
        rightChevronIcon:
            const Icon(Icons.chevron_right_rounded, color: _primary, size: 28),
        headerPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
        ),
        weekendStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
        ),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        cellMargin: const EdgeInsets.symmetric(vertical: 3, horizontal: 1),
        defaultTextStyle:
            const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
        weekendTextStyle:
            const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
        disabledTextStyle:
            TextStyle(fontSize: 14, color: Colors.grey.shade300),
        // Día de inicio del rango
        rangeStartDecoration: const BoxDecoration(
          color: _primary,
          shape: BoxShape.circle,
        ),
        rangeStartTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        // Día de fin del rango
        rangeEndDecoration: const BoxDecoration(
          color: _primary,
          shape: BoxShape.circle,
        ),
        rangeEndTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        // Días intermedios del rango
        withinRangeDecoration: BoxDecoration(
          color: _primary.withValues(alpha: 0.12),
          shape: BoxShape.rectangle,
        ),
        withinRangeTextStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFF1A1A2E),
        ),
        // Hoy
        todayDecoration: BoxDecoration(
          color: _primary.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _primary,
        ),
        // Día sencillo seleccionado (sin rango)
        selectedDecoration: const BoxDecoration(
          color: _primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _legendDot(color: _primary),
          const SizedBox(width: 6),
          Text(
            'Entrada / Salida',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 16),
          _legendDot(color: _primary.withValues(alpha: 0.15)),
          const SizedBox(width: 6),
          Text(
            'Días seleccionados',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _legendDot({required Color color}) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _canConfirm ? _confirm : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            disabledBackgroundColor: Colors.grey.shade200,
            foregroundColor: Colors.white,
            elevation: _canConfirm ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            _rangeStart == null
                ? 'Selecciona las fechas'
                : _rangeEnd == null
                    ? 'Solo 1 día (confirmar)'
                    : 'Confirmar fechas',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
