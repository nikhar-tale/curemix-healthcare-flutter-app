import 'dart:async';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../constants/app_colors.dart';

class NotificationHelper {
  /// Gradually increments progress while an async task is running.
  /// This prevents the "jumpy" 20% -> 100% behavior.
  static Future<T> runWithSmoothProgress<T>({
    required String title,
    required Future<T> Function() task,
    double initialProgress = 0.1,
    double maxAutoProgress = 0.9,
  }) async {
    final progressNotifier = ValueNotifier<double>(initialProgress);
    showProgressSnackBar(title: title, progressNotifier: progressNotifier);

    bool isTaskDone = false;
    
    // Start the actual task with error handling
    final taskFuture = task().then((value) {
      isTaskDone = true;
      progressNotifier.value = 1.0;
      return value;
    }).catchError((error) {
      isTaskDone = true;
      progressNotifier.value = 0.0; // Show error state
      throw error;
    });

    // Start a timer to "trickle" the progress up to maxAutoProgress
    // This makes the UI feel alive and "Pro"
    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (isTaskDone) {
        timer.cancel();
        return;
      }

      if (progressNotifier.value < maxAutoProgress) {
        // Slowly increment (less increment as it gets higher)
        final increment = (maxAutoProgress - progressNotifier.value) * 0.1;
        progressNotifier.value += increment.clamp(0.005, 0.05);
      } else {
        timer.cancel();
      }
    });

    try {
      return await taskFuture;
    } finally {
      // Final guard to ensure timer is stopped
      isTaskDone = true;
    }
  }

  /// Shows a persistent SnackBar with a progress bar that can be updated in real-time.
  static void showProgressSnackBar({
    required String title,
    required ValueNotifier<double> progressNotifier,
  }) {
    final messenger = CuremixApp.messengerKey.currentState;
    if (messenger == null) return;

    // Remove any existing snackbars to avoid stacking during rapid updates
    messenger.removeCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(days: 1), // Stay until manually dismissed
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
        content: ValueListenableBuilder<double>(
          valueListenable: progressNotifier,
          builder: (context, progress, child) {
            final isDone = progress >= 1.0;
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isDone ? Icons.check_circle : Icons.downloading,
                        color: isDone ? Colors.green : AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isDone ? 'Download Complete!' : title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (isDone)
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => messenger.hideCurrentSnackBar(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      else
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  if (!isDone) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Shows a quick success/error notification
  static void showNotification(String message, {bool isError = false}) {
    final messenger = CuremixApp.messengerKey.currentState;
    if (messenger == null) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
