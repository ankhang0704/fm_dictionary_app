import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/constants.dart';

class ProfileHeader extends StatelessWidget {
  final User user;
  final bool isDark;

  const ProfileHeader({super.key, required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppConstants.accentColor.withValues(alpha: 0.3),
              width: 3,
            ),
          ),
          child: CircleAvatar(
            radius: 56,
            backgroundColor: isDark
                ? AppConstants.darkCardColor
                : Colors.grey.withValues(alpha: 0.1),
            backgroundImage: user.photoURL != null
                ? NetworkImage(user.photoURL!)
                : null,
            child: user.photoURL == null
                ? Icon(
                    CupertinoIcons.person_solid,
                    size: 48,
                    color: isDark ? Colors.white54 : AppConstants.textSecondary,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.displayName ?? 'profile.default_name'.tr(),
          textAlign: TextAlign.center,
          style: AppConstants.bodyStyle.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email ?? '',
          textAlign: TextAlign.center,
          style: AppConstants.bodyStyle.copyWith(
            fontSize: 14,
            color: AppConstants.textSecondary,
          ),
        ),
      ],
    );
  }
}
