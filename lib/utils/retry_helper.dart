import 'dart:async';

class RetryHelper {
  static Future<T> retry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 2),
    Duration timeout = const Duration(seconds: 30),
    bool Function(Exception)? shouldRetry,
  }) async {
    int retryCount = 0;
    Exception? lastError;

    while (retryCount < maxRetries) {
      try {
        final result = await operation().timeout(timeout);
        return result;
      } on Exception catch (e) {
        lastError = e;
        retryCount++;

        if (retryCount < maxRetries) {
          // Check if we should retry
          if (shouldRetry != null && !shouldRetry(e)) {
            rethrow;
          }

          // Exponential backoff
          final waitTime = delay * retryCount;
          await Future.delayed(waitTime);
          print(
            'Retry ${retryCount + 1}/$maxRetries after ${waitTime.inSeconds}s',
          );
        }
      }
    }

    throw lastError ?? Exception('Operation failed after $maxRetries retries');
  }
}
