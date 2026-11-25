import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/main_wrapper_screen.dart';
import '../screens/requests/request_detail_screen.dart';
import '../screens/requests/create_request_screen.dart';
import '../screens/requests/requests_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainWrapperScreen(),
    ),
    GoRoute(
      path: '/create-request',
      builder: (context, state) => const CreateRequestScreen(),
    ),
    GoRoute(
      path: '/requests-feed',
      builder: (context, state) => const RequestsScreen(),
    ),
    GoRoute(
      path: '/requests/:id',
      builder: (context, state) {
        final idStr = state.pathParameters['id'] ?? '0';
        final id = int.tryParse(idStr) ?? 0;
        return RequestDetailScreen(requestId: id);
      },
    ),
  ],
);
