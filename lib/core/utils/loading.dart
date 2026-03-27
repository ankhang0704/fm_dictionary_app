// lib/core/utils/loading_manager.dart
import 'package:flutter/material.dart';

class LoadingManager {
  static final ValueNotifier<bool> isLoading = ValueNotifier(false);

  static void show() => isLoading.value = true;
  static void hide() => isLoading.value = false;
}
