import 'package:flutter/material.dart';
import '../../services/auth/auth_sync_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPass = TextEditingController();
  final _newPass = TextEditingController();
  
 void _handleUpdate() async {
    // Kiểm tra cơ bản
    if (_newPass.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu mới phải từ 6 ký tự trở lên")),
      );
      return;
    }

    try {
      // Gọi hàm đổi mật khẩu đã có Re-auth ở Bước 1
      await AuthSyncService.instance.changePassword(
        currentPassword: _oldPass.text.trim(),
        newPassword: _newPass.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã đổi mật khẩu thành công!")),
      );
      Navigator.pop(context);
    } catch (e) {
      // Hiển thị lỗi từ hàm _handleAuthError (Ví dụ: sai mật khẩu cũ)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đổi mật khẩu")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _oldPass,
              decoration: const InputDecoration(labelText: "Mật khẩu hiện tại"),
              obscureText: true,
            ),
            TextField(
              controller: _newPass,
              decoration: const InputDecoration(labelText: "Mật khẩu mới"),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _handleUpdate,
              child: const Text("Cập nhật mật khẩu"),
            ),
          ],
        ),
      ),
    );
  }
}
