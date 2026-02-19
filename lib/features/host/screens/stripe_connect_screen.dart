import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pool_and_chill_app/data/providers/auth_provider.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'package:pool_and_chill_app/features/host/home_host.dart';

// Estados internos de la pantalla
enum _StripeState {
  idle,       // Inicial: muestra cards + botón flecha
  loading,    // Obteniendo onboardingUrl del backend
  verifying,  // Recibido deep link /return: consultando GET /stripe/account-status
  success,    // chargesEnabled && payoutsEnabled → navega a Home tras 2 s
  pending,    // Cuenta existe pero Stripe aún no la activó
  retry,      // deep link /refresh o usuario quiere reintentar
}

class StripeConnectScreen extends ConsumerStatefulWidget {
  const StripeConnectScreen({super.key});

  @override
  ConsumerState<StripeConnectScreen> createState() =>
      _StripeConnectScreenState();
}

class _StripeConnectScreenState extends ConsumerState<StripeConnectScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFF2D9D91);

  _StripeState _state = _StripeState.idle;
  bool _visible = false;
  late AnimationController _pulseController;
  StreamSubscription<Uri>? _linkSub;

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────

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

    _initDeepLinks();
    _checkExistingAccount();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _linkSub?.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DEEP LINKS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _initDeepLinks() async {
    final appLinks = AppLinks();

    // URI que abrió la app en frío (Stripe redirigió mientras la app estaba cerrada)
    final initial = await appLinks.getInitialLink();
    if (initial != null) _handleUri(initial);

    // Escucha mientras la pantalla está activa
    _linkSub = appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri uri) {
    if (!mounted) return;
    if (uri.host != 'stripe') return;

    if (uri.path == '/return') {
      // No completar onboarding de inmediato: primero verificar con el backend
      _verifyAndComplete();
    } else if (uri.path == '/refresh') {
      setState(() => _state = _StripeState.retry);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LÓGICA DE NEGOCIO
  // ─────────────────────────────────────────────────────────────────────────

  /// Opcional: al abrir la pantalla comprueba si la cuenta ya está activa
  /// (caso de usuario que volvió a la app después de completar Stripe).
  Future<void> _checkExistingAccount() async {
    try {
      final service = ref.read(stripeServiceProvider);
      final status = await service.getAccountStatus();
      if (!mounted) return;
      if (status.isReady) {
        setState(() => _state = _StripeState.success);
        _navigateToHome();
      }
      // Si no está lista, permanece en idle para que el usuario configure.
    } catch (_) {
      // Sin cuenta o error de red → idle, el usuario inicia el flujo.
    }
  }

  /// Recibido deep link /return: consulta el estado real con el backend.
  Future<void> _verifyAndComplete() async {
    setState(() => _state = _StripeState.verifying);
    try {
      final service = ref.read(stripeServiceProvider);
      final status = await service.getAccountStatus();
      if (!mounted) return;

      if (status.isReady) {
        setState(() => _state = _StripeState.success);
        await _finalizeOnboarding();
      } else {
        // Stripe recibió los datos pero aún no activó la cuenta.
        setState(() => _state = _StripeState.pending);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _StripeState.pending);
    }
  }

  /// Marca el onboarding como completado en el backend y navega a Home.
  /// Solo se llama cuando el backend confirmó chargesEnabled && payoutsEnabled.
  Future<void> _finalizeOnboarding() async {
    try {
      await context.read<AuthProvider>().completeHostOnboarding();
    } catch (_) {
      // Si la llamada falla, Stripe ya confirmó → navegamos igual.
    }
    if (!mounted) return;
    await Future.delayed(const Duration(seconds: 2));
    _navigateToHome();
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeHostScreen()),
    );
  }

  /// Obtiene un nuevo onboardingUrl (un solo uso) y lo abre en el navegador in-app.
  /// Se llama tanto al primer intento como en reintentos.
  Future<void> _startOnboarding() async {
    setState(() => _state = _StripeState.loading);
    try {
      final service = ref.read(stripeServiceProvider);
      final userId = context.read<AuthProvider>().profile!.userId;
      final url = await service.createConnectAccount(userId: userId);
      await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);

      // Si el usuario cerró el navegador sin completar y sin generar deep link,
      // volvemos a idle para que pueda reintentar.
      if (mounted && _state == _StripeState.loading) {
        setState(() => _state = _StripeState.idle);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _state = _StripeState.idle);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo iniciar la configuración: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Círculo decorativo superior-derecho
            Positioned(
              top: -80,
              right: -80,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: _visible ? 0.07 : 0,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primary,
                  ),
                ),
              ),
            ),
            // Círculo decorativo inferior-izquierdo
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
                    color: _primary,
                  ),
                ),
              ),
            ),

            // Contenido central (cambia según el estado)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 450),
              opacity: _visible ? 1 : 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 450),
                offset: _visible ? Offset.zero : const Offset(0, 0.04),
                curve: Curves.easeOut,
                child: _buildBody(),
              ),
            ),

            // Botón flecha (solo en idle / loading)
            Positioned(
              bottom: 36,
              right: 24,
              child: _buildActionButton(),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BODY por estado
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return switch (_state) {
      _StripeState.verifying => _buildVerifyingBody(),
      _StripeState.success   => _buildSuccessBody(),
      _StripeState.pending   => _buildPendingBody(),
      _StripeState.retry     => _buildRetryBody(),
      _                      => _buildIdleBody(),
    };
  }

  // ── Idle ──────────────────────────────────────────────────────────────────

  Widget _buildIdleBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Configura tu cuenta\npara recibir ganancias',
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
            'Conecta tu cuenta bancaria a través de Stripe\npara cobrar cada reserva automáticamente.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          _InfoCard(
            delay: 100,
            visible: _visible,
            icon: Icons.account_balance_rounded,
            title: 'Pagos directos a tu banco',
            description:
                'Stripe deposita tus ganancias directamente en tu cuenta bancaria de forma segura.',
          ),
          const SizedBox(height: 16),
          _InfoCard(
            delay: 200,
            visible: _visible,
            icon: Icons.shield_rounded,
            title: 'Plataforma de confianza',
            description:
                'Stripe es el estándar global en pagos online. Tu información está protegida.',
          ),
          const SizedBox(height: 16),
          _InfoCard(
            delay: 300,
            visible: _visible,
            icon: Icons.bolt_rounded,
            title: 'Proceso rápido',
            description:
                'Solo necesitas unos minutos para completar el registro y comenzar a cobrar.',
          ),
        ],
      ),
    );
  }

  // ── Verificando ───────────────────────────────────────────────────────────

  Widget _buildVerifyingBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(strokeWidth: 4, color: _primary),
          ),
          const SizedBox(height: 32),
          const Text(
            'Verificando tu cuenta…',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Estamos confirmando el estado de tu cuenta con Stripe.\nEsto solo toma un momento.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Éxito ─────────────────────────────────────────────────────────────────

  Widget _buildSuccessBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5F3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: _primary,
              size: 52,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            '¡Cuenta configurada!',
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
            'Ya estás listo para recibir pagos.\nTe llevamos a tu panel de anfitrión…',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 3, color: _primary),
          ),
        ],
      ),
    );
  }

  // ── Cuenta en revisión ────────────────────────────────────────────────────

  Widget _buildPendingBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_top_rounded,
              color: Colors.blue.shade600,
              size: 48,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Cuenta en revisión',
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
            'Stripe aún no ha activado tu cuenta.\nSi falta información, completa el registro.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _startOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Completar registro en Stripe',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Reintentar ────────────────────────────────────────────────────────────

  Widget _buildRetryBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade700,
              size: 52,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'No completaste la\nconfiguración',
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
            'Puedes intentarlo de nuevo cuando quieras.\nTu progreso en Stripe se conserva.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _startOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Intentar de nuevo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BOTÓN FLECHA (solo en idle / cargando URL)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildActionButton() {
    switch (_state) {
      case _StripeState.loading:
        return const SizedBox(
          width: 68,
          height: 68,
          child: Center(child: CircularProgressIndicator(color: _primary)),
        );
      case _StripeState.idle:
        return _ArrowButton(
          onTap: _startOnboarding,
          controller: _pulseController,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TARJETA INFORMATIVA (mismo patrón que info_host.dart)
// ─────────────────────────────────────────────────────────────────────────────

class _InfoCard extends StatefulWidget {
  final int delay;
  final bool visible;
  final IconData icon;
  final String title;
  final String description;

  const _InfoCard({
    required this.delay,
    required this.visible,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  State<_InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<_InfoCard> {
  static const Color _primary = Color(0xFF2D9D91);
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _triggerAnimation();
  }

  @override
  void didUpdateWidget(_InfoCard old) {
    super.didUpdateWidget(old);
    if (widget.visible != old.visible) _triggerAnimation();
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
            border: Border.all(color: Colors.grey.shade100, width: 1.5),
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
                  color: const Color(0xFFE8F5F3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(widget.icon, color: _primary, size: 26),
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

// ─────────────────────────────────────────────────────────────────────────────
// BOTÓN FLECHA ANIMADO (mismo patrón que info_host.dart)
// ─────────────────────────────────────────────────────────────────────────────

class _ArrowButton extends StatefulWidget {
  final VoidCallback onTap;
  final AnimationController controller;

  const _ArrowButton({required this.onTap, required this.controller});

  @override
  State<_ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<_ArrowButton> {
  static const Color _primary = Color(0xFF2D9D91);
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
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) {
          return AnimatedScale(
            scale: _pressed ? 0.92 : 1,
            duration: const Duration(milliseconds: 120),
            child: Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_primary, Color(0xFF25857A)],
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
