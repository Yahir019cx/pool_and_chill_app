import 'dart:io';

import 'package:flutter/services.dart';

/// Canal de plataforma para el SDK nativo de Didit (Android e iOS).
/// No almacenar el sessionToken; se usa solo para la llamada.
class DiditPlatform {
  static const MethodChannel _channel =
      MethodChannel('com.poolandchill.app/didit');

  /// Inicia el flujo de verificación Didit en el SDK nativo (Android o iOS).
  /// [sessionToken] debe obtenerse del backend (POST /kyc/start), no hardcodear.
  /// Retorna el status de verificación: "APPROVED", "CANCELLED", etc.
  /// Lanza si la plataforma no es soportada o si el SDK falla.
  static Future<String?> startVerification(String sessionToken) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw UnsupportedError(
        'Didit SDK nativo solo está disponible en Android e iOS.',
      );
    }
    // ignore: avoid_print
    print('[Didit] DiditPlatform: invokeMethod startDiditVerification '
        '(platform=${Platform.isAndroid ? "Android" : "iOS"}, '
        'token length=${sessionToken.length})');
    final result = await _channel.invokeMethod<String>('startDiditVerification', <String, dynamic>{
      'sessionToken': sessionToken,
    });
    // ignore: avoid_print
    print('[Didit] DiditPlatform: invokeMethod retornó status=$result');
    return result;
  }
}
