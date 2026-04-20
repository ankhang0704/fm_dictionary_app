import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:provider/provider.dart';

// --- CORE UI & THEME ---
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
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

  // --- LEGACY LOGIC MAPPING ---
  void _handleReset(BuildContext context) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    final provider = context.read<AuthProvider>();
    try {
      await provider.resetPassword(email);
      if (!context.mounted) return;

      StatusNavigator.showSuccess(
        context: context,
        title: "Đã gửi Email",
        message:
            "Vui lòng kiểm tra hòm thư của bạn để tiến hành khôi phục mật khẩu.",
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

    return Container(
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
        appBar: _buildGlassHeader(context),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // HERO TEXT
                Text(
                  "Khôi phục mật khẩu",
                  style: AppTypography.heading1.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  "Nhập email của bạn để nhận liên kết đặt lại mật khẩu.",
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 40),

                // GLASS INPUT
                GlassBentoCard(
                  onTap: null,
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.mail,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: AppTypography.bodyLarge,
                          decoration: InputDecoration(
                            hintText: "Email đăng ký",
                            hintStyle: TextStyle(
                              color: AppColors.textPrimary.withValues(alpha:0.4),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                SmartActionButton(
                  text: "Gửi yêu cầu",
                  isLoading: auth.isLoading,
                  onPressed: () => _handleReset(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildGlassHeader(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppBar(
            backgroundColor: Colors.white.withValues(alpha:0.1),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                CupertinoIcons.back,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
    );
  }
}
