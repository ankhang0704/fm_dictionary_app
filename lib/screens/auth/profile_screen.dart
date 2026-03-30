import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/auth/auth_sync_service.dart';
import '../../services/database/database_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('profile.title'.tr())),
      body: ValueListenableBuilder<User?>(
        valueListenable: AuthSyncService.instance.currentUser,
        builder: (context, user, _) {
          if (user == null) {
            return Center(child: Text('profile.not_logged_in'.tr()));
          }

          final joinDate = user.metadata.creationTime != null 
              ? DateFormat('dd/MM/yyyy').format(user.metadata.creationTime!) 
              : '--';

          return ListView(
            padding: const EdgeInsets.all(24),
            children:[
              CircleAvatar(
                radius: 50,
                backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                child: user.photoURL == null ? const Icon(Icons.person, size: 50) : null,
              ),
              const SizedBox(height: 16),
              Text(user.displayName ?? 'Người dùng', textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(user.email ?? '', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 32),

              // BỌC THỐNG KÊ TRONG VALUELISTENABLE ĐỂ KHÔNG BỊ LAG
              ValueListenableBuilder(
                valueListenable: Hive.box(DatabaseService.progressBoxName).listenable(),
                builder: (context, box, _) {
                  int learned = 0;
                  int review = 0;
                  final now = DateTime.now().millisecondsSinceEpoch;

                  for (var value in box.values) {
                    final map = value as Map;
                    if ((map['s'] ?? 0) >= 4) learned++;
                    if ((map['nr'] ?? 0) <= now && (map['nr'] ?? 0) > 0) review++;
                  }

                  return Row(
                    children:[
                      Expanded(child: _buildStatCard(context, 'profile.learned'.tr(), learned.toString(), Colors.green)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard(context, 'profile.review'.tr(), review.toString(), Colors.orange)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                tileColor: theme.cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.calendar_today),
                title: Text('profile.join_date'.tr()),
                trailing: Text(joinDate, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () => _handleDeleteAccount(context, user),
                child: Text('profile.delete_account'.tr()),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children:[
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(color: color.withValues(alpha: 0.8), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _handleDeleteAccount(BuildContext context, User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('profile.delete_confirm_title'.tr()),
        content: Text('profile.delete_confirm_desc'.tr()),
        actions:[
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Gọi service xóa dữ liệu DB Firebase (nếu cần), sau đó xóa user
      await user.delete();
      await AuthSyncService.instance.signOut();
      if (!context.mounted) return;
      Navigator.pop(context); // Trở về màn hình chính
    } catch (e) {
      if (!context.mounted) return;
      // Lỗi Requires-recent-login
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('profile.delete_error'.tr())));
    }
  }
}