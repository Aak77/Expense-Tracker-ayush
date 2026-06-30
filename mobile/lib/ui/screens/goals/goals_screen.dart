import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/glass_styles.dart';
import '../../../core/utils/currency_format.dart';
import '../../widgets/common/glass_card.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
            child: Container(color: Colors.transparent),
          ),
        ),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBjGCoQ4XZwUNyc2TUB5SY9PooFXNd1kUUshrt5n3MiPUj5Oq7pHlK_p3Y2OOJWYZTvujPntSoNI3qD9REfC9mx-c7Y880LYH-mMMsUSOn646BfErFPwmk1NZJ_8PLeT4wU31wcBvbjxcniuYJHoua9sHr6hZFwI4jIo1s9fBFADyYgr9JhFmAlCIEOug_HzRgMF6E6zrzUOp12b2kcankoJfhZNdwip0lyZSCIsYSsArHnxOZA7hhulvftZ6jCRreP9oEg5P7JNxdJ',
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
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/goals/add');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.onPrimary, size: 32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Savings Goals',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Every rupee counts.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _buildSummaryCard(),
            const SizedBox(height: 16),
            _buildGoalCard(
              title: 'New Laptop 💻',
              category: 'ELECTRONICS FUND',
              currentAmount: 32000,
              targetAmount: 80000,
              percentage: 0.4,
              dateStr: 'Est. Oct 2024',
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            _buildGoalCard(
              title: 'Europe Trip ✈️',
              category: 'VACATION FUND',
              currentAmount: 150000,
              targetAmount: 200000,
              percentage: 0.75,
              dateStr: 'Est. Dec 2023',
              color: AppColors.secondary,
            ),
            const SizedBox(height: 16),
            _buildTipCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL GOAL SAVINGS',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppFormatters.formatINR(182000),
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up,
              color: AppColors.primary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard({
    required String title,
    required String category,
    required double currentAmount,
    required double targetAmount,
    required double percentage,
    required String dateStr,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 4,
                      color: AppColors.surfaceContainerHighest,
                    ),
                    CircularProgressIndicator(
                      value: percentage,
                      strokeWidth: 4,
                      color: color,
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Text(
                        '${(percentage * 100).toInt()}%',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    AppFormatters.formatINR(currentAmount),
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Target',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    AppFormatters.formatINR(targetAmount),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: AppColors.outline, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    dateStr,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Text(
                'Add Money',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lightbulb_outline, color: AppColors.secondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Tip',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Increasing your monthly laptop savings by ₹2,000 could help you reach your goal 2 months early.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppColors.onSurfaceVariant,
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
