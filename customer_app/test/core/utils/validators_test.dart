import 'package:flutter_test/flutter_test.dart';
import 'package:fixly_ai/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('returns error for empty email', () {
        expect(Validators.email(''), isNotNull);
        expect(Validators.email(null), isNotNull);
      });

      test('returns error for invalid email', () {
        expect(Validators.email('notanemail'), isNotNull);
        expect(Validators.email('missing@'), isNotNull);
        expect(Validators.email('@missing.com'), isNotNull);
      });

      test('returns null for valid email', () {
        expect(Validators.email('test@example.com'), isNull);
        expect(Validators.email('user.name@domain.co'), isNull);
      });
    });

    group('password', () {
      test('returns error for empty password', () {
        expect(Validators.password(''), isNotNull);
        expect(Validators.password(null), isNotNull);
      });

      test('returns error for short password', () {
        expect(Validators.password('Ab1'), isNotNull);
      });

      test('returns error for password without uppercase', () {
        expect(Validators.password('abcdefg1'), isNotNull);
      });

      test('returns error for password without number', () {
        expect(Validators.password('Abcdefgh'), isNotNull);
      });

      test('returns null for valid password', () {
        expect(Validators.password('Abcdefg1'), isNull);
        expect(Validators.password('MyP@ssw0rd'), isNull);
      });
    });

    group('name', () {
      test('returns error for empty name', () {
        expect(Validators.name(''), isNotNull);
        expect(Validators.name(null), isNotNull);
      });

      test('returns error for single character', () {
        expect(Validators.name('A'), isNotNull);
      });

      test('returns null for valid name', () {
        expect(Validators.name('John'), isNull);
        expect(Validators.name('Jane Doe'), isNull);
      });
    });

    group('phone', () {
      test('returns error for empty phone', () {
        expect(Validators.phone(''), isNotNull);
        expect(Validators.phone(null), isNotNull);
      });

      test('returns null for valid phone', () {
        expect(Validators.phone('+1 555-123-4567'), isNull);
        expect(Validators.phone('5551234567'), isNull);
      });
    });

    group('required', () {
      test('returns error for empty value', () {
        expect(Validators.required(''), isNotNull);
        expect(Validators.required(null), isNotNull);
        expect(Validators.required('  '), isNotNull);
      });

      test('returns null for non-empty value', () {
        expect(Validators.required('hello'), isNull);
      });
    });
  });
}
