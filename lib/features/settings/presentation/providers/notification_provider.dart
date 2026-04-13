// Đường dẫn: lib/features/settings/presentation/providers/notification_provider.dart

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../data/services/notify/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  bool _hasPermission = false;
  bool get hasPermission => _hasPermission;

  // Lấy dữ liệu từ Service hệ thống của bạn
  bool get isEnabled => NotificationService.instance.isEnabled.value;
  TimeOfDay? get reminderTime => NotificationService.instance.reminderTime.value;

  NotificationProvider() {
    checkPermission();
  }

  Future<void> checkPermission() async {
    final status = await Permission.notification.status;
    _hasPermission = status.isGranted;
    notifyListeners();
  }

  Future<void> toggleNotification(bool value) async {
    await NotificationService.instance.toggleNotification(value);
    notifyListeners();
  }

  Future<void> updateReminderTime(TimeOfDay time) async {
    await NotificationService.instance.updateReminderTime(time);
    notifyListeners();
  }
}