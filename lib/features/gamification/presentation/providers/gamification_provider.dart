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

  GamificationProvider() {
    _initBadges();
  }

  void _initBadges() {
    final box = Hive.box(_boxName);
    // Lấy danh sách ID huy hiệu đã mở khóa từ Hive (mặc định là rỗng)
    List<String> unlockedIds = box.get('unlocked_badges', defaultValue: <String>[])?.cast<String>() ?? [];

    // Cấu hình danh sách Huy hiệu mặc định
    _badges = [
      BadgeModel(id: 'first_blood', title: 'Khởi đầu', description: 'Hoàn thành bài học đầu tiên', icon: Icons.local_fire_department, isUnlocked: unlockedIds.contains('first_blood')),
      BadgeModel(id: 'flawless', title: 'Hoàn hảo', description: 'Đạt điểm tuyệt đối 100% trong Quiz', icon: Icons.star, isUnlocked: unlockedIds.contains('flawless')),
      BadgeModel(id: 'scholar', title: 'Học giả', description: 'Hoàn thành 1 Chặng (10 bài)', icon: Icons.school, isUnlocked: unlockedIds.contains('scholar')),
      BadgeModel(id: 'dedication', title: 'Chăm chỉ', description: 'Chuỗi học tập 7 ngày liên tiếp', icon: Icons.calendar_month, isUnlocked: unlockedIds.contains('dedication')),
    ];
    notifyListeners();
  }

  void checkAndUnlockBadges({required int score, required int maxScore, required bool isRoadmap}) {
    _recentlyUnlocked.clear();
    if (!isRoadmap) return;

    try {
      if (score == maxScore && !_isBadgeUnlocked('flawless')) {
        _unlockBadge('flawless');
      }
      if (score >= (maxScore * 0.8) && !_isBadgeUnlocked('first_blood')) {
        _unlockBadge('first_blood');
      }
      
      if (_recentlyUnlocked.isNotEmpty) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Lỗi Gamification: $e');
    }
  }

  bool _isBadgeUnlocked(String id) {
    return _badges.firstWhere((b) => b.id == id).isUnlocked;
  }

  void _unlockBadge(String id) {
    final index = _badges.indexWhere((b) => b.id == id);
    if (index != -1) {
      // 1. Cập nhật state
      _badges[index] = BadgeModel(
        id: _badges[index].id, title: _badges[index].title,
        description: _badges[index].description, icon: _badges[index].icon, isUnlocked: true,
      );
      _recentlyUnlocked.add(_badges[index]);

      // 2. Lưu xuống Hive
      final box = Hive.box(_boxName);
      List<String> unlockedIds = box.get('unlocked_badges', defaultValue: <String>[])?.cast<String>() ?? [];
      unlockedIds.add(id);
      box.put('unlocked_badges', unlockedIds);
    }
  }

  void clearRecentlyUnlocked() {
    _recentlyUnlocked.clear();
  }
}