import 'package:flutter_test/flutter_test.dart';
import 'package:fixly_ai/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    final sampleJson = {
      'id': 'user-123',
      'email': 'test@example.com',
      'full_name': 'John Doe',
      'phone': '+1234567890',
      'avatar_url': 'https://example.com/avatar.jpg',
      'address': '123 Main St',
      'latitude': 40.7128,
      'longitude': -74.0060,
      'is_verified': true,
      'created_at': '2024-01-01T00:00:00.000Z',
      'preferences': {'theme': 'dark', 'notifications': true},
    };

    test('fromJson creates correct model', () {
      final user = UserModel.fromJson(sampleJson);

      expect(user.id, 'user-123');
      expect(user.email, 'test@example.com');
      expect(user.fullName, 'John Doe');
      expect(user.phone, '+1234567890');
      expect(user.isVerified, true);
      expect(user.latitude, 40.7128);
      expect(user.preferences?['theme'], 'dark');
    });

    test('toJson produces correct map', () {
      final user = UserModel.fromJson(sampleJson);
      final json = user.toJson();

      expect(json['id'], 'user-123');
      expect(json['email'], 'test@example.com');
      expect(json['full_name'], 'John Doe');
      expect(json['is_verified'], true);
    });

    test('copyWith creates modified copy', () {
      final user = UserModel.fromJson(sampleJson);
      final updated = user.copyWith(
        fullName: 'Jane Smith',
        phone: '+0987654321',
      );

      expect(updated.id, user.id);
      expect(updated.email, user.email);
      expect(updated.fullName, 'Jane Smith');
      expect(updated.phone, '+0987654321');
      expect(updated.isVerified, user.isVerified);
    });

    test('fromJson handles missing optional fields', () {
      final minimalJson = {
        'id': 'user-min',
        'email': 'min@test.com',
      };

      final user = UserModel.fromJson(minimalJson);

      expect(user.id, 'user-min');
      expect(user.email, 'min@test.com');
      expect(user.fullName, '');
      expect(user.phone, isNull);
      expect(user.avatarUrl, isNull);
      expect(user.isVerified, false);
    });
  });
}
