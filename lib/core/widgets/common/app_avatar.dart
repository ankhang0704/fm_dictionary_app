// lib/core/widgets/common/app_avatar.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppAvatar extends StatelessWidget {
  final String? localPath;
  final String? networkUrl;
  final double radius;

  const AppAvatar({super.key, this.localPath, this.networkUrl, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    // Logic của bạn: Kiểm tra file tồn tại
    final bool hasLocalPhoto = localPath != null && File(localPath!).existsSync();

    ImageProvider? image;
    if (hasLocalPhoto) {
      image = FileImage(File(localPath!));
    } else if (networkUrl != null && networkUrl!.isNotEmpty) {
      image = NetworkImage(networkUrl!);
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blue.withOpacity(0.1),
      backgroundImage: image,
      child: image == null 
        ? Icon(CupertinoIcons.person, size: radius * 0.8, color: Colors.blue) 
        : null,
    );
  }
}