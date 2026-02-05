import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import '../widgets/step_navigation_buttons.dart';
import '../widgets/ine_capture_card.dart';

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
  final _picker = ImagePicker();
  bool _isLoading = false;
  static const Color mainColor = Color(0xFF3CA2A2);

  Future<void> _captureImage(String type) async {
    try {
      setState(() => _isLoading = true);

      final image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice:
            type == 'selfie' ? CameraDevice.front : CameraDevice.rear,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null && mounted) {
        final notifier = ref.read(propertyRegistrationProvider.notifier);
        switch (type) {
          case 'front':
            notifier.setIneFront(image.path);
            break;
          case 'back':
            notifier.setIneBack(image.path);
            break;
          case 'selfie':
            notifier.setSelfie(image.path);
            break;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al capturar imagen'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearImage(String type) {
    ref.read(propertyRegistrationProvider.notifier).clearIdentityPhoto(type);
  }

  @override
  Widget build(BuildContext context) {
    final identity = ref.watch(propertyRegistrationProvider).identity;
    final isComplete = identity.isComplete;

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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: mainColor),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Aviso de privacidad
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
                                Icons.security,
                                color: Colors.blue.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tus datos están protegidos',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tus documentos se utilizan únicamente para verificar tu identidad y cumplir con regulaciones. No compartimos esta información con terceros.',
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
                        const Text(
                          'Captura tu INE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Asegúrate de que la imagen sea clara y legible',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        IneCaptureCard(
                          title: 'INE Frente',
                          description: 'Foto frontal de tu credencial',
                          icon: Icons.credit_card,
                          imagePath: identity.ineFrontPath,
                          onCapture: () => _captureImage('front'),
                          onRetake: identity.ineFrontPath != null
                              ? () => _clearImage('front')
                              : null,
                        ),
                        const SizedBox(height: 12),
                        IneCaptureCard(
                          title: 'INE Reverso',
                          description: 'Foto trasera de tu credencial',
                          icon: Icons.flip,
                          imagePath: identity.ineBackPath,
                          onCapture: () => _captureImage('back'),
                          onRetake: identity.ineBackPath != null
                              ? () => _clearImage('back')
                              : null,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Selfie de verificación',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tomaremos una foto para comparar con tu INE',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        IneCaptureCard(
                          title: 'Selfie',
                          description: 'Foto de tu rostro mirando a la cámara',
                          icon: Icons.face,
                          imagePath: identity.selfiePath,
                          onCapture: () => _captureImage('selfie'),
                          onRetake: identity.selfiePath != null
                              ? () => _clearImage('selfie')
                              : null,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          StepNavigationButtons(
            onPrevious: widget.onPrevious,
            onNext: widget.onNext,
            isNextEnabled: isComplete,
          ),
        ],
      ),
    );
  }
}
