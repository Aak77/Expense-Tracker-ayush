import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/glass_styles.dart';
import '../../../core/utils/currency_format.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
            // Use native glass blur if preferred or leave transparent and let flutter handle it
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
                color: AppColors.primaryContainer,
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuB36hUrpAjgQ4xpyYWeMwt0Ijq1tsh9WNbdKvEeJQy3lXjn13pEBSsMazng0IpQUdLCE0sJ1c5HVnEzJlWHf8CUEEw2izoNh11YUKAOLyJgFCijroqphQ7jU9e9HQJ5-e6L3a1OzhxH9Cr7GaOopoUM_O7rOrbxmNxfKx6wnBByqZvtegnGzSEe2Pp32FNs3WZtF_SsPkoVBJs9cP_3rnm2nqj5-GA_eu-XQ_fzrAs3oSIdAGzx2JAnmXyDAU0ZHv9efkCYgrpiEN6y',
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
            icon: const Icon(MaterialSymbolsOutlined.notifications, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and Filter
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest.withOpacity(0.3),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(MaterialSymbolsOutlined.search, color: AppColors.outline, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Search transactions...',
                              hintStyle: GoogleFonts.inter(color: AppColors.outline, fontSize: 16),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: GlassStyles.glassCardDecoration.copyWith(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: IconButton(
                    icon: const Icon(MaterialSymbolsOutlined.filter_list, color: AppColors.primaryContainer),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Segmented Control
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTab(0, 'All'),
                  _buildTab(1, 'Income'),
                  _buildTab(2, 'Expense'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Today Section
            Text(
              'TODAY',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.outline,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _buildTransactionCard(
              icon: MaterialSymbolsOutlined.shopping_bag,
              iconColor: AppColors.secondary,
              iconBgColor: AppColors.secondaryContainer.withOpacity(0.2),
              title: 'Apple Store',
              subtitle: 'Electronics • 2:45 PM',
              amount: -89900,
              type: 'Debit',
            ),
            const SizedBox(height: 16),
            _buildTransactionCard(
              icon: MaterialSymbolsOutlined.payments,
              iconColor: AppColors.primary,
              iconBgColor: AppColors.primaryContainer.withOpacity(0.2),
              title: 'Salary Deposit',
              subtitle: 'Income • 10:00 AM',
              amount: 145000,
              type: 'Credit',
            ),
            const SizedBox(height: 32),

            // Yesterday Section
            Text(
              'YESTERDAY',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.outline,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _buildTransactionCard(
              icon: MaterialSymbolsOutlined.restaurant,
              iconColor: AppColors.tertiary,
              iconBgColor: AppColors.tertiaryContainer.withOpacity(0.2),
              title: 'The Gourmet Kitchen',
              subtitle: 'Food & Dining • 8:30 PM',
              amount: -3420,
              type: 'Debit',
            ),
            const SizedBox(height: 16),
            _buildTransactionCard(
              icon: MaterialSymbolsOutlined.local_taxi,
              iconColor: AppColors.secondary,
              iconBgColor: AppColors.secondaryContainer.withOpacity(0.2),
              title: 'Uber India',
              subtitle: 'Transport • 5:15 PM',
              amount: -450,
              type: 'Debit',
            ),
            const SizedBox(height: 16),
            _buildTransactionCard(
              icon: MaterialSymbolsOutlined.monitoring,
              iconColor: AppColors.primary,
              iconBgColor: AppColors.primaryContainer.withOpacity(0.2),
              title: 'Stock Dividend',
              subtitle: 'Investment • 11:30 AM',
              amount: 12400,
              type: 'Credit',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: isSelected
              ? BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 15,
                    ),
                  ],
                )
              : null,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required double amount,
    required String type,
  }) {
    final isIncome = amount >= 0;
    final displayAmount = isIncome ? '+${AppFormatters.formatINR(amount)}' : '-${AppFormatters.formatINR(amount.abs())}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: GlassStyles.glassCardDecoration,
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
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                displayAmount,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isIncome ? AppColors.secondary : AppColors.error,
                ),
              ),
              Text(
                type.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.outline,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MaterialSymbolsOutlined {
  static const IconData notifications = IconData(0xe7f4, fontFamily: 'MaterialIcons');
  static const IconData search = IconData(0xe8b6, fontFamily: 'MaterialIcons');
  static const IconData filter_list = IconData(0xe152, fontFamily: 'MaterialIcons');
  static const IconData shopping_bag = IconData(0xf1cc, fontFamily: 'MaterialIcons');
  static const IconData payments = IconData(0xef63, fontFamily: 'MaterialIcons');
  static const IconData restaurant = IconData(0xe56c, fontFamily: 'MaterialIcons');
  static const IconData local_taxi = IconData(0xe559, fontFamily: 'MaterialIcons');
  static const IconData monitoring = IconData(0xf119, fontFamily: 'MaterialIcons');
}
