import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  String? _accessToken;

  ApiClient({required this.baseUrl});

  // 👉 Se llama después del login
  void setAccessToken(String token) {
    _accessToken = token;
  }

  // 👉 Se llama en logout
  void clearAccessToken() {
    _accessToken = null;
  }

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

  Future<http.Response> get(
    String path, {
    bool withAuth = true,
  }) {
    return http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers(withAuth: withAuth),
    );
  }

  Future<http.Response> post(
    String path, {
    dynamic body,
    bool withAuth = true,
  }) {
    return http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(withAuth: withAuth),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> patch(
    String path, {
    dynamic body,
    bool withAuth = true,
  }) {
    return http.patch(
      Uri.parse('$baseUrl$path'),
      headers: _headers(withAuth: withAuth),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> delete(
    String path, {
    bool withAuth = true,
  }) {
    return http.delete(
      Uri.parse('$baseUrl$path'),
      headers: _headers(withAuth: withAuth),
    );
  }
}
