import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import 'app_exception.dart';
import 'result.dart';

class ErrorHandler {
  ErrorHandler._();

  static AppException handle(Object error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;

    if (error is AuthApiException) {
      return AuthException(
        error.message,
        code: error.statusCode,
        stackTrace: stackTrace,
      );
    }

    if (error is PostgrestException) {
      return ServerException(
        error.message,
        code: error.code,
        stackTrace: stackTrace,
      );
    }

    if (error is SocketException) {
      return NetworkException(
        'No internet connection',
        code: 'NO_INTERNET',
        stackTrace: stackTrace,
      );
    }

    if (error is TimeoutException) {
      return NetworkException(
        'Request timed out',
        code: 'TIMEOUT',
        stackTrace: stackTrace,
      );
    }

    if (error is FormatException) {
      return ValidationException(
        'Invalid data format: ${error.message}',
        code: 'FORMAT_ERROR',
        stackTrace: stackTrace,
      );
    }

    return ServerException(
      error.toString(),
      code: 'UNKNOWN',
      stackTrace: stackTrace,
    );
  }

  static Future<Result<T>> guard<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      return Result.success(result);
    } catch (e, st) {
      debugPrint('ErrorHandler.guard caught: $e');
      return Result.failure(handle(e, st));
    }
  }

  static Result<T> guardSync<T>(T Function() action) {
    try {
      final result = action();
      return Result.success(result);
    } catch (e, st) {
      debugPrint('ErrorHandler.guardSync caught: $e');
      return Result.failure(handle(e, st));
    }
  }
}
