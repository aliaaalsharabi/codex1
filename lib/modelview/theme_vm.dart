import 'package:flutter/material.dart';

class Theme_Vm extends ChangeNotifier {
  // الوضع الافتراضي هو الفاتح
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // دالة لتبديل الوضع
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // إشعار كل الواجهات بالتغيير
  }
}