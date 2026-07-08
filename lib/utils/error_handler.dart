import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';

class AppError {
  final String message;
  final String? details;
  final ErrorType type;
  final bool isRetryable;

  AppError({
    required this.message,
    this.details,
    this.type = ErrorType.general,
    this.isRetryable = true,
  });

  factory AppError.fromException(dynamic e) {
    if (e is SocketException) {
      return AppError(
        message: 'No internet connection',
        details: 'Please check your network settings and try again',
        type: ErrorType.network,
        isRetryable: true,
      );
    } else if (e is TimeoutException) {
      return AppError(
        message: 'Connection timeout',
        details: 'The server took too long to respond',
        type: ErrorType.timeout,
        isRetryable: true,
      );
    } else if (e.toString().contains('400') || e.toString().contains('401')) {
      return AppError(
        message: 'Authentication error',
        details: 'Please try again later',
        type: ErrorType.auth,
        isRetryable: false,
      );
    } else if (e.toString().contains('404')) {
      return AppError(
        message: 'Resource not found',
        details: 'The requested data is not available',
        type: ErrorType.notFound,
        isRetryable: false,
      );
    } else if (e.toString().contains('429')) {
      return AppError(
        message: 'Too many requests',
        details: 'API rate limit reached. Please try again in a moment.',
        type: ErrorType.rateLimit,
        isRetryable: true,
      );
    } else if (e.toString().contains('500') ||
        e.toString().contains('502') ||
        e.toString().contains('503')) {
      return AppError(
        message: 'Server error',
        details: 'The server is currently unavailable',
        type: ErrorType.server,
        isRetryable: true,
      );
    } else {
      return AppError(
        message: 'Something went wrong',
        details: e.toString(),
        type: ErrorType.general,
        isRetryable: true,
      );
    }
  }
}

enum ErrorType { network, timeout, auth, notFound, rateLimit, server, general }

class ErrorHandler {
  static void showErrorSnackBar(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
  }) {
    final isNetworkError = error.type == ErrorType.network;
    final isRateLimit = error.type == ErrorType.rateLimit;
    final isServerError = error.type == ErrorType.server;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  isNetworkError
                      ? Icons.wifi_off
                      : isRateLimit
                      ? Icons.timer_off
                      : isServerError
                      ? Icons.cloud_off
                      : Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    error.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (error.details != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  error.details!,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
          ],
        ),
        backgroundColor: isNetworkError
            ? Colors.orange.shade800
            : isRateLimit
            ? Colors.purple.shade800
            : isServerError
            ? Colors.red.shade800
            : Colors.red,
        duration: const Duration(seconds: 5),
        action: (onRetry != null && error.isRetryable)
            ? SnackBarAction(
                label: 'RETRY',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static Widget buildErrorWidget(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    final isNetworkError = error.type == ErrorType.network;
    final isRateLimit = error.type == ErrorType.rateLimit;
    final isServerError = error.type == ErrorType.server;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    (isNetworkError
                            ? Colors.orange
                            : isRateLimit
                            ? Colors.purple
                            : isServerError
                            ? Colors.red
                            : Colors.red)
                        .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNetworkError
                    ? Icons.wifi_off
                    : isRateLimit
                    ? Icons.timer_off
                    : isServerError
                    ? Icons.cloud_off
                    : Icons.error_outline,
                color: isNetworkError
                    ? Colors.orange
                    : isRateLimit
                    ? Colors.purple
                    : isServerError
                    ? Colors.red
                    : Colors.red,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              error.message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Details
            if (error.details != null)
              Text(
                error.details!,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),

            // Actions
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                if (onDismiss != null)
                  OutlinedButton(
                    onPressed: onDismiss,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Dismiss'),
                  ),
                if (onRetry != null && error.isRetryable)
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Retry',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
