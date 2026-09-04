class ApiConfig {
  ApiConfig._();

  static const definedBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Defaults to localhost 127.0.0.1:8000 (standard for desktop and physical Android via `adb reverse tcp:8000 tcp:8000`).
  /// Android emulators without reverse proxy can specify --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
  /// or rely on ApiClient auto-fallback.
  static String get baseUrl {
    if (definedBaseUrl.isNotEmpty) return definedBaseUrl;
    return 'http://127.0.0.1:8000/api/v1';
  }
}
