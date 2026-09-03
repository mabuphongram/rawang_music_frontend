import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rawang_melodies/data/local/entity/entities.dart';

class AuthService {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://192.168.90.31:5000/api';
  static const _storage = FlutterSecureStorage();
  static const _kToken = 'auth_token';
  static const _kRefresh = 'refresh_token';
  static const _kUser = 'auth_user_json';

  static Future<String?> getToken() => _storage.read(key: _kToken);
  static Future<String?> getRefreshToken() => _storage.read(key: _kRefresh);

  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    if (token == null) return {'Content-Type': 'application/json'};
    return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  static Future<void> saveSession({required String token, required String refreshToken, required Map<String, dynamic> userJson}) async {
    await _storage.write(key: _kToken, value: token);
    await _storage.write(key: _kRefresh, value: refreshToken);
    await _storage.write(key: _kUser, value: json.encode(userJson));
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: _kToken);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kUser);
  }

  static Future<Map<String, dynamic>?> getCachedUserJson() async {
    final s = await _storage.read(key: _kUser);
    if (s == null) return null;
    try { return json.decode(s) as Map<String, dynamic>; } catch (_) { return null; }
  }

  static Future<UserEntity?> getCachedUser() async {
    final j = await getCachedUserJson();
    if (j == null) return null;
    try { return UserEntity.fromMap(j); } catch (_) { return null; }
  }

  // ── API ──────────────────────────────────────
  static Future<Map<String, dynamic>> register({required String phone, required String password, required String name, String? email}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'phone': phone, 'password': password, 'name': name, if (email != null && email.isNotEmpty) 'email': email}),
    ).timeout(const Duration(seconds: 8));
    final body = json.decode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201) {
      await saveSession(token: body['token'], refreshToken: body['refreshToken'], userJson: body['user']);
      return body;
    }
    throw Exception(body['error'] ?? 'Register failed');
  }

  static Future<Map<String, dynamic>> login({required String phone, required String password}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'phone': phone, 'password': password}),
    ).timeout(const Duration(seconds: 8));
    final body = json.decode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      await saveSession(token: body['token'], refreshToken: body['refreshToken'], userJson: body['user']);
      return body;
    }
    throw Exception(body['error'] ?? 'Login failed');
  }

  static Future<UserEntity> fetchMe() async {
    final headers = await authHeaders();
    final res = await http.get(Uri.parse('$baseUrl/auth/me'), headers: headers).timeout(const Duration(seconds: 8));
    if (res.statusCode == 200) {
      final body = json.decode(res.body) as Map<String, dynamic>;
      final user = UserEntity.fromMap(body['user']);
      await _storage.write(key: _kUser, value: json.encode(body['user']));
      return user;
    }
    if (res.statusCode == 401) throw Exception('Unauthorized');
    throw Exception('Failed to fetch profile');
  }

  static Future<void> refresh() async {
    final rt = await getRefreshToken();
    if (rt == null) throw Exception('No refresh token');
    final res = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refreshToken': rt}),
    ).timeout(const Duration(seconds: 8));
    if (res.statusCode == 200) {
      final body = json.decode(res.body) as Map<String, dynamic>;
      await _storage.write(key: _kToken, value: body['token']);
      await _storage.write(key: _kRefresh, value: body['refreshToken']);
      return;
    }
    throw Exception('Refresh failed');
  }

  static Future<String> forgotRequest(String phone) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/forgot-request'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'phone': phone}),
    ).timeout(const Duration(seconds: 8));
    final body = json.decode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return body['message'] ?? 'Request sent';
    throw Exception(body['error'] ?? 'Request failed');
  }

  static Future<void> changePassword({required String oldPassword, required String newPassword}) async {
    final headers = await authHeaders();
    final res = await http.post(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: headers,
      body: json.encode({'oldPassword': oldPassword, 'newPassword': newPassword}),
    ).timeout(const Duration(seconds: 8));
    if (res.statusCode == 200) return;
    final body = json.decode(res.body);
    throw Exception(body['error'] ?? 'Change password failed');
  }

  static Future<void> logout() => clearSession();
}
