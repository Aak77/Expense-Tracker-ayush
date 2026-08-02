import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/glass_styles.dart';
import '../../../core/utils/currency_format.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';

class CsvReviewScreen extends StatefulWidget {
  final List<Map<String, dynamic>> parsedTransactions;

  const CsvReviewScreen({
    super.key,
    required this.parsedTransactions,
  });

  @override
  State<CsvReviewScreen> createState() => _CsvReviewScreenState();
}

class _CsvReviewScreenState extends State<CsvReviewScreen> {
  late List<Map<String, dynamic>> _items;
  bool _isSaving = false;

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

  @override
  void initState() {
    super.initState();
    // Copy the input transactions list and add editing metadata
    _items = widget.parsedTransactions.map((item) {
      return {
        'transaction_date': item['transaction_date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'description': item['description'] ?? '',
        'amount': (item['amount'] ?? 0.0).toString(),
        'type': item['type'] ?? 'expense',
        'category': item['category'] ?? 'other',
        'isSelected': true,
      };
    }).toList();
  }

  IconData _getCategoryIcon(String category, String type) {
    final list = type == 'income' ? _incomeCategories : _expenseCategories;
    final match = list.firstWhere(
      (c) => c['name'] == category.toLowerCase(),
      orElse: () => {'icon': Icons.swap_horiz},
    );
    return match['icon'] as IconData;
  }

  String _getCategoryLabel(String category, String type) {
    final list = type == 'income' ? _incomeCategories : _expenseCategories;
    final match = list.firstWhere(
      (c) => c['name'] == category.toLowerCase(),
      orElse: () => {'label': 'Other'},
    );
    return match['label'] as String;
  }

  void _showCategoryPicker(int index) {
    final item = _items[index];
    final isExpense = item['type'] == 'expense';
    final categoriesList = isExpense ? _expenseCategories : _incomeCategories;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Category',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: categoriesList.length,
                  itemBuilder: (context, catIdx) {
                    final cat = categoriesList[catIdx];
                    final isSelected = item['category'] == cat['name'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _items[index]['category'] = cat['name'];
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.15)
                              : Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              cat['icon'] as IconData,
                              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                              size: 24,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat['label'] as String,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? AppColors.primary : AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickDate(int index) async {
    final item = _items[index];
    DateTime initialDate;
    try {
      initialDate = DateTime.parse(item['transaction_date']);
    } catch (_) {
      initialDate = DateTime.now();
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
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
      setState(() {
        _items[index]['transaction_date'] = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _importTransactions() async {
    final selectedItems = _items.where((item) => item['isSelected'] == true).toList();
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one transaction to import')),
      );
      return;
    }

    // Validate amounts
    final List<Map<String, dynamic>> validatedTransactions = [];
    for (var item in selectedItems) {
      final amt = double.tryParse(item['amount']);
      if (amt == null || amt <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid amount for transaction: "${item['description']}"')),
        );
        return;
      }
      validatedTransactions.add({
        'amount': amt,
        'type': item['type'],
        'category': item['category'],
        'description': item['description'].toString().trim().isEmpty ? null : item['description'].toString().trim(),
        'transaction_date': item['transaction_date'],
      });
    }

    setState(() => _isSaving = true);

    try {
      final apiClient = context.read<ApiClient>();
      await apiClient.dio.post(
        '${ApiConstants.transactions}/bulk',
        data: {
          'transactions': validatedTransactions,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully imported ${validatedTransactions.length} transactions!'),
            backgroundColor: AppColors.secondary,
          ),
        );
        Navigator.pop(context, true); // Return true to trigger refresh
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        String msg = 'Failed to import transactions';
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
    final selectedCount = _items.where((i) => i['isSelected'] == true).length;

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
          'Review CSV Import',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _items.every((i) => i['isSelected']) ? Icons.deselect : Icons.select_all,
              color: AppColors.onSurface,
            ),
            onPressed: () {
              final allSelected = _items.every((i) => i['isSelected']);
              setState(() {
                for (var i = 0; i < _items.length; i++) {
                  _items[i]['isSelected'] = !allSelected;
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Verify transactions, modify types, edit amounts or descriptions, and confirm the bulk upload.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final isSelected = item['isSelected'] as bool;
                    final isExpense = item['type'] == 'expense';
                    final category = item['category'] as String;
                    final displayDate = item['transaction_date'];

                    return Opacity(
                      opacity: isSelected ? 1.0 : 0.4,
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        color: Colors.transparent,
                        elevation: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: GlassStyles.glassCardDecoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row 1: Selection and Type Toggle and Amount
                              Row(
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) {
                                      setState(() {
                                        _items[index]['isSelected'] = val ?? false;
                                      });
                                    },
                                  ),
                                  // Type Toggle Chip
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        final newType = isExpense ? 'income' : 'expense';
                                        _items[index]['type'] = newType;
                                        // Auto-adjust default category
                                        _items[index]['category'] = newType == 'income' ? 'salary' : 'food';
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isExpense
                                            ? AppColors.primaryContainer.withOpacity(0.2)
                                            : AppColors.secondaryContainer.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isExpense
                                              ? AppColors.primary.withOpacity(0.3)
                                              : AppColors.secondary.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        isExpense ? 'EXPENSE' : 'INCOME',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isExpense ? AppColors.primary : AppColors.secondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  // Amount Input Box
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      onChanged: (val) {
                                        _items[index]['amount'] = val;
                                      },
                                      controller: TextEditingController(text: item['amount'])
                                        ..selection = TextSelection.fromPosition(
                                          TextPosition(offset: item['amount'].length),
                                        ),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      textAlign: TextAlign.right,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isExpense ? AppColors.tertiary : AppColors.secondary,
                                      ),
                                      decoration: InputDecoration(
                                        prefixText: '₹ ',
                                        prefixStyle: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isExpense ? AppColors.tertiary : AppColors.secondary,
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                        hintText: '0.00',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Row 2: Description Textfield
                              TextField(
                                onChanged: (val) {
                                  _items[index]['description'] = val;
                                },
                                controller: TextEditingController(text: item['description'])
                                  ..selection = TextSelection.fromPosition(
                                    TextPosition(offset: item['description'].length),
                                  ),
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                  labelStyle: GoogleFonts.inter(color: AppColors.outline, fontSize: 12),
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.primary),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Row 3: Category & Date Buttons
                              Row(
                                children: [
                                  // Category Select Button
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _showCategoryPicker(index),
                                      icon: Icon(
                                        _getCategoryIcon(category, item['type']),
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      label: Text(
                                        _getCategoryLabel(category, item['type']),
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Date Select Button
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _pickDate(index),
                                      icon: const Icon(
                                        Icons.calendar_month,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      label: Text(
                                        displayDate,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.onSurface,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Colors.white.withOpacity(0.1)),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Confirm Floating Action Area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.background,
                    AppColors.background.withOpacity(0.9),
                    AppColors.background.withOpacity(0.0),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isSaving ? null : _importTransactions,
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Import $selectedCount Transactions',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
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
