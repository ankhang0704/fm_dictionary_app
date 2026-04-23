import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; // IMPORTED

// --- CORE UI & THEME ---
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bento_grid/bento_card.dart';
import '../../../../core/widgets/common/smart_action_button.dart';
import '../../../../core/utils/status_navigator.dart';

// --- PROVIDERS ---
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // --- STRICTLY PRESERVED LOGIC ---
  void _handleReset(BuildContext context) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    final provider = context.read<AuthProvider>();
    try {
      await provider.resetPassword(email);
      if (!context.mounted) return;

      StatusNavigator.showSuccess(
        context: context,
        title: 'auth.forgot_password.email_sent_title'.tr(), // INJECTED
        message: 'auth.forgot_password.email_sent_msg'.tr(), // INJECTED
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildBentoHeader(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // HERO TEXT
              Text(
                'auth.forgot_password.title'.tr(), // INJECTED
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'auth.forgot_password.description'.tr(), // INJECTED
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: 40),

              // VIBRANT BENTO INPUT
              BentoCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bentoMint.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.mail,
                        color: AppColors.bentoMint,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: Theme.of(context).textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'auth.forgot_password.email_hint'
                              .tr(), // INJECTED
                          hintStyle: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color
                                    ?.withValues(alpha: 0.5),
                              ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

      SmartActionButton(
                text: 'auth.forgot_password.send_btn'
                    .tr(), // [PRESERVED] Logic localization
                icon: Icons.send_rounded, // [NEW] Icon gửi yêu cầu rực rỡ
                color: const Color(
                  0xFF8B5CF6,
                ), // [NEW] Vibrant Violet (Màu tím bảo mật/trí tuệ)
                textColor: Colors.white,
                isLoading: auth.isLoading, // [PRESERVED] Logic loading state
                onPressed: () =>
                    _handleReset(context), // [PRESERVED] Logic action
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildBentoHeader(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              CupertinoIcons.back,
              color: Theme.of(context).textTheme.displayLarge?.color,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
