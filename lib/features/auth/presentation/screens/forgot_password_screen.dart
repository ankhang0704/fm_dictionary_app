// Đường dẫn: lib/features/auth/presentation/screens/forgot_password_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../../core/utils/status_navigator.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  void _handleReset(BuildContext context) async {
    if (_emailController.text.trim().isEmpty) return;

    final provider = context.read<AuthProvider>();
    try {
      await provider.resetPassword(_emailController.text.trim());
      if (!context.mounted) return;
      
      StatusNavigator.showSuccess(
        context, 
        title: "Đã gửi Email", 
        message: "Vui lòng kiểm tra hòm thư của bạn để tiến hành khôi phục mật khẩu."
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Khôi phục mật khẩu")),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (auth.isLoading) return const Center(child: CircularProgressIndicator());

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
               padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(CupertinoIcons.question_circle, size: 60, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  const Text(
                    "Đừng lo lắng! Nhập email của bạn và chúng tôi sẽ gửi liên kết đặt lại mật khẩu.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email đăng ký",
                      prefixIcon: const Icon(CupertinoIcons.mail),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    onPressed: () => _handleReset(context),
                    child: const Text("Gửi yêu cầu"),
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