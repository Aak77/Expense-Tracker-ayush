import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/glass_styles.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool _isExpense = true;
  String _selectedCategory = 'Food';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Transport', 'icon': Icons.commute},
    {'name': 'Shopping', 'icon': Icons.shopping_bag},
    {'name': 'Leisure', 'icon': Icons.movie},
    {'name': 'Health', 'icon': Icons.medical_services},
    {'name': 'Other', 'icon': Icons.more_horiz},
  ];

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
                          onTap: () => setState(() => _isExpense = true),
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
                          onTap: () => setState(() => _isExpense = false),
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
                    Text(
                      'Manage',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 80,
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
                              category['name'],
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: GlassStyles.glassCardDecoration.copyWith(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Text(
                            'Oct 27, 2023',
                            style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Optional Receipt
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: GlassStyles.glassCardDecoration.copyWith(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.receipt, color: AppColors.secondary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attach Receipt',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              'Optional JPEG or PDF',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.outline),
                    ],
                  ),
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
                onPressed: () {},
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
                child: Text(
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
