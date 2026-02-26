import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:pool_and_chill_app/data/api/api_client.dart';
import 'package:pool_and_chill_app/data/models/user/index.dart';
import 'package:pool_and_chill_app/data/models/property/index.dart';
import 'package:pool_and_chill_app/data/services/auth_service.dart';
import 'package:pool_and_chill_app/data/services/user_service.dart';
import 'package:pool_and_chill_app/data/services/property_service.dart';
import 'package:pool_and_chill_app/data/storage/secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final AuthService _authService;
  final UserService _userService;
  final PropertyService _propertyService;

  UserProfileModel? _profile;
  List<MyPropertyModel> _myProperties = [];
  bool _loading = false;
  bool _bootstrapped = false;
  bool _loadingProperties = false;
  // Cuando true, AuthGate muestra WelcomeScreen (modo huésped) aunque el
  // usuario sea host. Se resetea al hacer logout o al volver a modo host.
  bool _guestModeOverride = false;

  AuthProvider(this.apiClient)
    : _authService = AuthService(apiClient),
      _userService = UserService(apiClient),
      _propertyService = PropertyService(apiClient);

  // ===== GETTERS =====
  bool get isLoading => _loading;
  bool get isAuthenticated => _profile != null;
  bool get isBootstrapped => _bootstrapped;
  UserProfileModel? get profile => _profile;
  List<MyPropertyModel> get myProperties => _myProperties;
  bool get isLoadingProperties => _loadingProperties;
  bool get isGuestModeOverride => _guestModeOverride;

  // ===== MODO HUÉSPED / MODO HOST =====
  /// Activa la vista de huésped para un usuario host (sin cerrar sesión).
  /// AuthGate mostrará WelcomeScreen mientras este flag esté activo.
  void switchToGuestMode() {
    _guestModeOverride = true;
    notifyListeners();
  }

  /// Vuelve a la vista de host. Útil desde la pantalla de perfil huésped.
  void switchToHostMode() {
    _guestModeOverride = false;
    notifyListeners();
  }

  // Expone el UserService para operaciones de perfil
  UserService get userService => _userService;

  // ===== PROFILE IMAGE =====
  /// Actualiza la imagen de perfil en memoria
  void updateUserImage(String? imageUrl) {
    if (_profile != null) {
      _profile = _profile!.copyWith(
        profileImageUrl: imageUrl,
        clearProfileImageUrl: imageUrl == null,
      );
      notifyListeners();
    }
  }

  /// Refresca el perfil completo desde el servidor
  Future<void> refreshProfile() async {
    if (_profile != null) {
      _profile = await _userService.getMe();
      notifyListeners();
    }
  }

  /// Actualiza el perfil con los nuevos datos
  void setProfile(UserProfileModel profile) {
    _profile = profile;
    notifyListeners();
  }

  /// Actualiza el perfil del usuario en el backend
  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? phoneNumber,
    String? location,
  }) async {
    await _userService.updateProfile(
      displayName: displayName,
      bio: bio,
      phoneNumber: phoneNumber,
      location: location,
    );
    // Refrescar perfil completo para obtener todos los datos
    await refreshProfile();
  }

  // ===== MY PROPERTIES =====
  /// Obtiene las propiedades del host autenticado
  Future<void> fetchMyProperties() async {
    _loadingProperties = true;
    notifyListeners();

    try {
      _myProperties = await _propertyService.getMyProperties();
    } catch (_) {
      _myProperties = [];
    } finally {
      _loadingProperties = false;
      notifyListeners();
    }
  }

  // ===== HOST ONBOARDING =====
  /// Completa el onboarding de host y refresca el perfil
  Future<void> completeHostOnboarding() async {
    await _userService.completeHostOnboarding();
    await refreshProfile();
  }

  // ===== INTERNAL =====
  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  // ===== BOOTSTRAP (Splash) =====
  Future<void> bootstrap() async {
    _setLoading(true);

    try {
      final accessToken = await SecureStorage.getAccessToken();
      if (accessToken != null) {
        apiClient.setAccessToken(accessToken);
        _profile = await _userService.getMe();
        if (_profile != null && _profile!.isHost) {
          await fetchMyProperties();
        }
      }
    } catch (_) {
      _profile = null;
      await SecureStorage.clear();
      apiClient.clearAccessToken();
    } finally {
      _loading = false;
      _bootstrapped = true;
      notifyListeners();
    }
  }

  // ===== LOGIN =====
  Future<void> login({required String email, required String password}) async {
    _setLoading(true);

    try {
      final session = await _authService.login(email, password);

      apiClient.setAccessToken(session.accessToken);

      await SecureStorage.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );

      try {
        _profile = await _userService.getMe();
      } catch (e) {
        // Si getMe() falla después de guardar tokens, limpiamos para evitar
        // que un reload autentique al usuario sin haber completado el flujo.
        await SecureStorage.clear();
        apiClient.clearAccessToken();
        rethrow;
      }

      if (_profile != null && _profile!.isHost) {
        try {
          _myProperties = await _propertyService.getMyProperties();
        } catch (_) {
          _myProperties = [];
        }
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ===== LOGIN WITH APPLE =====
  Future<void> loginWithApple() async {
    _setLoading(true);

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (credential.identityToken == null) {
        return;
      }

      final session = await _authService.loginWithApple(
        identityToken: credential.identityToken!,
        firstName: credential.givenName,
        lastName: credential.familyName,
      );

      apiClient.setAccessToken(session.accessToken);
      await SecureStorage.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );

      try {
        _profile = await _userService.getMe();
      } catch (e) {
        await SecureStorage.clear();
        apiClient.clearAccessToken();
        rethrow;
      }

      if (_profile != null && _profile!.isHost) {
        try {
          _myProperties = await _propertyService.getMyProperties();
        } catch (_) {
          _myProperties = [];
        }
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return;
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ===== LOGIN WITH GOOGLE =====
  Future<void> loginWithGoogle() async {
    _setLoading(true);

    try {
      final googleSignIn = GoogleSignIn(
        serverClientId:
            '395705090497-7n4m477hvgf5un5kiv0ajcfk58tvi9o2.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // El usuario canceló el popup
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) throw Exception('No se pudo obtener el token de Google');

      final session = await _authService.loginWithGoogle(idToken);

      apiClient.setAccessToken(session.accessToken);
      await SecureStorage.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );

      try {
        _profile = await _userService.getMe();
      } catch (e) {
        await SecureStorage.clear();
        apiClient.clearAccessToken();
        rethrow;
      }

      if (_profile != null && _profile!.isHost) {
        try {
          _myProperties = await _propertyService.getMyProperties();
        } catch (_) {
          _myProperties = [];
        }
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ===== REGISTER =====
  Future<void> register({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
    String? dateOfBirth,
    int? gender,
  }) async {
    _setLoading(true);

    try {
      await _authService.register(
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        password: password,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );
    } finally {
      _setLoading(false);
    }
  }

  // ===== FORGOT PASSWORD =====
  Future<void> forgotPassword(String email) async {
    _setLoading(true);
    try {
      await _authService.forgotPassword(email);
    } finally {
      _setLoading(false);
    }
  }

  // ===== LOGOUT =====
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {
      // Si falla el endpoint, igual limpiamos localmente
    }

    _profile = null;
    _myProperties = [];
    _guestModeOverride = false;
    await SecureStorage.clear();
    apiClient.clearAccessToken();
    notifyListeners();
  }

  Completer<bool>? _refreshCompleter;

  Future<bool> refreshSession() async {
    // Si ya hay un refresh en curso, esperar su resultado
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null) throw Exception('No refresh token');

      final result = await _authService.refresh(refreshToken);

      // El endpoint /auth/refresh solo devuelve accessToken + expiresIn
      // El refreshToken no cambia, solo actualizamos el accessToken
      apiClient.setAccessToken(result.accessToken);
      await SecureStorage.saveAccessToken(result.accessToken);

      _refreshCompleter!.complete(true);
      return true;
    } catch (_) {
      _refreshCompleter!.complete(false);
      await logout();
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }
}
