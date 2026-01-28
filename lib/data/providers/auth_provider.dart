import 'package:flutter/material.dart';

import 'package:pool_and_chill_app/data/api/api_client.dart';
import 'package:pool_and_chill_app/data/models/user/index.dart';
import 'package:pool_and_chill_app/data/services/auth_service.dart';
import 'package:pool_and_chill_app/data/services/user_service.dart';
import 'package:pool_and_chill_app/data/storage/secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final AuthService _authService;
  final UserService _userService;

  UserProfileModel? _profile;
  bool _loading = false;
  bool _bootstrapped = false;

  AuthProvider(this.apiClient)
    : _authService = AuthService(apiClient),
      _userService = UserService(apiClient);

  // ===== GETTERS =====
  bool get isLoading => _loading;
  bool get isAuthenticated => _profile != null;
  bool get isBootstrapped => _bootstrapped;
  UserProfileModel? get profile => _profile;

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

      _profile = await _userService.getMe();
    } finally {
      _setLoading(false);
    }
  }

  // ===== LOGOUT =====
  Future<void> logout() async {
    _profile = null;
    await SecureStorage.clear();
    apiClient.clearAccessToken();
    notifyListeners();
  }

  bool _refreshing = false;

  Future<bool> refreshSession() async {
    if (_refreshing) return false;
    _refreshing = true;

    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null) throw Exception();

      final session = await _authService.refresh(refreshToken);

      apiClient.setAccessToken(session.accessToken);

      await SecureStorage.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );

      return true;
    } catch (_) {
      await logout();
      return false;
    } finally {
      _refreshing = false;
    }
  }
}
