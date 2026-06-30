import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/glass_styles.dart';
import '../../../core/utils/currency_format.dart';
import '../../widgets/common/glass_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ColorFilter.mode(Colors.transparent, BlendMode.src), // Placeholder for real blur if needed, or just remove and let glass take over
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer,
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Icon(Icons.person, color: AppColors.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning,',
                  style: GoogleFonts.inter(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Ayush 👋',
                  style: GoogleFonts.inter(
                    color: AppColors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.white.withOpacity(0.1),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNetWorthCard(),
            const SizedBox(height: 24),
            _buildSummaryGrid(),
            const SizedBox(height: 32),
            _buildRecentTransactions(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimaryContainer,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Widget _buildNetWorthCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL NET WORTH',
                style: GoogleFonts.inter(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: AppColors.secondary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '8.2%',
                      style: GoogleFonts.inter(
                        color: AppColors.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppFormatters.formatINR(245000),
            style: GoogleFonts.inter(
              color: AppColors.onSurface,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.65,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '65% of target',
                style: GoogleFonts.inter(
                  color: AppColors.outline,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                icon: Icons.south_west,
                iconColor: Colors.greenAccent,
                iconBgColor: Colors.greenAccent.withOpacity(0.1),
                label: 'Monthly Income',
                amount: AppFormatters.formatINR(35000),
                amountColor: Colors.greenAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                icon: Icons.north_east,
                iconColor: Colors.orangeAccent,
                iconBgColor: Colors.orangeAccent.withOpacity(0.1),
                label: 'Expenses',
                amount: AppFormatters.formatINR(18400),
                amountColor: Colors.orangeAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                icon: Icons.account_balance_wallet_outlined,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.primary.withOpacity(0.1),
                label: 'Total Savings',
                amount: AppFormatters.formatINR(16600),
                amountColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String amount,
    required Color amountColor,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
              border: Border.all(color: iconColor.withOpacity(0.2)),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                amount,
                style: GoogleFonts.inter(
                  color: amountColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: GoogleFonts.inter(
                color: AppColors.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildTransactionItem(
          icon: Icons.restaurant,
          iconColor: AppColors.onSurfaceVariant,
          iconBgColor: AppColors.surfaceVariant,
          title: 'Starbucks Coffee',
          subtitle: 'Today, 09:45 AM',
          amount: '-₹450',
          amountColor: AppColors.onSurface,
          category: 'Food & Drinks',
        ),
        const SizedBox(height: 8),
        _buildTransactionItem(
          icon: Icons.shopping_bag_outlined,
          iconColor: AppColors.onSurfaceVariant,
          iconBgColor: AppColors.surfaceVariant,
          title: 'Zara Fashion',
          subtitle: 'Yesterday, 06:20 PM',
          amount: '-₹3,200',
          amountColor: AppColors.onSurface,
          category: 'Shopping',
        ),
        const SizedBox(height: 8),
        _buildTransactionItem(
          icon: Icons.work_outline,
          iconColor: Colors.greenAccent,
          iconBgColor: Colors.greenAccent.withOpacity(0.2),
          title: 'Salary Deposit',
          subtitle: '01 Oct, 10:00 AM',
          amount: '+₹35,000',
          amountColor: Colors.greenAccent,
          category: 'Income',
        ),
        const SizedBox(height: 8),
        _buildTransactionItem(
          icon: Icons.home_repair_service_outlined,
          iconColor: AppColors.onSurfaceVariant,
          iconBgColor: AppColors.surfaceVariant,
          title: 'Monthly Rent',
          subtitle: '01 Oct, 08:30 AM',
          amount: '-₹12,000',
          amountColor: AppColors.onSurface,
          category: 'Housing',
        ),
        const SizedBox(height: 8),
        _buildTransactionItem(
          icon: Icons.directions_car_outlined,
          iconColor: AppColors.onSurfaceVariant,
          iconBgColor: AppColors.surfaceVariant,
          title: 'Petrol Refill',
          subtitle: '30 Sep, 11:15 PM',
          amount: '-₹2,500',
          amountColor: AppColors.onSurface,
          category: 'Transport',
        ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String amount,
    required Color amountColor,
    required String category,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: AppColors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: AppColors.outline,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.inter(
                  color: amountColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                category,
                style: GoogleFonts.inter(
                  color: AppColors.outlineVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
