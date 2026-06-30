import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/primary_button.dart';

class AddEditGoalScreen extends StatefulWidget {
  const AddEditGoalScreen({super.key});

  @override
  State<AddEditGoalScreen> createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends State<AddEditGoalScreen> {
  final _goalNameController = TextEditingController(text: 'New Tesla Model 3');
  final _targetAmountController = TextEditingController(text: '4500000');
  final _currentAmountController = TextEditingController(text: '2925000');
  
  @override
  void dispose() {
    _goalNameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Savings Goal',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background visual decoration
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 48),
            child: Column(
              children: [
                _buildProgressSummary(),
                const SizedBox(height: 32),
                _buildForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSummary() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.ads_click, color: AppColors.primary),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'PROGRESS',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.outline,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    '65%',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.65,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Goal Name',
          controller: _goalNameController,
          hintText: 'What are you saving for?',
          suffixIcon: Icons.edit_outlined,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Target Amount (₹)',
                controller: _targetAmountController,
                hintText: '0.00',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.currency_rupee,
                prefixColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                label: 'Current Amount (₹)',
                controller: _currentAmountController,
                hintText: '0.00',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.currency_rupee,
                prefixColor: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Target Date',
          controller: TextEditingController(text: '2025-12-31'),
          hintText: 'YYYY-MM-DD',
          suffixIcon: Icons.calendar_today_outlined,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: AppColors.primaryContainer),
              const SizedBox(width: 16),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                    children: const [
                      TextSpan(text: 'To reach your goal by Dec 2025, you\'ll need to save approximately '),
                      TextSpan(
                        text: '₹82,895',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' per month.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          text: 'Save Goal',
          onPressed: () {},
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'All data is encrypted and stored securely.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.outline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    IconData? suffixIcon,
    IconData? prefixIcon,
    Color? prefixColor,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(color: AppColors.outline.withOpacity(0.5)),
            filled: true,
            fillColor: AppColors.surfaceContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: prefixColor ?? AppColors.onSurface)
                : null,
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: AppColors.outline)
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
      ],
    );
  }
}
