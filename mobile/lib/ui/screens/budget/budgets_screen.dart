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

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _budgets = [];

  @override
  void initState() {
    super.initState();
    _fetchBudgets();
  }

  Future<void> _fetchBudgets() async {
    try {
      setState(() { _isLoading = true; _error = null; });
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.dio.get(ApiConstants.budgets);
      
      if (mounted) {
        setState(() {
          _budgets = List<Map<String, dynamic>>.from(response.data ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load budgets';
          _isLoading = false;
        });
      }
    }
  }

  double get _totalLimit {
    final globalBudget = _budgets.firstWhere(
      (b) => b['category']?.toString().toLowerCase() == 'global',
      orElse: () => {},
    );
    if (globalBudget.isNotEmpty) {
      return parseDouble(globalBudget['monthly_limit']);
    }
    return _budgets.fold(0.0, (sum, b) => sum + parseDouble(b['monthly_limit']));
  }

  double get _totalSpent {
    final globalBudget = _budgets.firstWhere(
      (b) => b['category']?.toString().toLowerCase() == 'global',
      orElse: () => {},
    );
    if (globalBudget.isNotEmpty) {
      return parseDouble(globalBudget['current_spending']);
    }
    return _budgets.fold(0.0, (sum, b) => sum + parseDouble(b['current_spending']));
  }

  double get _totalUtilization {
    if (_totalLimit <= 0) return 0.0;
    return (_totalSpent / _totalLimit).clamp(0.0, 1.0);
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'global': return Icons.public;
      case 'food': return Icons.restaurant;
      case 'transport': return Icons.commute;
      case 'shopping': return Icons.shopping_bag;
      case 'entertainment': return Icons.movie;
      case 'bills': return Icons.receipt_long;
      case 'health': return Icons.medical_services;
      case 'education': return Icons.school;
      case 'travel': return Icons.flight;
      default: return Icons.category;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'exceeded': return AppColors.tertiary;
      case 'danger': return const Color(0xFFF59E0B);
      case 'warning': return const Color(0xFFF59E0B).withOpacity(0.85);
      default: return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        title: Text(
          'Budgets',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.outline, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _fetchBudgets,
                        child: Text('Retry', style: GoogleFonts.inter(color: AppColors.primary)),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchBudgets,
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      children: [
                        // Total Utilization Card
                        if (_budgets.isNotEmpty) ...[
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
                                      (_totalUtilization * 100).toInt().toString(),
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
                                      'Spent: ${AppFormatters.formatINR(_totalSpent)}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      'Limit: ${AppFormatters.formatINR(_totalLimit)}',
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
                                      widthFactor: _totalUtilization,
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
                                if (_totalLimit > _totalSpent)
                                  Text(
                                    'You are on track to save ${AppFormatters.formatINR(_totalLimit - _totalSpent)} this month',
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
                        ],

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
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (_budgets.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: GlassStyles.glassCardDecoration,
                            width: double.infinity,
                            child: Column(
                              children: [
                                const Icon(Icons.account_balance_wallet_outlined, color: AppColors.outline, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'No budgets set',
                                  style: GoogleFonts.inter(
                                    color: AppColors.onSurface,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap + to create a budget',
                                  style: GoogleFonts.inter(
                                    color: AppColors.outline,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...List.generate(_budgets.length, (index) {
                            final b = _budgets[index];
                            final category = b['category']?.toString() ?? 'unknown';
                            final limit = parseDouble(b['monthly_limit']);
                            final spent = parseDouble(b['current_spending']);
                            final status = b['status']?.toString();
                            final remaining = parseDouble(b['remaining']);
                            final utilPercent = parseDouble(b['utilization_percentage']);
                            
                            final color = _getStatusColor(status);
                            final title = category.toLowerCase() == 'global'
                                ? 'Global (All Expenses)'
                                : '${category[0].toUpperCase()}${category.substring(1)}';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildBudgetCard(
                                icon: _getCategoryIcon(category),
                                iconColor: color,
                                iconBgColor: color.withOpacity(0.1),
                                title: title,
                                subtitle: remaining >= 0 ? '${AppFormatters.formatINR(remaining)} remaining' : '${AppFormatters.formatINR(remaining.abs())} over budget',
                                subtitleColor: remaining < 0 ? AppColors.tertiary : null,
                                spent: AppFormatters.formatINR(spent),
                                limit: ' / ${AppFormatters.formatINR(limit)}',
                                percentageText: '${utilPercent.toInt()}% used',
                                percentageColor: color,
                                progressValue: (utilPercent / 100).clamp(0.0, 1.0),
                              ),
                            );
                          }),
                        // Bottom padding for FAB
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 96),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () async {
              final result = await context.push('/budgets/add');
              if (result == true) _fetchBudgets();
            },
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            focusElevation: 0,
            hoverElevation: 0,
            highlightElevation: 0,
            shape: const CircleBorder(),
            child: const Icon(Icons.add),
          ),
        ),
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
                widthFactor: progressValue,
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
