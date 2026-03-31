import 'package:flutter/material.dart';

class Appearance {
  const Appearance({
    required this.background,
    required this.surface,
    required this.surfaceStrong,
    required this.border,
    required this.primary,
    required this.primarySoft,
    required this.textHigh,
    required this.textMid,
    required this.textLow,
    required this.success,
    required this.warning,
    required this.error,
  });

  final Color background;
  final Color surface;
  final Color surfaceStrong;
  final Color border;
  final Color primary;
  final Color primarySoft;
  final Color textHigh;
  final Color textMid;
  final Color textLow;
  final Color success;
  final Color warning;
  final Color error;

  factory Appearance.defaultAppearance() {
    return const Appearance(
      background: Color(0xFF07111A),
      surface: Color(0xFF10202D),
      surfaceStrong: Color(0xFF173243),
      border: Color(0xFF2A4B5F),
      primary: Color(0xFF44D7B6),
      primarySoft: Color(0xFF173E40),
      textHigh: Color(0xFFF3FAFF),
      textMid: Color(0xFFB1C6D3),
      textLow: Color(0xFF7F9AAA),
      success: Color(0xFF3DDC97),
      warning: Color(0xFFFFC857),
      error: Color(0xFFFF6B6B),
    );
  }
}
