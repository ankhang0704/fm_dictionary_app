import 'package:flutter/material.dart';
import 'package:fm_dictionary/screens/auth/email_verification_screen.dart';
import 'package:fm_dictionary/services/database/database_service.dart';
import '../../services/auth/auth_sync_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final String nameFromHive = DatabaseService.getSettings().userName;
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  void _register() async {
    try {
      await AuthSyncService.instance.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
        name: nameFromHive,
      );
      if (!mounted) return;
       Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(email: _emailController.text.trim()),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng ký")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: TextEditingController(text: nameFromHive),
              decoration: const InputDecoration(labelText: "Họ và Tên"),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: "Mật khẩu"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _register, child: const Text("Đăng ký")),
          ],
        ),
      ),
    );
  }
}
