// Đường dẫn: lib/features/auth/presentation/screens/change_password_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../../core/utils/status_navigator.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPass = TextEditingController();
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();

  void _handleUpdate(BuildContext context) async {
    final oldP = _oldPass.text.trim();
    final newP = _newPass.text.trim();
    final confP = _confirmPass.text.trim();

    if (oldP.isEmpty || newP.isEmpty || confP.isEmpty) return _showMsg("Vui lòng nhập đầy đủ");
    if (newP.length < 6) return _showMsg("Mật khẩu mới phải từ 6 ký tự trở lên");
    if (newP != confP) return _showMsg("Xác nhận mật khẩu không khớp");

    final provider = context.read<AuthProvider>();
    try {
      await provider.changePassword(oldP, newP);
      if (!context.mounted) return;
      
      // Nhiệm vụ 4: Điều hướng màn hình Feedback chung
      StatusNavigator.showSuccess(
        context, 
        title: "Thành công!", 
        message: "Mật khẩu của bạn đã được thay đổi an toàn."
      );
    } catch (e) {
      _showMsg(e.toString());
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đổi mật khẩu")),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (auth.isLoading) return const Center(child: CircularProgressIndicator());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(CupertinoIcons.lock_shield, size: 60, color: Colors.orange),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _oldPass,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Mật khẩu hiện tại", border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newPass,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Mật khẩu mới", border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPass,
                    obscureText: true,
                    decoration: InputDecoration(labelText: "Xác nhận mật khẩu mới", border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () => _handleUpdate(context),
                    child: const Text("Cập nhật mật khẩu"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}