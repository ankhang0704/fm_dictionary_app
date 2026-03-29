import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';

class RightSideBar extends StatefulWidget {
  const RightSideBar({super.key});

  @override
  State<RightSideBar> createState() => _RightSideBarState();
}

class _RightSideBarState extends State<RightSideBar> {
  bool _hasNotificationPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.notification.status;
    setState(() => _hasNotificationPermission = status.isGranted);
  }

  Future<void> _requestPermission() async {
    final status = await Permission.notification.request();
    setState(() => _hasNotificationPermission = status.isGranted);
    if (status.isPermanentlyDenied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('calendar.permission_denied'.tr()),
          action: SnackBarAction(label: 'Cài đặt', onPressed: () => openAppSettings()),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children:[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('calendar.title'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            CalendarDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onDateChanged: (date) {},
            ),
            const Divider(),
            
            // Khu vực Thông báo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  Text('calendar.notifications'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  Switch(
                    value: _hasNotificationPermission,
                    onChanged: (val) {
                      if (val) {
                        _requestPermission();
                      } else {
                        openAppSettings(); // iOS/Android 13+ không cho tắt quyền qua app, phải mở Cài đặt
                      }
                    },
                  )
                ],
              ),
            ),
            
            Expanded(
              child: _hasNotificationPermission 
                ? ListView(
                    children:[
                      ListTile(
                        leading: const Icon(Icons.notifications_active, color: Colors.orange),
                        title: Text('calendar.notification_1'.tr()),
                        subtitle: const Text("10 mins ago"),
                      ),
                    ],
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text('calendar.turn_on_notify'.tr(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                    ),
                  ),
            )
          ],
        ),
      ),
    );
  }
}