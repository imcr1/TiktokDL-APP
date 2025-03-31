import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_view.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate to home after animations
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAll(() => HomeView());
    });

    return Scaffold(
      backgroundColor: context.theme.colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TikTok-style logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: context.theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.download_rounded,
                size: 50,
                color: Colors.white,
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(),
                )
                .shimmer(
                  duration: const Duration(seconds: 2),
                  color: context.theme.colorScheme.primary.withOpacity(0.3),
                )
                .shake(
                  duration: const Duration(seconds: 1),
                  delay: const Duration(seconds: 1),
                )
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: const Duration(milliseconds: 500),
                )
                .then()
                .scale(
                  begin: const Offset(1.1, 1.1),
                  end: const Offset(1, 1),
                  duration: const Duration(milliseconds: 500),
                ),
            const SizedBox(height: 24),
            // App name
            Text(
              'TikTok Downloader',
              style: context.textTheme.headlineMedium?.copyWith(
                color: context.theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fadeIn(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 400),
                )
                .slideY(
                  begin: 0.3,
                  end: 0,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                ),
            const SizedBox(height: 8),
            // Tagline
            Text(
              'Download your favorite videos',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            )
                .animate()
                .fadeIn(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 600),
                )
                .slideY(
                  begin: 0.3,
                  end: 0,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                ),
          ],
        ),
      ),
    );
  }
}
