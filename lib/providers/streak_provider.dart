import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class StreakProvider extends ChangeNotifier {
  static const String _boxName = 'user_data_box';
  static const String _streakKey = 'streak_count';
  static const String _lastAccessKey = 'last_access_date';

  int _streakCount = 0;
  int get streakCount => _streakCount;

  DateTime? _lastAccessDate;

  StreakProvider() {
    _initData();
  }

  Future<void> _initData() async {
    try {
      final box = await Hive.openBox(_boxName);
      _streakCount = box.get(_streakKey, defaultValue: 0);
      
      final lastAccessStr = box.get(_lastAccessKey);
      if (lastAccessStr != null) {
        _lastAccessDate = DateTime.parse(lastAccessStr);
      }
      
      // Chạy kiểm tra streak ngay khi khởi tạo
      await checkAndUpdateStreak();
    } catch (e) {
      debugPrint('Lỗi init StreakProvider: $e');
    }
  }

  /// Logic cốt lõi: Kiểm tra và cập nhật Streak
  Future<void> checkAndUpdateStreak() async {
    try {
      final box = await Hive.openBox(_boxName);
      final DateTime now = DateTime.now();
      
      // Đưa về 0h00 để so sánh chuẩn xác theo ngày, bỏ qua giờ/phút
      final DateTime today = DateTime(now.year, now.month, now.day);
      
      if (_lastAccessDate == null) {
        // Lần đầu vào app
        _streakCount = 1;
        _lastAccessDate = today;
      } else {
        final DateTime lastAccess = DateTime(_lastAccessDate!.year, _lastAccessDate!.month, _lastAccessDate!.day);
        final int differenceInDays = today.difference(lastAccess).inDays;

        if (differenceInDays == 0) {
          // Vào lại trong cùng 1 ngày -> Không làm gì
          debugPrint('Streak: User đã truy cập hôm nay, giữ nguyên.');
          return; 
        } else if (differenceInDays == 1) {
          // Vào ngày hôm sau -> Cộng 1
          _streakCount += 1;
          _lastAccessDate = today;
          debugPrint('Streak: +1 ngày liên tiếp!');
        } else if (differenceInDays > 1) {
          // Bỏ lỡ quá 1 ngày -> Reset về 1 (tính cho ngày hôm nay)
          _streakCount = 1;
          _lastAccessDate = today;
          debugPrint('Streak: Bỏ lỡ ngày, reset về 1.');
        }
      }

      // Lưu lại vào Hive
      await box.put(_streakKey, _streakCount);
      await box.put(_lastAccessKey, _lastAccessDate!.toIso8601String());
      
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi checkAndUpdateStreak: $e');
    }
  }

  /// Backdoor để Test: Lùi ngày truy cập cuối về "Hôm qua" rồi chạy hàm check
  Future<void> incrementStreakDebug() async {
    try {
      final box = await Hive.openBox(_boxName);
      final DateTime now = DateTime.now();
      
      // Giả lập: User truy cập lần cuối là ngày hôm qua
      final DateTime fakeYesterday = now.subtract(const Duration(days: 1));
      _lastAccessDate = fakeYesterday;
      
      await box.put(_lastAccessKey, fakeYesterday.toIso8601String());
      debugPrint('DEBUG: Đã set last_access_date về hôm qua. Đang tính lại streak...');
      
      // Chạy lại logic check
      await checkAndUpdateStreak();
    } catch (e) {
      debugPrint('Lỗi incrementStreakDebug: $e');
    }
  }
}