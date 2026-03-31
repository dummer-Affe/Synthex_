import 'package:flutter/material.dart';

class Appearance {
  const Appearance({
    required this.background,
    required this.surface,
    required this.surfaceContainer,
    required this.surfaceContainerLow,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.outline,
    required this.outlineVariant,
    required this.primary,
    required this.primaryContainer,
    required this.primaryGlow,
    required this.onPrimary,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.success,
    required this.warning,
    required this.error,
    required this.errorContainer,
    required this.onError,
  });

  final Color background;
  final Color surface;
  final Color surfaceContainer;
  final Color surfaceContainerLow;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color outline;
  final Color outlineVariant;
  final Color primary;
  final Color primaryContainer;
  final Color primaryGlow;
  final Color onPrimary;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color success;
  final Color warning;
  final Color error;
  final Color errorContainer;
  final Color onError;

  factory Appearance.defaultAppearance() {
    return const Appearance(
      background: Color(0xFF131313),
      surface: Color(0xFF131313),
      surfaceContainer: Color(0xFF201F1F),
      surfaceContainerLow: Color(0xFF1C1B1B),
      surfaceContainerHigh: Color(0xFF2A2A2A),
      surfaceContainerHighest: Color(0xFF353534),
      outline: Color(0xFF8C909F),
      outlineVariant: Color(0xFF424753),
      primary: Color(0xFF387BEB),
      primaryContainer: Color(0xFF4F8EFF),
      primaryGlow: Color(0xFF387BEB),
      onPrimary: Color(0xFFFFFFFF),
      onSurface: Color(0xFFE5E2E1),
      onSurfaceVariant: Color(0xFFC2C6D6),
      success: Color(0xFF4F8EFF),
      warning: Color(0xFFC8C6C4),
      error: Color(0xFFFFB4AB),
      errorContainer: Color(0xFF93000A),
      onError: Color(0xFF690005),
    );
  }
}
