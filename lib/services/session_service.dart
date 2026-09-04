import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionService {
  SessionService._();
  static final instance = SessionService._();
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'skillup_access_token';
  static const _roleKey = 'skillup_user_role';

  Future<String?> get accessToken => _storage.read(key: _tokenKey);
  Future<String?> get role => _storage.read(key: _roleKey);

  Future<void> saveSession({
    required String accessToken,
    required String role,
  }) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _roleKey, value: role);
  }

  Future<void> clear() => _storage.deleteAll();
}
