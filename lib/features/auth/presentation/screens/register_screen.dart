import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; // IMPORTED

// --- CORE UI & THEME ---
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/bento_grid/bento_card.dart';
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
  // --- STRICTLY PRESERVED STATE ---
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

  // --- STRICTLY PRESERVED LOGIC ---
  void _handleRegister(BuildContext context) async {
    final provider = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final password = _passController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('auth.validation.fill_all'.tr())), // INJECTED
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

                    const SizedBox(height: 40),

                    // --- VIBRANT BENTO INPUT FIELDS ---
                    _buildBentoInput(
                      context: context,
                      controller: _nameController,
                      hint: 'auth.register.name_hint'.tr(), // INJECTED
                      icon: CupertinoIcons.person,
                      iconTint: AppColors.bentoBlue,
                    ),
                    const SizedBox(height: 16),
                    _buildBentoInput(
                      context: context,
                      controller: _emailController,
                      hint: 'auth.register.email_hint'.tr(), // INJECTED
                      icon: CupertinoIcons.mail,
                      iconTint: AppColors.bentoPurple,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildBentoInput(
                      context: context,
                      controller: _passController,
                      hint: 'auth.register.pass_hint'.tr(), // INJECTED
                      icon: CupertinoIcons.lock,
                      iconTint: AppColors.bentoMint,
                      obscureText: true,
                    ),

                    const SizedBox(height: 48),

                    // --- ACTION SECTION ---
                    SmartActionButton(
                      text: 'auth.register.btn'
                          .tr(), // [PRESERVED] Logic localization
                      icon: Icons
                          .person_add_alt_1_rounded, // [NEW] Icon người dùng mới rực rỡ
                      color: const Color(
                        0xFF10B981,
                      ), // [NEW] Vibrant Emerald (Màu xanh khởi tạo)
                      textColor: Colors.white,
                      isLoading:
                          auth.isLoading, // [PRESERVED] Logic loading state
                      onPressed: () =>
                          _handleRegister(context), // [PRESERVED] Logic action
                    ),

                    const SizedBox(height: 24),

                    // --- LOGIN LINK ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'auth.register.already_have_acc'.tr(), // INJECTED
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                          ),
                          child: Text(
                            'auth.register.login_now'.tr(), // INJECTED
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
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
          'auth.register.title'.tr(), // INJECTED
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontSize: 34),
        ),
        const SizedBox(height: 8),
        Text(
          'auth.register.description'.tr(), // INJECTED
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
