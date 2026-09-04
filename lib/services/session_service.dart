import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionService {
  SessionService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static SessionService instance = SessionService();

  final FlutterSecureStorage _storage;
  static const _tokenKey = 'skillup_access_token';
  static const _roleKey = 'skillup_user_role';

  String? _cachedAccessToken;
  String? _cachedRole;

  String? get cachedAccessToken => _cachedAccessToken;
  String? get cachedRole => _cachedRole;

  Future<String?> get accessToken async {
    _cachedAccessToken ??= await _storage.read(key: _tokenKey);
    return _cachedAccessToken;
  }

  Future<String?> get role async {
    _cachedRole ??= await _storage.read(key: _roleKey);
    return _cachedRole;
  }

  Future<bool> get isAuthenticated async {
    final token = await accessToken;
    return token != null && token.isNotEmpty;
  }

  bool get isCachedAuthenticated =>
      _cachedAccessToken != null && _cachedAccessToken!.isNotEmpty;

  Future<void> saveSession({
    required String accessToken,
    required String role,
  }) async {
    _cachedAccessToken = accessToken;
    _cachedRole = role;
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _roleKey, value: role);
  }

  Future<void> loadSession() async {
    _cachedAccessToken = await _storage.read(key: _tokenKey);
    _cachedRole = await _storage.read(key: _roleKey);
  }

  Future<void> clear() async {
    _cachedAccessToken = null;
    _cachedRole = null;
    await _storage.deleteAll();
  }
}
