import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skillup/router/app_router.dart';
import 'package:skillup/screens/splash_screen.dart';
import 'package:skillup/services/api_client.dart';
import 'package:skillup/services/auth_service.dart';
import 'package:skillup/services/session_service.dart';

class _FakeSessionService extends SessionService {
  final Map<String, String> _data = {};

  @override
  String? get cachedAccessToken => _data['skillup_access_token'];

  @override
  String? get cachedRole => _data['skillup_user_role'];

  @override
  Future<String?> get accessToken async => _data['skillup_access_token'];

  @override
  Future<String?> get role async => _data['skillup_user_role'];

  @override
  Future<bool> get isAuthenticated async =>
      _data['skillup_access_token'] != null &&
      _data['skillup_access_token']!.isNotEmpty;

  @override
  Future<void> saveSession({
    required String accessToken,
    required String role,
  }) async {
    _data['skillup_access_token'] = accessToken;
    _data['skillup_user_role'] = role;
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }
}

class _MockAuthService extends AuthService {
  _MockAuthService({this.stubbedSession, this.throwUnauthorized = false});

  final AuthResult? stubbedSession;
  final bool throwUnauthorized;

  @override
  Future<AuthResult?> validateSession() async {
    if (throwUnauthorized) {
      await SessionService.instance.clear();
      return null;
    }
    return stubbedSession;
  }
}

Widget _wrapSplashRouter(SplashScreen splash) {
  final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (c, s) => splash),
      GoRoute(path: '/language', builder: (c, s) => const Scaffold(body: Text('Language Screen'))),
      GoRoute(path: '/customer-home', builder: (c, s) => const Scaffold(body: Text('Customer Home Screen'))),
      GoRoute(path: '/home', builder: (c, s) => const Scaffold(body: Text('Worker Home Screen'))),
      GoRoute(path: '/role', builder: (c, s) => const Scaffold(body: Text('Role Screen'))),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  late _FakeSessionService fakeSession;

  setUp(() {
    fakeSession = _FakeSessionService();
    SessionService.instance = fakeSession;
  });

  group('SessionService and AuthService unit tests', () {
    test('SessionService manages token, role, and isAuthenticated flag', () async {
      final session = SessionService.instance;
      expect(await session.isAuthenticated, isFalse);

      await session.saveSession(accessToken: 'test-token', role: 'CUSTOMER');
      expect(await session.isAuthenticated, isTrue);
      expect(await session.accessToken, 'test-token');
      expect(await session.role, 'CUSTOMER');

      await session.clear();
      expect(await session.isAuthenticated, isFalse);
      expect(await session.accessToken, isNull);
      expect(await session.role, isNull);
    });

    test('AuthService.getMe() parses role and name correctly', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'user': {
                    'id': 'u-1',
                    'full_name': 'Aarav Patel',
                    'email': 'aarav@example.com',
                    'phone': '+919876543210',
                    'role': 'CUSTOMER',
                  },
                  'role': 'CUSTOMER',
                },
              ),
            );
          },
        ),
      );

      final authService = AuthService(client: ApiClient.custom(dio));
      final me = await authService.getMe();
      expect(me.role, 'CUSTOMER');
      expect(me.fullName, 'Aarav Patel');
    });

    test('AuthService.validateSession() clears session on 401 Unauthorized', () async {
      await SessionService.instance.saveSession(
        accessToken: 'expired-token',
        role: 'CUSTOMER',
      );

      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: {'detail': 'Token expired or invalid.'},
                ),
              ),
            );
          },
        ),
      );

      final authService = AuthService(client: ApiClient.custom(dio));
      final result = await authService.validateSession();
      expect(result, isNull);
      expect(await SessionService.instance.isAuthenticated, isFalse);
    });
  });

  group('SplashScreen startup restoration tests', () {
    testWidgets('Customer with valid session auto-routes to /customer-home', (tester) async {
      final mockAuth = _MockAuthService(
        stubbedSession: const AuthResult(role: 'CUSTOMER', fullName: 'Customer One'),
      );

      await tester.pumpWidget(_wrapSplashRouter(SplashScreen(authService: mockAuth)));
      expect(find.text('SkillUp'), findsOneWidget);

      // Advance past splash animation
      await tester.pump(const Duration(milliseconds: 2300));
      await tester.pumpAndSettle();

      expect(find.text('Customer Home Screen'), findsOneWidget);
    });

    testWidgets('Worker with valid session auto-routes to /home', (tester) async {
      final mockAuth = _MockAuthService(
        stubbedSession: const AuthResult(role: 'WORKER', fullName: 'Worker One'),
      );

      await tester.pumpWidget(_wrapSplashRouter(SplashScreen(authService: mockAuth)));
      expect(find.text('SkillUp'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 2300));
      await tester.pumpAndSettle();

      expect(find.text('Worker Home Screen'), findsOneWidget);
    });

    testWidgets('Signed-out user navigates to /language', (tester) async {
      final mockAuth = _MockAuthService(stubbedSession: null);

      await tester.pumpWidget(_wrapSplashRouter(SplashScreen(authService: mockAuth)));
      expect(find.text('SkillUp'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 2300));
      await tester.pumpAndSettle();

      expect(find.text('Language Screen'), findsOneWidget);
    });

    testWidgets('Expired session clears credentials and falls back to /language', (tester) async {
      await SessionService.instance.saveSession(accessToken: 'bad-token', role: 'CUSTOMER');
      final mockAuth = _MockAuthService(throwUnauthorized: true);

      await tester.pumpWidget(_wrapSplashRouter(SplashScreen(authService: mockAuth)));

      await tester.pump(const Duration(milliseconds: 2300));
      await tester.pumpAndSettle();

      expect(find.text('Language Screen'), findsOneWidget);
      expect(await SessionService.instance.isAuthenticated, isFalse);
    });
  });

  group('Route Guard tests', () {
    testWidgets('Unauthenticated user navigating to customer-home redirects to /role', (tester) async {
      await SessionService.instance.clear();

      final router = GoRouter(
        initialLocation: '/customer-home',
        redirect: appRouteGuard,
        routes: [
          GoRoute(path: '/role', builder: (c, s) => const Scaffold(body: Text('Role Screen'))),
          GoRoute(path: '/customer-home', builder: (c, s) => const Scaffold(body: Text('Customer Home'))),
          GoRoute(path: '/home', builder: (c, s) => const Scaffold(body: Text('Worker Home'))),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Role Screen'), findsOneWidget);
    });

    testWidgets('Worker role navigating to customer-home redirects to /home', (tester) async {
      await SessionService.instance.saveSession(accessToken: 'worker-token', role: 'WORKER');

      final router = GoRouter(
        initialLocation: '/customer-home',
        redirect: appRouteGuard,
        routes: [
          GoRoute(path: '/role', builder: (c, s) => const Scaffold(body: Text('Role Screen'))),
          GoRoute(path: '/customer-home', builder: (c, s) => const Scaffold(body: Text('Customer Home'))),
          GoRoute(path: '/home', builder: (c, s) => const Scaffold(body: Text('Worker Home'))),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Worker Home'), findsOneWidget);
    });

    testWidgets('Customer role navigating to /home redirects to /customer-home', (tester) async {
      await SessionService.instance.saveSession(accessToken: 'cust-token', role: 'CUSTOMER');

      final router = GoRouter(
        initialLocation: '/home',
        redirect: appRouteGuard,
        routes: [
          GoRoute(path: '/role', builder: (c, s) => const Scaffold(body: Text('Role Screen'))),
          GoRoute(path: '/customer-home', builder: (c, s) => const Scaffold(body: Text('Customer Home'))),
          GoRoute(path: '/home', builder: (c, s) => const Scaffold(body: Text('Worker Home'))),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Customer Home'), findsOneWidget);
    });

    testWidgets('Public route allows unauthenticated access', (tester) async {
      await SessionService.instance.clear();

      final router = GoRouter(
        initialLocation: '/login',
        redirect: appRouteGuard,
        routes: [
          GoRoute(path: '/login', builder: (c, s) => const Scaffold(body: Text('Login Screen'))),
          GoRoute(path: '/role', builder: (c, s) => const Scaffold(body: Text('Role Screen'))),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Login Screen'), findsOneWidget);
    });
  });
}
