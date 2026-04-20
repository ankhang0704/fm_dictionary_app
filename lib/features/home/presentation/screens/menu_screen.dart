import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';

// --- CORE UI & THEME ---
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/common/smart_action_button.dart';
import '../../../../core/widgets/common/app_avatar.dart';
import '../../../../core/utils/status_navigator.dart';

// --- PROVIDERS / SERVICES ---
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../data/services/database/database_service.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final settings = DatabaseService.getSettings();
    final currentLocale = context.locale.languageCode;

    return Container(
      // MESH GRADIENT BACKGROUND INTEGRATION
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.meshBlue, AppColors.meshPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Glass Overlay for the whole screen
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.black.withValues(alpha:0.1)),
            ),

            SafeArea(
              child: Column(
                children: [
                  // --- TOP: PROFILE QUICK-VIEW ---
                  _buildProfileHeader(context, user, settings, auth),

                  // --- MIDDLE: NAVIGATION ITEMS ---
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.all(AppLayout.defaultPadding),
                      child: Column(
                        children: [
                          // Group 1: Learning Tools
                          _buildBentoSection([
                            _buildNavItem(
                              context,
                              CupertinoIcons.arrow_2_circlepath,
                              'sidebar.sync'.tr(),
                              () => _handleSync(context),
                              iconColor: AppColors.meshMint,
                            ),
                            _buildNavItem(
                              context,
                              CupertinoIcons.clock_fill,
                              'sidebar.history'.tr(),
                              () => Navigator.pushNamed(
                                context,
                                AppRoutes.history,
                              ),
                            ),
                            _buildNavItem(
                              context,
                              CupertinoIcons.star_fill,
                              'sidebar.saved'.tr(),
                              () =>
                                  Navigator.pushNamed(context, AppRoutes.saved),
                            ),
                          ]),
                          const SizedBox(height: 16),

                          // Group 2: App & Legal
                          _buildBentoSection([
                            _buildNavItem(
                              context,
                              CupertinoIcons.gear_solid,
                              'sidebar.settings'.tr(),
                              () => Navigator.pushNamed(
                                context,
                                AppRoutes.settings,
                              ),
                            ),
                            _buildNavItem(
                              context,
                              CupertinoIcons.chat_bubble_text,
                              'sidebar.feedback'.tr(),
                              () => _navigateToStatic(
                                context,
                                'sidebar.feedback'.tr(),
                                'feedback_$currentLocale.md',
                              ),
                            ),
                            _buildNavItem(
                              context,
                              CupertinoIcons.shield_fill,
                              'sidebar.privacy'.tr(),
                              () => _navigateToStatic(
                                context,
                                'sidebar.privacy'.tr(),
                                'privacy_$currentLocale.md',
                              ),
                            ),
                            _buildNavItem(
                              context,
                              CupertinoIcons.info_circle_fill,
                              'sidebar.about'.tr(),
                              () => _navigateToStatic(
                                context,
                                'sidebar.about'.tr(),
                                'about_$currentLocale.md',
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),

                  // --- BOTTOM: LOGOUT & VERSION ---
                  _buildFooter(context, auth, user),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  Widget _buildProfileHeader(
    BuildContext context,
    dynamic user,
    dynamic settings,
    AuthProvider auth,
  ) {
    return Padding(
      padding: EdgeInsets.all(AppLayout.defaultPadding),
      child: GlassBentoCard(
        onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
        child: Row(
          children: [
            AppAvatar(
              localPath: settings.userAvatarPath,
              networkUrl: user?.photoURL,
              radius: 30,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      user?.displayName ?? 'sidebar.guest'.tr(),
                      style: AppTypography.heading3,
                    ),
                  ),
                  Text(
                    user?.email ?? 'sidebar.login_desc'.tr(),
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Edit Profile",
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.meshBlue,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoSection(List<Widget> items) {
    return GlassBentoCard(onTap: null, child: Column(children: items));
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? iconColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.textPrimary).withValues(alpha:0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: iconColor ?? AppColors.textPrimary),
      ),
      title: Text(title, style: AppTypography.bodyLarge),
      trailing: const Icon(
        CupertinoIcons.chevron_right,
        size: 14,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildFooter(BuildContext context, AuthProvider auth, dynamic user) {
    return Padding(
      padding: EdgeInsets.all(AppLayout.defaultPadding),
      child: Column(
        children: [
          SmartActionButton(
            text: user != null ? "sidebar.logout".tr() : "sidebar.login".tr(),
            isGlass: true,
            isLoading: false,
            onPressed: () => user != null
                ? auth.logout()
                : Navigator.pushNamed(context, AppRoutes.login),
          ),
          const SizedBox(height: 16),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              return Text(
                'Version ${snapshot.data?.version ?? '1.0.0'}',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // LEGACY LOGIC INTEGRATION
  // ===========================================================================

  void _navigateToStatic(BuildContext context, String title, String fileName) {
    Navigator.pushNamed(
      context,
      AppRoutes.staticContent,
      arguments: {'title': title, 'mdFileName': fileName},
    );
  }

  Future<void> _handleSync(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) {
      _showLoginRequiredDialog(context);
      return;
    }

    try {
      await authProvider.syncData();
      if (!context.mounted) return;
      StatusNavigator.showSuccess(
        context: context,
        title: "Sync Successful",
        message: "Progress has been synced with the cloud.",
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    }
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Yêu cầu đăng nhập"),
        content: const Text(
          "Bạn cần đăng nhập để sử dụng tính năng đồng bộ đám mây.",
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Để sau"),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("Đăng nhập"),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}
