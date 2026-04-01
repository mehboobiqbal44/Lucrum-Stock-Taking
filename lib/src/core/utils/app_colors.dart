import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const primary = Color(0xFF16A085);
  static const primaryLight = Color(0xFFE8F6F3);
  static const primaryDark = Color(0xFF138D75);

  // Semantic
  static const infoBg = Color(0xFFD6EAF8);
  static const infoText = Color(0xFF3498DB);
  static const successBg = Color(0xFFE8F8F5);
  static const successText = Color(0xFF27AE60);
  static const warningBg = Color(0xFFFEF5E7);
  static const warningText = Color(0xFFF39C12);
  static const errorBg = Color(0xFFFADBD8);
  static const errorText = Color(0xFFE74C3C);

  // Surfaces
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF8F9FA);

  // Text
  static const textHigh = Color(0xFF2D3436);
  static const textMedium = Color(0xFF636E72);
  static const textLow = Color(0xFF95A5A6);

  // Border
  static const border = Color(0xFFDFE6E9);

  // Shadows
  static const shadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  static const shadowLg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 30,
      offset: Offset(0, 10),
    ),
  ];
}
