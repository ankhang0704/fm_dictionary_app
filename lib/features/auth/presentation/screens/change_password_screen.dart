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

  // --- LEGACY LOGIC MAPPING ---
  void _handleUpdate(BuildContext context) async {
    final oldP = _oldPass.text.trim();
    final newP = _newPass.text.trim();
    final confP = _confirmPass.text.trim();

    if (oldP.isEmpty || newP.isEmpty || confP.isEmpty) {
      return _showMsg("Vui lòng nhập đầy đủ");
    }
    if (newP.length < 6) {
      return _showMsg("Mật khẩu mới phải từ 6 ký tự trở lên");
    }
    if (newP != confP) return _showMsg("Xác nhận mật khẩu không khớp");

    final provider = context.read<AuthProvider>();
    try {
      await provider.changePassword(oldP, newP);
      if (!context.mounted) return;

      StatusNavigator.showSuccess(
        context: context,
        title: "Thành công!",
        message: "Mật khẩu của bạn đã được thay đổi an toàn.",
      );
    } catch (e) {
      _showMsg(e.toString());
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                Text(
                  "Đổi mật khẩu mới",
                  style: AppTypography.heading1.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 40),

                // GLASS INPUTS
                _buildGlassInput(
                  _oldPass,
                  "Mật khẩu hiện tại",
                  CupertinoIcons.lock,
                ),
                const SizedBox(height: 16),
                _buildGlassInput(
                  _newPass,
                  "Mật khẩu mới",
                  CupertinoIcons.lock_shield,
                ),
                const SizedBox(height: 16),
                _buildGlassInput(
                  _confirmPass,
                  "Xác nhận mật khẩu mới",
                  CupertinoIcons.lock_shield_fill,
                ),

                const SizedBox(height: 40),

                SmartActionButton(
                  text: "Cập nhật mật khẩu",
                  isLoading: auth.isLoading,
                  onPressed: () => _handleUpdate(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassInput(
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return GlassBentoCard(
      onTap: null,
      child: Row(
        children: [
          Icon(icon, color: AppColors.textPrimary),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: true,
              style: AppTypography.bodyLarge,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColors.textPrimary.withValues(alpha: 0.4),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
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
            backgroundColor: Colors.white.withValues(alpha: 0.1),
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
