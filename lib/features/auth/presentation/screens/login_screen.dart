import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:provider/provider.dart';

// --- CORE UI & THEME ---
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/common/smart_action_button.dart';

// --- PROVIDERS ---
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- LEGACY STATE EXTRACTION ---
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // --- LEGACY LOGIC MAPPING ---
  void _handleLogin(BuildContext context) async {
    final provider = context.read<AuthProvider>();
    try {
      await provider.login(
        _emailController.text.trim(),
        _passController.text.trim(),
      );
      if (!context.mounted) return;

      // Navigate to dashboard on success
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
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

                      const SizedBox(height: 48),

                      // --- INPUT FIELDS (FLOATING GLASS) ---
                      _buildInputField(
                        controller: _emailController,
                        hint: "Email",
                        icon: CupertinoIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _passController,
                        hint: "Mật khẩu",
                        icon: CupertinoIcons.lock,
                        obscureText: true,
                      ),

                      // --- FORGOT PASSWORD LINK ---
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/forgot_password',
                          ), // Ensure route exists
                          child: Text(
                            "Quên mật khẩu?",
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // --- ACTION SECTION ---
                      SmartActionButton(
                        text: "Đăng nhập",
                        isGlass: false,
                        isLoading: auth.isLoading,
                        onPressed: () => _handleLogin(context),
                      ),

                      const SizedBox(height: 24),

                      // --- REGISTER LINK ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Chưa có tài khoản?",
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.register,
                            ),
                            child: Text(
                              "Đăng ký ngay",
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
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
          "Chào mừng trở lại! 👋",
          style: AppTypography.heading1.copyWith(
            fontSize: 34,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Cùng tiếp tục hành trình chinh phục tiếng Anh của bạn nhé.",
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
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
