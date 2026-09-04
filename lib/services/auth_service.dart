import 'api_client.dart';
import 'session_service.dart';

class AuthResult {
  const AuthResult({required this.role, required this.fullName});
  final String role;
  final String fullName;
}

class AuthService {
  AuthService({ApiClient? client, SessionService? sessionService})
      : _client = client ?? ApiClient.instance,
        _sessionService = sessionService ?? SessionService.instance;

  static AuthService instance = AuthService();

  final ApiClient _client;
  final SessionService _sessionService;

  Future<AuthResult> registerCustomer({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) => _authenticate('/auth/register/customer', {
    'full_name': fullName,
    'email': email,
    'phone': phone,
    'password': password,
  });

  Future<AuthResult> registerWorker({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) => _authenticate('/auth/register/worker', {
    'full_name': fullName,
    'email': email,
    'phone': phone,
    'password': password,
  });

  Future<AuthResult> login({
    required String identifier,
    required String password,
  }) => _authenticate('/auth/login', {
    'identifier': identifier,
    'password': password,
  });

  Future<void> sendOtp({
    required String identifier,
    String purpose = 'REGISTRATION',
  }) async {
    await _client.post(
      '/auth/otp/send',
      data: {'identifier': identifier, 'purpose': purpose},
    );
  }

  Future<bool> verifyOtp({
    required String identifier,
    required String otp,
    String purpose = 'REGISTRATION',
  }) async {
    final result = await _client.post(
      '/auth/otp/verify',
      data: {'identifier': identifier, 'otp_code': otp, 'purpose': purpose},
    );
    return result['is_verified'] == true;
  }

  Future<void> acceptTerms({String version = 'v1.0'}) async {
    await _client.post(
      '/me/terms-acceptance',
      data: {'version': version},
    );
  }

  Future<AuthResult> getMe() async {
    final result = await _client.get('/me');
    final user = result['user'] as Map<String, dynamic>?;
    final role = result['role']?.toString() ?? user?['role']?.toString() ?? '';
    final fullName = user?['full_name']?.toString() ?? '';
    if (role.isEmpty) {
      throw const ApiException('Invalid user profile response.');
    }
    return AuthResult(role: role, fullName: fullName);
  }

  Future<AuthResult?> validateSession() async {
    final token = await _sessionService.accessToken;
    if (token == null || token.isEmpty) {
      return null;
    }
    try {
      final me = await getMe();
      final currentRole = await _sessionService.role;
      if (currentRole != me.role) {
        await _sessionService.saveSession(
          accessToken: token,
          role: me.role,
        );
      }
      return me;
    } on ApiException catch (e) {
      if (e.statusCode == 401 ||
          e.message.contains('401') ||
          e.message.toLowerCase().contains('unauthorized')) {
        await _sessionService.clear();
        return null;
      }
      // If temporary backend connectivity error, fall back to locally stored role
      final role = await _sessionService.role;
      if (role != null && role.isNotEmpty) {
        return AuthResult(role: role, fullName: '');
      }
      return null;
    } catch (_) {
      final role = await _sessionService.role;
      if (role != null && role.isNotEmpty) {
        return AuthResult(role: role, fullName: '');
      }
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _client.post('/auth/logout');
    } catch (_) {
      // Best-effort logout notification to server
    } finally {
      await _sessionService.clear();
    }
  }

  Future<AuthResult> _authenticate(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    final result = await _client.post(endpoint, data: payload);
    final token = result['access_token']?.toString();
    final role = result['role']?.toString();
    if (token == null || role == null) {
      throw const ApiException(
        'The backend returned an invalid sign-in response.',
      );
    }
    await _sessionService.saveSession(accessToken: token, role: role);
    return AuthResult(
      role: role,
      fullName: result['full_name']?.toString() ?? '',
    );
  }
}
