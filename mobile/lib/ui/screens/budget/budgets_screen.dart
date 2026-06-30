import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/glass_styles.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBvQJHP3_hLf-sWfw-1FvcDscc6vD5nhvTFmAzibWl-JeND8UOGa9lsdec36cG60DuhYzwbW9rKfesGxTXYBX5g0zMYgukV1PvLDtrj_59K1TgTmuUKKnT5yEVSvPXd6l7mQJSDwQAIEqbuda3tf3Rzc-bj5zlogI4fWzkLPqK_G-yBhVNMEQoLb6We42kWNHD2Cdu9RlUcEuHib6QP9RJZWszuX5DSq8xwmuJ2qiQmaxFsjL9eadGbX8Ylq6gjQxj_r5YN9voPkUAw',
                  ),
                  fit: BoxFit.cover,
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
            icon: const Icon(Icons.notifications, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Total Utilization Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: GlassStyles.glassCardDecoration.copyWith(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Utilization',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '78',
                        style: GoogleFonts.inter(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                          letterSpacing: -0.8,
                        ),
                      ),
                      Text(
                        '%',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spent: ₹1,24,800',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Limit: ₹1,60,000',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.78,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You are on track to save ₹35,200 this month',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Monthly Budgets Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Budgets',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Text(
                        'View History',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Budget Items
            _buildBudgetCard(
              icon: Icons.restaurant,
              iconColor: AppColors.primary,
              iconBgColor: AppColors.primary.withOpacity(0.1),
              title: 'Food & Dining',
              subtitle: '₹800 remaining',
              spent: '₹4,200',
              limit: ' / ₹5,000',
              percentageText: '84% used',
              percentageColor: AppColors.primary,
              progressValue: 0.84,
            ),
            const SizedBox(height: 16),
            _buildBudgetCard(
              icon: Icons.directions_car,
              iconColor: AppColors.secondary,
              iconBgColor: AppColors.secondary.withOpacity(0.1),
              title: 'Transport',
              subtitle: '₹1,500 remaining',
              spent: '₹1,500',
              limit: ' / ₹3,000',
              percentageText: '50% used',
              percentageColor: AppColors.secondary,
              progressValue: 0.50,
            ),
            const SizedBox(height: 16),
            _buildBudgetCard(
              icon: Icons.movie,
              iconColor: AppColors.error,
              iconBgColor: AppColors.errorContainer.withOpacity(0.2),
              title: 'Entertainment',
              subtitle: '₹200 over budget',
              subtitleColor: AppColors.error,
              spent: '₹2,200',
              limit: ' / ₹2,000',
              percentageText: '110% used',
              percentageColor: AppColors.error,
              progressValue: 1.0,
            ),
            const SizedBox(height: 16),
            _buildBudgetCard(
              icon: Icons.shopping_bag,
              iconColor: AppColors.tertiary,
              iconBgColor: AppColors.tertiary.withOpacity(0.1),
              title: 'Shopping',
              subtitle: '₹6,000 remaining',
              spent: '₹4,000',
              limit: ' / ₹10,000',
              percentageText: '40% used',
              percentageColor: AppColors.tertiary,
              progressValue: 0.40,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBudgetCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    Color? subtitleColor,
    required String spent,
    required String limit,
    required String percentageText,
    required Color percentageColor,
    required double progressValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: GlassStyles.glassCardDecoration.copyWith(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor),
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
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: subtitleColor ?? AppColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: spent,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        TextSpan(
                          text: limit,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    percentageText,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: percentageColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progressValue.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: percentageColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
