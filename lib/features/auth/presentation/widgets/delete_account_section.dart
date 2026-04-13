import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/utils/status_navigator.dart';
import 'package:fm_dictionary/features/auth/presentation/providers/auth_provider.dart';

Widget buildDangerZoneBento(
  BuildContext context,
  AuthProvider provider,
  bool isDark,
) {
  return OutlinedButton.icon(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.red,
      padding: const EdgeInsets.all(16),
      side: const BorderSide(color: Colors.red, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    icon: const Icon(CupertinoIcons.trash),
    label: const Text(
      "Xóa tài khoản",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
    onPressed: () => _handleDeleteAccount(context, provider, isDark),
  );
}

// --- LOGIC XÓA TÀI KHOẢN ---
Future<void> _handleDeleteAccount(
  BuildContext context,
  AuthProvider provider,
  bool isDark,
) async {
  // 1. Hỏi XÁC NHẬN lần 1
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Xóa tài khoản', style: TextStyle(color: Colors.red)),
      content: const Text(
        'Hành động này không thể hoàn tác. Toàn bộ dữ liệu của bạn sẽ bị xóa vĩnh viễn.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Xóa', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  if (confirm != true || !context.mounted) return;

  // 2. Hỏi MẬT KHẨU
  final passwordController = TextEditingController();
  final password = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Xác nhận mật khẩu"),
      content: TextField(
        controller: passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: "Nhập mật khẩu",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text("Hủy"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(ctx, passwordController.text),
          child: const Text("Xác nhận", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  if (password == null || password.isEmpty || !context.mounted) return;

  // 3. THỰC HIỆN XÓA TÀI KHOẢN
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    await provider.deleteAccount(password);
    if (!context.mounted) return;

    Navigator.of(context, rootNavigator: true).pop(); // Tắt Loading

    // 4. CHUYỂN SANG MÀN HÌNH FEEDBACK CHUNG (Generic Status Screen)
    StatusNavigator.showSuccess(
      context,
      title: "Đã xóa tài khoản",
      message: "Tài khoản và dữ liệu của bạn đã được xóa thành công. Tạm biệt!",
      // Khi ấn "Hoàn tất" nó sẽ tự động bay về trang Login!
    );
  } catch (e) {
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Tắt Loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
    );
  }
}
