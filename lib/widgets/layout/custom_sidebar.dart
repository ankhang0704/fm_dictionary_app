// file: lib/widgets/layout/custom_sidebar.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fm_dictionary/widgets/layout/logic/syns_data.dart';
import 'package:fm_dictionary/widgets/layout/widgets/sidebar_header.dart';
import 'package:fm_dictionary/widgets/layout/widgets/sidebar_item.dart';
import '../../screens/auth/profile_screen.dart';
import '../../screens/info/static_content_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../services/auth/auth_sync_service.dart';
import '../../core/constants/constants.dart';

class CustomSideBar extends StatelessWidget {
  const CustomSideBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark
          ? AppConstants.darkBgColor
          : AppConstants.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            ValueListenableBuilder<User?>(
              valueListenable: AuthSyncService.instance.currentUser,
              builder: (context, user, _) =>
                  SidebarHeader(user: user, isDark: isDark),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  SidebarItem(
                    icon: CupertinoIcons.person_crop_circle,
                    title: 'sidebar.profile'.tr(),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  SidebarItem(
                    icon: CupertinoIcons.arrow_2_circlepath,
                    title: 'sidebar.sync'.tr(),
                    onTap: () {
                      handleSync(context);
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, thickness: 1),
                  ),
                  SidebarItem(
                    icon: CupertinoIcons.chat_bubble_text,
                    title: 'sidebar.feedback'.tr(),
                    onTap: () => _navigateToStatic(
                      context,
                      'sidebar.feedback',
                      'content.feedback_text',
                    ),
                  ),
                  SidebarItem(
                    icon: CupertinoIcons.share,
                    title: 'sidebar.share'.tr(),
                    onTap: () => _navigateToStatic(
                      context,
                      'sidebar.share',
                      'content.share_text',
                    ),
                  ),
                  SidebarItem(
                    icon: CupertinoIcons.shield_lefthalf_fill,
                    title: 'sidebar.privacy'.tr(),
                    onTap: () => _navigateToStatic(
                      context,
                      'sidebar.privacy',
                      'content.privacy_text',
                    ),
                  ),
                  SidebarItem(
                    icon: CupertinoIcons.doc_text,
                    title: 'sidebar.terms'.tr(),
                    onTap: () => _navigateToStatic(
                      context,
                      'sidebar.terms',
                      'content.terms_text',
                    ),
                  ),
                  SidebarItem(
                    icon: CupertinoIcons.info_circle,
                    title: 'sidebar.about'.tr(),
                    onTap: () => _navigateToStatic(
                      context,
                      'sidebar.about',
                      'content.about_text',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, thickness: 1),
                  ),
                  SidebarItem(
                    icon: CupertinoIcons.gear_solid,
                    title: 'sidebar.settings'.tr(),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            ValueListenableBuilder<User?>(
              valueListenable: AuthSyncService.instance.currentUser,
              builder: (context, user, _) =>
                  SidebarFooter(user: user, isDark: isDark),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToStatic(
    BuildContext context,
    String titleKey,
    String contentKey,
  ) {
    Navigator.pop(context);
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) =>
            StaticContentScreen(titleKey: titleKey, contentKey: contentKey),
      ),
    );
  }

  
}



