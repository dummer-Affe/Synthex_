import 'package:flutter/material.dart';

import '../app_states/app_settings.dart';

class AppColors {
  AppColors._();

  static Color get containerL0 => AppSettings.instance.appearance.background;
  static Color get containerL1 => AppSettings.instance.appearance.surface;
  static Color get containerL2 => AppSettings.instance.appearance.surfaceStrong;
  static Color get strokeDefault => AppSettings.instance.appearance.border;
  static Color get primary => AppSettings.instance.appearance.primary;
  static Color get primarySoft => AppSettings.instance.appearance.primarySoft;
  static Color get textHigh => AppSettings.instance.appearance.textHigh;
  static Color get textMid => AppSettings.instance.appearance.textMid;
  static Color get textLow => AppSettings.instance.appearance.textLow;
  static Color get success => AppSettings.instance.appearance.success;
  static Color get warning => AppSettings.instance.appearance.warning;
  static Color get error => AppSettings.instance.appearance.error;
}
