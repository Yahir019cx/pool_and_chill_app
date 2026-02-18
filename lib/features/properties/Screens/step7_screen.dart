import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import 'package:pool_and_chill_app/data/services/kyc_service.dart';
import '../widgets/step_navigation_buttons.dart';

/// Step 7: Verificación de identidad con Didit (KYC).
/// Si el usuario ya está verificado (isIdentityVerified), este step se salta desde Publish.
class Step7Screen extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const Step7Screen({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  ConsumerState<Step7Screen> createState() => _Step7ScreenState();
}

class _Step7ScreenState extends ConsumerState<Step7Screen> {
  bool _isLoading = false;
  bool _verified = false;
  bool _skipped = false;
  String? _statusMessage;
  static const Color mainColor = Color(0xFF3CA2A2);

  Future<void> _startVerification() async {
    debugPrint('[Didit] Step7: usuario pulsó Verificar identidad');
    final apiClient = ref.read(apiClientProvider);
    final kycService = KycService(apiClient);

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      debugPrint('[Didit] Step7: llamando a startDiditVerificationOnDevice()');
      final status = await kycService.startDiditVerificationOnDevice();
      debugPrint('[Didit] Step7: SDK retornó status=$status');
      if (!mounted) return;

      final upperStatus = status?.toUpperCase() ?? '';

      if (upperStatus == 'APPROVED') {
        setState(() {
          _verified = true;
          _statusMessage = 'Identidad verificada correctamente.';
        });
      } else if (upperStatus == 'CANCELLED') {
        setState(() {
          _statusMessage = 'Verificación cancelada. Puedes intentarlo de nuevo.';
        });
      } else {
        // DECLINED, PENDING, u otro estado
        setState(() {
          _statusMessage = 'La verificación no fue aprobada. Intenta de nuevo.';
        });
      }
    } catch (e, st) {
      debugPrint('[Didit] Step7: ERROR - $e');
      debugPrint('[Didit] Step7: stackTrace - $st');
      if (mounted) {
        setState(() {
          _statusMessage = e.toString().replaceFirst('Exception: ', '');
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_statusMessage ?? 'Error al iniciar verificación'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          const Text(
            'Paso 7 de 8',
            style: TextStyle(fontSize: 13, color: Colors.black45),
          ),
          const SizedBox(height: 8),
          const Text(
            'Verificación de identidad',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verificación segura con Didit',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Verificaremos tu identidad de forma segura. Al pulsar "Verificar" se abrirá el flujo oficial. Tus datos están protegidos.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_verified)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Identidad verificada correctamente.\nPulsa Siguiente para continuar.',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(color: mainColor),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _startVerification,
                        icon: const Icon(Icons.badge_outlined, size: 22),
                        label: const Text(
                          'Verificar identidad',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  if (_statusMessage != null && !_verified) ...[
                    const SizedBox(height: 16),
                    Text(
                      _statusMessage!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                  if (!_verified && !_isLoading) ...[
                    const SizedBox(height: 32),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _skipped = true;
                          });
                          widget.onNext();
                        },
                        child: Text(
                          'Verificar después',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Podrás verificar tu identidad más tarde desde tu perfil. Tu propiedad no será visible hasta completar la verificación.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          StepNavigationButtons(
            onPrevious: widget.onPrevious,
            onNext: widget.onNext,
            isNextEnabled: _verified,
          ),
        ],
      ),
    );
  }
}
