import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'home_view.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  Future<void> _requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final isAndroid14OrHigher = androidInfo.version.sdkInt >= 34;

        bool permissionsGranted = false;
        if (isAndroid14OrHigher) {
          final videoStatus = await Permission.videos.request();
          final storageStatus = await Permission.manageExternalStorage.request();
          permissionsGranted = videoStatus.isGranted && storageStatus.isGranted;
        } else {
          final storageStatus = await Permission.storage.request();
          permissionsGranted = storageStatus.isGranted;
        }

        if (permissionsGranted) {
          Get.off(() => HomeView());
        } else {
          Get.snackbar(
            'Permission Required',
            'Please grant the required permissions to use this app',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        // For non-Android platforms, just proceed to HomeView
        Get.off(() => HomeView());
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to request permissions: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_special,
                size: 80,
                color: context.theme.colorScheme.primary,
              ),
              const SizedBox(height: 32),
              Text(
                'Storage Permission Required',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'To save TikTok videos to your device, we need permission to access your storage.',
                style: context.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _requestPermissions,
                icon: const Icon(Icons.check_circle),
                label: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
