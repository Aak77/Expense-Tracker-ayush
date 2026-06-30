import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/glass_styles.dart';
import '../../../core/utils/currency_format.dart';
import '../../widgets/common/glass_card.dart';

class NetWorthScreen extends StatefulWidget {
  const NetWorthScreen({super.key});

  @override
  State<NetWorthScreen> createState() => _NetWorthScreenState();
}

class _NetWorthScreenState extends State<NetWorthScreen> {
  bool _showAssets = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ColorFilter.mode(Colors.transparent, BlendMode.src),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerHigh,
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(Icons.person, color: AppColors.onSurface, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'FinTrack',
              style: GoogleFonts.inter(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
            _buildTabNavigation(),
            const SizedBox(height: 16),
            _showAssets ? _buildAssetsList() : _buildLiabilitiesList(),
            const SizedBox(height: 32),
            _buildDebtRatioChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildNetWorthCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Net Worth',
            style: GoogleFonts.inter(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppFormatters.formatINR(245000),
            style: GoogleFonts.inter(
              color: AppColors.primary,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.trending_up, color: AppColors.secondary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'ASSETS',
                          style: GoogleFonts.inter(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.formatINR(310000),
                      style: GoogleFonts.inter(
                        color: AppColors.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.1),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.trending_down, color: AppColors.error, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'LIABILITIES',
                          style: GoogleFonts.inter(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppFormatters.formatINR(65000),
                      style: GoogleFonts.inter(
                        color: AppColors.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 82,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Expanded(
                  flex: 18,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.4),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(3),
                        bottomRight: Radius.circular(3),
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

  Widget _buildTabNavigation() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showAssets = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _showAssets ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _showAssets
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 0,
                          )
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Assets',
                  style: GoogleFonts.inter(
                    color: _showAssets ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showAssets = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: !_showAssets ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: !_showAssets
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 0,
                          )
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Liabilities',
                  style: GoogleFonts.inter(
                    color: !_showAssets ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ASSET CATEGORIES',
              style: GoogleFonts.inter(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
              label: Text(
                'ADD ASSET',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildListItem(
          icon: Icons.account_balance,
          iconColor: AppColors.primary,
          iconBgColor: AppColors.primaryContainer.withOpacity(0.2),
          title: 'Bank Savings',
          subtitle: 'HDFC • **** 4290',
          amount: AppFormatters.formatINR(120000),
          trailingText: '+2.4%',
          trailingColor: AppColors.secondary,
        ),
        const SizedBox(height: 12),
        _buildListItem(
          icon: Icons.monitoring,
          iconColor: AppColors.secondary,
          iconBgColor: AppColors.secondaryContainer.withOpacity(0.2),
          title: 'Mutual Funds',
          subtitle: 'Growth Direct Plan',
          amount: AppFormatters.formatINR(150000),
          trailingText: '+12.8%',
          trailingColor: AppColors.secondary,
        ),
        const SizedBox(height: 12),
        _buildListItem(
          icon: Icons.lock_outline,
          iconColor: AppColors.tertiaryContainer,
          iconBgColor: AppColors.surfaceVariant.withOpacity(0.4),
          title: 'Fixed Deposit',
          subtitle: 'ICICI Bank • Matures 2025',
          amount: AppFormatters.formatINR(35000),
          trailingText: 'Fixed',
          trailingColor: AppColors.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        _buildListItem(
          icon: Icons.payments_outlined,
          iconColor: AppColors.tertiaryContainer,
          iconBgColor: AppColors.surfaceVariant.withOpacity(0.4),
          title: 'Cash in Hand',
          subtitle: 'Liquid Assets',
          amount: AppFormatters.formatINR(5000),
        ),
      ],
    );
  }

  Widget _buildLiabilitiesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LIABILITY CATEGORIES',
              style: GoogleFonts.inter(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18, color: AppColors.error),
              label: Text(
                'ADD LIABILITY',
                style: GoogleFonts.inter(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildListItem(
          icon: Icons.credit_card,
          iconColor: AppColors.error,
          iconBgColor: AppColors.errorContainer.withOpacity(0.2),
          title: 'Credit Card',
          subtitle: 'AMEX Platinum • Due in 12d',
          amount: AppFormatters.formatINR(25000),
          trailingText: '18% APR',
          trailingColor: AppColors.error,
        ),
        const SizedBox(height: 12),
        _buildListItem(
          icon: Icons.handshake_outlined,
          iconColor: AppColors.error,
          iconBgColor: AppColors.errorContainer.withOpacity(0.2),
          title: 'Personal Loan',
          subtitle: 'Education • 24 months left',
          amount: AppFormatters.formatINR(40000),
          trailingText: '8.5% Fixed',
          trailingColor: AppColors.error,
        ),
      ],
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String amount,
    String? trailingText,
    Color? trailingColor,
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
                    color: AppColors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: AppColors.onSurfaceVariant,
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
                  color: AppColors.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (trailingText != null) ...[
                const SizedBox(height: 2),
                Text(
                  trailingText,
                  style: GoogleFonts.inter(
                    color: trailingColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDebtRatioChart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: SizedBox(
          width: 192,
          height: 192,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                    width: 12,
                  ),
                ),
              ),
              // Simulating the partial chart with CircularProgressIndicator
              SizedBox(
                width: 192,
                height: 192,
                child: CircularProgressIndicator(
                  value: 0.791, // 100 - 20.9 = 79.1%
                  strokeWidth: 12,
                  color: AppColors.primary,
                  backgroundColor: Colors.transparent,
                ),
              ),
              Transform.rotate(
                angle: 3.14159 * 1.582, // position the error bar
                child: SizedBox(
                  width: 192,
                  height: 192,
                  child: CircularProgressIndicator(
                    value: 0.209,
                    strokeWidth: 12,
                    color: AppColors.secondary,
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'DEBT RATIO',
                    style: GoogleFonts.inter(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '20.9%',
                    style: GoogleFonts.inter(
                      color: AppColors.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
