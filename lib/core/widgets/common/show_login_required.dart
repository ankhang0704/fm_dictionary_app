import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/app_routes.dart';
import 'package:fm_dictionary/core/widgets/common/smart_action_button.dart';

void showLoginRequiredDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    isScrollControlled: true, // Cho phép sheet điều chỉnh chiều cao linh hoạt
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(
              ctx,
            ).viewInsets.bottom, // Chống đè bởi bàn phím
          ),
          child: SingleChildScrollView(
            // [ANTI-OVERFLOW] Bọc scroll cho toàn bộ nội dung
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Indicator
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // VIBRANT ICON
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_person_rounded,
                      color: Color(0xFF3B82F6),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // TIÊU ĐỀ [ANTI-OVERFLOW: maxLines + ellipsis]
                  Text(
                    "sidebar.login_required_title".tr(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // MÔ TẢ [ANTI-OVERFLOW: Flexible + Scrollable Text if needed]
                  Text(
                    "sidebar.sync_description".tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                    // Không giới hạn maxLines ở đây vì đã có SingleChildScrollView bọc ngoài
                  ),
                  const SizedBox(height: 32),

                  // BENTO ACTION BUTTONS
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                    ), // Giới hạn chiều ngang trên Tablet
                    child: Column(
                      children: [
                        SmartActionButton(
                          text: 'sidebar.btn_login'.tr(),
                          icon: Icons.login_rounded,
                          color: const Color(0xFF3B82F6),
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.pushNamed(context, AppRoutes.login);
                          },
                        ),
                        const SizedBox(height: 12),
                        SmartActionButton(
                          text: 'sidebar.btn_later'.tr(),
                          isGlass: true,
                          textColor: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.color,
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
