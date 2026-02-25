import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'package:pool_and_chill_app/data/models/booking/booking_model.dart';
import 'package:pool_and_chill_app/data/models/property/index.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'package:pool_and_chill_app/features/properties/Screens/booking_review_screen.dart';
import 'detail_constants.dart';

/// Bottom sheet con calendario de disponibilidad para reservar.
class BookingCalendarSheet extends ConsumerStatefulWidget {
  final String propertyId;
  final PropertyDetailResponse propertyDetail;

  const BookingCalendarSheet({
    super.key,
    required this.propertyId,
    required this.propertyDetail,
  });

  @override
  ConsumerState<BookingCalendarSheet> createState() =>
      _BookingCalendarSheetState();
}

class _BookingCalendarSheetState extends ConsumerState<BookingCalendarSheet> {
  bool _isLoading = true;
  bool _isConfirming = false;
  String? _error;
  Map<DateTime, CalendarDayModel> _calendarMap = {};
  int _calendarKey = 0;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool _showMaxWarning = false;

  late final bool _isPoolOnly;
  late final int? _minNights;
  late final int? _maxNights;

  @override
  void initState() {
    super.initState();
    final prop = widget.propertyDetail.property;
    _isPoolOnly = prop.hasPool && !prop.hasCabin && !prop.hasCamping;

    // Obtener minNights/maxNights de cabañas o camping.
    if (widget.propertyDetail.cabins.isNotEmpty) {
      _minNights = widget.propertyDetail.cabins.first.minNights;
      _maxNights = widget.propertyDetail.cabins.first.maxNights;
    } else if (widget.propertyDetail.campingAreas.isNotEmpty) {
      _minNights = widget.propertyDetail.campingAreas.first.minNights;
      _maxNights = widget.propertyDetail.campingAreas.first.maxNights;
    } else {
      _minNights = null;
      _maxNights = null;
    }

    _loadCalendar();
  }

  Future<void> _loadCalendar() async {
    try {
      final service = ref.read(propertyServiceProvider);
      final response =
          await service.getBookingCalendar(widget.propertyId);
      final map = <DateTime, CalendarDayModel>{};
      for (final day in response.data.calendar) {
        final dt = DateTime.parse(day.date);
        map[DateTime.utc(dt.year, dt.month, dt.day)] = day;
      }
      if (!mounted) return;
      setState(() {
        _calendarMap = map;
        _calendarKey++;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar el calendario';
        _isLoading = false;
      });
    }
  }

  // ─── Helpers de disponibilidad ─────────────────────────────────

  CalendarDayModel? _dayModel(DateTime day) {
    return _calendarMap[DateTime.utc(day.year, day.month, day.day)];
  }

  bool _isDayEnabled(DateTime day) {
    final model = _dayModel(day);
    if (model == null) return false;
    return model.isAvailable;
  }

  /// Verifica que todos los días del rango seleccionado estén disponibles.
  bool _isRangeFullyAvailable(DateTime start, DateTime end) {
    var current = start;
    while (!current.isAfter(end.subtract(const Duration(days: 1)))) {
      if (!_isDayEnabled(current)) return false;
      current = current.add(const Duration(days: 1));
    }
    return true;
  }

  void _triggerMaxWarning() {
    setState(() => _showMaxWarning = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showMaxWarning = false);
    });
  }

  // ─── Selección ─────────────────────────────────────────────────

  void _onDaySelected(DateTime selected, DateTime focused) {
    if (!_isDayEnabled(selected)) return;

    if (_isPoolOnly) {
      setState(() {
        _selectedDay = selected;
        _rangeStart = null;
        _rangeEnd = null;
        _focusedDay = focused;
      });
      return;
    }

    // Modo rango: primer tap = check-in, segundo tap = check-out.
    setState(() {
      if (_rangeStart == null || _rangeEnd != null) {
        _rangeStart = selected;
        _rangeEnd = null;
        _selectedDay = null;
      } else {
        if (selected.isAfter(_rangeStart!)) {
          final nights = selected.difference(_rangeStart!).inDays;

          // Validar maxNights: no permitir seleccionar más del máximo.
          if (_maxNights != null && nights > _maxNights) {
            _triggerMaxWarning();
            return;
          }

          if (_isRangeFullyAvailable(_rangeStart!, selected)) {
            _rangeEnd = selected;
          } else {
            _rangeStart = selected;
            _rangeEnd = null;
          }
        } else {
          _rangeStart = selected;
          _rangeEnd = null;
        }
        _selectedDay = null;
      }
      _focusedDay = focused;
    });
  }

  // ─── Cálculos de precio ────────────────────────────────────────

  double? get _singleDayPrice {
    if (_selectedDay == null) return null;
    return _dayModel(_selectedDay!)?.price;
  }

  int get _nightsCount {
    if (_rangeStart == null || _rangeEnd == null) return 0;
    return _rangeEnd!.difference(_rangeStart!).inDays;
  }

  double get _totalRangePrice {
    if (_rangeStart == null || _rangeEnd == null) return 0;
    double total = 0;
    var current = _rangeStart!;
    while (current.isBefore(_rangeEnd!)) {
      final model = _dayModel(current);
      total += model?.price ?? 0;
      current = current.add(const Duration(days: 1));
    }
    return total;
  }

  String? get _validationMessage {
    if (_isPoolOnly) return null;
    if (_rangeStart == null || _rangeEnd == null) return null;
    final nights = _nightsCount;
    if (_minNights != null && nights < _minNights) {
      return 'Mínimo $_minNights noches';
    }
    if (_maxNights != null && nights > _maxNights) {
      return 'Máximo $_maxNights noches';
    }
    return null;
  }

  bool get _canConfirm {
    if (_isPoolOnly) return _selectedDay != null;
    if (_rangeStart == null || _rangeEnd == null) return false;
    return _validationMessage == null;
  }

  // ─── Formato de precios ────────────────────────────────────────

  String _formatMXN(double amount) {
    final fmt = NumberFormat('#,##0', 'es_MX');
    return '\$${fmt.format(amount)}';
  }

  String _shortPrice(double? price) {
    if (price == null) return '';
    if (price >= 1000) {
      final k = price / 1000;
      if (k == k.truncateToDouble()) {
        return '\$${k.toInt()}k';
      }
      return '\$${k.toStringAsFixed(1)}k';
    }
    return '\$${price.toInt()}';
  }

  // ─── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Título
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Selecciona tus fechas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: kDetailDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kDetailPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _isPoolOnly
                          ? '1 día'
                          : _minNights != null
                              ? 'Mín. $_minNights noches'
                              : 'Rango de fechas',
                      style: const TextStyle(
                        fontSize: 12,
                        color: kDetailPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Contenido principal
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: kDetailPrimary))
                  : _error != null
                      ? _buildError()
                      : _buildCalendar(scrollController),
            ),

            // Resumen y botón
            _buildBottomBar(bottomPad),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline,
              size: 48, color: kDetailGreyLight),
          const SizedBox(height: 12),
          Text(_error!,
              style: const TextStyle(color: kDetailGreyLight)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadCalendar();
            },
            child: const Text('Reintentar',
                style: TextStyle(color: kDetailPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(ScrollController scrollController) {
    final now = DateTime.now();
    final firstDay = DateTime.utc(now.year, now.month, now.day);
    final lastDay = firstDay.add(const Duration(days: 180));

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TableCalendar<void>(
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
            color: kDetailDark,
          ),
          leftChevronIcon:
              Icon(Icons.chevron_left, color: kDetailPrimary),
          rightChevronIcon:
              Icon(Icons.chevron_right, color: kDetailPrimary),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kDetailGreyLight,
          ),
          weekendStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kDetailGreyLight,
          ),
        ),
        calendarStyle: const CalendarStyle(
          rangeHighlightColor: Colors.transparent,
        ),
        selectedDayPredicate: (day) {
          if (_isPoolOnly) return isSameDay(day, _selectedDay);
          return false;
        },
        rangeStartDay: _isPoolOnly ? null : _rangeStart,
        rangeEndDay: _isPoolOnly ? null : _rangeEnd,
        rangeSelectionMode: RangeSelectionMode.disabled,
        enabledDayPredicate: _isDayEnabled,
        onDaySelected: _onDaySelected,
        onPageChanged: (focused) =>
            setState(() => _focusedDay = focused),
        rowHeight: 64,
        calendarBuilders: CalendarBuilders<void>(
          defaultBuilder: (context, day, focused) {
            final model = _dayModel(day);
            return _buildDayCell(
              day: day,
              model: model,
              isSelected: false,
              isInRange: _isDayInRange(day),
              isRangeStart: isSameDay(day, _rangeStart),
              isRangeEnd: isSameDay(day, _rangeEnd),
            );
          },
          selectedBuilder: (context, day, focused) {
            final model = _dayModel(day);
            return _buildDayCell(
              day: day,
              model: model,
              isSelected: true,
              isInRange: false,
              isRangeStart: false,
              isRangeEnd: false,
            );
          },
          todayBuilder: (context, day, focused) {
            final model = _dayModel(day);
            final isSelected =
                _isPoolOnly && isSameDay(day, _selectedDay);
            return _buildDayCell(
              day: day,
              model: model,
              isSelected: isSelected,
              isToday: true,
              isInRange: _isDayInRange(day),
              isRangeStart: isSameDay(day, _rangeStart),
              isRangeEnd: isSameDay(day, _rangeEnd),
            );
          },
          disabledBuilder: (context, day, focused) {
            final model = _dayModel(day);
            return _buildDisabledDayCell(day, model);
          },
          outsideBuilder: (context, day, focused) {
            return const SizedBox.shrink();
          },
          rangeStartBuilder: (context, day, focused) {
            final model = _dayModel(day);
            return _buildDayCell(
              day: day,
              model: model,
              isSelected: false,
              isInRange: true,
              isRangeStart: true,
              isRangeEnd: false,
            );
          },
          rangeEndBuilder: (context, day, focused) {
            final model = _dayModel(day);
            return _buildDayCell(
              day: day,
              model: model,
              isSelected: false,
              isInRange: true,
              isRangeStart: false,
              isRangeEnd: true,
            );
          },
          withinRangeBuilder: (context, day, focused) {
            final model = _dayModel(day);
            return _buildDayCell(
              day: day,
              model: model,
              isSelected: false,
              isInRange: true,
              isRangeStart: false,
              isRangeEnd: false,
            );
          },
        ),
      ),
    );
  }

  bool _isDayInRange(DateTime day) {
    if (_rangeStart == null || _rangeEnd == null) return false;
    return day.isAfter(
            _rangeStart!.subtract(const Duration(days: 1))) &&
        day.isBefore(_rangeEnd!.add(const Duration(days: 1)));
  }

  Widget _buildDayCell({
    required DateTime day,
    CalendarDayModel? model,
    required bool isSelected,
    bool isToday = false,
    required bool isInRange,
    required bool isRangeStart,
    required bool isRangeEnd,
  }) {
    final isStartOrEnd = isRangeStart || isRangeEnd || isSelected;

    Color bgColor;
    Color textColor;
    if (isStartOrEnd) {
      bgColor = kDetailPrimary;
      textColor = Colors.white;
    } else if (isInRange) {
      bgColor = kDetailPrimary.withValues(alpha: 0.12);
      textColor = kDetailDark;
    } else {
      bgColor = Colors.transparent;
      textColor = kDetailDark;
    }

    final priceText = _shortPrice(model?.price);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: isStartOrEnd
            ? BorderRadius.circular(10)
            : (isInRange
                ? BorderRadius.zero
                : BorderRadius.circular(10)),
        border: isToday && !isStartOrEnd && !isInRange
            ? Border.all(color: kDetailPrimary, width: 1.5)
            : null,
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
          if (priceText.isNotEmpty)
            Text(
              priceText,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: isStartOrEnd
                    ? Colors.white.withValues(alpha: 0.85)
                    : kDetailPrimary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDisabledDayCell(DateTime day, CalendarDayModel? model) {
    final isOutOfCalendar = model == null;
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
              color: Colors.grey[350],
              decoration:
                  isOutOfCalendar ? null : TextDecoration.lineThrough,
              decorationColor: Colors.grey[400],
            ),
          ),
          if (!isOutOfCalendar)
            Text(
              model.isBooked ? 'Reservado' : 'No disp.',
              style: TextStyle(fontSize: 8, color: Colors.grey[400]),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double bottomPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 16),
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
        children: [
          // Resumen de selección
          if (_isPoolOnly && _selectedDay != null) ...[
            _buildSummaryRow(
              'Fecha seleccionada',
              DateFormat('d MMM yyyy', 'es_MX').format(_selectedDay!),
            ),
            if (_singleDayPrice != null)
              _buildSummaryRow(
                  'Precio', _formatMXN(_singleDayPrice!),
                  isBold: true),
            const SizedBox(height: 12),
          ],
          if (!_isPoolOnly && _rangeStart != null) ...[
            _buildSummaryRow(
              'Check-in',
              DateFormat('d MMM yyyy', 'es_MX').format(_rangeStart!),
            ),
            if (_rangeEnd != null) ...[
              _buildSummaryRow(
                'Check-out',
                DateFormat('d MMM yyyy', 'es_MX').format(_rangeEnd!),
              ),
              _buildSummaryRow('Noches', '$_nightsCount'),
              _buildSummaryRow(
                  'Total', _formatMXN(_totalRangePrice),
                  isBold: true),
            ],
            if (_validationMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _validationMessage!,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],

          // Chip de advertencia maxNights
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _showMaxWarning
                ? Container(
                    key: const ValueKey('max-warn'),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Máximo $_maxNights noches permitidas',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('no-warn')),
          ),

          // Hint si no hay selección aún
          if ((_isPoolOnly && _selectedDay == null) ||
              (!_isPoolOnly && _rangeStart == null))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _isPoolOnly
                    ? 'Toca un día disponible para seleccionarlo'
                    : 'Selecciona fecha de entrada y salida',
                style: const TextStyle(
                  fontSize: 13,
                  color: kDetailGreyLight,
                ),
              ),
            ),

          // Botón confirmar
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _canConfirm && !_isConfirming ? _onConfirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kDetailPrimary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                disabledForegroundColor: Colors.grey[500],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: _isConfirming
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Continuar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: kDetailGreyLight,
              fontWeight:
                  isBold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: kDetailDark,
              fontWeight:
                  isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onConfirm() async {
    if (_isConfirming) return;
    setState(() => _isConfirming = true);

    try {
      final service = ref.read(bookingServiceProvider);

      final request = CreateBookingRequest(
        propertyId: widget.propertyId,
        bookingDate: _isPoolOnly
            ? DateFormat('yyyy-MM-dd').format(_selectedDay!)
            : null,
        checkInDate: !_isPoolOnly
            ? DateFormat('yyyy-MM-dd').format(_rangeStart!)
            : null,
        checkOutDate: !_isPoolOnly
            ? DateFormat('yyyy-MM-dd').format(_rangeEnd!)
            : null,
      );

      final response = await service.createBooking(request);
      if (!mounted) return;

      final String datesLabel;
      if (_isPoolOnly) {
        datesLabel =
            DateFormat('d MMM yyyy', 'es_MX').format(_selectedDay!);
      } else {
        final checkIn =
            DateFormat('d MMM', 'es_MX').format(_rangeStart!);
        final checkOut =
            DateFormat('d MMM yyyy', 'es_MX').format(_rangeEnd!);
        datesLabel = '$checkIn – $checkOut · $_nightsCount noches';
      }

      final nav = Navigator.of(context);
      nav.pop(); // cierra el bottom sheet
      nav.push(
        MaterialPageRoute(
          builder: (_) => BookingReviewScreen(
            bookingResponse: response,
            propertyName: widget.propertyDetail.property.propertyName,
            datesLabel: datesLabel,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isConfirming = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
