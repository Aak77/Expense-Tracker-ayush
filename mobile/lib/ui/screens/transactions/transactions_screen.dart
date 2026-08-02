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
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _selectedTabIndex = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTransactions() async {
    try {
      setState(() => _isLoading = true);
      final apiClient = context.read<ApiClient>();

      String? typeFilter;
      if (_selectedTabIndex == 1) typeFilter = 'income';
      if (_selectedTabIndex == 2) typeFilter = 'expense';

      final queryParams = <String, dynamic>{'limit': 50, 'page': 1};
      if (typeFilter != null) queryParams['type'] = typeFilter;

      final response = await apiClient.dio.get(
        ApiConstants.transactions,
        queryParameters: queryParams,
      );
      final data = response.data;

      if (mounted) {
        setState(() {
          _transactions = List<Map<String, dynamic>>.from(
            data['transactions'] ?? [],
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _importCSV() async {
    final apiClient = context.read<ApiClient>();
    final router = GoRouter.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

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
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
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
          final importConfirmed = await router.push('/transactions/csv-review', extra: parsedTxns);
          if (importConfirmed == true) {
            _fetchTransactions();
          }
        }
      } else {
        throw Exception('Invalid response format from server');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String msg = 'Failed to parse CSV file';
        if (e is DioException && e.response?.data != null) {
          final detail = e.response?.data['detail'];
          if (detail != null) msg = detail.toString();
        }
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Group transactions by date
  Map<String, List<Map<String, dynamic>>> _groupByDate() {
    final search = _searchController.text.toLowerCase();
    final filtered = search.isEmpty
        ? _transactions
        : _transactions.where((t) {
            final desc = (t['description'] ?? '').toString().toLowerCase();
            final cat = (t['category'] ?? '').toString().toLowerCase();
            return desc.contains(search) || cat.contains(search);
          }).toList();

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final t in filtered) {
      final dateStr = t['transaction_date']?.toString() ?? '';
      String label;
      try {
        final parsed = DateTime.parse(dateStr);
        label = AppFormatters.formatDate(parsed).toUpperCase();
      } catch (_) {
        label = dateStr;
      }
      grouped.putIfAbsent(label, () => []).add(t);
    }
    return grouped;
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'food': return Icons.restaurant;
      case 'transport': return Icons.commute;
      case 'shopping': return Icons.shopping_bag;
      case 'entertainment': return Icons.movie;
      case 'bills': return Icons.receipt_long;
      case 'health': return Icons.medical_services;
      case 'education': return Icons.school;
      case 'travel': return Icons.flight;
      case 'salary': return Icons.work;
      case 'freelance': return Icons.laptop;
      case 'investment': return Icons.trending_up;
      case 'gift': return Icons.card_giftcard;
      default: return Icons.swap_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        title: Text(
          'Transactions',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file, color: AppColors.primary),
            tooltip: 'Import CSV',
            onPressed: _importCSV,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
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
                        const Icon(Icons.search, color: AppColors.outline, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
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
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Segmented Control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
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
          ),
          const SizedBox(height: 16),

          // Transaction List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, color: AppColors.outline, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'No transactions yet',
                              style: GoogleFonts.inter(color: AppColors.onSurfaceVariant, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchTransactions,
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: grouped.length,
                          itemBuilder: (context, sectionIndex) {
                            final dateLabel = grouped.keys.elementAt(sectionIndex);
                            final items = grouped[dateLabel]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (sectionIndex > 0) const SizedBox(height: 16),
                                Text(
                                  dateLabel,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.outline,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...items.map((t) {
                                  final isIncome = t['type'] == 'income';
                                  final amount = parseDouble(t['amount']);
                                  final category = t['category']?.toString() ?? 'other';
                                  final description = t['description']?.toString() ?? category;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildTransactionCard(
                                      icon: _getCategoryIcon(category),
                                      iconColor: isIncome ? AppColors.secondary : AppColors.primary,
                                      iconBgColor: isIncome
                                          ? AppColors.secondaryContainer.withOpacity(0.2)
                                          : AppColors.primaryContainer.withOpacity(0.2),
                                      title: description,
                                      subtitle: '${category[0].toUpperCase()}${category.substring(1)}',
                                      amount: amount * (isIncome ? 1 : -1),
                                      type: isIncome ? 'Credit' : 'Debit',
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                      ),
          ),
        ],
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
              final result = await context.push('/transactions/add');
              if (result == true) _fetchTransactions();
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

  Widget _buildTab(int index, String title) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
          _fetchTransactions();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: isSelected
              ? BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                )
              : null,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
                  color: isIncome ? AppColors.secondary : AppColors.tertiary,
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
