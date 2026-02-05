import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PriceInput extends StatefulWidget {
  final String label;
  final String? sublabel;
  final double value;
  final ValueChanged<double> onChanged;

  static const Color mainColor = Color(0xFF3CA2A2);

  const PriceInput({
    super.key,
    required this.label,
    this.sublabel,
    required this.value,
    required this.onChanged,
  });

  @override
  State<PriceInput> createState() => _PriceInputState();
}

class _PriceInputState extends State<PriceInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value > 0 ? widget.value.toStringAsFixed(0) : '',
    );
  }

  @override
  void didUpdateWidget(PriceInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final newText = widget.value > 0 ? widget.value.toStringAsFixed(0) : '';
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (widget.sublabel != null) ...[
              const SizedBox(width: 6),
              Text(
                widget.sublabel!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(7),
          ],
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          onChanged: (value) {
            final parsed = double.tryParse(value) ?? 0;
            widget.onChanged(parsed);
          },
          decoration: InputDecoration(
            prefixText: '\$ ',
            prefixStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
            suffixText: 'MXN',
            suffixStyle: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
            hintText: '0',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: PriceInput.mainColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
