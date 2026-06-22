import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';

/// Parámetros de búsqueda confirmados por el usuario.
class SearchParams {
  final DateTime checkIn;
  final DateTime? checkOut;
  final int guests;
  final bool hasPool;
  final bool hasCabin;
  final bool hasCamping;

  const SearchParams({
    required this.checkIn,
    this.checkOut,
    required this.guests,
    this.hasPool = false,
    this.hasCabin = false,
    this.hasCamping = false,
  });

  String get checkInFormatted => _fmt(checkIn);
  String get checkOutFormatted => checkOut != null ? _fmt(checkOut!) : '';

  String get datesSummary {
    if (checkOut == null || checkOut == checkIn) {
      return '${checkIn.day} ${_monthShort(checkIn.month)} · solo entrada';
    }
    final n = nights;
    if (checkIn.month == checkOut!.month) {
      return '${checkIn.day}–${checkOut!.day} ${_monthShort(checkIn.month)} · $n ${n == 1 ? "noche" : "noches"}';
    }
    return '${checkIn.day} ${_monthShort(checkIn.month)} – ${checkOut!.day} ${_monthShort(checkOut!.month)} · $n ${n == 1 ? "noche" : "noches"}';
  }

  String get guestsSummary =>
      '$guests ${guests == 1 ? 'huésped' : 'huéspedes'}';

  int get nights {
    if (checkOut == null) return 1;
    final d = checkOut!.difference(checkIn).inDays;
    return d < 1 ? 1 : d;
  }

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

class SearchSheet extends StatefulWidget {
  const SearchSheet({super.key});

  static Future<SearchParams?> show(BuildContext context) {
    return showModalBottomSheet<SearchParams>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SearchSheet(),
    );
  }

  @override
  State<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  static const _primary = Color(0xFF3CA2A2);
  static const _dark = Color(0xFF1A1A2E);

  bool _hasPool = false;
  bool _hasCabin = false;
  bool _hasCamping = false;

  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime _focusedDay = DateTime.now();

  DateTime get _firstDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _lastDate => _firstDate.add(const Duration(days: 365));

  bool get _typeSelected => _hasPool || _hasCabin || _hasCamping;
  bool get _isSingleDayMode => _hasPool && !_hasCabin && !_hasCamping;
  bool get _isRangeRequired => _hasCabin || _hasCamping;

  bool get _canSearch {
    if (!_typeSelected || _rangeStart == null) return false;
    if (_isRangeRequired) return _rangeEnd != null;
    return true;
  }

  int get _nights =>
      (_rangeStart != null && _rangeEnd != null)
          ? _rangeEnd!.difference(_rangeStart!).inDays.clamp(1, 999)
          : 1;

  void _toggleType(String type) {
    HapticFeedback.selectionClick();
    setState(() {
      switch (type) {
        case 'pool':   _hasPool   = !_hasPool;
        case 'cabin':  _hasCabin  = !_hasCabin;
        case 'camping': _hasCamping = !_hasCamping;
      }
      // Al cambiar a día único limpiar el rango
      if (_isSingleDayMode) _rangeEnd = null;
      // Al cambiar a rango obligatorio y solo tenía un día, resetear
      if (_isRangeRequired && _rangeEnd == null) _rangeStart = null;
    });
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    setState(() {
      _rangeStart = selected;
      _rangeEnd = null;
      _focusedDay = focused;
    });
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focused) {
    setState(() {
      _rangeStart = start;
      _rangeEnd = end;
      _focusedDay = focused;
    });
  }

  void _confirm() {
    if (!_canSearch) return;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(
      SearchParams(
        checkIn: _rangeStart!,
        checkOut: _isSingleDayMode ? null : _rangeEnd,
        guests: 1,
        hasPool: _hasPool,
        hasCabin: _hasCabin,
        hasCamping: _hasCamping,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildTypeSelector(),
          // El calendario solo aparece tras seleccionar tipo
          AnimatedSize(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOut,
            child: _typeSelected
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Divider(height: 1),
                      _buildSelectionHeader(),
                      _buildCalendar(),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          const Divider(height: 1),
          _buildSearchButton(),
        ],
      ),
    );
  }

  // ── Handle ───────────────────────────────────────────────────────

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
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

  // ── Selector de tipo (prominente) ────────────────────────────────

  Widget _buildTypeSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _typeSelected ? '¿Qué buscas?' : '¿Qué estás buscando?',
              key: ValueKey(_typeSelected),
              style: TextStyle(
                fontSize: _typeSelected ? 16 : 22,
                fontWeight: FontWeight.w800,
                color: _dark,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _typeSelected
                ? 'Puedes combinar opciones'
                : 'Selecciona uno o más tipos de espacio',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _typeChip(
                label: 'Alberca',
                icon: Icons.pool_rounded,
                selected: _hasPool,
                onTap: () => _toggleType('pool'),
              ),
              const SizedBox(width: 10),
              _typeChip(
                label: 'Cabaña',
                icon: Icons.cabin_rounded,
                selected: _hasCabin,
                onTap: () => _toggleType('cabin'),
              ),
              const SizedBox(width: 10),
              _typeChip(
                label: 'Camping',
                icon: Icons.forest_rounded,
                selected: _hasCamping,
                onTap: () => _toggleType('camping'),
              ),
            ],
          ),
          // Nota de modo calendario
          if (_typeSelected) ...[
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Container(
                key: ValueKey(_isSingleDayMode),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isSingleDayMode
                      ? _primary.withValues(alpha: 0.08)
                      : const Color(0xFF3E838C).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isSingleDayMode
                          ? Icons.wb_sunny_rounded
                          : Icons.nights_stay_rounded,
                      size: 14,
                      color: _primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isSingleDayMode
                          ? 'Solo alberca · elige un día'
                          : _isRangeRequired
                              ? 'Check-in y check-out obligatorios'
                              : 'Elige rango de fechas',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _typeChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            vertical: _typeSelected ? 10 : 16,
          ),
          decoration: BoxDecoration(
            color: selected ? _primary : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? _primary : Colors.grey.shade200,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: _typeSelected ? 22 : 30,
                color: selected ? Colors.white : Colors.grey.shade600,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: _typeSelected ? 12 : 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : _dark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header de fechas ─────────────────────────────────────────────

  Widget _buildSelectionHeader() {
    String title;
    String subtitle;

    if (_rangeStart == null) {
      title = _isSingleDayMode ? '¿Qué día quieres ir?' : '¿Cuándo quieres ir?';
      subtitle = _isRangeRequired
          ? 'Elige la fecha de entrada'
          : 'Selecciona la fecha';
    } else if (_isSingleDayMode) {
      title =
          '${_rangeStart!.day} de ${SearchParams._monthShort(_rangeStart!.month)}';
      subtitle = 'Día seleccionado';
    } else if (_rangeEnd == null) {
      title = _isRangeRequired ? 'Ahora elige la salida' : 'Elige la salida';
      subtitle = _isRangeRequired
          ? 'Obligatorio · entrada: ${_rangeStart!.day} ${SearchParams._monthShort(_rangeStart!.month)}'
          : 'Opcional · entrada: ${_rangeStart!.day} ${SearchParams._monthShort(_rangeStart!.month)}';
    } else {
      final n = _nights;
      title = '$n ${n == 1 ? "noche" : "noches"}';
      subtitle =
          '${_rangeStart!.day} ${SearchParams._monthShort(_rangeStart!.month)} → '
          '${_rangeEnd!.day} ${SearchParams._monthShort(_rangeEnd!.month)}';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    title,
                    key: ValueKey(title),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _dark,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          if (_rangeStart != null)
            TextButton(
              onPressed: () => setState(() {
                _rangeStart = null;
                _rangeEnd = null;
              }),
              child: const Text('Limpiar',
                  style: TextStyle(color: _primary, fontSize: 13)),
            ),
        ],
      ),
    );
  }

  // ── Calendario ───────────────────────────────────────────────────

  Widget _buildCalendar() {
    final calStyle = CalendarStyle(
      outsideDaysVisible: false,
      cellMargin: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
      defaultTextStyle:
          const TextStyle(fontSize: 14, color: _dark),
      weekendTextStyle:
          const TextStyle(fontSize: 14, color: _dark),
      disabledTextStyle:
          TextStyle(fontSize: 14, color: Colors.grey.shade300),
      rangeStartDecoration:
          const BoxDecoration(color: _primary, shape: BoxShape.circle),
      rangeStartTextStyle: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
      rangeEndDecoration:
          const BoxDecoration(color: _primary, shape: BoxShape.circle),
      rangeEndTextStyle: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
      withinRangeDecoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.10),
        shape: BoxShape.rectangle,
      ),
      withinRangeTextStyle: const TextStyle(fontSize: 14, color: _dark),
      todayDecoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      todayTextStyle: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: _primary),
      selectedDecoration:
          const BoxDecoration(color: _primary, shape: BoxShape.circle),
      selectedTextStyle: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
    );

    final headerStyle = HeaderStyle(
      titleCentered: true,
      formatButtonVisible: false,
      titleTextStyle: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w700, color: _dark),
      leftChevronIcon:
          const Icon(Icons.chevron_left_rounded, color: _primary, size: 26),
      rightChevronIcon:
          const Icon(Icons.chevron_right_rounded, color: _primary, size: 26),
      headerPadding: const EdgeInsets.symmetric(vertical: 4),
    );

    final daysStyle = DaysOfWeekStyle(
      weekdayStyle: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade400),
      weekendStyle: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade400),
    );

    if (_isSingleDayMode) {
      return TableCalendar<void>(
        locale: 'es_ES',
        firstDay: _firstDate,
        lastDay: _lastDate,
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) =>
            _rangeStart != null && isSameDay(day, _rangeStart),
        onDaySelected: _onDaySelected,
        onPageChanged: (d) => setState(() => _focusedDay = d),
        calendarFormat: CalendarFormat.month,
        availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: headerStyle,
        daysOfWeekStyle: daysStyle,
        calendarStyle: calStyle,
      );
    }

    return TableCalendar<void>(
      locale: 'es_ES',
      firstDay: _firstDate,
      lastDay: _lastDate,
      focusedDay: _focusedDay,
      rangeStartDay: _rangeStart,
      rangeEndDay: _rangeEnd,
      rangeSelectionMode: RangeSelectionMode.toggledOn,
      onRangeSelected: _onRangeSelected,
      onPageChanged: (d) => setState(() => _focusedDay = d),
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: headerStyle,
      daysOfWeekStyle: daysStyle,
      calendarStyle: calStyle,
    );
  }

  // ── Botón buscar ─────────────────────────────────────────────────

  Widget _buildSearchButton() {
    final String label;
    if (!_typeSelected) {
      label = 'Elige qué buscas primero';
    } else if (_rangeStart == null) {
      label = 'Selecciona las fechas';
    } else if (_isRangeRequired && _rangeEnd == null) {
      label = 'Elige la fecha de salida';
    } else {
      label = 'Buscar propiedades';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 38),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _canSearch ? 1.0 : 0.45,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _canSearch ? _confirm : null,
            icon: const Icon(Icons.search_rounded, size: 20),
            label: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              disabledBackgroundColor: _primary,
              foregroundColor: Colors.white,
              elevation: _canSearch ? 3 : 0,
              shadowColor: _primary.withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
