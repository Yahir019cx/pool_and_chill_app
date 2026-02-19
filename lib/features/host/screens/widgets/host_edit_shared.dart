import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pool_and_chill_app/features/properties/Screens/widget_details/detail_constants.dart';

// ─── Input decoration helper ──────────────────────────────────────

InputDecoration hostEditInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: kDetailPrimary, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}

// ─── Numeric text field ───────────────────────────────────────────

class HostEditNumField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isInt;

  const HostEditNumField({
    super.key,
    required this.controller,
    required this.label,
    this.isInt = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: isInt
          ? TextInputType.number
          : const TextInputType.numberWithOptions(decimal: true),
      inputFormatters:
          isInt ? [FilteringTextInputFormatter.digitsOnly] : const [],
      decoration: hostEditInputDecoration(label),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────

class HostEditSectionHeader extends StatelessWidget {
  final String title;
  const HostEditSectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: kDetailDark,
      ),
    );
  }
}

// ─── Save button ──────────────────────────────────────────────────

class HostEditSaveButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const HostEditSaveButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kDetailPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(label,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ─── Time selector con chips + "Otro" (CupertinoDatePicker) ──────

class HostTimeSelector extends StatelessWidget {
  final String label;
  final String? selectedTime;
  final List<String> options;
  final ValueChanged<String> onChanged;

  static const Color _kPrimary = Color(0xFF3CA2A2);

  const HostTimeSelector({
    super.key,
    required this.label,
    required this.selectedTime,
    required this.options,
    required this.onChanged,
  });

  // '10:30 AM' / '2:00 PM' → DateTime
  DateTime _toDateTime(String? display) {
    if (display == null) return DateTime(2000, 1, 1, 10, 0);
    try {
      final parts = display.split(' ');
      final tp = parts[0].split(':');
      int h = int.parse(tp[0]);
      final m = int.parse(tp[1]);
      if (parts[1] == 'PM' && h != 12) h += 12;
      if (parts[1] == 'AM' && h == 12) h = 0;
      return DateTime(2000, 1, 1, h, m);
    } catch (_) {
      return DateTime(2000, 1, 1, 10, 0);
    }
  }

  // DateTime → '10:30 AM'
  String _fromDateTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute;
    final suffix = h < 12 ? 'AM' : 'PM';
    final displayH = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$displayH:${m.toString().padLeft(2, '0')} $suffix';
  }

  void _showPicker(BuildContext context) {
    DateTime selected = _toDateTime(selectedTime);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Seleccionar hora',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      onChanged(_fromDateTime(selected));
                      Navigator.pop(ctx);
                    },
                    style: TextButton.styleFrom(foregroundColor: _kPrimary),
                    child: const Text(
                      'Listo',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
            // Cupertino drum picker
            SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: false,
                initialDateTime: _toDateTime(selectedTime),
                onDateTimeChanged: (dt) {
                  setModal(() => selected = dt);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCustom =
        selectedTime != null && selectedTime!.isNotEmpty && !options.contains(selectedTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
            ...options.map((time) {
              final isSelected = time == selectedTime;
              return _HostTimeChip(
                label: time,
                isSelected: isSelected,
                onTap: () => onChanged(time),
              );
            }),
            // Chip "Otro" — muestra la hora personalizada si está seleccionada
            _HostTimeChip(
              label: isCustom ? selectedTime! : 'Otro',
              isSelected: isCustom,
              onTap: () => _showPicker(context),
            ),
          ],
        ),
      ],
    );
  }
}

class _HostTimeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _kPrimary = Color(0xFF3CA2A2);

  const _HostTimeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? _kPrimary.withValues(alpha: 0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _kPrimary : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? _kPrimary : Colors.black87,
          ),
        ),
      ),
    );
  }
}
