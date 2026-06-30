import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fintrack_mobile/core/theme/glass_styles.dart';
import 'package:fintrack_mobile/core/theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final Widget child;

  const CustomBottomNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: GlassStyles.glassNavBarDecoration,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  path: '/dashboard',
                ),
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  label: 'Activity',
                  path: '/transactions',
                ),
                _NavItem(
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet,
                  label: 'Budget',
                  path: '/budgets',
                ),
                _NavItem(
                  icon: Icons.ads_click_outlined,
                  activeIcon: Icons.ads_click,
                  label: 'Goals',
                  path: '/goals',
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  path: '/profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    final String currentPath = GoRouterState.of(context).matchedLocation;
    final bool isActive = currentPath.startsWith(path);

    return InkWell(
      onTap: () {
        if (!isActive) {
          context.go(path);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? AppColors.secondary : AppColors.outline,
            size: 24,
            shadows: isActive
                ? [Shadow(color: AppColors.secondary.withOpacity(0.6), blurRadius: 12)]
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isActive ? AppColors.secondary : AppColors.outline,
                ),
          ),
        ],
      ),
    );
  }
}
