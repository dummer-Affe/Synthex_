import 'package:flutter/material.dart';

import '../app_states/app_settings.dart';

class AppColors {
  AppColors._();

  static Color get background => AppSettings.instance.appearance.background;
  static Color get surface => AppSettings.instance.appearance.surface;
  static Color get surfaceContainer =>
      AppSettings.instance.appearance.surfaceContainer;
  static Color get surfaceContainerLow =>
      AppSettings.instance.appearance.surfaceContainerLow;
  static Color get surfaceContainerHigh =>
      AppSettings.instance.appearance.surfaceContainerHigh;
  static Color get surfaceContainerHighest =>
      AppSettings.instance.appearance.surfaceContainerHighest;
  static Color get outline => AppSettings.instance.appearance.outline;
  static Color get outlineVariant =>
      AppSettings.instance.appearance.outlineVariant;
  static Color get primary => AppSettings.instance.appearance.primary;
  static Color get primaryContainer =>
      AppSettings.instance.appearance.primaryContainer;
  static Color get primaryGlow => AppSettings.instance.appearance.primaryGlow;
  static Color get onPrimary => AppSettings.instance.appearance.onPrimary;
  static Color get onSurface => AppSettings.instance.appearance.onSurface;
  static Color get onSurfaceVariant =>
      AppSettings.instance.appearance.onSurfaceVariant;
  static Color get success => AppSettings.instance.appearance.success;
  static Color get warning => AppSettings.instance.appearance.warning;
  static Color get error => AppSettings.instance.appearance.error;
  static Color get errorContainer =>
      AppSettings.instance.appearance.errorContainer;
  static Color get onError => AppSettings.instance.appearance.onError;

  static Color get containerL0 => background;
  static Color get containerL1 => surfaceContainer;
  static Color get containerL2 => surfaceContainerHigh;
  static Color get strokeDefault => outlineVariant;
  static Color get primarySoft => primaryContainer;
  static Color get textHigh => onSurface;
  static Color get textMid => onSurfaceVariant;
  static Color get textLow => outline;
}
