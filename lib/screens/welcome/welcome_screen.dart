import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../services/theme_manager.dart';
import '../home/main_navigation.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                const Text(
                  "English\nMaster.",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Chào mừng bạn đến với hành trình chinh phục 1500 từ vựng chuyên ngành.",
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 40),
                
                // Ô nhập tên
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Tên của bạn là gì?",
                    hintText: "Nhập tên...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 30),
  
                // Chọn Giao diện
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: _isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
                      const SizedBox(width: 15),
                      const Expanded(child: Text("Giao diện tối", style: TextStyle(fontWeight: FontWeight.bold))),
                      Switch(
                        value: _isDarkMode,
                        onChanged: (value) {
                          setState(() {
                            _isDarkMode = value;
                          });
                          // Preview theme ngay lập tức
                          ThemeManager.updateTheme(value ? 'dark' : 'light');
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 60),
  
                // Nút bắt đầu
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () async {
                      final name = _nameController.text.trim();
  
                      // 1. Kiểm tra Validate
                      if (name.isEmpty) {
                        if (!mounted) return; 
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Vui lòng nhập tên của bạn")),
                        );
                        return; 
                      }
                      final navigator = Navigator.of(context);
                      // 2. Xử lý Logic dữ liệu
                      var settings = DatabaseService.getSettings();
                      settings.userName = name;
                      settings.themeMode = _isDarkMode ? 'dark' : 'light';
                      settings.isFirstRun = false;
                      
                      await DatabaseService.saveSettings(settings); // Async Gap ở đây
  
                      // 4. Dùng biến navigator đã lấy từ trước -> HẾT GẠCH XANH 100%
                      navigator.pushReplacement(
                        MaterialPageRoute(builder: (_) => const MainNavigation()),
                      );
                    },
                   
                    child: const Text("BẮT ĐẦU HỌC", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}