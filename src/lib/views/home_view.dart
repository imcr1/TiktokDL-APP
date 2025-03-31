import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/download_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/language_controller.dart';
import '../models/tiktok_video.dart';
import 'settings_view.dart';

class HomeView extends GetView<DownloadController> {
  final urlController = TextEditingController();
  late final DownloadController downloadController;
  late final ThemeController themeController;
  late final LanguageController languageController;

  HomeView({super.key}) {
    downloadController = Get.find<DownloadController>();
    themeController = Get.find<ThemeController>();
    languageController = Get.find<LanguageController>();
  }

  void _handleDownload() async {
    final url = urlController.text.trim();
    if (url.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'please_enter_url'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    await downloadController.downloadVideo(url);
    urlController.clear();
  }

  void _shareVideo(TikTokVideo video) async {
    await Share.shareFiles(
      [video.downloadPath],
      text: video.description,
    );
  }

  void _copyDescription(String description) async {
    await Clipboard.setData(ClipboardData(text: description));
    Get.snackbar(
      'success'.tr,
      'description_copied'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: themeController.themeMode == ThemeMode.light
          ? Colors.blue
          : Colors.deepPurple,
      colorText: Colors.white,
    );
  }

  void _downloadCover(TikTokVideo video) async {
    await downloadController.downloadCover(video);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TikTok Downloader',
          style: GoogleFonts.vt323(
            fontSize: 28,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: themeController.themeMode == ThemeMode.light
                  ? Colors.blue
                  : Colors.deepPurple,
            ),
            onPressed: () => Get.to(() => SettingsView()),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    hintText: 'paste_link'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: themeController.themeMode == ThemeMode.light
                            ? Colors.blue
                            : Colors.deepPurple,
                      ),
                      onPressed: urlController.clear,
                    ),
                  ),
                  textDirection: languageController.isRTL
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                ).animate().fadeIn().slideX(),
                const SizedBox(height: 16),
                Obx(() => ElevatedButton.icon(
                  onPressed: downloadController.isLoading.value
                      ? null
                      : _handleDownload,
                  icon: downloadController.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  label: Text(
                    downloadController.isLoading.value
                        ? '${(downloadController.downloadProgress.value * 100).toInt()}%'
                        : 'download'.tr,
                    style: GoogleFonts.vt323(
                      fontSize: 20,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )).animate().fadeIn().slideX(delay: 100.ms),
                if (downloadController.isLoading.value)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: LinearProgressIndicator(
                      value: downloadController.downloadProgress.value,
                      backgroundColor: themeController.themeMode == ThemeMode.light
                          ? Colors.grey[200]
                          : Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        themeController.themeMode == ThemeMode.light
                            ? Colors.blue
                            : Colors.deepPurple,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (downloadController.history.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: themeController.themeMode == ThemeMode.light
                            ? Colors.blue.withOpacity(0.5)
                            : Colors.deepPurple.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'no_downloads_yet'.tr,
                        style: GoogleFonts.vt323(
                          fontSize: 24,
                          letterSpacing: 1.2,
                          color: themeController.themeMode == ThemeMode.light
                              ? Colors.blue.withOpacity(0.5)
                              : Colors.deepPurple.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().scale();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: downloadController.history.length,
                itemBuilder: (context, index) {
                  final video = downloadController.history[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => OpenFile.open(video.downloadPath),
                      onLongPress: () async {
                        if (video.originalUrl.isEmpty) {
                          Get.snackbar(
                            'error'.tr,
                            'original_url_not_available'.tr,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        await Clipboard.setData(ClipboardData(text: video.originalUrl));
                        Get.snackbar(
                          'success'.tr,
                          'tiktok_url_copied'.tr,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: themeController.themeMode == ThemeMode.light
                              ? Colors.blue
                              : Colors.deepPurple,
                          colorText: Colors.white,
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (video.coverUrl.isNotEmpty)
                            SizedBox(
                              width: 100,
                              height: 180,
                              child: CachedNetworkImage(
                                imageUrl: video.coverUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: themeController.themeMode == ThemeMode.light
                                      ? Colors.grey[200]
                                      : Colors.grey[800],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: themeController.themeMode == ThemeMode.light
                                      ? Colors.grey[200]
                                      : Colors.grey[800],
                                  child: const Center(
                                    child: Icon(Icons.error),
                                  ),
                                ),
                              ),
                            ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    video.description,
                                    style: context.textTheme.bodyLarge,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textDirection: languageController.isRTL
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Wrap(
                                          spacing: 8,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            Text(
                                              video.timestamp.toLocal().toString().split('.')[0],
                                              style: context.textTheme.bodySmall?.copyWith(
                                                color: themeController.themeMode == ThemeMode.light
                                                    ? Colors.blue
                                                    : Colors.deepPurple,
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.touch_app,
                                                  size: 16,
                                                  color: themeController.themeMode == ThemeMode.light
                                                      ? Colors.blue.withOpacity(0.5)
                                                      : Colors.deepPurple.withOpacity(0.5),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'hold_to_copy_url'.tr,
                                                  style: context.textTheme.bodySmall?.copyWith(
                                                    color: themeController.themeMode == ThemeMode.light
                                                        ? Colors.blue.withOpacity(0.5)
                                                        : Colors.deepPurple.withOpacity(0.5),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: downloadController.isCoverDownloading.value
                                            ? Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  CircularProgressIndicator(
                                                    value: downloadController.coverDownloadProgress.value,
                                                    strokeWidth: 2,
                                                  ),
                                                  Icon(
                                                    Icons.download,
                                                    color: themeController.themeMode == ThemeMode.light
                                                        ? Colors.blue
                                                        : Colors.deepPurple,
                                                    size: 16,
                                                  ),
                                                ],
                                              )
                                            : Icon(
                                                Icons.download,
                                                color: themeController.themeMode == ThemeMode.light
                                                    ? Colors.blue
                                                    : Colors.deepPurple,
                                              ),
                                        onPressed: downloadController.isCoverDownloading.value
                                            ? null
                                            : () => downloadController.downloadCover(video),
                                        tooltip: 'download_cover'.tr,
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.share,
                                          color: themeController.themeMode == ThemeMode.light
                                              ? Colors.blue
                                              : Colors.deepPurple,
                                        ),
                                        onPressed: () => _shareVideo(video),
                                        tooltip: 'share_video'.tr,
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.copy,
                                          color: themeController.themeMode == ThemeMode.light
                                              ? Colors.blue
                                              : Colors.deepPurple,
                                        ),
                                        onPressed: () => _copyDescription(video.description),
                                        tooltip: 'copy_description'.tr,
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: themeController.themeMode == ThemeMode.light
                                              ? Colors.red
                                              : Colors.redAccent,
                                        ),
                                        onPressed: () => downloadController.removeFromHistory(video),
                                        tooltip: 'delete_from_history'.tr,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn().slideX(delay: (100 * index).ms);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
