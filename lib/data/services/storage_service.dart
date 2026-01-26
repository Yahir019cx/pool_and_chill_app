import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Subir imagen de perfil a Firebase Storage
  /// Retorna la URL de descarga de la imagen
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      // 1. Comprimir imagen antes de subir
      final compressedFile = await compressImage(imageFile);

      // 2. Generar nombre único con timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'profile_$timestamp.jpg';

      // 3. Crear referencia en Firebase Storage
      // Ruta: profiles/{userId}/profile_{timestamp}.jpg
      final storageRef = _storage
          .ref()
          .child('profiles')
          .child(userId)
          .child(fileName);

      // 4. Eliminar imagen anterior del usuario
      await deleteOldProfileImage(userId);

      // 5. Subir archivo con metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = storageRef.putFile(compressedFile, metadata);

      // 6. Esperar a que termine la subida
      final snapshot = await uploadTask;

      // 7. Obtener URL de descarga
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      if (e.code == 'unauthorized') {
        throw Exception('No tienes permisos para subir imágenes');
      } else if (e.code == 'canceled') {
        throw Exception('Subida cancelada');
      } else {
        throw Exception('Error de Firebase: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  /// Eliminar todas las imágenes anteriores del usuario
  Future<void> deleteOldProfileImage(String userId) async {
    try {
      final listResult = await _storage
          .ref()
          .child('profiles')
          .child(userId)
          .listAll();

      for (var item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      // Si no hay imágenes anteriores, no es un error
    }
  }

  /// Comprimir imagen antes de subir
  /// Redimensiona a máximo 1024x1024 y calidad 85%
  Future<File> compressImage(File imageFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final targetPath = '${tempDir.path}/compressed_$timestamp.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 85,
        minWidth: 1024,
        minHeight: 1024,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        throw Exception('Error al comprimir imagen');
      }

      return File(compressedFile.path);
    } catch (e) {
      throw Exception('Error al comprimir imagen: $e');
    }
  }
}
