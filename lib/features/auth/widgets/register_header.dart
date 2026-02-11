import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        child: Column(
          children: [
            Text(
              "Crear cuenta",
              style: GoogleFonts.lilitaOne(
                fontSize: 28,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Completa tus datos para comenzar",
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: const Color.fromARGB(255, 104, 104, 104),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
