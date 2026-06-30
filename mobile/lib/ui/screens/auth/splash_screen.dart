import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/glass_styles.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/primary_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox(),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox(),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 32.0),
              child: Column(
                children: [
                  const Spacer(),
                  // Top Visual
                  Center(
                    child: Container(
                      width: 128,
                      height: 128,
                      decoration: GlassStyles.glassCardDecoration.copyWith(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.account_balance_wallet,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Branding & Tagline
                  Text(
                    'FinTrack',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your money, understood.',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Interactive Grid / Aesthetic Element
                  Opacity(
                    opacity: 0.6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GlassCard(
                            height: 64,
                            child: Center(
                              child: Container(
                                width: 32,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: GlassCard(
                            height: 64,
                            child: Center(
                              child: Icon(
                                Icons.trending_up,
                                color: AppColors.outline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Action Buttons
                  PrimaryButton(
                    text: 'Get Started',
                    icon: Icons.arrow_forward,
                    onPressed: () => context.push('/register'),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context.push('/login'),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: GlassStyles.glassCardDecoration.copyWith(
                        border: Border.all(color: AppColors.outlineVariant),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Login',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
