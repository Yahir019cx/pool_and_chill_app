import 'package:flutter/material.dart';
import 'package:pool_and_chill_app/features/host/screens/info_host.dart';

class WelcomeAnfitrionScreen extends StatefulWidget {
  const WelcomeAnfitrionScreen({super.key});

  @override
  State<WelcomeAnfitrionScreen> createState() =>
      _WelcomeAnfitrionScreenState();
}

class _WelcomeAnfitrionScreenState extends State<WelcomeAnfitrionScreen> {

  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Animación ligera al cargar
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // ☀️ Sol decorativo
            Positioned(
              top: 10,
              right: -10,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _visible ? 1 : 0,
                child: Image.asset(
                  'assets/images/sol.png',
                  width: 170,
                  height: 170,
                ),
              ),
            ),

            // Contenido principal
            Center(
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 450),
                offset: _visible ? Offset.zero : const Offset(0, 0.05),
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 450),
                  opacity: _visible ? 1 : 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 🏖️ Ilustración
                        Image.asset(
                          'assets/images/paraguas.png',
                          height: 150,
                        ),
                        const SizedBox(height: 36),

                        // 🧿 Logo (hero opcional)
                        Hero(
                          tag: 'logo-anfitrion',
                          child: Image.asset(
                            'assets/images/logoLT.png',
                            height: 90,
                          ),
                        ),
                        const SizedBox(height: 32),

                        const Text(
                          '¡Bienvenido a tu espacio como anfitrión!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),

                        const Text(
                          'Administra tus espacios, revisa reservas\ny controla tus ganancias fácilmente.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.5,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 👉 Botón acción
            Positioned(
              bottom: 40,
              right: 28,
              child: _AnimatedActionButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WelcomeHostInfoScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedActionButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedActionButton({required this.onTap});

  @override
  State<_AnimatedActionButton> createState() =>
      _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFF2D9D91),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),
      ),
    );
  }
}
