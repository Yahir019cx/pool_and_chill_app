import 'package:flutter/material.dart';
import 'package:pool_and_chill_app/data/models/property/calendar_day_model.dart';

const _kSpecialRate = Color(0xFFD4A017);
const _kDark = Color(0xFF1A1A2E);

/// Celda de día compartida para los calendarios de tarifas especiales.
/// [accentColor] define el color de endpoints y rango seleccionado.
/// [subText]    texto pequeño debajo del número (precio o "T.Esp."), nullable.
class SrCalendarDayCell extends StatelessWidget {
  const SrCalendarDayCell({
    super.key,
    required this.day,
    required this.model,
    required this.accentColor,
    this.isToday = false,
    this.inRange = false,
    this.isStart = false,
    this.isEnd = false,
    this.subText,
  });

  final DateTime day;
  final CalendarDayModel? model;
  final Color accentColor;
  final bool isToday;
  final bool inRange;
  final bool isStart;
  final bool isEnd;
  final String? subText;

  @override
  Widget build(BuildContext context) {
    final isSpecialRate = model?.isSpecialRate ?? false;
    final isEndpoint = isStart || isEnd;

    Color bg;
    Color fg;
    if (isEndpoint) {
      bg = accentColor;
      fg = Colors.white;
    } else if (inRange) {
      bg = accentColor.withValues(alpha: 0.12);
      fg = _kDark;
    } else if (isSpecialRate) {
      bg = _kSpecialRate.withValues(alpha: 0.12);
      fg = _kSpecialRate;
    } else {
      bg = Colors.transparent;
      fg = _kDark;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: isEndpoint
            ? BorderRadius.circular(10)
            : (inRange ? BorderRadius.zero : BorderRadius.circular(10)),
        border: isToday && !isEndpoint && !inRange
            ? Border.all(color: accentColor, width: 1.5)
            : isSpecialRate && !isEndpoint && !inRange
                ? Border.all(color: _kSpecialRate.withValues(alpha: 0.3))
                : null,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fg),
          ),
          if (subText != null && subText!.isNotEmpty)
            Text(
              subText!,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: isEndpoint ? Colors.white.withValues(alpha: 0.85) : fg,
              ),
            ),
        ],
      ),
    );
  }
}

/// Celda deshabilitada (días pasados / fuera de rango).
Widget srDisabledDayCell(DateTime day) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(fontSize: 14, color: Colors.grey.shade300),
      ),
    );
