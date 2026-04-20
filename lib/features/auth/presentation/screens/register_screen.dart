import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:provider/provider.dart';

// --- CORE UI & THEME ---
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/common/smart_action_button.dart';
import '../../../../core/utils/status_navigator.dart';

// --- PROVIDERS ---
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // --- LEGACY STATE EXTRACTION ---
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // --- LEGACY LOGIC MAPPING ---
  void _handleRegister(BuildContext context) async {
    final provider = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final password = _passController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }

    try {
      await provider.register(email, password, name);
      if (!context.mounted) return;

      // Success -> Show Verification Status (Legacy logic preserved)
      StatusNavigator.showEmailVerification(
        context: context,
        email: email, // Truyền biến email của bro vào đây
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Container(
      // GLOBAL DESIGN SYSTEM: Mesh Gradient Background
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.meshBlue,
            AppColors.meshPurple,
            AppColors.meshMint,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: auth.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),

                      // --- HERO SECTION (OPEN DESIGN) ---
                      _buildHeroHeader(),

                      const SizedBox(height: 40),

                      // --- INPUT FIELDS (FLOATING GLASS INPUTS) ---
                      _buildGlassInput(
                        controller: _nameController,
                        hint: "Họ và Tên",
                        icon: CupertinoIcons.person,
                      ),
                      const SizedBox(height: 16),
                      _buildGlassInput(
                        controller: _emailController,
                        hint: "Email",
                        icon: CupertinoIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildGlassInput(
                        controller: _passController,
                        hint: "Mật khẩu",
                        icon: CupertinoIcons.lock,
                        obscureText: true,
                      ),

                      const SizedBox(height: 48),

                      // --- ACTION SECTION ---
                      SmartActionButton(
                        text: "Đăng ký",
                        isGlass: false,
                        isLoading: auth.isLoading,
                        onPressed: () => _handleRegister(context),
                      ),

                      const SizedBox(height: 24),

                      // --- LOGIN LINK ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Đã có tài khoản?",
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            ),
                            child: Text(
                              "Đăng nhập",
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  Widget _buildHeroHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tạo tài khoản mới 🚀",
          style: AppTypography.heading1.copyWith(
            fontSize: 34,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Bắt đầu hành trình học tập cùng hàng ngàn học viên khác.",
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return GlassBentoCard(
      onTap: null, // Card acts as visual container only
      child: Row(
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
              cursorColor: AppColors.meshBlue,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.4),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
