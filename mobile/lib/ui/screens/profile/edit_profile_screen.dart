import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/primary_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: 'Alexander Mitchell');
  final _emailController = TextEditingController(text: 'a.mitchell@fintrack.io');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
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
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.05),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                _buildAvatarSection(),
                const SizedBox(height: 32),
                _buildFormSection(),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'Save Changes',
                  onPressed: () {},
                  icon: Icons.check_circle_outline,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Discard Changes',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.outline,
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

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surfaceContainerHigh, width: 4),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBq6yo3wqGMtInxdGonJLLjNck07jHvMNU7EcAcOSx3c0xeD6apwz8dEknRLgDeLruMJVN7_j_8Cfn1xxinhyRhZwCasMx6WZeoT4ofTsQXAz8ptLRAFy2Ewv2k64TF6YpT6dh9Edg6o0jsGhrdGuFFseDCOTO5qohEJnpA_qg33vF6BmUCCrNPh0ACOHaS5VQ_VD9EfKUTNYEE9l28SMRUWMovTwnChQKggOwG1GeLZMb2OSTrPOSWXw4OYQ4YTyd0fbmNfJ8un8Y8',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.edit,
                color: AppColors.onPrimary,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'Full Name',
            controller: _nameController,
            hintText: 'Enter your full name',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 24),
          _buildTextField(
            label: 'Email Address',
            controller: _emailController,
            hintText: 'name@example.com',
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_user_outlined, color: AppColors.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Security',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your identity is verified via biometrics and 2FA. Changing your email will trigger a security alert.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
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
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(color: AppColors.outline.withOpacity(0.5)),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryContainer),
            ),
            prefixIcon: Icon(prefixIcon, color: AppColors.outline),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
