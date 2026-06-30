import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/common/glass_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuASOUasih3O6721h0_lxs1QGQrnZqJNRY1k3ArVh7DFVJ21KJYowpD5QCkYKj6VWdqimU1ilL3isyLqkBiTwjr9mYEs5cgJ65RX7MadkF7E7zNVmkAu3k6ih6no4OA_Oj_DFOMlnaaMW940AivU-Dw8DNsxcogT8k_MP3VfzZC67r7NrnVFC4jUpmRM-XglGjkCQ_PjI2V7ybnuXx0jOrhBpj2frKpdz6x0HCP-w2Jd7Tw3SdVhwU4kppglnz3YYCqRGyxqlCAUj1jW',
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
      body: Stack(
        children: [
          // Ambient Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
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
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Insights',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your personalized financial health report for October.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                _buildInsightCard(
                  type: 'SPENDING',
                  title: 'Food spending up 18%',
                  description: 'You\'ve spent ₹4,200 more on dining out than your 3-month average. Consider a home-cooked meal tonight?',
                  icon: Icons.trending_up,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildInsightCard(
                  type: 'GOALS',
                  title: 'Emergency fund reached 85%',
                  description: 'Great job! You\'re only ₹12,000 away from your 6-month safety net goal. Keep the momentum going!',
                  icon: Icons.savings,
                  color: Colors.green,
                  progressValue: 0.85,
                ),
                const SizedBox(height: 16),
                _buildInsightCard(
                  type: 'INVEST',
                  title: 'Idle cash detected',
                  description: '₹50,000 has been sitting in your savings for 30 days. Moving this to a Liquid Fund could earn ~6% p.a.',
                  icon: Icons.show_chart,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildInsightCard(
                  type: 'RECURRING',
                  title: 'Double subscription detected',
                  description: 'We found two payments to "CloudStorage Inc" this month. You might want to check for duplicate accounts.',
                  icon: Icons.event_repeat,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildInsightCard(
                  type: 'BUDGET',
                  title: 'Under budget in Shopping',
                  description: 'You\'re 30% below your shopping budget this month. This surplus has been moved to your "Travel" goal.',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                _buildInsightCard(
                  type: 'BILLS',
                  title: 'Electricity bill is lower',
                  description: 'Your utility bill is ₹800 lower than last month. Great job on energy efficiency!',
                  icon: Icons.receipt_long,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildInsightCard(
                  type: 'MARKET',
                  title: 'Tech sector rebound',
                  description: 'Your portfolio\'s tech holdings are up 4.2% following the recent quarterly earnings reports.',
                  icon: Icons.analytics,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildInsightCard(
                  type: 'REWARDS',
                  title: 'Unused Credit Points',
                  description: 'You have 12,400 points expiring in 15 days. Redeem them for a ₹1,000 Amazon voucher now.',
                  icon: Icons.card_giftcard,
                  color: Colors.green,
                  showButton: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required String type,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    double? progressValue,
    bool showButton = false,
  }) {
    return Stack(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      type,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              if (progressValue != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
              if (showButton) ...[
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Redeem Now'),
                ),
              ],
            ],
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
