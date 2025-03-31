import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  final _storage = GetStorage();
  static const _languageKey = 'language_code';
  static const _countryKey = 'country_code';

  final languages = [
    {'name': 'English', 'code': 'en', 'country': 'US'},
    {'name': 'العربية', 'code': 'ar', 'country': 'SA'},
  ];

  var _locale = const Locale('en', 'US').obs;

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  void _loadLanguage() {
    final languageCode = _storage.read(_languageKey);
    final countryCode = _storage.read(_countryKey);

    if (languageCode != null) {
      _locale.value = Locale(languageCode, countryCode);
      Get.updateLocale(_locale.value);
    }
  }

  Locale get locale => _locale.value;
  String get currentLanguage => _locale.value.languageCode == 'ar' ? 'العربية' : 'English';
  bool get isRTL => _locale.value.languageCode == 'ar';

  void changeLanguage(String languageCode, String countryCode) {
    final locale = Locale(languageCode, countryCode);
    _storage.write(_languageKey, languageCode);
    _storage.write(_countryKey, countryCode);
    _locale.value = locale;
    Get.updateLocale(locale);
    update();
  }

  void toggleLanguage() {
    if (_locale.value.languageCode == 'en') {
      changeLanguage('ar', 'SA');
    } else {
      changeLanguage('en', 'US');
    }
  }
}
