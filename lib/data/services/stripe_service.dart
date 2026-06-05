import 'dart:convert';

import 'package:pool_and_chill_app/data/api/index.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DTOs
// ─────────────────────────────────────────────────────────────────────────────

/// Domicilio fiscal de la propiedad del host (GET /properties/my/fiscal-address).
class FiscalAddress {
  final String street;
  final String exteriorNumber;
  final String? interiorNumber;
  final String neighborhood;
  final String zipCode;
  final String stateName;
  final String cityName;

  const FiscalAddress({
    required this.street,
    required this.exteriorNumber,
    this.interiorNumber,
    required this.neighborhood,
    required this.zipCode,
    required this.stateName,
    required this.cityName,
  });

  factory FiscalAddress.fromJson(Map<String, dynamic> json) {
    return FiscalAddress(
      street:          json['street']          as String? ?? '',
      exteriorNumber:  json['exteriorNumber']  as String? ?? '',
      interiorNumber:  json['interiorNumber']  as String?,
      neighborhood:    json['neighborhood']    as String? ?? '',
      zipCode:         json['zipCode']         as String? ?? '',
      stateName:       json['stateName']       as String? ?? '',
      cityName:        json['cityName']        as String? ?? '',
    );
  }
}

/// Datos del formulario fiscal enviados al backend (POST /stripe/connect/setup-account).
class SetupAccountRequest {
  final String firstName;
  final String lastName;
  final String dateOfBirth;   // YYYY-MM-DD
  final String phone;         // 10 dígitos sin +52
  final String rfc;
  final String clabe;
  final String street;
  final String exteriorNumber;
  final String? interiorNumber;
  final String neighborhood;
  final String zipCode;
  final String stateName;
  final String cityName;

  const SetupAccountRequest({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.phone,
    required this.rfc,
    required this.clabe,
    required this.street,
    required this.exteriorNumber,
    this.interiorNumber,
    required this.neighborhood,
    required this.zipCode,
    required this.stateName,
    required this.cityName,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName':      firstName,
      'lastName':       lastName,
      'dateOfBirth':    dateOfBirth,
      'phone':          phone,
      'rfc':            rfc,
      'clabe':          clabe,
      'street':         street,
      'exteriorNumber': exteriorNumber,
      if (interiorNumber != null && interiorNumber!.isNotEmpty)
        'interiorNumber': interiorNumber,
      'neighborhood':   neighborhood,
      'zipCode':        zipCode,
      'stateName':      stateName,
      'cityName':       cityName,
    };
  }
}

/// Se lanza cuando el host no tiene propiedad registrada (404 en fiscal-address).
class FiscalAddressNotFoundException implements Exception {
  const FiscalAddressNotFoundException();
}

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

  /// GET /properties/my/fiscal-address → domicilio de la propiedad del host.
  /// Lanza [FiscalAddressNotFoundException] si el host no tiene propiedad (404).
  Future<FiscalAddress> getFiscalAddress() async {
    final response = await api.get(ApiRoutes.propertyFiscalAddress);

    if (response.statusCode == 404) {
      throw const FiscalAddressNotFoundException();
    }

    if (response.statusCode != 200) {
      try {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        final message = error['message'];
        if (message is List) throw Exception(message.join('\n'));
        throw Exception(message ?? 'Error al obtener el domicilio');
      } catch (e) {
        if (e is Exception && e.toString().startsWith('Exception:')) rethrow;
        throw Exception('Error al conectar con el servidor');
      }
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return FiscalAddress.fromJson(data);
  }

  /// POST /stripe/connect/setup-account
  /// Guarda los datos fiscales en la BD, crea la cuenta Stripe con pre-llenado
  /// y devuelve la onboardingUrl.
  Future<String> setupConnectAccount(SetupAccountRequest request) async {
    final response = await api.post(
      ApiRoutes.stripeConnectSetupAccount,
      body: request.toJson(),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      try {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        final message = error['message'];
        if (message is List) throw Exception(message.join('\n'));
        throw Exception(message ?? 'Error al configurar la cuenta de Stripe');
      } catch (e) {
        if (e is Exception && e.toString().startsWith('Exception:')) rethrow;
        throw Exception('Error al conectar con Stripe');
      }
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['onboardingUrl'] as String;
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
