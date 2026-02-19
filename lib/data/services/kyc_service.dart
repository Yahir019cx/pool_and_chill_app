import 'dart:convert';

import 'package:pool_and_chill_app/data/api/index.dart';

/// Respuesta de POST /kyc/start.
class KycStartResponse {
  final String sessionId;
  final String verificationUrl;

  const KycStartResponse({
    required this.sessionId,
    required this.verificationUrl,
  });

  factory KycStartResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return KycStartResponse(
      sessionId: (data['sessionId'] ?? data['session_id'])?.toString() ?? '',
      verificationUrl:
          (data['verificationUrl'] ?? data['verification_url'])?.toString() ??
              '',
    );
  }
}

/// Respuesta de GET /kyc/status.
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

  /// POST /kyc/start → devuelve sessionId + verificationUrl.
  /// Requiere usuario autenticado (JWT).
  Future<KycStartResponse> startKyc() async {
    final response = await api.post(ApiRoutes.kycStart);

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        final msg = err['message'];
        throw Exception(
          msg is List
              ? msg.join('\n')
              : (msg ?? 'Error al iniciar verificación'),
        );
      } catch (e) {
        if (e is Exception && e.toString().startsWith('Exception:')) rethrow;
        throw Exception('Error al iniciar verificación KYC');
      }
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return KycStartResponse.fromJson(data);
  }

  /// GET /kyc/status → estado de verificación del usuario.
  Future<KycStatusResponse> getStatus() async {
    final response = await api.get(ApiRoutes.kycStatus);

    if (response.statusCode != 200) {
      throw Exception('Error al consultar estado de verificación');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return KycStatusResponse.fromJson(data);
  }
}
