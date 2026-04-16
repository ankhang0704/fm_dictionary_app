import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BadgeModel {
  final String id;
  final String title;
  final String description;
  final IconData icon; 
  final bool isUnlocked;

  BadgeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
  });
}

class GamificationProvider extends ChangeNotifier {
  static const String _boxName = 'gamification_box';
  
  List<BadgeModel> _badges = [];
  List<BadgeModel> get badges => _badges;

  final List<BadgeModel> _recentlyUnlocked = [];
  List<BadgeModel> get recentlyUnlocked => _recentlyUnlocked;

  bool _isInitialized = false;

  GamificationProvider() {
    _initBadges();
  }

  Future<void> _initBadges() async {
    try {
      // 1. Kiểm tra và mở Box nếu chưa mở
      Box box;
      if (!Hive.isBoxOpen(_boxName)) {
        box = await Hive.openBox(_boxName);
      } else {
        box = Hive.box(_boxName);
      }

      // 2. Lấy dữ liệu
      List<String> unlockedIds = box.get('unlocked_badges', defaultValue: <String>[])?.cast<String>() ?? [];

      // 3. Setup danh sách
      _badges = [
        BadgeModel(id: 'first_blood', title: 'Khởi đầu', description: 'Hoàn thành bài học đầu tiên', icon: Icons.local_fire_department, isUnlocked: unlockedIds.contains('first_blood')),
        BadgeModel(id: 'flawless', title: 'Hoàn hảo', description: 'Đạt điểm tuyệt đối 100% trong Quiz', icon: Icons.star, isUnlocked: unlockedIds.contains('flawless')),
        BadgeModel(id: 'scholar', title: 'Học giả', description: 'Hoàn thành 1 Chặng (10 bài)', icon: Icons.school, isUnlocked: unlockedIds.contains('scholar')),
        BadgeModel(id: 'dedication', title: 'Chăm chỉ', description: 'Chuỗi học tập 7 ngày liên tiếp', icon: Icons.calendar_month, isUnlocked: unlockedIds.contains('dedication')),
      ];
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi khởi tạo Gamification Hive: $e');
    }
  }

 void checkAndUnlockBadges({
    required int score,
    required int maxScore,
    required bool isRoadmap,
  }) async {
    if (!isRoadmap || !_isInitialized) return;
    _recentlyUnlocked.clear();

    try {
      if (score == maxScore && !_isBadgeUnlocked('flawless')) {
        await _unlockBadge('flawless');
      }
      if (score >= (maxScore * 0.8) && !_isBadgeUnlocked('first_blood')) {
        await _unlockBadge('first_blood');
      }

      if (_recentlyUnlocked.isNotEmpty) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Lỗi Gamification Check: $e');
    }
  }

  bool _isBadgeUnlocked(String id) {
    if (_badges.isEmpty) return false;
    return _badges
        .firstWhere(
          (b) => b.id == id,
          orElse: () =>
              BadgeModel(id: '', title: '', description: '', icon: Icons.error),
        )
        .isUnlocked;
  }

  Future<void> _unlockBadge(String id) async {
    final index = _badges.indexWhere((b) => b.id == id);
    if (index != -1) {
      // 1. Cập nhật State
      _badges[index] = BadgeModel(
        id: _badges[index].id,
        title: _badges[index].title,
        description: _badges[index].description,
        icon: _badges[index].icon,
        isUnlocked: true,
      );
      _recentlyUnlocked.add(_badges[index]);

      // 2. Lưu xuống Hive an toàn
      Box box;
      if (!Hive.isBoxOpen(_boxName)) {
        box = await Hive.openBox(_boxName);
      } else {
        box = Hive.box(_boxName);
      }

      List<String> unlockedIds =
          box
              .get('unlocked_badges', defaultValue: <String>[])
              ?.cast<String>() ??
          [];
      if (!unlockedIds.contains(id)) {
        unlockedIds.add(id);
        await box.put('unlocked_badges', unlockedIds);
      }
    }
  }

  void clearRecentlyUnlocked() {
    _recentlyUnlocked.clear();
  }
}
