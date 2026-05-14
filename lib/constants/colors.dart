import 'package:flutter/material.dart';

class TColors {
  TColors._();

  // الألوان الأساسية
  static const Color primary = Color(0xFF5DB1DF);
  static const Color secondry = Color(0xFFFFE24B);
  static const Color accent = Color(0xFFb0c7ff);

  // الألوان العامة
  static const Color white = Color(0xFFffffff);
  static const Color white70 = Color(0xB3ffffff);
  static const Color black = Color(0xFF232323);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF939393);
  static const Color darkerGrey = Color(0xFF4F4F4F);  // ✅ أضيفي هذا السطر
  static const Color darkergrey = Color(0xFF4F4F4F);  // ✅ أضيفي هذا السطر (للتوافق)

  // ألوان الحالة
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // ألوان النص
  static const Color textprimary = Color(0xFF333333);
  static const Color textsecondry = Color(0xFF6C757D);
  static const Color textwhite = Colors.white;

  // ألوان الخلفية
  static const Color light = Color(0xFFF6F6F6);
  static const Color dark = Color(0xFF272727);
  static const Color primaryBackground = Color(0xFFF3F5FF);
  static const Color lightContainer = Color(0xFFF6F6F6);
  static Color darkContainer = TColors.white.withOpacity(0.1);

  // ألوان الأزرار
  static const Color buttonPrimary = Color(0xFF4b68ff);
  static const Color buttonSecondary = Color(0xFF6C757D);
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  // ألوان الحدود
  static const Color borderPrimary = Color(0xFFD9D9D9);
  static const Color borderSecondary = Color(0xFFE6E6E6);

  // تدرج لوني
  static const Gradient linearGradient = LinearGradient(
    begin: Alignment(0.0, 0.0),
    end: Alignment(0.707, -0.707),
    colors: [Color(0xffff9a9e), Color(0xfffad0c4), Color(0xfffad0c4)],
  );

  // ألوان إضافية
  static const Color green = Colors.green;
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);
}