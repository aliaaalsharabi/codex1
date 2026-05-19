import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codex_firebase/l10n/app_localization.dart';
import 'package:codex_firebase/l10n/app_localization_ar.dart';
import 'package:codex_firebase/l10n/app_localization_en.dart';

enum AppLanguage { system, arabic, english }

class Language_Vm extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.system;
  Locale _locale = const Locale('ar');
  AppLocalization _localization = AppLocalizationAR();
  TextDirection _textDirection = TextDirection.rtl;

  AppLanguage get currentLanguage => _currentLanguage;
  Locale get locale => _locale;
  AppLocalization get localization => _localization;
  TextDirection get textDirection => _textDirection;

  // ✅ helper سهل الاستخدام في الشاشات
  bool get isArabic => _textDirection == TextDirection.rtl;

  Language_Vm() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('app_language') ?? 'system';
    switch (saved) {
      case 'arabic':
        await setLanguage(AppLanguage.arabic);
        break;
      case 'english':
        await setLanguage(AppLanguage.english);
        break;
      default:
        await setLanguage(AppLanguage.system);
        break;
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    _currentLanguage = language;
    final prefs = await SharedPreferences.getInstance();

    switch (language) {
      case AppLanguage.system:
      // ✅ يقرأ لغة الجهاز الفعلية بدل افتراض العربي دائماً
        final deviceLocale =
            WidgetsBinding.instance.platformDispatcher.locale;
        final isArabic = deviceLocale.languageCode == 'ar';
        _locale = Locale(deviceLocale.languageCode);
        _localization = isArabic ? AppLocalizationAR() : AppLocalizationEN();
        _textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;
        await prefs.setString('app_language', 'system');
        break;

      case AppLanguage.arabic:
        _locale = const Locale('ar');
        _localization = AppLocalizationAR();
        _textDirection = TextDirection.rtl;
        await prefs.setString('app_language', 'arabic');
        break;

      case AppLanguage.english:
        _locale = const Locale('en');
        _localization = AppLocalizationEN();
        _textDirection = TextDirection.ltr;
        await prefs.setString('app_language', 'english');
        break;
    }
    notifyListeners();
  }
}