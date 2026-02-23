import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pool_and_chill_app/data/models/property/calendar_day_model.dart';
import 'sr_calendar_day_cell.dart';

const _kSpecialRate = Color(0xFFD4A017);
const _kDark = Color(0xFF1A1A2E);

/// Bottom sheet para seleccionar un rango y eliminar tarifas especiales en él.
class SrDeactivateSheet extends StatefulWidget {
  const SrDeactivateSheet({
    super.key,
    required this.calendarMap,
    required this.calendarKey,
    required this.fmtDate,
    required this.onDeactivate,
  });

  final Map<DateTime, CalendarDayModel> calendarMap;
  final int calendarKey;
  final String Function(DateTime) fmtDate;
  final void Function(DateTime start, DateTime end) onDeactivate;

  @override
  State<SrDeactivateSheet> createState() => _SrDeactivateSheetState();
}

class _SrDeactivateSheetState extends State<SrDeactivateSheet> {
  DateTime? _start;
  DateTime? _end;
  DateTime _focused = DateTime.now();

  CalendarDayModel? _dayModel(DateTime day) =>
      widget.calendarMap[DateTime.utc(day.year, day.month, day.day)];

  bool _inRange(DateTime day) {
    if (_start == null || _end == null) return false;
    return day.isAfter(_start!.subtract(const Duration(days: 1))) &&
        day.isBefore(_end!.add(const Duration(days: 1)));
  }

  bool get _hasSpecialInRange {
    if (_start == null || _end == null) return false;
    var cur = _start!;
    while (!cur.isAfter(_end!)) {
      if (_dayModel(cur)?.isSpecialRate == true) return true;
      cur = cur.add(const Duration(days: 1));
    }
    return false;
  }

  Widget _cell(DateTime day,
      {bool isToday = false,
      bool inRange = false,
      bool isStart = false,
      bool isEnd = false}) {
    final model = _dayModel(day);
    final isSpecialRate = model?.isSpecialRate ?? false;
    final isEndpoint = isStart || isEnd;
    return SrCalendarDayCell(
      day: day,
      model: model,
      accentColor: _kSpecialRate,
      isToday: isToday,
      inRange: inRange,
      isStart: isStart,
      isEnd: isEnd,
      subText: isSpecialRate && !isEndpoint && !inRange ? 'T.Esp.' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, now.day);
    final lastDay = firstDay.add(const Duration(days: 730));
    final hasDates = _start != null && _end != null;
    final hasStart = _start != null && _end == null;

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _handle(),
            _titleRow(hasDates || hasStart),
            _legend(),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TableCalendar<void>(
                  key: ValueKey('deactivate_${widget.calendarKey}'),
                  locale: 'es_ES',
                  firstDay: firstDay,
                  lastDay: lastDay,
                  focusedDay: _focused,
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: _kDark),
                    leftChevronIcon:
                        Icon(Icons.chevron_left, color: _kSpecialRate),
                    rightChevronIcon:
                        Icon(Icons.chevron_right, color: _kSpecialRate),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade400),
                    weekendStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade400),
                  ),
                  calendarStyle:
                      const CalendarStyle(rangeHighlightColor: Colors.transparent),
                  rangeStartDay: _start,
                  rangeEndDay: _end,
                  rangeSelectionMode: RangeSelectionMode.disabled,
                  enabledDayPredicate: (day) => !day.isBefore(firstDay),
                  onDaySelected: (selected, f) => setState(() {
                    _focused = f;
                    if (_start == null || _end != null) {
                      _start = selected;
                      _end = null;
                    } else {
                      if (!selected.isBefore(_start!)) {
                        _end = selected;
                      } else {
                        _start = selected;
                        _end = null;
                      }
                    }
                  }),
                  onPageChanged: (f) => setState(() => _focused = f),
                  rowHeight: 60,
                  calendarBuilders: CalendarBuilders<void>(
                    defaultBuilder: (_, day, _) => _cell(day,
                        inRange: _inRange(day),
                        isStart: isSameDay(day, _start),
                        isEnd: isSameDay(day, _end)),
                    todayBuilder: (_, day, _) => _cell(day,
                        isToday: true,
                        inRange: _inRange(day),
                        isStart: isSameDay(day, _start),
                        isEnd: isSameDay(day, _end)),
                    rangeStartBuilder: (_, day, _) =>
                        _cell(day, inRange: true, isStart: true),
                    rangeEndBuilder: (_, day, _) =>
                        _cell(day, inRange: true, isEnd: true),
                    withinRangeBuilder: (_, day, _) => _cell(day, inRange: true),
                    disabledBuilder: (_, day, _) => srDisabledDayCell(day),
                    outsideBuilder: (_, day, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            _actionBar(hasDates, hasStart),
          ],
        ),
      ),
    );
  }

  // ─── Sub-widgets ────────────────────────────────────────────────

  Widget _handle() => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2)),
        ),
      );

  Widget _titleRow(bool showClear) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.remove_circle_outline,
                color: _kSpecialRate, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Eliminar tarifas especiales',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: _kDark),
              ),
            ),
            if (showClear)
              GestureDetector(
                onTap: () => setState(() {
                  _start = null;
                  _end = null;
                }),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('Limpiar',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500)),
                ),
              ),
          ],
        ),
      );

  Widget _legend() => Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _kSpecialRate.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3),
                border:
                    Border.all(color: _kSpecialRate.withValues(alpha: 0.4)),
              ),
            ),
            const SizedBox(width: 6),
            Text('Días con tarifa especial',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      );

  Widget _actionBar(bool hasDates, bool hasStart) => Container(
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, -2))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasDates) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _summaryItem('Inicio', widget.fmtDate(_start!)),
                  Container(width: 1, height: 32, color: Colors.grey.shade200),
                  _summaryItem('Fin', widget.fmtDate(_end!)),
                  Container(width: 1, height: 32, color: Colors.grey.shade200),
                  _summaryItem(
                      'Días', '${_end!.difference(_start!).inDays + 1}'),
                ],
              ),
              const SizedBox(height: 12),
              if (!_hasSpecialInRange)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'No hay tarifas especiales en este rango',
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey.shade400),
                    textAlign: TextAlign.center,
                  ),
                ),
            ] else
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  hasStart
                      ? 'Inicio: ${widget.fmtDate(_start!)} — selecciona el fin'
                      : 'Toca el primer día y luego el último del rango',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: (hasDates && _hasSpecialInRange)
                    ? () {
                        Navigator.pop(context);
                        widget.onDeactivate(_start!, _end!);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kSpecialRate,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  disabledBackgroundColor: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                icon: const Icon(Icons.remove_circle_outline, size: 18),
                label: const Text('Eliminar tarifas del rango'),
              ),
            ),
          ],
        ),
      );

  Widget _summaryItem(String label, String value) => Column(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  fontSize: 14, color: _kDark, fontWeight: FontWeight.w700)),
        ],
      );
}
