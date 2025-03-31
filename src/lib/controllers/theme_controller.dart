import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemePreset {
  final String name;
  final Color accentColor;
  final Color? secondaryColor;
  final IconData icon;

  const ThemePreset({
    required this.name,
    required this.accentColor,
    this.secondaryColor,
    required this.icon,
  });
}

class ThemeController extends GetxController {
  final _storage = GetStorage();
  static const _themeKey = 'theme_mode';
  static const _presetIndexKey = 'preset_index';

  final presets = [
    ThemePreset(
      name: 'TikTok Pink',
      accentColor: const Color(0xFFFF2C55),
      icon: Icons.favorite_rounded,
    ),
    ThemePreset(
      name: 'Ocean Blue',
      accentColor: const Color(0xFF00B4D8),
      icon: Icons.water_rounded,
    ),
    ThemePreset(
      name: 'Emerald',
      accentColor: const Color(0xFF2ECC71),
      icon: Icons.eco_rounded,
    ),
    ThemePreset(
      name: 'Royal Purple',
      accentColor: const Color(0xFF9B59B6),
      icon: Icons.auto_awesome_rounded,
    ),
    ThemePreset(
      name: 'Sunset Orange',
      accentColor: const Color(0xFFE67E22),
      icon: Icons.wb_sunny_rounded,
    ),
    ThemePreset(
      name: 'Neon',
      accentColor: const Color(0xFF39FF14),
      icon: Icons.bolt_rounded,
    ),
    ThemePreset(
      name: 'Cherry Red',
      accentColor: const Color(0xFFE74C3C),
      icon: Icons.local_florist_rounded,
    ),
    ThemePreset(
      name: 'Deep Purple',
      accentColor: const Color(0xFF6C3483),
      icon: Icons.nights_stay_rounded,
    ),
  ];

  final _currentPresetIndex = 0.obs;
  final _themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeSettings();
  }

  void _loadThemeSettings() {
    final savedPresetIndex = _storage.read(_presetIndexKey);
    if (savedPresetIndex != null) {
      _currentPresetIndex.value = savedPresetIndex;
    }

    final savedThemeMode = _storage.read(_themeKey);
    if (savedThemeMode != null) {
      _themeMode.value = ThemeMode.values[savedThemeMode];
    }
    
    Get.changeThemeMode(_themeMode.value);
  }

  Color get accentColor => presets[_currentPresetIndex.value].accentColor;
  ThemeMode get themeMode => _themeMode.value;
  int get currentPresetIndex => _currentPresetIndex.value;

  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    _storage.write(_themeKey, mode.index);
    Get.changeThemeMode(mode);
    update();
  }

  void cycleThemeMode() {
    final modes = ThemeMode.values;
    final currentIndex = modes.indexOf(_themeMode.value);
    final nextIndex = (currentIndex + 1) % modes.length;
    setThemeMode(modes[nextIndex]);
  }

  void setPreset(int index) {
    if (index >= 0 && index < presets.length) {
      _currentPresetIndex.value = index;
      _storage.write(_presetIndexKey, index);
      Get.forceAppUpdate();
      update();
    }
  }

  void nextPreset() {
    setPreset((_currentPresetIndex.value + 1) % presets.length);
  }

  void previousPreset() {
    setPreset((_currentPresetIndex.value - 1 + presets.length) % presets.length);
  }
}
