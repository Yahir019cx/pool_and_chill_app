import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:pool_and_chill_app/data/providers/auth_provider.dart';

class ApiClient {
  final String baseUrl;
  String? _accessToken;
  AuthProvider? _authProvider;

  ApiClient({required this.baseUrl});

  // ===== AUTH PROVIDER ATTACH =====
  void attachAuthProvider(AuthProvider provider) {
    _authProvider = provider;
  }

  // ===== TOKEN HANDLING =====
  void setAccessToken(String token) {
    _accessToken = token;
  }

  void clearAccessToken() {
    _accessToken = null;
  }

  // ===== HEADERS =====
  Map<String, String> _headers({bool withAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  // ===== CORE REQUEST WITH RETRY =====
  Future<http.Response> _send(
    Future<http.Response> Function() request, {
    bool retry = true,
  }) async {
    final response = await request();

    if (response.statusCode != 401) {
      return response;
    }

    if (!retry || _authProvider == null) {
      return response;
    }

    final refreshed = await _authProvider!.refreshSession();
    if (!refreshed) {
      return response;
    }

    // retry original request once
    return await _send(request, retry: false);
  }

  // ===== HTTP METHODS =====
  Future<http.Response> get(
    String path, {
    bool withAuth = true,
  }) {
    return _send(() {
      return http.get(
        Uri.parse('$baseUrl$path'),
        headers: _headers(withAuth: withAuth),
      );
    });
  }

  Future<http.Response> post(
    String path, {
    dynamic body,
    bool withAuth = true,
  }) {
    return _send(() {
      return http.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers(withAuth: withAuth),
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  Future<http.Response> patch(
    String path, {
    dynamic body,
    bool withAuth = true,
  }) {
    return _send(() {
      return http.patch(
        Uri.parse('$baseUrl$path'),
        headers: _headers(withAuth: withAuth),
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  Future<http.Response> delete(
    String path, {
    dynamic body,
    bool withAuth = true,
  }) {
    return _send(() {
      return http.delete(
        Uri.parse('$baseUrl$path'),
        headers: _headers(withAuth: withAuth),
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  /// DELETE con body (necesario para endpoints que requieren body en DELETE).
  Future<http.Response> deleteWithBody(
    String path, {
    dynamic body,
    bool withAuth = true,
  }) {
    return _send(() async {
      final request = http.Request('DELETE', Uri.parse('$baseUrl$path'));
      request.headers.addAll(_headers(withAuth: withAuth));
      if (body != null) {
        request.body = jsonEncode(body);
      }
      final streamed = await request.send();
      return http.Response.fromStream(streamed);
    });
  }
}
