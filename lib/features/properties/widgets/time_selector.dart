import 'package:flutter/material.dart';

class TimeSelector extends StatefulWidget {
  final String label;
  final String selectedTime;
  final List<String> options;
  final ValueChanged<String> onChanged;

  static const Color mainColor = Color(0xFF3CA2A2);

  const TimeSelector({
    super.key,
    required this.label,
    required this.selectedTime,
    required this.options,
    required this.onChanged,
  });

  @override
  State<TimeSelector> createState() => _TimeSelectorState();
}

class _TimeSelectorState extends State<TimeSelector> {
  static const Color _primary = Color(0xFF3CA2A2);

  bool get _isCustom => !widget.options.contains(widget.selectedTime);

  TimeOfDay _parseCustomTime() {
    final s = widget.selectedTime.toLowerCase().trim();
    final isPm = s.endsWith('pm');
    final isAm = s.endsWith('am');
    if (isPm || isAm) {
      final part = s.replaceAll('am', '').replaceAll('pm', '').trim();
      final parts = part.split(':');
      int h = int.tryParse(parts.first) ?? 12;
      final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      if (isPm && h != 12) h += 12;
      if (isAm && h == 12) h = 0;
      return TimeOfDay(hour: h, minute: m);
    }
    return TimeOfDay.now();
  }

  Future<void> _openPicker() async {
    final initial = _isCustom && widget.selectedTime.isNotEmpty
        ? _parseCustomTime()
        : TimeOfDay.now();

    int selHour = initial.hour % 12 == 0 ? 12 : initial.hour % 12;
    int selMinute = (initial.minute ~/ 5) * 5;
    bool selIsPm = initial.hour >= 12;

    final hourCtrl =
        FixedExtentScrollController(initialItem: selHour - 1);
    final minCtrl =
        FixedExtentScrollController(initialItem: selMinute ~/ 5);
    final amPmCtrl =
        FixedExtentScrollController(initialItem: selIsPm ? 1 : 0);

    String fmt() =>
        '$selHour:${selMinute.toString().padLeft(2, '0')} ${selIsPm ? 'PM' : 'AM'}';

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          return SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header con preview y acciones
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ),
                      Text(
                        fmt(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          widget.onChanged(fmt());
                        },
                        child: Text(
                          'Listo',
                          style: TextStyle(
                            color: _primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Rueditas
                SizedBox(
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Líneas de selección
                      Container(
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: _primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      Row(
                        children: [
                          // Hora (1-12)
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              controller: hourCtrl,
                              itemExtent: 50,
                              perspective: 0.003,
                              physics:
                                  const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (i) =>
                                  setS(() => selHour = i + 1),
                              childDelegate:
                                  ListWheelChildBuilderDelegate(
                                childCount: 12,
                                builder: (_, i) => Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: selHour == i + 1
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: selHour == i + 1
                                          ? _primary
                                          : Colors.black38,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Separador
                          Text(
                            ':',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: _primary,
                            ),
                          ),
                          // Minutos (00, 05 … 55)
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              controller: minCtrl,
                              itemExtent: 50,
                              perspective: 0.003,
                              physics:
                                  const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (i) =>
                                  setS(() => selMinute = i * 5),
                              childDelegate:
                                  ListWheelChildBuilderDelegate(
                                childCount: 12,
                                builder: (_, i) => Center(
                                  child: Text(
                                    (i * 5)
                                        .toString()
                                        .padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: selMinute == i * 5
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: selMinute == i * 5
                                          ? _primary
                                          : Colors.black38,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // AM / PM
                          Expanded(
                            child: ListWheelScrollView(
                              controller: amPmCtrl,
                              itemExtent: 50,
                              perspective: 0.003,
                              physics:
                                  const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (i) =>
                                  setS(() => selIsPm = i == 1),
                              children: [
                                Center(
                                  child: Text(
                                    'AM',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: !selIsPm
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: !selIsPm
                                          ? _primary
                                          : Colors.black38,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    'PM',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: selIsPm
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: selIsPm
                                          ? _primary
                                          : Colors.black38,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );

    hourCtrl.dispose();
    minCtrl.dispose();
    amPmCtrl.dispose();
  }

  Widget _buildChip(String time, {bool isOtro = false}) {
    final isSelected =
        isOtro ? _isCustom : (time == widget.selectedTime && !_isCustom);
    final label = isOtro
        ? (_isCustom && widget.selectedTime.isNotEmpty
            ? widget.selectedTime
            : 'Otro')
        : time;

    return GestureDetector(
      onTap: isOtro ? _openPicker : () => widget.onChanged(time),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? _primary.withValues(alpha: 0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _primary : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOtro) ...[
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: isSelected ? _primary : Colors.black54,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? _primary : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...widget.options.map((t) => _buildChip(t)),
            _buildChip('', isOtro: true),
          ],
        ),
      ],
    );
  }
}
