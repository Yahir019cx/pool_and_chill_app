import 'dart:io';

import 'package:flutter/services.dart';

/// Canal de plataforma para el SDK nativo de Didit (solo Android).
/// No almacenar el sessionToken; se usa solo para la llamada.
class DiditPlatform {
  static const MethodChannel _channel =
      MethodChannel('com.poolandchill.app/didit');

  /// Inicia el flujo de verificación Didit en el SDK nativo Android.
  /// [sessionToken] debe obtenerse del backend (POST /kyc/start), no hardcodear.
  /// Lanza si no es Android o si el SDK falla.
  static Future<void> startVerification(String sessionToken) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError(
        'Didit SDK nativo solo está disponible en Android. '
        'En web/iOS usa la URL de verificación.',
      );
    }
    // ignore: avoid_print
    print('[Didit] DiditPlatform: invokeMethod startDiditVerification (token length=${sessionToken.length})');
    await _channel.invokeMethod<void>('startDiditVerification', <String, dynamic>{
      'sessionToken': sessionToken,
    });
    // ignore: avoid_print
    print('[Didit] DiditPlatform: invokeMethod retornó OK');
  }
}
