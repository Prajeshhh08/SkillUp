import 'api_client.dart';
import 'session_service.dart';

class AuthResult {
  const AuthResult({required this.role, required this.fullName});
  final String role;
  final String fullName;
}

class AuthService {
  AuthService._();
  static final instance = AuthService._();

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
    await ApiClient.instance.post(
      '/auth/otp/send',
      data: {'identifier': identifier, 'purpose': purpose},
    );
  }

  Future<bool> verifyOtp({
    required String identifier,
    required String otp,
    String purpose = 'REGISTRATION',
  }) async {
    final result = await ApiClient.instance.post(
      '/auth/otp/verify',
      data: {'identifier': identifier, 'otp_code': otp, 'purpose': purpose},
    );
    return result['is_verified'] == true;
  }

  Future<void> acceptTerms({String version = 'v1.0'}) async {
    await ApiClient.instance.post(
      '/me/terms-acceptance',
      data: {'version': version},
    );
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.post('/auth/logout');
    } catch (_) {
      // Best-effort logout notification to server
    } finally {
      await SessionService.instance.clear();
    }
  }

  Future<AuthResult> _authenticate(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    final result = await ApiClient.instance.post(endpoint, data: payload);
    final token = result['access_token']?.toString();
    final role = result['role']?.toString();
    if (token == null || role == null) {
      throw const ApiException(
        'The backend returned an invalid sign-in response.',
      );
    }
    await SessionService.instance.saveSession(accessToken: token, role: role);
    return AuthResult(
      role: role,
      fullName: result['full_name']?.toString() ?? '',
    );
  }
}
