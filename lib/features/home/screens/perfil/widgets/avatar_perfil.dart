// perfil/widgets/avatar_perfil.dart
import 'package:flutter/material.dart';

class AvatarPerfil extends StatelessWidget {
  final VoidCallback? onTap;

  const AvatarPerfil({super.key, this.onTap});

  static const Color primary = Color(0xFF3CA2A2);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: primary.withOpacity(0.15),
            child: const Icon(
              Icons.person,
              size: 52,
              color: Colors.grey,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 4,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary,
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
}
