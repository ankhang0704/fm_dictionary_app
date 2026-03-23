import 'package:flutter/material.dart';
import '../screens/search/search_screen.dart'; // Đảm bảo đường dẫn này đúng với thư mục của bạn

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Khi bấm vào thanh search, nhảy sang màn hình Search chuyên dụng
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      },
      child: Hero(
        tag: 'search_hero',
        // Hiệu ứng "bay" mượt mà giữa 2 màn hình
        flightShuttleBuilder: (_, animation, _, _, _) {
          return FadeTransition(
            opacity: animation,
            child: Material(
              color: Colors.transparent, // Fix lỗi chữ bị gạch chân vàng khi đang chuyển cảnh
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children:[
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 12),
                    Text('Search 1,500 words...', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              ),
            ),
          );
        },
        // BẮT BUỘC: child của Hero (giao diện hiển thị khi nằm yên ở Dashboard)
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children:[
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 12),
                Text('Search 1,500 words...', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}