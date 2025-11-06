// lib/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String rule34_tokenKey = 'auth_token';
const String rule34_userIdKey = 'auth_user_id';
const String civitai_tokenKey = 'civitai_auth';

class AuthService {
  final SharedPreferences _prefs;
  AuthService(this._prefs);

  String? getCivitaiToken() => _prefs.getString(civitai_tokenKey);
  Future<void> saveCivitaiToken(String token) async {
    debugPrint('[AuthService] Saving Civitai token.');
    await _prefs.setString(civitai_tokenKey, token);
  }

  String? getRule34Token() => _prefs.getString(rule34_tokenKey);
  String? getRule34UserId() => _prefs.getString(rule34_userIdKey);
  Future<void> saveRule34Credentials(String token, String userId) async {
    debugPrint('[AuthService] Saving Rule34 credentials.');
    await _prefs.setString(rule34_tokenKey, token);
    await _prefs.setString(rule34_userIdKey, userId);
  }
}
