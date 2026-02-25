import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:pool_and_chill_app/data/models/date_block_model.dart';
import 'package:pool_and_chill_app/data/models/property/index.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'package:pool_and_chill_app/data/services/date_block_service.dart';

class DateBlockCalendarScreen extends ConsumerStatefulWidget {
  final String propertyId;
  final String propertyTitle;
  final String coverImageUrl;
  final List<String> availableTypes;

  const DateBlockCalendarScreen({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
    required this.coverImageUrl,
    required this.availableTypes,
  });

  @override
  ConsumerState<DateBlockCalendarScreen> createState() =>
      _DateBlockCalendarScreenState();
}

class _DateBlockCalendarScreenState
    extends ConsumerState<DateBlockCalendarScreen> {
  static const _kPrimary = Color(0xFF2D9D91);
  static const _kDark = Color(0xFF1A1A2E);
  static const _kBlocked = Color(0xFFE07B2A);
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

  static const _reasonLabels = {
    'maintenance': 'Mantenimiento',
    'personal_use': 'Uso personal',
    'renovation': 'Remodelación',
    'weather': 'Clima',
    'other': 'Otro',
  };

  /// Mutaciones confirmadas por API que sobreviven navegación.
  /// Se aplican encima de datos del servidor hasta que este los refleje.
  static final Map<String, List<_DateOverride>> _pendingOverrides = {};

  // ─── Calendar state ────────────────────────────────────────────
  bool _isLoading = true;
  String? _loadError;
  Map<DateTime, CalendarDayModel> _calendarMap = {};
  int _calendarKey = 0;

  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  // ─── Form state ────────────────────────────────────────────────
  late String _selectedType;
  String? _selectedReason;
  final _notesCtrl = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.availableTypes.isNotEmpty
        ? widget.availableTypes.first
        : 'pool';
    _loadCalendar();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  // ─── Calendar loading ──────────────────────────────────────────

  Future<void> _loadCalendar() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final service = ref.read(propertyServiceProvider);
      final response = await service.getBookingCalendar(widget.propertyId);
      final map = <DateTime, CalendarDayModel>{};
      for (final day in response.data.calendar) {
        final dt = DateTime.parse(day.date);
        map[DateTime.utc(dt.year, dt.month, dt.day)] = day;
      }
      // Aplica mutaciones confirmadas que el servidor aún no refleja (caché backend)
      _applyPendingOverrides(map);
      if (!mounted) return;
      setState(() {
        _calendarMap = map;
        _calendarKey++;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'No se pudo cargar el calendario';
        _isLoading = false;
      });
    }
  }

  /// Aplica overrides pendientes sobre [map] y limpia los que ya caducaron
  /// o que el servidor ya refleja correctamente.
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

  /// Guarda overrides para el rango [start]..[end] que sobreviven navegación.
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
      list.add(_DateOverride(dateKey: key, updater: updater, createdAt: now));
      current = current.add(const Duration(days: 1));
    }
  }

  /// Actualiza [_calendarMap] para el rango [start]..[end] optimistamente.
  void _applyOptimisticUpdate(
    DateTime start,
    DateTime end,
    CalendarDayModel Function(CalendarDayModel existing) updater,
  ) {
    final updatedMap = Map<DateTime, CalendarDayModel>.from(_calendarMap);
    var current = start;
    while (!current.isAfter(end)) {
      final key = DateTime.utc(current.year, current.month, current.day);
      final existing = updatedMap[key];
      if (existing != null) updatedMap[key] = updater(existing);
      current = current.add(const Duration(days: 1));
    }
    setState(() {
      _calendarMap = updatedMap;
    });
  }

  // ─── Day helpers ───────────────────────────────────────────────

  CalendarDayModel? _dayModel(DateTime day) =>
      _calendarMap[DateTime.utc(day.year, day.month, day.day)];

  bool _isDayEnabled(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (day.isBefore(today)) return false;
    final model = _dayModel(day);
    if (model == null) return false;
    // Booked days cannot be selected; available and blocked can
    return !model.isBooked;
  }

  bool _isDayInRange(DateTime day) {
    if (_rangeStart == null || _rangeEnd == null) return false;
    return day.isAfter(_rangeStart!.subtract(const Duration(days: 1))) &&
        day.isBefore(_rangeEnd!.add(const Duration(days: 1)));
  }

  // ─── Selection ─────────────────────────────────────────────────

  void _onDaySelected(DateTime selected, DateTime focused) {
    if (!_isDayEnabled(selected)) return;
    setState(() {
      if (_rangeStart == null || _rangeEnd != null) {
        _rangeStart = selected;
        _rangeEnd = null;
      } else {
        if (!selected.isBefore(_rangeStart!)) {
          _rangeEnd = selected;
        } else {
          _rangeStart = selected;
          _rangeEnd = null;
        }
      }
      _focusedDay = focused;
    });
  }

  // ─── Computed helpers ──────────────────────────────────────────

  int get _daysCount {
    if (_rangeStart == null || _rangeEnd == null) return 0;
    return _rangeEnd!.difference(_rangeStart!).inDays + 1;
  }

  bool get _canBlock =>
      _rangeStart != null &&
      _rangeEnd != null &&
      _selectedReason != null;

  bool get _canUnblock =>
      _rangeStart != null && _rangeEnd != null;


  String _apiDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}'
      '-${d.day.toString().padLeft(2, '0')}';

  String _fmtDate(DateTime d) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${d.day} ${months[d.month - 1]}, ${d.year}';
  }

  // ─── Actions ───────────────────────────────────────────────────

  Future<void> _block() async {
    if (!_canBlock) return;
    setState(() => _saving = true);
    final start = _rangeStart!;
    final end = _rangeEnd!;
    final reason = _selectedReason!;
    try {
      final service = ref.read(dateBlockServiceProvider);
      await service.createDateBlock(CreateDateBlockRequest(
        idProperty: widget.propertyId,
        propertyType: _selectedType,
        startDate: _apiDate(start),
        endDate: _apiDate(end),
        reason: reason,
        notes: _notesCtrl.text.trim(),
      ));
      if (!mounted) return;
      _snack('Fechas bloqueadas exitosamente', success: true);
      final blockUpdater = (CalendarDayModel d) => d.copyWith(
        availabilityStatus: 'ownerBlocked',
        blockReason: reason,
      );
      _applyOptimisticUpdate(start, end, blockUpdater);
      _storeOverrides(start, end, blockUpdater);
      setState(() {
        _rangeStart = null;
        _rangeEnd = null;
        _selectedReason = null;
      });
      _notesCtrl.clear();
    } catch (e) {
      _snack(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _unblock() async {
    if (!_canUnblock) return;
    setState(() => _saving = true);
    final start = _rangeStart!;
    final end = _rangeEnd!;
    try {
      final service = ref.read(dateBlockServiceProvider);
      await service.deleteDateBlock(DeleteDateBlockRequest(
        idProperty: widget.propertyId,
        propertyType: _selectedType,
        startDate: _apiDate(start),
        endDate: _apiDate(end),
      ));
      if (!mounted) return;
      _snack('Fechas desbloqueadas exitosamente', success: true);
      final unblockUpdater = (CalendarDayModel d) => d.copyWith(
        availabilityStatus: 'available',
        blockReason: null,
      );
      _applyOptimisticUpdate(start, end, unblockUpdater);
      _storeOverrides(start, end, unblockUpdater);
      setState(() {
        _rangeStart = null;
        _rangeEnd = null;
      });
    } catch (e) {
      _snack(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }


  void _snack(String msg, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? _kPrimary : Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ─── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _kDark,
        title: const Text(
          'Bloquear fechas',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Property header
          _buildPropertyHeader(),
          const Divider(height: 1),

          // Type selector (only if multiple types)
          if (widget.availableTypes.length > 1) ...[
            _buildTypeSelector(),
            const Divider(height: 1),
          ],

          // Calendar
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _kPrimary))
                : _loadError != null
                    ? _buildError()
                    : _buildCalendar(),
          ),

          // Bottom bar
          _buildBottomBar(bottomPad),
        ],
      ),
    );
  }

  Widget _buildPropertyHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 44,
              child: widget.coverImageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.coverImageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _imgPlaceholder(),
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
                    color: _kDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Gestión de disponibilidad',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: widget.availableTypes.map((type) {
          final selected = _selectedType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedType = type;
                _rangeStart = null;
                _rangeEnd = null;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? _kPrimary.withValues(alpha: 0.1)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? _kPrimary : Colors.grey.shade200,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _typeIcons[type] ?? Icons.pool_rounded,
                      size: 15,
                      color:
                          selected ? _kPrimary : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _typeLabels[type] ?? type,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? _kPrimary
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(_loadError!,
              style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _loadCalendar,
            child: const Text('Reintentar',
                style: TextStyle(color: _kPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final firstDay = DateTime.utc(now.year, now.month, now.day);
    final lastDay = firstDay.add(const Duration(days: 365));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          TableCalendar<void>(
            key: ValueKey(_calendarKey),
            locale: 'es_ES',
            firstDay: firstDay,
            lastDay: lastDay,
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _kDark,
              ),
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: _kPrimary),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: _kPrimary),
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
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            rangeSelectionMode: RangeSelectionMode.disabled,
            enabledDayPredicate: _isDayEnabled,
            onDaySelected: _onDaySelected,
            onPageChanged: (focused) =>
                setState(() => _focusedDay = focused),
            rowHeight: 60,
            calendarBuilders: CalendarBuilders<void>(
              defaultBuilder: (context, day, focused) => _buildDayCell(
                day: day,
                isInRange: _isDayInRange(day),
                isRangeStart: isSameDay(day, _rangeStart),
                isRangeEnd: isSameDay(day, _rangeEnd),
              ),
              todayBuilder: (context, day, focused) => _buildDayCell(
                day: day,
                isToday: true,
                isInRange: _isDayInRange(day),
                isRangeStart: isSameDay(day, _rangeStart),
                isRangeEnd: isSameDay(day, _rangeEnd),
              ),
              rangeStartBuilder: (context, day, focused) => _buildDayCell(
                day: day,
                isInRange: true,
                isRangeStart: true,
                isRangeEnd: false,
              ),
              rangeEndBuilder: (context, day, focused) => _buildDayCell(
                day: day,
                isInRange: true,
                isRangeStart: false,
                isRangeEnd: true,
              ),
              withinRangeBuilder: (context, day, focused) => _buildDayCell(
                day: day,
                isInRange: true,
                isRangeStart: false,
                isRangeEnd: false,
              ),
              disabledBuilder: (context, day, focused) =>
                  _buildDisabledDayCell(day),
              outsideBuilder: (context, day, focused) =>
                  const SizedBox.shrink(),
            ),
          ),
          // Legend
          _buildLegend(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDayCell({
    required DateTime day,
    bool isToday = false,
    required bool isInRange,
    required bool isRangeStart,
    required bool isRangeEnd,
  }) {
    final model = _dayModel(day);
    final isOwnerBlocked = model?.isOwnerBlocked ?? false;
    final isSpecialRate = model?.isSpecialRate ?? false;
    final isEndpoint = isRangeStart || isRangeEnd;

    Color bgColor;
    Color textColor;
    Color? subColor;

    if (isEndpoint) {
      bgColor = _kPrimary;
      textColor = Colors.white;
      subColor = Colors.white.withValues(alpha: 0.8);
    } else if (isInRange) {
      bgColor = _kPrimary.withValues(alpha: 0.12);
      textColor = _kDark;
      subColor = _kPrimary;
    } else if (isOwnerBlocked) {
      bgColor = _kBlocked.withValues(alpha: 0.12);
      textColor = _kBlocked;
      subColor = _kBlocked;
    } else if (isSpecialRate) {
      bgColor = _kSpecialRate.withValues(alpha: 0.12);
      textColor = _kSpecialRate;
      subColor = _kSpecialRate;
    } else {
      bgColor = Colors.transparent;
      textColor = _kDark;
      subColor = Colors.grey.shade500;
    }

    String? subText;
    if (isOwnerBlocked && !isEndpoint && !isInRange) {
      subText = 'Bloq.';
    } else if (isSpecialRate && !isEndpoint && !isInRange) {
      subText = 'T.Esp.';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: isEndpoint
            ? BorderRadius.circular(10)
            : (isInRange ? BorderRadius.zero : BorderRadius.circular(10)),
        border: isToday && !isEndpoint && !isInRange
            ? Border.all(color: _kPrimary, width: 1.5)
            : (isOwnerBlocked && !isEndpoint && !isInRange
                ? Border.all(color: _kBlocked.withValues(alpha: 0.3))
                : isSpecialRate && !isEndpoint && !isInRange
                    ? Border.all(color: _kSpecialRate.withValues(alpha: 0.3))
                    : null),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          if (subText != null)
            Text(
              subText,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w500,
                color: subColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDisabledDayCell(DateTime day) {
    final model = _dayModel(day);
    final isBooked = model?.isBooked ?? false;
    final isPast = day.isBefore(DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
              decoration:
                  isBooked ? TextDecoration.lineThrough : null,
              decorationColor: Colors.grey.shade400,
            ),
          ),
          if (isBooked && !isPast)
            Text(
              'Reservado',
              style: TextStyle(fontSize: 7, color: Colors.grey.shade400),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(_kPrimary.withValues(alpha: 0.15), _kPrimary,
              'Seleccionado'),
          const SizedBox(width: 12),
          _legendItem(_kBlocked.withValues(alpha: 0.12), _kBlocked,
              'Bloqueado'),
          const SizedBox(width: 12),
          _legendItem(_kSpecialRate.withValues(alpha: 0.12), _kSpecialRate,
              'T. especial'),
          const SizedBox(width: 12),
          _legendItem(Colors.grey.shade200, Colors.grey.shade500,
              'Reservado'),
        ],
      ),
    );
  }

  Widget _legendItem(Color bg, Color fg, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: fg.withValues(alpha: 0.4)),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildBottomBar(double bottomPad) {
    final hasRange = _rangeStart != null && _rangeEnd != null;
    final hasStart = _rangeStart != null && _rangeEnd == null;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPad + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hint / date range summary
          if (!hasRange && !hasStart)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Icon(Icons.touch_app_rounded,
                      size: 16, color: Colors.grey.shade400),
                  const SizedBox(width: 8),
                  Text(
                    'Toca el primer día y luego el último',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),

          if (hasStart && !hasRange)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(
                'Inicio: ${_fmtDate(_rangeStart!)}  — Toca el día de fin',
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade600),
              ),
            ),

          if (hasRange) ...[
            // Date range row
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.date_range_rounded,
                      size: 18, color: _kPrimary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${_fmtDate(_rangeStart!)}  →  ${_fmtDate(_rangeEnd!)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kDark,
                      ),
                    ),
                  ),
                  Text(
                    '$_daysCount día${_daysCount == 1 ? '' : 's'}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Reason label
            Text(
              'Motivo del bloqueo',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),

            // Reason chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _reasonLabels.entries.map((e) {
                final selected = _selectedReason == e.key;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedReason = e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected
                          ? _kPrimary.withValues(alpha: 0.1)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? _kPrimary
                            : Colors.grey.shade200,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: selected
                            ? _kPrimary
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Notes field
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              maxLength: 500,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Notas adicionales (opcional)...',
                hintStyle:
                    TextStyle(color: Colors.grey.shade400, fontSize: 13),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: _kPrimary, width: 1.5),
                ),
                counterStyle: TextStyle(
                    fontSize: 10, color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 12),


            // Action buttons
            Row(
              children: [
                // Unblock (outlined)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving || !_canUnblock ? null : _unblock,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: BorderSide(
                        color: _saving || !_canUnblock
                            ? Colors.grey.shade200
                            : Colors.redAccent.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: _saving
                        ? const SizedBox.shrink()
                        : const Text(
                            'Desbloquear',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                // Block (filled)
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saving || !_canBlock ? null : _block,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Bloquear fechas',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        color: Colors.grey.shade100,
        child: Icon(Icons.villa_outlined,
            color: Colors.grey.shade300, size: 24),
      );
}

class _DateOverride {
  final DateTime dateKey;
  final CalendarDayModel Function(CalendarDayModel existing) updater;
  final DateTime createdAt;

  _DateOverride({
    required this.dateKey,
    required this.updater,
    required this.createdAt,
  });
}
