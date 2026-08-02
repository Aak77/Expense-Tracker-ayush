import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

// Screen imports
import '../../ui/screens/auth/splash_screen.dart';
import '../../ui/screens/auth/login_screen.dart';
import '../../ui/screens/auth/register_screen.dart';
import '../../ui/screens/dashboard/dashboard_screen.dart';
import '../../ui/screens/transactions/transactions_screen.dart';
import '../../ui/screens/transactions/add_transaction_screen.dart';
import '../../ui/screens/transactions/csv_review_screen.dart';
import '../../ui/screens/budget/budgets_screen.dart';
import '../../ui/screens/budget/add_edit_budget_screen.dart';
import '../../ui/screens/goals/goals_screen.dart';
import '../../ui/screens/goals/add_edit_goal_screen.dart';
import '../../ui/screens/profile/profile_screen.dart';
import '../../ui/screens/profile/edit_profile_screen.dart';
import '../../ui/widgets/navigation/custom_bottom_nav_bar.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isLoggedIn = authProvider.isAuthenticated;
      final isLoading = authProvider.isLoading;
      final currentPath = state.matchedLocation;

      // While auth status is loading, stay on splash
      if (isLoading) {
        return currentPath == '/splash' ? null : '/splash';
      }

      final isOnAuthPage = currentPath == '/login' ||
          currentPath == '/register' ||
          currentPath == '/splash';

      // Not logged in → redirect to login (unless already on auth page)
      if (!isLoggedIn) {
        return isOnAuthPage ? null : '/login';
      }

      // Logged in but on auth page → redirect to dashboard
      if (isLoggedIn && isOnAuthPage) {
        return '/dashboard';
      }

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
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
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
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddTransactionScreen(),
              ),
              GoRoute(
                path: 'csv-review',
                builder: (context, state) {
                  final parsedTransactions = state.extra as List<Map<String, dynamic>>;
                  return CsvReviewScreen(parsedTransactions: parsedTransactions);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/budgets',
            builder: (context, state) => const BudgetsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddEditBudgetScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/goals',
            builder: (context, state) => const GoalsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const AddEditGoalScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => const EditProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
