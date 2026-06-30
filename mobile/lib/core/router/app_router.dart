import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

// Placeholder screen imports
import '../../ui/screens/auth/splash_screen.dart';
import '../../ui/screens/auth/login_screen.dart';
import '../../ui/screens/dashboard/dashboard_screen.dart';
import '../../ui/widgets/navigation/custom_bottom_nav_bar.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: authProvider,
    redirect: (context, state) {
      // Temporarily bypass authentication
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return CustomBottomNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          // Other tabs will be added here
        ],
      ),
    ],
  );
}
