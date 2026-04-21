import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

// --- CORE UI & THEME ---
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/bento_grid/bento_card.dart';
import '../../../../core/widgets/common/smart_action_button.dart';

// --- PROVIDERS ---
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- STRICTLY PRESERVED STATE ---
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  // --- STRICTLY PRESERVED LOGIC ---
  void _handleLogin(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final pass = _passController.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập email và mật khẩu.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

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
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor, // Replaced heavy mesh gradient
      body: SafeArea(
        child: auth.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),

                    // --- HERO SECTION ---
                    _buildHeroHeader(context),

                    const SizedBox(height: 48),

                    // --- VIBRANT BENTO INPUT FIELDS ---
                    _buildBentoInput(
                      context: context,
                      controller: _emailController,
                      hint: "Email",
                      icon: CupertinoIcons.mail,
                      iconTint: AppColors.bentoBlue,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildBentoInput(
                      context: context,
                      controller: _passController,
                      hint: "Mật khẩu",
                      icon: CupertinoIcons.lock,
                      iconTint: AppColors.bentoPurple,
                      obscureText: true,
                    ),

                    // --- FORGOT PASSWORD LINK ---
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.forgotPassword,
                        ),
                        child: Text(
                          "Quên mật khẩu?",
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.displayLarge?.color,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // --- ACTION SECTION ---
                    SmartActionButton(
                      text: "Đăng nhập",
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
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.register),
                          child: Text(
                            "Đăng ký ngay",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  Widget _buildHeroHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Chào mừng trở lại! 👋",
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontSize: 34),
        ),
        const SizedBox(height: 8),
        Text(
          "Cùng tiếp tục hành trình chinh phục tiếng Anh của bạn nhé.",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildBentoInput({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconTint,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return BentoCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconTint.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconTint, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: Theme.of(context).textTheme.bodyLarge,
              cursorColor: Theme.of(context).primaryColor,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
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
