import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pool_and_chill_app/core/widgets/top_chip.dart';
import 'package:pool_and_chill_app/data/providers/property_registration_provider.dart';
import '../widgets/step_navigation_buttons.dart';
import '../widgets/photo_grid.dart';

class Step6Screen extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const Step6Screen({
    super.key,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  ConsumerState<Step6Screen> createState() => _Step6ScreenState();
}

class _Step6ScreenState extends ConsumerState<Step6Screen> {
  final _picker = ImagePicker();
  bool _isLoading = false;
  static const Color mainColor = Color(0xFF3CA2A2);
  static const int _maxPhotos = 10;
  static const int _maxFileSizeMB = 10;

  /// Copia la imagen a una ruta persistente para que siga existiendo al subir en Step 8.
  Future<String?> _persistPhotoPath(String sourcePath, [int suffix = 0]) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final photoDir = Directory('${dir.path}/property_photos');
      if (!await photoDir.exists()) await photoDir.create(recursive: true);
      final name = '${DateTime.now().millisecondsSinceEpoch}_$suffix.jpg';
      final destFile = File('${photoDir.path}/$name');
      await File(sourcePath).copy(destFile.path);
      return destFile.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickImages(ImageSource source) async {
    try {
      setState(() => _isLoading = true);

      if (source == ImageSource.gallery) {
        final images = await _picker.pickMultiImage(
          imageQuality: 85,
          maxWidth: 1920,
          maxHeight: 1920,
        );

        final notifier = ref.read(propertyRegistrationProvider.notifier);
        var i = 0;
        for (final image in images) {
          final fileSize = await image.length();
          if (fileSize > _maxFileSizeMB * 1024 * 1024) {
            if (mounted) {
              _showError('La imagen ${image.name} excede ${_maxFileSizeMB}MB');
            }
            continue;
          }
          final persistentPath = await _persistPhotoPath(image.path, i);
          if (persistentPath != null && mounted) {
            notifier.addPhoto(persistentPath);
          } else if (mounted) {
            notifier.addPhoto(image.path);
          }
          i++;
        }
      } else {
        final image = await _picker.pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 1920,
          maxHeight: 1920,
        );

        if (image != null && mounted) {
          final fileSize = await image.length();
          if (fileSize > _maxFileSizeMB * 1024 * 1024) {
            _showError('La imagen excede ${_maxFileSizeMB}MB');
            return;
          }
          final persistentPath = await _persistPhotoPath(image.path);
          final path = persistentPath ?? image.path;
          ref.read(propertyRegistrationProvider.notifier).addPhoto(path);
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Error al seleccionar imagen');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    TopChip.showError(context, message);
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Agregar fotos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              _SourceOption(
                icon: Icons.photo_library_outlined,
                label: 'Galería',
                subtitle: 'Selecciona varias fotos',
                onTap: () {
                  Navigator.pop(context);
                  _pickImages(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
              _SourceOption(
                icon: Icons.camera_alt_outlined,
                label: 'Cámara',
                subtitle: 'Toma una foto',
                onTap: () {
                  Navigator.pop(context);
                  _pickImages(ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = ref.watch(propertyRegistrationProvider).photos.photoPaths;
    final hasPhotos = photos.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          const Text(
            'Paso 6 de 8',
            style: TextStyle(fontSize: 13, color: Colors.black45),
          ),
          const SizedBox(height: 8),
          const Text(
            'Fotos del espacio',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'La primera foto será la principal',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            'Formatos: JPG, PNG, HEIC • Máx ${_maxFileSizeMB}MB por imagen',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: mainColor),
                  )
                : hasPhotos
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            PhotoGrid(
                              photos: photos,
                              maxPhotos: _maxPhotos,
                              onAddPhoto: _showImageSourceDialog,
                              onRemovePhoto: (index) {
                                ref
                                    .read(propertyRegistrationProvider.notifier)
                                    .removePhoto(index);
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${photos.length} de $_maxPhotos fotos',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildEmptyState(),
          ),
          const SizedBox(height: 16),
          StepNavigationButtons(
            onPrevious: widget.onPrevious,
            onNext: widget.onNext,
            isNextEnabled: hasPhotos,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: GestureDetector(
        onTap: _showImageSourceDialog,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: mainColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: mainColor.withValues(alpha: 0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 64,
                color: mainColor.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              const Text(
                'Agregar fotos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: mainColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toca aquí para seleccionar\nimágenes de tu espacio',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  static const Color mainColor = Color(0xFF3CA2A2);

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: mainColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: mainColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
