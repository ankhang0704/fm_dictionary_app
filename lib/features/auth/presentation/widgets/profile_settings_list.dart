// =======================================================================
// 2. BENTO SETTINGS (ĐỔI MẬT KHẨU, NGÀY THAM GIA)
// =======================================================================
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/features/auth/presentation/screens/change_password_screen.dart';

Widget buildSettingsBento(BuildContext context, user) {
  // Format ngày tham gia
  final joinDate = user.metadata.creationTime != null
      ? DateFormat('dd/MM/yyyy').format(user.metadata.creationTime!)
      : '--/--/----';

  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      children: [
        ListTile(
          leading: const Icon(CupertinoIcons.lock),
          title: const Text("Đổi mật khẩu"),
          trailing: const Icon(CupertinoIcons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
          ),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(CupertinoIcons.calendar),
          title: const Text("Ngày tham gia"),
          trailing: Text(
            joinDate,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
