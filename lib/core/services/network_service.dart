import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Retries only transient Firebase/network failures. Permanent validation,
/// authentication and permission errors are returned immediately.
class NetworkService {
  static const int defaultRetries = 3;
  static const Duration defaultDelay = Duration(milliseconds: 700);

  static bool isTransient(Object error) {
    if (error is FirebaseException) {
      return const {
        'unavailable',
        'deadline-exceeded',
        'aborted',
        'resource-exhausted',
      }.contains(error.code);
    }
    if (error is FirebaseFunctionsException) {
      return const {
        'unavailable',
        'deadline-exceeded',
        'aborted',
        'resource-exhausted',
      }.contains(error.code);
    }
    final value = error.toString().toLowerCase();
    return value.contains('timeout') ||
        value.contains('network') ||
        value.contains('connection reset') ||
        value.contains('socketexception');
  }

  static Future<T> callWithRetry<T>(
    Future<T> Function() operation, {
    int retries = defaultRetries,
    Duration initialDelay = defaultDelay,
  }) async {
    Object? lastError;
    StackTrace? lastStack;

    for (var attempt = 0; attempt <= retries; attempt++) {
      try {
        return await operation();
      } catch (error, stack) {
        lastError = error;
        lastStack = stack;
        if (attempt >= retries || !isTransient(error)) {
          Error.throwWithStackTrace(error, stack);
        }
        final multiplier = pow(2, attempt).toInt();
        await Future<void>.delayed(initialDelay * multiplier);
      }
    }

    Error.throwWithStackTrace(
      lastError ?? StateError('تعذر تنفيذ العملية'),
      lastStack ?? StackTrace.current,
    );
  }
}
