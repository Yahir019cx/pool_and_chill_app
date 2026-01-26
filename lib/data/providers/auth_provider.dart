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
  Future<void> login({
    required String email,
    required String password,
  }) async {
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
}
