// perfil/widgets/avatar_perfil.dart
import 'package:flutter/material.dart';

class AvatarPerfil extends StatelessWidget {
  final VoidCallback? onTap;
  final String? imageUrl;
  final String initials;
  final bool isLoading;

  const AvatarPerfil({
    super.key,
    this.onTap,
    this.imageUrl,
    this.initials = '',
    this.isLoading = false,
  });

  static const Color primary = Color(0xFF3CA2A2);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          // Avatar con imagen o iniciales
          CircleAvatar(
            radius: 52,
            backgroundColor: primary.withValues(alpha: 0.15),
            backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                ? NetworkImage(imageUrl!)
                : null,
            child: _buildAvatarContent(),
          ),

          // Indicador de carga superpuesto
          if (isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),

          // Botón de cámara
          Positioned(
            bottom: 0,
            right: 4,
            child: GestureDetector(
              onTap: isLoading ? null : onTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isLoading ? Colors.grey : primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildAvatarContent() {
    // Si hay imagen, no mostrar contenido (la imagen es el fondo)
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return null;
    }

    // Si hay iniciales, mostrarlas
    if (initials.isNotEmpty) {
      return Text(
        initials,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primary,
        ),
      );
    }

    // Icono por defecto
    return const Icon(
      Icons.person,
      size: 52,
      color: Colors.grey,
    );
  }
}
