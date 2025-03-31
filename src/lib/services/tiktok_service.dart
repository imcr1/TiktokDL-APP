import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:media_scanner/media_scanner.dart';
import '../models/tiktok_video.dart';

typedef ProgressCallback = void Function(int received, int total);

class TikTokService {
  final _dio = Dio();
  final _cookieJar = CookieJar();

  TikTokService() {
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  Future<TikTokVideo> downloadVideo(String url, {ProgressCallback? onProgress}) async {
    try {
      // Clean up and format the URL
      var cleanUrl = url.trim();
      if (!cleanUrl.startsWith('http')) {
        cleanUrl = 'https://$cleanUrl';
      }
      print('Downloading video from URL: $cleanUrl'); // Debug print

      // Get the HTML content of the TikTok page
      final response = await _dio.get(cleanUrl);
      final html = response.data.toString();

      // Extract video URL using regex
      final videoUrlMatch = RegExp(r'"playAddr":"([^"]+)"').firstMatch(html);
      if (videoUrlMatch == null) {
        throw Exception('Could not find video URL');
      }
      final videoUrl = videoUrlMatch.group(1)?.replaceAll(r'\u002F', '/');
      if (videoUrl == null) {
        throw Exception('Invalid video URL format');
      }

      // Extract description using regex, handle case where description might not exist
      String description = '';
      final descMatch = RegExp(r'"desc":"([^"]*)"').firstMatch(html);
      if (descMatch != null && descMatch.group(1) != null) {
        description = descMatch.group(1)!.replaceAll(r'\u002F', '/');
      }

      // Extract cover image URL, handle case where it might not exist
      String coverUrl = '';
      final coverMatch = RegExp(r'"cover":"([^"]+)"').firstMatch(html);
      if (coverMatch != null && coverMatch.group(1) != null) {
        coverUrl = coverMatch.group(1)!.replaceAll(r'\u002F', '/');
      }

      // Create download path
      final downloadPath = await getDownloadPath();
      if (downloadPath == null) {
        throw Exception('Could not access download directory');
      }

      // Generate unique filename using timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final videoPath = '$downloadPath/tiktok_$timestamp.mp4';

      // Download the video
      await _downloadFile(videoUrl, videoPath, onProgress: onProgress);

      // Scan media to make it visible in gallery
      if (Platform.isAndroid) {
        await MediaScanner.loadMedia(path: videoPath);
      }

      final video = TikTokVideo(
        downloadPath: videoPath,
        description: description.isNotEmpty ? description : 'No description',
        coverUrl: coverUrl,
        originalUrl: cleanUrl, // Use the cleaned URL
      );
      print('Created video with original URL: ${video.originalUrl}'); // Debug print
      return video;
    } catch (e) {
      throw Exception('Failed to download video: $e');
    }
  }

  Future<void> downloadCoverImage(TikTokVideo video, {ProgressCallback? onProgress}) async {
    try {
      if (video.coverUrl.isEmpty) {
        throw Exception('No cover image available');
      }

      final downloadPath = await getDownloadPath();
      if (downloadPath == null) {
        throw Exception('Could not access download directory');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = '$downloadPath/tiktok_cover_$timestamp.jpg';

      await _downloadFile(video.coverUrl, imagePath, onProgress: onProgress);

      if (Platform.isAndroid) {
        await MediaScanner.loadMedia(path: imagePath);
      }
    } catch (e) {
      throw Exception('Failed to download cover image: $e');
    }
  }

  Future<void> _downloadFile(String url, String savePath, {ProgressCallback? onProgress}) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
      );
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  Future<String?> getDownloadPath() async {
    try {
      if (Platform.isAndroid) {
        final directory = Directory('/storage/emulated/0/DCIM/TIKTOKDOWNLOADER');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        return directory.path;
      }
      return null;
    } catch (e) {
      print('Error getting download path: $e');
      return null;
    }
  }
}
