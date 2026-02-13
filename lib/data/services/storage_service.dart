import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Subir imagen de perfil a Firebase Storage (sin comprimir, igual que el flujo del avatar).
  /// Retorna la URL de descarga de la imagen.
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      if (!await imageFile.exists()) {
        throw Exception('El archivo de imagen no existe');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'profile_$timestamp.jpg';

      final storageRef = _storage
          .ref()
          .child('profiles')
          .child(userId)
          .child(fileName);

      await deleteOldProfileImage(userId);

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final snapshot = await storageRef.putFile(imageFile, metadata);
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

  /// Subir varias imágenes de propiedad a Firebase Storage (sin comprimir).
  /// Ruta: properties/{userId}/img_{timestamp}_{i}.jpg
  /// Retorna la lista de URLs de descarga en el mismo orden que [imageFiles].
  Future<List<String>> uploadPropertyImages(
    List<File> imageFiles,
    String userId,
  ) async {
    if (imageFiles.isEmpty) return [];
    final urls = <String>[];
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < imageFiles.length; i++) {
      final file = imageFiles[i];
      if (!await file.exists()) continue;
      final fileName = 'img_${timestamp}_$i.jpg';
      final storageRef = _storage
          .ref()
          .child('properties')
          .child(userId)
          .child(fileName);
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
      final snapshot = await storageRef.putFile(file, metadata);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      urls.add(downloadUrl);
    }
    return urls;
  }
}
