import 'package:flutter/material.dart';

import 'package:pool_and_chill_app/data/api/api_client.dart';
import 'package:pool_and_chill_app/data/models/login/index.dart';
import 'package:pool_and_chill_app/data/models/user/index.dart';
import 'package:pool_and_chill_app/data/services/auth_service.dart';
import 'package:pool_and_chill_app/data/services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final AuthService _authService;
  final UserService _userService;

  AuthResponseModel? _session;
  UserProfileModel? _profile;
  bool _loading = false;

  AuthProvider(this.apiClient)
      : _authService = AuthService(apiClient),
        _userService = UserService(apiClient);

  // ===== GETTERS =====
  bool get isLoading => _loading;
  bool get isAuthenticated => _session != null;
  UserProfileModel? get profile => _profile;

  // ===== LOGIN =====
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      // Login
      final session = await _authService.login(email, password);
      apiClient.setAccessToken(session.accessToken);
      _session = session;

      // Get perfil
      _profile = await _userService.getMe();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ===== LOGOUT =====
  Future<void> logout() async {
    _session = null;
    _profile = null;
    apiClient.clearAccessToken();
    notifyListeners();
  }
}
