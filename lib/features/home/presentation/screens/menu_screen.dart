import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';

// --- CORE UI & THEME ---
import '../../../../core/theme/app_colors.dart';
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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- TOP: PROFILE QUICK-VIEW ---
            _buildProfileHeader(context, user, settings, auth),

            // --- MIDDLE: NAVIGATION ITEMS ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppLayout.defaultPadding),
                child: Column(
                  children: [
                    // Group 1: Learning Tools (Vibrant Mint/Blue/Yellow)
                    _buildBentoSection([
                      _buildNavItem(
                        context,
                        CupertinoIcons.arrow_2_circlepath,
                        'sidebar.sync'.tr(),
                        () => _handleSync(context),
                        iconColor: AppColors.bentoMint,
                      ),
                      _buildNavItem(
                        context,
                        CupertinoIcons.clock_fill,
                        'sidebar.history'.tr(),
                        () => Navigator.pushNamed(context, AppRoutes.history),
                        iconColor: AppColors.bentoBlue,
                      ),
                      _buildNavItem(
                        context,
                        CupertinoIcons.star_fill,
                        'sidebar.saved'.tr(),
                        () => Navigator.pushNamed(context, AppRoutes.saved),
                        iconColor: AppColors.bentoYellow,
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Group 2: App & Legal (Vibrant Purple/Blue/Pink)
                    _buildBentoSection([
                      _buildNavItem(
                        context,
                        CupertinoIcons.gear_solid,
                        'sidebar.settings'.tr(),
                        () => Navigator.pushNamed(context, AppRoutes.settings),
                        iconColor: AppColors.bentoPurple,
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
                        iconColor: AppColors.bentoBlue,
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
                        iconColor: AppColors.bentoPink,
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
                        iconColor: AppColors.bentoMint,
                      ),
                    ]),
                  ],
                ),
              ),
            ),

            // --- BOTTOM: LOGOUT & VERSION ---
            _buildFooter(context, auth, user),
            const SizedBox(height: 100), // Navigation clearance
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
      padding: const EdgeInsets.all(AppLayout.defaultPadding),
      child: BentoCard(
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
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                  Text(
                    user?.email ?? 'sidebar.login_desc'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Edit Profile",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoSection(List<Widget> items) {
    return BentoCard(
      padding: EdgeInsets.zero,
      child: Column(children: items),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    required Color iconColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: Icon(
        CupertinoIcons.chevron_right,
        size: 14,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      onTap: onTap,
    );
  }

  Widget _buildFooter(BuildContext context, AuthProvider auth, dynamic user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.defaultPadding),
      child: Column(
        children: [
          SmartActionButton(
            text: user != null ? "sidebar.logout".tr() : "sidebar.login".tr(),
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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 12),
              );
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // STRICTLY PRESERVED LOGIC
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
