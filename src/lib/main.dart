import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'controllers/download_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/language_controller.dart';
import 'translations/app_translations.dart';
import 'views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await _requestPermissions();

  Get.put(ThemeController());
  Get.put(DownloadController());
  Get.put(LanguageController());

  runApp(const MyApp());
}

Future<void> _requestPermissions() async {
  if (Platform.isAndroid) {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    if (deviceInfo.version.sdkInt <= 32) {
      await Permission.storage.request();
    } else {
      await Permission.photos.request();
      await Permission.videos.request();
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    
    return GetBuilder<ThemeController>(
      builder: (themeController) => GetMaterialApp(
        title: 'TikTok Downloader',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(Brightness.light, themeController.accentColor),
        darkTheme: _buildTheme(Brightness.dark, themeController.accentColor),
        themeMode: themeController.themeMode,
        translations: AppTranslations(),
        locale: languageController.locale,
        fallbackLocale: const Locale('en', 'US'),
        home: const SplashView(),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness, Color accentColor) {
    final isDark = brightness == Brightness.dark;
    final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();

    return baseTheme.copyWith(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: brightness,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.vt323(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.vt323(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
        titleLarge: GoogleFonts.vt323(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        titleMedium: GoogleFonts.vt323(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
        titleSmall: GoogleFonts.vt323(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
