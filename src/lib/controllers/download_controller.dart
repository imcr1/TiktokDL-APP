import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/tiktok_service.dart';
import '../models/tiktok_video.dart';

class DownloadController extends GetxController {
  final _tikTokService = TikTokService();
  final _storage = GetStorage();
  final videoInfo = Rxn<TikTokVideo>();
  final history = <TikTokVideo>[].obs;
  final isLoading = false.obs;
  final downloadProgress = 0.0.obs;
  final isCoverDownloading = false.obs;
  final coverDownloadProgress = 0.0.obs;
  static const _historyKey = 'download_history';

  @override
  void onInit() {
    super.onInit();
    _loadHistory();
  }

  void _loadHistory() {
    try {
      final jsonList = _storage.read<List>(_historyKey) ?? [];
      history.value = jsonList
          .map((json) => TikTokVideo.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('Error loading history: $e');
    }
  }

  void _saveHistory() {
    try {
      final jsonList = history.map((video) => video.toJson()).toList();
      _storage.write(_historyKey, jsonList);
    } catch (e) {
      print('Error saving history: $e');
    }
  }

  Future<void> downloadVideo(String url) async {
    try {
      isLoading.value = true;
      downloadProgress.value = 0.0;

      final video = await _tikTokService.downloadVideo(
        url,
        onProgress: (received, total) {
          if (total != -1) {
            downloadProgress.value = received / total;
          }
        },
      );

      videoInfo.value = video;
      history.insert(0, video);
      _saveHistory();
      Get.snackbar(
        'Success',
        'Video downloaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Colors.black,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      downloadProgress.value = 0.0;
    }
  }

  Future<void> downloadCover(TikTokVideo video) async {
    try {
      isCoverDownloading.value = true;
      coverDownloadProgress.value = 0.0;

      await _tikTokService.downloadCoverImage(
        video,
        onProgress: (received, total) {
          if (total != -1) {
            coverDownloadProgress.value = received / total;
          }
        },
      );

      Get.snackbar(
        'Success',
        'Cover image downloaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Colors.black,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCoverDownloading.value = false;
      coverDownloadProgress.value = 0.0;
    }
  }

  Future<String?> getDownloadPath() async {
    try {
      final downloadPath = await _tikTokService.getDownloadPath();
      if (downloadPath == null) {
        Get.snackbar(
          'Error',
          'Could not access download directory',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      return downloadPath;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not access download directory: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  void clearHistory() {
    history.clear();
    _saveHistory();
  }

  void removeFromHistory(TikTokVideo video) {
    history.remove(video);
    _saveHistory();
  }
}
