import 'package:flutter/material.dart';

class StepNavigationButtons extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String previousLabel;
  final String nextLabel;
  final bool isNextEnabled;

  static const Color mainColor = Color(0xFF3CA2A2);

  const StepNavigationButtons({
    super.key,
    this.onPrevious,
    this.onNext,
    this.previousLabel = 'Anterior',
    this.nextLabel = 'Siguiente',
    this.isNextEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onPrevious != null)
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: onPrevious,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: mainColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  previousLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: mainColor,
                  ),
                ),
              ),
            ),
          ),
        if (onPrevious != null) const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isNextEnabled ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                disabledBackgroundColor: mainColor.withValues(alpha: 0.4),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                nextLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
