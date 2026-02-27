import 'dart:convert';

import 'package:pool_and_chill_app/data/api/index.dart';

/// DTO con el estado de la cuenta Stripe Connect del host.
class StripeAccountStatus {
  final bool hasAccount;
  final bool chargesEnabled;
  final bool payoutsEnabled;
  final bool onboardingCompleted;
  final String accountStatus;

  const StripeAccountStatus({
    required this.hasAccount,
    required this.chargesEnabled,
    required this.payoutsEnabled,
    required this.onboardingCompleted,
    required this.accountStatus,
  });

  factory StripeAccountStatus.fromJson(Map<String, dynamic> json) {
    return StripeAccountStatus(
      hasAccount: json['hasAccount'] as bool? ?? false,
      chargesEnabled: json['chargesEnabled'] as bool? ?? false,
      payoutsEnabled: json['payoutsEnabled'] as bool? ?? false,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      accountStatus: json['accountStatus'] as String? ?? '',
    );
  }

  /// La cuenta está lista para recibir pagos.
  bool get isReady => chargesEnabled && payoutsEnabled;
}

class StripeService {
  final ApiClient api;

  StripeService(this.api);

  /// POST /stripe/connect/create-account → devuelve la onboardingUrl.
  /// El link es de un solo uso; llamar cada vez que el host inicie/reintente el flujo.
  Future<String> createConnectAccount({required String userId}) async {
    final response = await api.post(
      ApiRoutes.stripeConnectCreateAccount,
      body: {'userId': userId},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        final message = error['message'];
        if (message is List) throw Exception(message.join('\n'));
        throw Exception(message ?? 'Error al crear cuenta de Stripe');
      } catch (e) {
        if (e is Exception && e.toString().startsWith('Exception:')) rethrow;
        throw Exception('Error al conectar con Stripe');
      }
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['onboardingUrl'] as String;
  }

  /// POST /stripe/connect/account-update-link → devuelve la updateUrl de un solo uso.
  /// Permite al host actualizar sus datos bancarios/fiscales en Stripe.
  /// Lanza Exception si el usuario no tiene cuenta Connect (400) o si hay error de red.
  Future<String> getAccountUpdateLink() async {
    final response = await api.post(
      ApiRoutes.stripeConnectAccountUpdateLink,
      body: {},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        final message = error['message'];
        if (message is List) throw Exception(message.join('\n'));
        throw Exception(message ?? 'Error al obtener el enlace de actualización');
      } catch (e) {
        if (e is Exception && e.toString().startsWith('Exception:')) rethrow;
        throw Exception('Error al conectar con Stripe');
      }
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['updateUrl'] as String;
  }

  /// GET /stripe/account-status → estado actual de la cuenta Connect.
  /// El backend refresca el estado desde Stripe antes de responder.
  Future<StripeAccountStatus> getAccountStatus() async {
    final response = await api.get(ApiRoutes.stripeAccountStatus);

    if (response.statusCode != 200) {
      try {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        final message = error['message'];
        if (message is List) throw Exception(message.join('\n'));
        throw Exception(message ?? 'Error al verificar cuenta de Stripe');
      } catch (e) {
        if (e is Exception && e.toString().startsWith('Exception:')) rethrow;
        throw Exception('Error al verificar cuenta de Stripe');
      }
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return StripeAccountStatus.fromJson(data);
  }
}
