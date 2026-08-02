import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/glass_styles.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool _isExpense = true;
  String _selectedCategory = 'food';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<Map<String, dynamic>> _expenseCategories = [
    {'name': 'food', 'label': 'Food', 'icon': Icons.restaurant},
    {'name': 'transport', 'label': 'Transport', 'icon': Icons.commute},
    {'name': 'shopping', 'label': 'Shopping', 'icon': Icons.shopping_bag},
    {'name': 'entertainment', 'label': 'Leisure', 'icon': Icons.movie},
    {'name': 'health', 'label': 'Health', 'icon': Icons.medical_services},
    {'name': 'bills', 'label': 'Bills', 'icon': Icons.receipt_long},
    {'name': 'education', 'label': 'Education', 'icon': Icons.school},
    {'name': 'travel', 'label': 'Travel', 'icon': Icons.flight},
    {'name': 'investment', 'label': 'Invest', 'icon': Icons.trending_up},
    {'name': 'other', 'label': 'Other', 'icon': Icons.more_horiz},
  ];

  final List<Map<String, dynamic>> _incomeCategories = [
    {'name': 'salary', 'label': 'Salary', 'icon': Icons.work},
    {'name': 'freelance', 'label': 'Freelance', 'icon': Icons.laptop},
    {'name': 'investment', 'label': 'Investment', 'icon': Icons.trending_up},
    {'name': 'gift', 'label': 'Gift', 'icon': Icons.card_giftcard},
    {'name': 'other', 'label': 'Other', 'icon': Icons.more_horiz},
  ];

  List<Map<String, dynamic>> get _categories =>
      _isExpense ? _expenseCategories : _incomeCategories;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTransaction() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final apiClient = context.read<ApiClient>();
      await apiClient.dio.post(
        '${ApiConstants.transactions}/',
        data: {
          'amount': amount,
          'type': _isExpense ? 'expense' : 'income',
          'category': _selectedCategory,
          'description': _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          'transaction_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_isExpense ? "Expense" : "Income"} added!'),
            backgroundColor: AppColors.secondary,
          ),
        );
        context.pop(true); // Return true to trigger refresh
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        String msg = 'Failed to save transaction';
        if (e is DioException && e.response?.data != null) {
          final detail = e.response?.data['detail'];
          if (detail != null) msg = detail.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Transaction',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 100),
            child: Column(
              children: [
                // Amount Input
                Column(
                  children: [
                    Text(
                      '₹',
                      style: GoogleFonts.inter(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                        letterSpacing: -0.8,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: GoogleFonts.inter(
                          color: AppColors.onSurface.withOpacity(0.2),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Type Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: GlassStyles.glassCardDecoration.copyWith(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  width: 256,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _isExpense = true;
                            _selectedCategory = 'food';
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: _isExpense
                                ? BoxDecoration(
                                    color: AppColors.errorContainer,
                                    borderRadius: BorderRadius.circular(32),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  )
                                : null,
                            child: Text(
                              'Expense',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _isExpense ? AppColors.onErrorContainer : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _isExpense = false;
                            _selectedCategory = 'salary';
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: !_isExpense
                                ? BoxDecoration(
                                    color: AppColors.secondaryContainer,
                                    borderRadius: BorderRadius.circular(32),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  )
                                : null,
                            child: Text(
                              'Income',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: !_isExpense ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Category Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 95,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category['name'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = category['name']),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: isSelected
                                  ? BoxDecoration(
                                      color: AppColors.primaryContainer.withOpacity(0.2),
                                      border: Border.all(color: AppColors.primaryContainer.withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(16),
                                    )
                                  : GlassStyles.glassCardDecoration.copyWith(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                              child: Icon(
                                category['icon'],
                                color: isSelected ? AppColors.primaryContainer : AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category['label'],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? AppColors.primaryContainer : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),

                // Form Fields
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Description',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: GlassStyles.glassCardDecoration.copyWith(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.notes, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _descriptionController,
                              style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'What was this for?',
                                hintStyle: GoogleFonts.inter(color: AppColors.onSurface.withOpacity(0.3)),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Date',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: GlassStyles.glassCardDecoration.copyWith(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('MMM dd, yyyy').format(_selectedDate),
                              style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 16),
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right, color: AppColors.outline),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Fixed Action Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).padding.bottom + 20,
                top: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.background,
                    AppColors.background.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimaryContainer,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 10,
                  shadowColor: AppColors.primaryContainer.withOpacity(0.4),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.onPrimaryContainer,
                        ),
                      )
                    : Text(
                        'Save Transaction',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
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
