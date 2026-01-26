import 'package:flutter/material.dart';

import 'package:pool_and_chill_app/data/api/api_client.dart';
import 'package:pool_and_chill_app/data/models/login/index.dart';
import 'package:pool_and_chill_app/data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final AuthService _authService;

  UserModel? _user;
  bool _loading = false;

  AuthProvider(this.apiClient) : _authService = AuthService(apiClient);

  // ===== GETTERS =====
  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _loading;

  // ===== LOGIN =====
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);

      apiClient.setAccessToken(response.accessToken);
      _user = response.user;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ===== LOGOUT =====
  Future<void> logout() async {
    _user = null;
    apiClient.clearAccessToken();
    notifyListeners();
  }
}
