import 'package:flutter/material.dart';
import '../widgets/step_item.dart';
import '../../home/screens/welcome.dart';

class FirstAnfitrionesScreen extends StatelessWidget {
  const FirstAnfitrionesScreen({super.key, this.onStartPressed});

  final VoidCallback? onStartPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FA),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              );
            },
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 25),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// HEADER
              const Text(
                'Publica tu espacio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Te tomará solo unos minutos',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),

              const SizedBox(height: 28),

              /// STEPS
              _StepCard(
                child: const StepItem(
                  number: 1,
                  title: 'Describe tu espacio',
                  description:
                      'Agrega ubicación, servicios, reglas y capacidad para que los huéspedes sepan qué esperar.',
                  delay: Duration(milliseconds: 0),
                ),
              ),
              const SizedBox(height: 16),
              _StepCard(
                child: const StepItem(
                  number: 2,
                  title: 'Sube fotos atractivas',
                  description:
                      'Incluye al menos 5 fotos claras y un título que destaque tu espacio.',
                  delay: Duration(milliseconds: 120),
                ),
              ),
              const SizedBox(height: 16),
              _StepCard(
                child: const StepItem(
                  number: 3,
                  title: 'Define tu precio',
                  description:
                      'Configura el precio por día, disponibilidad y preferencias de reserva.',
                  delay: Duration(milliseconds: 240),
                ),
              ),
              const SizedBox(height: 16),
              _StepCard(
                child: const StepItem(
                  number: 4,
                  title: 'Publica y recibe reservas',
                  description:
                      'Haz visible tu anuncio y comienza a recibir solicitudes en minutos.',
                  delay: Duration(milliseconds: 360),
                ),
              ),

              const SizedBox(height: 32),

              /// CTA
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onStartPressed ?? () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3CA2A2),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Empezar ahora',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// STEP CARD
class _StepCard extends StatelessWidget {
  const _StepCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
