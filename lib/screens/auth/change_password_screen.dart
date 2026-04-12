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
  final _confirmPass = TextEditingController(); // Thêm mới

  void _handleUpdate() async {
    final oldP = _oldPass.text.trim();
    final newP = _newPass.text.trim();
    final confP = _confirmPass.text.trim();

    // 1. Kiểm tra trống
    if (oldP.isEmpty || newP.isEmpty || confP.isEmpty) {
      _showMsg("Vui lòng nhập đầy đủ các trường");
      return;
    }

    // 2. Kiểm tra độ dài
    if (newP.length < 6) {
      _showMsg("Mật khẩu mới phải từ 6 ký tự trở lên");
      return;
    }

    // 3. Kiểm tra trùng khớp (Xác nhận mật khẩu)
    if (newP != confP) {
      _showMsg("Xác nhận mật khẩu không khớp");
      return;
    }

    // 4. Kiểm tra mật khẩu mới không được trùng mật khẩu cũ (Tùy chọn bảo mật)
    if (oldP == newP) {
      _showMsg("Mật khẩu mới không được giống mật khẩu cũ");
      return;
    }

    try {
      await AuthSyncService.instance.changePassword(
        currentPassword: oldP,
        newPassword: newP,
      );

      if (!mounted) return;
      _showMsg("Đã đổi mật khẩu thành công!");
      Navigator.pop(context);
    } catch (e) {
      _showMsg(e.toString().replaceAll("Exception: ", ""));
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
            TextField(
              controller: _confirmPass,
              decoration: const InputDecoration(
                labelText: "Nhập lại mật khẩu mới",
              ),
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
