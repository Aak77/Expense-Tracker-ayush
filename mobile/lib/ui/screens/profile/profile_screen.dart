import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/common/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'JD',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'FinTrack',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.1),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 100),
            child: Column(
              children: [
                _buildProfileHeader(context),
                const SizedBox(height: 32),
                _buildAccountSection(context),
                const SizedBox(height: 24),
                _buildPreferencesSection(),
                const SizedBox(height: 24),
                _buildDataSection(),
                const SizedBox(height: 24),
                _buildDangerZone(),
                const SizedBox(height: 32),
                Text(
                  'FinTrack Version 2.4.1\nManaged with Precision',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.outline.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryContainer, AppColors.secondaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white10, width: 4),
              ),
              child: Center(
                child: Text(
                  'JD',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  context.push('/profile/edit');
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 3),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: AppColors.onPrimary,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'John Doe',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'john.doe@fintrack.app',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'ACCOUNT',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.outline,
            ),
          ),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildListItem(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () => context.push('/profile/edit'),
              ),
              const Divider(height: 1, color: Colors.white10),
              _buildListItem(
                icon: Icons.lock_outline,
                title: 'Password',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'PREFERENCES',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.outline,
            ),
          ),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildListItem(
                icon: Icons.payments_outlined,
                title: 'Currency',
                subtitle: 'USD (\$)',
                onTap: () {},
              ),
              const Divider(height: 1, color: Colors.white10),
              _buildListItem(
                icon: Icons.notifications_active_outlined,
                title: 'Notifications',
                trailingText: 'On',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'DATA',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.outline,
            ),
          ),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: _buildListItem(
            icon: Icons.file_download_outlined,
            title: 'CSV Export',
            trailingIcon: Icons.download_outlined,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'DANGER ZONE',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.error,
            ),
          ),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildListItem(
                icon: Icons.logout,
                title: 'Logout',
                iconColor: AppColors.error,
                textColor: AppColors.onSurface,
                onTap: () {},
              ),
              const Divider(height: 1, color: Colors.white10),
              _buildListItem(
                icon: Icons.delete_forever,
                title: 'Delete Account',
                iconColor: AppColors.error,
                textColor: AppColors.error,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    IconData trailingIcon = Icons.chevron_right,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.secondary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? AppColors.secondary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: textColor ?? AppColors.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(trailingIcon, color: iconColor ?? AppColors.outline),
          ],
        ),
      ),
    );
  }
}
