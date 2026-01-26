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

  AuthProvider(this.apiClient)
    : _authService = AuthService(apiClient),
      _userService = UserService(apiClient);

  // ===== GETTERS =====
  bool get isLoading => _loading;
  bool get isAuthenticated => _profile != null;
  UserProfileModel? get profile => _profile;

  // ===== PRIVATE STATE HELPERS =====
  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
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
    } catch (e) {
      _profile = null;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ===== RESTORE SESSION (Splash) =====
  Future<bool> tryRestoreSession() async {
    _setLoading(true);

    try {
      final accessToken = await SecureStorage.getAccessToken();
      if (accessToken == null) return false;

      apiClient.setAccessToken(accessToken);
      _profile = await _userService.getMe();

      return true;
    } catch (_) {
      _profile = null;
      await SecureStorage.clear();
      apiClient.clearAccessToken();
      return false;
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
