import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: const SizedBox(),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: const SizedBox(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Nav
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/login');
                          }
                        },
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Brand Identity
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primaryContainer.withOpacity(0.3)),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.lock_reset,
                                size: 32,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Forgot Password',
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No worries, it happens. Enter the email address associated with your account.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Form
                          GlassCard(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email Address',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.2),
                                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: GoogleFonts.inter(color: AppColors.onSurface),
                                    decoration: InputDecoration(
                                      hintText: 'name@company.com',
                                      hintStyle: GoogleFonts.inter(color: AppColors.outline.withOpacity(0.5)),
                                      prefixIcon: const Icon(Icons.mail_outline, color: AppColors.outline),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                PrimaryButton(
                                  text: 'Send Reset Link',
                                  icon: Icons.send,
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Reset link sent to ${_emailController.text}',
                                          style: GoogleFonts.inter(),
                                        ),
                                        backgroundColor: AppColors.secondary,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 48),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Remembered your password? ',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/login'),
                                child: Text(
                                  'Log In',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
