import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/glass_styles.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Transaction Detail',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Header
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.1),
                    blurRadius: 24,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.restaurant,
                size: 48,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Text(
                'Expense',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹1,450.00',
              style: GoogleFonts.inter(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Gourmet Garden Bistro',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),

            // Description & Category Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: GlassStyles.glassCardDecoration.copyWith(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.category, color: AppColors.outline),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CATEGORY',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.outline,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Dining & Drinks',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.outline),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Colors.white10, height: 1),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.notes, color: AppColors.outline),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DESCRIPTION',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.outline,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Dinner with the product team for project kickoff celebration.',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Date & Account Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: GlassStyles.glassCardDecoration.copyWith(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.calendar_today, color: AppColors.outline),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DATE & TIME',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.outline,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Oct 24, 2023 • 08:45 PM',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Colors.white10, height: 1),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.account_balance, color: AppColors.outline),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PAID VIA',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.outline,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'HDFC Bank •••• 4291',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Receipt
            Container(
              height: 192,
              width: double.infinity,
              decoration: GlassStyles.glassCardDecoration.copyWith(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBLGrAjTccrdgyAoqK5haHRaU4wtJFr6lrilRTCpzd7U4SQCfyjquyV6nhlRiVPHjy3c016fhPJd5Z2IX2NMnBBr8pt_LbCctc0d_dLUcJf47MCXyT9ReMdjLP7KFRBWecTP4XGaWuD0zyfV8LKMKihxfVY1uiSlMKD_MdF5RL8Jl21YHD-GeGqC1EsEiWox3Q-0peNSFcne29xAUiFTQ4p9JdVwQBFiQ5KXc35mDa3RsoOAgl655wJwXM7Uy2T317Avb6fkY4B7lP4',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black54, // To dim the image
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.image, color: AppColors.primary, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'View Receipt',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Action Buttons
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit, color: AppColors.primary),
              label: Text(
                'Edit Transaction',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.primaryContainer),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.delete, color: AppColors.error),
              label: Text(
                'Delete Record',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
