import 'package:flutter/material.dart';
import 'home_host.dart';

class WelcomeHostInfoScreen extends StatefulWidget {
  final VoidCallback? onContinue;

  const WelcomeHostInfoScreen({
    super.key,
    this.onContinue,
  });

  @override
  State<WelcomeHostInfoScreen> createState() => _WelcomeHostInfoScreenState();
}

class _WelcomeHostInfoScreenState extends State<WelcomeHostInfoScreen>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  late AnimationController _pulseController;

  static const Color primary = Color(0xFF2D9D91);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _continuar() {
    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeHostScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Decoración de fondo
            Positioned(
              top: -80,
              right: -80,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: _visible ? 0.08 : 0,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -60,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: _visible ? 0.05 : 0,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary,
                  ),
                ),
              ),
            ),

            // Contenido principal
            AnimatedOpacity(
              duration: const Duration(milliseconds: 450),
              opacity: _visible ? 1 : 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 450),
                offset: _visible ? Offset.zero : const Offset(0, 0.04),
                curve: Curves.easeOut,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿Qué puedes hacer\ncomo anfitrión?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Administra todo desde un solo lugar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _AnimatedInfoCard(
                        delay: 100,
                        visible: _visible,
                        icon: Icons.villa_rounded,
                        iconBgColor: const Color(0xFFE8F5F3),
                        title: 'Gestiona tus espacios',
                        description:
                            'Crea, edita o pausa tus albercas disponibles para renta.',
                      ),
                      const SizedBox(height: 16),
                      _AnimatedInfoCard(
                        delay: 200,
                        visible: _visible,
                        icon: Icons.calendar_month_rounded,
                        iconBgColor: const Color(0xFFE8F5F3),
                        title: 'Controla tus reservas',
                        description:
                            'Consulta quién reservó, fechas y administra cancelaciones.',
                      ),
                      const SizedBox(height: 16),
                      _AnimatedInfoCard(
                        delay: 300,
                        visible: _visible,
                        icon: Icons.account_balance_wallet_rounded,
                        iconBgColor: const Color(0xFFE8F5F3),
                        title: 'Recibe tus ganancias',
                        description:
                            'Consulta tus ingresos y pagos de forma clara y segura.',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Botón flecha
            Positioned(
              bottom: 36,
              right: 24,
              child: _ArrowActionButton(
                onTap: _continuar,
                controller: _pulseController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------
/// ANIMATED INFO CARD
/// ------------------------------------------------------
class _AnimatedInfoCard extends StatefulWidget {
  final int delay;
  final bool visible;
  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String description;

  const _AnimatedInfoCard({
    required this.delay,
    required this.visible,
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.description,
  });

  @override
  State<_AnimatedInfoCard> createState() => _AnimatedInfoCardState();
}

class _AnimatedInfoCardState extends State<_AnimatedInfoCard> {
  bool _show = false;

  static const Color primary = Color(0xFF2D9D91);

  @override
  void initState() {
    super.initState();
    _triggerAnimation();
  }

  @override
  void didUpdateWidget(_AnimatedInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      _triggerAnimation();
    }
  }

  void _triggerAnimation() {
    if (widget.visible) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) setState(() => _show = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: _show ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 400),
        offset: _show ? Offset.zero : const Offset(0.05, 0),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.shade100,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.iconBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  widget.icon,
                  color: primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------
/// BOTÓN FLECHA CON ANIMACIÓN
/// ------------------------------------------------------
class _ArrowActionButton extends StatefulWidget {
  final VoidCallback onTap;
  final AnimationController controller;

  const _ArrowActionButton({
    required this.onTap,
    required this.controller,
  });

  @override
  State<_ArrowActionButton> createState() => _ArrowActionButtonState();
}

class _ArrowActionButtonState extends State<_ArrowActionButton> {
  bool _pressed = false;

  static const Color primary = Color(0xFF2D9D91);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) {
          return AnimatedScale(
            scale: _pressed ? 0.92 : 1,
            duration: const Duration(milliseconds: 120),
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary,
                    primary.withValues(alpha: 0.85),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          );
        },
      ),
    );
  }
}
