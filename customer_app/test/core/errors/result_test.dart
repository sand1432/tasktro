import 'package:flutter_test/flutter_test.dart';
import 'package:fixly_ai/core/errors/app_exception.dart';
import 'package:fixly_ai/core/errors/result.dart';

void main() {
  group('Result', () {
    test('Success contains data', () {
      final result = Result.success(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.data, equals(42));
      expect(result.exception, isNull);
    });

    test('Failure contains exception', () {
      const exception = ServerException('Test error', code: 'TEST');
      final result = Result<int>.failure(exception);
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.data, isNull);
      expect(result.exception, equals(exception));
    });

    test('when() routes to correct callback', () {
      final success = Result.success('hello');
      final successResult = success.when(
        success: (data) => 'Got: $data',
        failure: (e) => 'Error: ${e.message}',
      );
      expect(successResult, equals('Got: hello'));

      final failure = Result<String>.failure(
        const NetworkException('No internet'),
      );
      final failureResult = failure.when(
        success: (data) => 'Got: $data',
        failure: (e) => 'Error: ${e.message}',
      );
      expect(failureResult, equals('Error: No internet'));
    });

    test('map() transforms success data', () {
      final result = Result.success(10);
      final mapped = result.map((data) => data * 2);
      expect(mapped.data, equals(20));
    });

    test('map() preserves failure', () {
      const exception = ServerException('Error');
      final result = Result<int>.failure(exception);
      final mapped = result.map((data) => data * 2);
      expect(mapped.isFailure, isTrue);
      expect(mapped.exception?.message, equals('Error'));
    });
  });
}
