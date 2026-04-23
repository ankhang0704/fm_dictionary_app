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

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPass = TextEditingController();
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();

  @override
  void dispose() {
    _oldPass.dispose();
    _newPass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  // --- STRICTLY PRESERVED LOGIC ---
  void _handleUpdate(BuildContext context) async {
    final oldP = _oldPass.text.trim();
    final newP = _newPass.text.trim();
    final confP = _confirmPass.text.trim();

    if (oldP.isEmpty || newP.isEmpty || confP.isEmpty) {
      return _showMsg('auth.validation.fill_all'.tr()); // INJECTED
    }
    if (newP.length < 6) {
      return _showMsg('auth.validation.pass_length'.tr()); // INJECTED
    }
    if (newP != confP) {
      return _showMsg('auth.validation.pass_mismatch'.tr()); // INJECTED
    }

    final provider = context.read<AuthProvider>();
    try {
      await provider.changePassword(oldP, newP);
      if (!context.mounted) return;

      StatusNavigator.showSuccess(
        context: context,
        title: 'auth.change_password.success_title'.tr(), // INJECTED
        message: 'auth.change_password.success_msg'.tr(), // INJECTED
      );
    } catch (e) {
      _showMsg(e.toString());
    }
  }

  void _showMsg(String msg) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg.replaceAll('Exception: ', '')),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
              Text(
                'auth.change_password.header'.tr(), // INJECTED
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 40),

              // VIBRANT BENTO INPUTS
              _buildBentoInput(
                context: context,
                controller: _oldPass,
                hint: 'auth.change_password.current_hint'.tr(), // INJECTED
                icon: CupertinoIcons.lock,
                iconTint: AppColors.bentoBlue,
              ),
              const SizedBox(height: 16),
              _buildBentoInput(
                context: context,
                controller: _newPass,
                hint: 'auth.change_password.new_hint'.tr(), // INJECTED
                icon: CupertinoIcons.lock_shield,
                iconTint: AppColors.bentoPurple,
              ),
              const SizedBox(height: 16),
              _buildBentoInput(
                context: context,
                controller: _confirmPass,
                hint: 'auth.change_password.confirm_hint'.tr(), // INJECTED
                icon: CupertinoIcons.lock_shield_fill,
                iconTint: AppColors.bentoMint,
              ),

              const SizedBox(height: 40),

              SmartActionButton(
                text: 'auth.change_password.update_btn'
                    .tr(), // [PRESERVED] Logic localization
                icon: Icons
                    .published_with_changes_rounded, // [NEW] Icon cập nhật thành công rực rỡ
                color: const Color(
                  0xFF6366F1,
                ), // [NEW] Vibrant Indigo (Màu Indigo bảo mật)
                textColor: Colors.white,
                isLoading: auth.isLoading, // [PRESERVED] Logic loading state
                onPressed: () =>
                    _handleUpdate(context), // [PRESERVED] Logic action
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBentoInput({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconTint,
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
              obscureText: true,
              style: Theme.of(context).textTheme.bodyLarge,
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
