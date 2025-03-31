import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:open_file/open_file.dart';
import '../controllers/download_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/language_controller.dart';

class SettingsView extends GetView<ThemeController> {
  SettingsView({super.key}) {
    downloadController = Get.find<DownloadController>();
    languageController = Get.find<LanguageController>();
  }

  late final DownloadController downloadController;
  late final LanguageController languageController;

  Future<void> _openDownloadsFolder() async {
    try {
      final path = await downloadController.getDownloadPath();
      if (path != null) {
        if (Platform.isWindows) {
          await Process.run('explorer', [path]);
        } else {
          await OpenFile.open(path);
        }
      } else {
        Get.snackbar(
          'error'.tr,
          'download_path_not_set'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'could_not_open_folder'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        centerTitle: true,
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              title: Text(
                'theme_mode'.tr,
                style: context.textTheme.titleMedium,
              ),
              trailing: IconButton(
                icon: Icon(
                  controller.themeMode == ThemeMode.light
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  color: controller.accentColor,
                ),
                onPressed: controller.cycleThemeMode,
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'color_themes'.tr,
                style: context.textTheme.titleMedium,
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: controller.presets.length,
                itemBuilder: (context, index) {
                  final preset = controller.presets[index];
                  final isSelected = index == controller.currentPresetIndex;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () => controller.setPreset(index),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 80,
                        decoration: BoxDecoration(
                          color: preset.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? preset.accentColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              preset.icon,
                              color: preset.accentColor,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              preset.name,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: preset.accentColor,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                'language'.tr,
                style: context.textTheme.titleMedium,
              ),
              trailing: TextButton.icon(
                onPressed: languageController.toggleLanguage,
                icon: Icon(
                  Icons.language,
                  color: controller.accentColor,
                ),
                label: Text(
                  languageController.currentLanguage,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: controller.accentColor,
                  ),
                ),
              ),
            ),
            const Divider(),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.folder,
                  color: controller.accentColor,
                ),
                title: Text(
                  'downloads_folder'.tr,
                  style: context.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'open_downloads'.tr,
                  style: context.textTheme.bodyMedium,
                ),
                onTap: _openDownloadsFolder,
              ),
            ).animate().fadeIn().slideX(),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.info,
                  color: controller.accentColor,
                ),
                title: Text(
                  'about'.tr,
                  style: context.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'version'.tr,
                  style: context.textTheme.bodyMedium,
                ),
              ),
            ).animate().fadeIn().slideX(delay: 100.ms),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.person,
                  color: controller.accentColor,
                ),
                title: Text(
                  'developer'.tr,
                  style: context.textTheme.bodyLarge,
                ),
                subtitle: const Text(
                  'Hassan Al-Naham',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                onTap: () => launchUrlString(
                  'https://www.instagram.com/cr1/',
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ).animate().fadeIn().slideX(delay: 200.ms),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.code,
                  color: controller.accentColor,
                ),
                title: Text(
                  'source_code'.tr,
                  style: context.textTheme.bodyLarge,
                ),
                subtitle: Text(
                  'view_github'.tr,
                  style: context.textTheme.bodyMedium,
                ),
                onTap: () => launchUrlString(
                  'https://github.com/imcr1',
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ).animate().fadeIn().slideX(delay: 300.ms),
          ],
        ),
      ),
    );
  }
}
