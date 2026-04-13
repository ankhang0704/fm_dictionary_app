// Đường dẫn: lib/core/utils/status_navigator.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/generic_status_screen.dart';

class StatusNavigator {
  // 1. Màn hình xác thực Email (Thay thế EmailVerificationScreen)
  static void showEmailVerification(BuildContext context, String email) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GenericStatusScreen(
          icon: CupertinoIcons.mail,
          themeColor: Colors.blue,
          title: "Xác thực Email",
          subTitle: "Chúng tôi đã gửi một liên kết xác thực đến:\n$email\n\nVui lòng kiểm tra hộp thư (bao gồm cả mục Spam).",
          primaryButtonLabel: "Quay lại Đăng nhập",
          onPrimaryPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
    );
  }

  // 2. Màn hình Thành công chung (Đổi mật khẩu, Xóa tài khoản, v.v)
  static void showSuccess(BuildContext context, {required String title, required String message, VoidCallback? onDone}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GenericStatusScreen(
          icon: CupertinoIcons.checkmark_seal_fill,
          themeColor: Colors.green,
          title: title,
          subTitle: message,
          primaryButtonLabel: "Hoàn tất",
          onPrimaryPressed: onDone ?? () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
    );
  }
}