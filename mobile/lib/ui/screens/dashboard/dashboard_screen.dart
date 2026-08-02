import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/glass_styles.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/utils/parse_utils.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/common/glass_card.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String? _error;

  double _netWorth = 0;
  double _totalIncome = 0;
  double _totalExpenses = 0;
  double _savings = 0;
  double _savingsRate = 0;
  List<Map<String, dynamic>> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    try {
      setState(() { _isLoading = true; _error = null; });
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.dio.get(ApiConstants.dashboard);
      final data = response.data;

      if (mounted) {
        setState(() {
          _netWorth = parseDouble(data['net_worth']);
          _totalIncome = parseDouble(data['total_income']);
          _totalExpenses = parseDouble(data['total_expenses']);
          _savings = parseDouble(data['savings']);
          _savingsRate = parseDouble(data['savings_rate']);
          _recentTransactions = List<Map<String, dynamic>>.from(
            data['recent_transactions'] ?? [],
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load dashboard';
          _isLoading = false;
        });
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  String _getUserName() {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user != null && user['name'] != null) {
      return user['name'].toString().split(' ').first;
    }
    return 'there';
  }

  String _getUserInitials() {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user != null && user['name'] != null) {
      final parts = user['name'].toString().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  Color _getCategoryChartColor(String category) {
    switch (category.toLowerCase()) {
      case 'housing':
      case 'rent':
        return const Color(0xFFEF4444);
      case 'shopping':
        return const Color(0xFFF43F5E);
      case 'transport':
      case 'travel':
      case 'commute':
        return const Color(0xFFFB7185);
      case 'food':
      case 'restaurant':
      case 'dining':
        return const Color(0xFFFCA5A5);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.commute;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      case 'entertainment':
        return Icons.movie;
      case 'bills':
        return Icons.receipt_long;
      case 'health':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      case 'travel':
        return Icons.flight;
      case 'salary':
        return Icons.work_outline;
      case 'freelance':
        return Icons.laptop;
      case 'investment':
        return Icons.trending_up;
      case 'gift':
        return Icons.card_giftcard;
      default:
        return Icons.swap_horiz;
    }
  }

  Widget _buildCircularActionButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.03),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFFE2E8F0), size: 18),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, color: AppColors.outline, size: 48),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _fetchDashboard,
            child: Text('Retry', style: GoogleFonts.inter(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildNetWorthCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL BALANCE',
                style: GoogleFonts.inter(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              if (_savingsRate > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, color: AppColors.secondary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '+${_savingsRate.toStringAsFixed(1)}%',
                        style: GoogleFonts.inter(
                          color: AppColors.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppFormatters.formatINR(_netWorth),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${AppFormatters.formatINR(_totalIncome - _totalExpenses)} saved this month',
            style: GoogleFonts.inter(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Goal Progress',
                    style: GoogleFonts.inter(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_savingsRate.toStringAsFixed(0)}% of target',
                    style: GoogleFonts.inter(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (_totalIncome > 0)
                      ? (_savings / _totalIncome).clamp(0.0, 1.0)
                      : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCsvImportModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return const _CsvImportBottomSheet();
      },
    ).then((confirmed) {
      if (confirmed == true) {
        _fetchDashboard();
      }
    });
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionItem(Icons.upload_file, 'Import CSV', _showCsvImportModal),
        _buildActionItem(Icons.add, 'Add Txn', () async {
          final res = await context.push('/transactions/add');
          if (res == true) _fetchDashboard();
        }),
        _buildActionItem(Icons.pie_chart_outline, 'New Budget', () async {
          final res = await context.push('/budgets/add');
          if (res == true) _fetchDashboard();
        }),
        _buildActionItem(Icons.savings_outlined, 'Set Goal', () async {
          final res = await context.push('/goals/add');
          if (res == true) _fetchDashboard();
        }),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildCompactSummaryItem(
            icon: Icons.south_west,
            iconColor: AppColors.secondary,
            label: 'Income',
            amount: AppFormatters.formatINR(_totalIncome),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCompactSummaryItem(
            icon: Icons.north_east,
            iconColor: AppColors.tertiary,
            label: 'Expenses',
            amount: AppFormatters.formatINR(_totalExpenses),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCompactSummaryItem(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppColors.primary,
            label: 'Savings',
            amount: AppFormatters.formatINR(_savings),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactSummaryItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String amount,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: iconColor.withOpacity(0.2)),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: GoogleFonts.inter(
              color: iconColor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGridPlaceholder() {
    return Container();
  }

  Widget _buildCategorySpendingSection() {
    final Map<String, double> breakdown = {};
    for (final t in _recentTransactions) {
      if (t['type'] == 'expense') {
        final cat = t['category']?.toString() ?? 'other';
        final amt = parseDouble(t['amount']);
        breakdown[cat] = (breakdown[cat] ?? 0.0) + amt;
      }
    }

    if (breakdown.isEmpty) {
      breakdown['Housing'] = 12000;
      breakdown['Shopping'] = 3200;
      breakdown['Transport'] = 2500;
      breakdown['Food'] = 450;
      breakdown['Other'] = 250;
    }

    final double sum = breakdown.values.fold(0.0, (prev, val) => prev + val);
    final sortedBreakdown = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final List<double> values = sortedBreakdown.map((e) => e.value).toList();
    final List<String> labels = sortedBreakdown.map((e) => e.key).toList();
    final List<Color> colors = labels.map((e) => _getCategoryChartColor(e)).toList();

    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Spending',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Monthly breakdown of expense distributions',
            style: GoogleFonts.inter(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          DonutChart(
            values: values,
            colors: colors,
            labels: labels,
            total: sum,
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
              'Latest Transaction',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/transactions'),
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_recentTransactions.isEmpty)
          GlassCard(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, color: AppColors.outline, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'No transactions yet',
                    style: GoogleFonts.inter(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: List.generate(_recentTransactions.length, (index) {
              final t = _recentTransactions[index];
              final isIncome = t['type'] == 'income';
              final amount = parseDouble(t['amount']);
              final category = t['category']?.toString() ?? 'other';
              final description = t['description']?.toString() ?? category;
              final dateStr = t['date']?.toString() ?? '';

              String displayDate = dateStr;
              try {
                final parsed = DateTime.parse(dateStr);
                displayDate = AppFormatters.formatDate(parsed);
              } catch (_) {}

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTransactionItem(
                  icon: _getCategoryIcon(category),
                  iconColor: isIncome ? AppColors.secondary : AppColors.onSurfaceVariant,
                  iconBgColor: Colors.white.withOpacity(0.02),
                  title: description,
                  subtitle: displayDate,
                  amount: isIncome
                      ? '+${AppFormatters.formatINR(amount)}'
                      : '-${AppFormatters.formatINR(amount)}',
                  amountColor: isIncome ? AppColors.secondary : AppColors.tertiary,
                  category: category,
                ),
              );
            }),
          ),
        const SizedBox(height: 80),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category.toUpperCase(),
                style: GoogleFonts.inter(
                  color: AppColors.outlineVariant,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryContainer,
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Center(
                  child: Text(
                    _getUserInitials(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getGreeting(),
                    style: GoogleFonts.inter(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${_getUserName()} 👋',
                    style: GoogleFonts.inter(
                      color: AppColors.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                _buildCircularActionButton(Icons.search, () {}),
                const SizedBox(width: 8),
                _buildCircularActionButton(Icons.notifications_none, () {}),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? _buildErrorWidget()
              : Stack(
                  children: [
                    // Background Nebula Glows
                    Positioned(
                      top: -150,
                      left: MediaQuery.of(context).size.width / 2 - 150,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -50,
                      right: -100,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.05),
                        ),
                      ),
                    ),
                    // Main Scroll View
                    RefreshIndicator(
                      onRefresh: _fetchDashboard,
                      color: AppColors.primary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildNetWorthCard(),
                            const SizedBox(height: 20),
                            _buildQuickActions(),
                            const SizedBox(height: 20),
                            _buildSummaryGrid(),
                            const SizedBox(height: 28),
                            _buildCategorySpendingSection(),
                            const SizedBox(height: 28),
                            _buildRecentTransactions(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class DonutChart extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  final List<String> labels;
  final double total;

  const DonutChart({
    super.key,
    required this.values,
    required this.colors,
    required this.labels,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final double sum = values.fold(0, (prev, element) => prev + element);
    final List<double> percentages = values.map((val) => sum > 0 ? val / sum : 0.0).toList();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CustomPaint(
                    painter: DonutChartPainter(
                      percentages: percentages,
                      colors: colors,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'EXPENSES',
                      style: GoogleFonts.inter(
                        color: AppColors.outline,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppFormatters.formatINR(total),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Column(
          children: List.generate(values.length, (index) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.05),
                    width: index < values.length - 1 ? 1 : 0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors[index],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        labels[index],
                        style: GoogleFonts.inter(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        AppFormatters.formatINR(values[index]),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(percentages[index] * 100).toStringAsFixed(1)}%',
                        style: GoogleFonts.inter(
                          color: AppColors.outline,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<double> percentages;
  final List<Color> colors;

  DonutChartPainter({required this.percentages, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.butt;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - paint.strokeWidth / 2;

    double startAngle = -3.14159265 / 2;

    for (int i = 0; i < percentages.length; i++) {
      paint.color = colors[i];
      final sweepAngle = percentages[i] * 2 * 3.14159265;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CsvImportBottomSheet extends StatefulWidget {
  const _CsvImportBottomSheet();

  @override
  State<_CsvImportBottomSheet> createState() => _CsvImportBottomSheetState();
}

class _CsvImportBottomSheetState extends State<_CsvImportBottomSheet> {
  int _selectedTabIndex = 0; // 0: Upload File, 1: Paste CSV
  bool _isLoading = false;
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _processParsedTransactions(List<Map<String, dynamic>> parsedTxns) async {
    final router = GoRouter.of(context);
    Navigator.pop(context, true); // Close bottom sheet
    await router.push('/transactions/csv-review', extra: parsedTxns);
  }

  Future<void> _pickAndUploadFile() async {
    final apiClient = context.read<ApiClient>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      setState(() => _isLoading = true);

      final filePath = result.files.single.path!;
      final fileName = result.files.single.name;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await apiClient.dio.post(
        '${ApiConstants.transactions}/parse-csv',
        data: formData,
      );

      final data = response.data;
      if (data is List) {
        final parsedTxns = List<Map<String, dynamic>>.from(data);
        if (mounted) {
          setState(() => _isLoading = false);
          await _processParsedTransactions(parsedTxns);
        }
      } else {
        throw Exception('Invalid server response');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String msg = 'Failed to parse CSV file';
        if (e is DioException && e.response?.data != null) {
          final detail = e.response?.data['detail'];
          if (detail != null) msg = detail.toString();
        }
        messenger.showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _submitPastedText() async {
    final rawText = _textController.text.trim();
    if (rawText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste some CSV text to import')),
      );
      return;
    }

    final apiClient = context.read<ApiClient>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isLoading = true);

    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromString(
          rawText,
          filename: 'pasted_transactions.csv',
        ),
      });

      final response = await apiClient.dio.post(
        '${ApiConstants.transactions}/parse-csv',
        data: formData,
      );

      final data = response.data;
      if (data is List) {
        final parsedTxns = List<Map<String, dynamic>>.from(data);
        if (mounted) {
          setState(() => _isLoading = false);
          await _processParsedTransactions(parsedTxns);
        }
      } else {
        throw Exception('Invalid server response');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String msg = 'Failed to parse CSV text';
        if (e is DioException && e.response?.data != null) {
          final detail = e.response?.data['detail'];
          if (detail != null) msg = detail.toString();
        }
        messenger.showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Import Transactions (CSV)',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Tab switcher
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: _selectedTabIndex == 0
                          ? BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                            )
                          : null,
                      child: Text(
                        'Upload File',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _selectedTabIndex == 0 ? AppColors.primary : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: _selectedTabIndex == 1
                          ? BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                            )
                          : null,
                      child: Text(
                        'Paste CSV',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _selectedTabIndex == 1 ? AppColors.primary : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (_selectedTabIndex == 0)
            Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Select a .CSV file from your device',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Supports columns: date, description, amount, type/category',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _pickAndUploadFile,
                    icon: const Icon(Icons.file_open, color: Colors.white),
                    label: Text(
                      'Browse File',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paste Raw CSV Content',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _textController,
                  maxLines: 6,
                  style: GoogleFonts.robotoMono(
                    fontSize: 13,
                    color: AppColors.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: "date,description,amount\n2026-07-01,Swiggy Lunch,450\n2026-07-02,Uber Commute,250\n2026-07-03,TCS Salary,75000",
                    hintStyle: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.outline.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.03),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _submitPastedText,
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: Text(
                      'Parse & Review CSV',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
