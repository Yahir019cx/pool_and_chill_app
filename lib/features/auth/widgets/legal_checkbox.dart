import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LegalCheckbox extends StatelessWidget {
  /// Texto gris antes del link, ej: "Acepto los"
  final String prefix;

  /// Texto en color brand que abre el modal, ej: "Términos y Condiciones"
  final String highlight;

  final bool value;
  final String legalContent;
  final ValueChanged<bool> onChanged;

  const LegalCheckbox({
    super.key,
    required this.prefix,
    required this.highlight,
    required this.value,
    required this.legalContent,
    required this.onChanged,
  });

  static const _brandColor = Color(0xFF41838F);

  void _showLegalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(highlight, style: GoogleFonts.openSans(fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(child: Text(legalContent)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar", style: TextStyle(color: _brandColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                activeColor: _brandColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                side: BorderSide(color: Colors.grey.shade400),
                onChanged: (v) => onChanged(v ?? false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => _showLegalDialog(context),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.openSans(fontSize: 13, color: Colors.grey.shade600),
                    children: [
                      TextSpan(text: '$prefix '),
                      TextSpan(
                        text: highlight,
                        style: GoogleFonts.openSans(
                          fontSize: 13,
                          color: _brandColor,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: _brandColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
