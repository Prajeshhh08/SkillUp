import 'dart:io';

class ApiConfig {
  ApiConfig._();

  static const _definedBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Override for a physical device with:
  /// flutter run --dart-define=API_BASE_URL=http://YOUR_COMPUTER_IP:8000/api/v1
  static String get baseUrl {
    if (_definedBaseUrl.isNotEmpty) return _definedBaseUrl;
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/v1';
    return 'http://127.0.0.1:8000/api/v1';
  }
}
