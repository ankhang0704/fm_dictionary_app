// lib/features/settings/presentation/providers/notification_provider.dart

import 'package:flutter/material.dart';
import '../../../../data/services/notify/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService.instance;

  NotificationProvider() {
    // Lắng nghe sự thay đổi từ Service để notify cho UI
    _service.isEnabled.addListener(_onServiceUpdate);
    _service.reminderTime.addListener(_onServiceUpdate);
  }

  // Getters lấy dữ liệu từ Service
  bool get isEnabled => _service.isEnabled.value;
  TimeOfDay? get reminderTime => _service.reminderTime.value;

  void _onServiceUpdate() {
    notifyListeners();
  }

  // Hàm bật/tắt thông báo
  Future<void> toggleNotification(bool value) async {
    await _service.toggleNotification(value);
    // notifyListeners() sẽ được gọi tự động qua listener ở constructor
  }

  // Hàm cập nhật giờ nhắc
  Future<void> updateReminderTime(TimeOfDay time) async {
    await _service.updateReminderTime(time);
    // notifyListeners() sẽ được gọi tự động qua listener ở constructor
  }

  @override
  void dispose() {
    // Hủy lắng nghe khi provider bị hủy để tránh rò rỉ bộ nhớ
    _service.isEnabled.removeListener(_onServiceUpdate);
    _service.reminderTime.removeListener(_onServiceUpdate);
    super.dispose();
  }
}