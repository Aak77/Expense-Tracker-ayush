import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/glass_styles.dart';

class AddEditBudgetScreen extends StatefulWidget {
  const AddEditBudgetScreen({super.key});

  @override
  State<AddEditBudgetScreen> createState() => _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends State<AddEditBudgetScreen> {
  String _amount = '0';
  bool _repeatMonthly = true;
  double _alertThreshold = 80.0;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Set Budget',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background decorations (as mock)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
                backgroundBlendMode: BlendMode.screen,
              ),
              child: BackdropFilter(
                filter: ColorFilter.mode(Colors.black.withOpacity(0.01), BlendMode.srcOver),
                child: Container(),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                // Target Monthly Limit
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: GlassStyles.glassCardDecoration.copyWith(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Target Monthly Limit',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₹ ',
                            style: GoogleFonts.inter(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                          Text(
                            _amount.isEmpty ? '0' : _amount,
                            style: GoogleFonts.inter(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                              letterSpacing: -0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adjust your financial boundaries',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Category Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Category',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.category, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                hint: Text(
                                  'Select a category',
                                  style: GoogleFonts.inter(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                dropdownColor: AppColors.surfaceContainerHigh,
                                icon: const Icon(Icons.expand_more, color: AppColors.outlineVariant),
                                isExpanded: true,
                                items: [
                                  'Shopping',
                                  'Dining & Drinks',
                                  'Groceries',
                                  'Travel & Transport',
                                  'Entertainment',
                                  'Utility Bills',
                                  'Health & Wellness',
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: GoogleFonts.inter(color: AppColors.onSurface),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Monthly Limit Input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'Monthly Limit (₹)',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.payments, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: '5,000',
                                hintStyle: GoogleFonts.inter(color: AppColors.outline.withOpacity(0.5)),
                                border: InputBorder.none,
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _amount = val;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Suggested: ₹12,500',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.outline,
                            ),
                          ),
                          Text(
                            'View Trends',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Repeat Monthly Toggle
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
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.sync, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Repeat Monthly',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              'Reset on the 1st of every month',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _repeatMonthly,
                        onChanged: (val) {
                          setState(() {
                            _repeatMonthly = val;
                          });
                        },
                        activeColor: AppColors.onPrimaryContainer,
                        activeTrackColor: AppColors.primaryContainer,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: AppColors.surfaceVariant,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Alert Threshold Slider
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Alert Threshold',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${_alertThreshold.toInt()}%',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Slider(
                      value: _alertThreshold,
                      min: 50,
                      max: 100,
                      divisions: 10,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.surfaceContainer,
                      onChanged: (val) {
                        setState(() {
                          _alertThreshold = val;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'We\'ll notify you when you reach ${_alertThreshold.toInt()}% of this budget.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Actions
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle),
                  label: Text(
                    'Save Budget',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimaryContainer,
                    minimumSize: const Size.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 10,
                    shadowColor: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppColors.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
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
}
