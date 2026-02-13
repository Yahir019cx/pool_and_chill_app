import 'dart:convert';

import 'package:pool_and_chill_app/data/api/index.dart';
import 'package:pool_and_chill_app/data/services/didit_platform.dart';

/// Respuesta de POST /kyc/start. Solo el backend tiene API key y workflow.
class KycStartResponse {
  final String sessionToken;
  final String? verificationUrl;
  final String? sessionId;

  const KycStartResponse({
    required this.sessionToken,
    this.verificationUrl,
    this.sessionId,
  });

  factory KycStartResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return KycStartResponse(
      sessionToken: (data['sessionToken'] ?? data['session_token'])?.toString() ?? '',
      verificationUrl: (data['verificationUrl'] ?? data['verification_url'])?.toString(),
      sessionId: (data['sessionId'] ?? data['session_id'])?.toString(),
    );
  }
}

/// Respuesta de GET /kyc/status (o /verification/status).
class KycStatusResponse {
  final bool isVerified;
  final String verificationStatus;
  final bool hasPendingSession;

  const KycStatusResponse({
    required this.isVerified,
    required this.verificationStatus,
    required this.hasPendingSession,
  });

  factory KycStatusResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return KycStatusResponse(
      isVerified: data['isVerified'] as bool? ?? false,
      verificationStatus:
          data['verificationStatus'] as String? ?? 'PENDING',
      hasPendingSession: data['hasPendingSession'] as bool? ?? false,
    );
  }
}

class KycService {
  final ApiClient api;

  KycService(this.api);

  /// Crea una sesión de KYC en el backend y devuelve sessionToken (y opcionalmente verificationUrl para web).
  /// Requiere usuario autenticado (JWT).
  Future<KycStartResponse> startKyc() async {
    // ignore: avoid_print
    print('[Didit] KycService: POST /kyc/start');
    final response = await api.post(ApiRoutes.kycStart);
    // ignore: avoid_print
    print('[Didit] KycService: respuesta status=${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        final msg = err['message'];
        throw Exception(
          msg is List ? msg.join('\n') : (msg ?? 'Error al iniciar verificación'),
        );
      } catch (e) {
        if (e is Exception && e.toString().startsWith('Exception:')) rethrow;
        throw Exception('Error al iniciar verificación KYC');
      }
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final start = KycStartResponse.fromJson(data);
    // ignore: avoid_print
    print('[Didit] KycService: sessionToken length=${start.sessionToken.length}, sessionId=${start.sessionId ?? "null"}');
    return start;
  }

  /// Consulta el estado de verificación del usuario (isVerified, verificationStatus, hasPendingSession).
  Future<KycStatusResponse> getStatus() async {
    final response = await api.get(ApiRoutes.kycStatus);

    if (response.statusCode != 200) {
      throw Exception('Error al consultar estado de verificación');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return KycStatusResponse.fromJson(data);
  }

  /// Flujo móvil Android: inicia sesión en backend y abre el SDK nativo Didit con el sessionToken.
  /// No almacena el token; solo lo usa para la llamada al SDK.
  Future<void> startDiditVerificationOnDevice() async {
    // ignore: avoid_print
    print('[Didit] KycService: startDiditVerificationOnDevice() - obteniendo sesión...');
    final start = await startKyc();
    if (start.sessionToken.isEmpty) {
      // ignore: avoid_print
      print('[Didit] KycService: ERROR - sessionToken vacío');
      throw Exception('El servidor no devolvió sessionToken');
    }
    // ignore: avoid_print
    print('[Didit] KycService: llamando DiditPlatform.startVerification()');
    await DiditPlatform.startVerification(start.sessionToken);
    // ignore: avoid_print
    print('[Didit] KycService: DiditPlatform.startVerification() retornó');
  }
}
