import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

/// Service for handling authentication using a local JSON file and Hive.
class AuthService {
  final Box _box;
  static const _tokenKey = 'token';
  static const _emailKey = 'email';
  static const _expiryKey = 'expiry';

  AuthService(this._box);

  /// Attempts login with [email] and [password] against a local JSON asset.
  /// On success, stores token, email, and expiration in Hive box.
  Future<Map<String, String>> login(String email, String password) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 500));
    final jsonStr = await rootBundle.loadString('assets/auth/users.json');
    final users = (json.decode(jsonStr) as List).cast<Map<String, dynamic>>();
    final user = users.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => throw Exception('Invalid email or password'),
    );
    final token = user['token'] as String;
    final expiration = DateTime.now()
        .add(const Duration(days: 30))
        .millisecondsSinceEpoch;
    await _box.put(_tokenKey, token);
    await _box.put(_emailKey, email);
    await _box.put(_expiryKey, expiration);
    return {'email': email, 'token': token};
  }

  /// Tries to restore a previous session by checking stored token validity.
  Future<bool> tryAutoLogin() async {
    final token = _box.get(_tokenKey) as String?;
    final expiry = _box.get(_expiryKey) as int?;
    if (token != null && expiry != null && expiry > DateTime.now().millisecondsSinceEpoch) {
      return true;
    }
    await logout();
    return false;
  }

  /// Clears stored authentication data.
  Future<void> logout() async {
    await _box.delete(_tokenKey);
    await _box.delete(_emailKey);
    await _box.delete(_expiryKey);
  }

  /// Returns the current token, if any.
  String? get token => _box.get(_tokenKey) as String?;
  /// Returns the current user email, if any.
  String? get email => _box.get(_emailKey) as String?;
}