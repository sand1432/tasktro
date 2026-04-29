import 'package:flutter_test/flutter_test.dart';
import 'package:fixly_ai/data/models/booking_model.dart';

void main() {
  group('BookingModel', () {
    final sampleJson = {
      'id': 'booking-123',
      'user_id': 'user-456',
      'provider_id': 'provider-789',
      'service_id': 'service-101',
      'status': 'pending',
      'booking_type': 'scheduled',
      'description': 'Leaky faucet',
      'scheduled_at': '2024-02-01T14:00:00.000Z',
      'address': '123 Main St',
      'latitude': 40.7128,
      'longitude': -74.0060,
      'estimated_cost_min': 50.0,
      'estimated_cost_max': 150.0,
      'is_locked': true,
      'locked_price': 150.0,
      'locked_at': '2024-01-31T10:00:00.000Z',
      'before_images': ['img1.jpg'],
      'after_images': [],
      'created_at': '2024-01-31T10:00:00.000Z',
      'provider_name': 'Mike\'s Plumbing',
      'service_name': 'Plumbing',
    };

    test('fromJson creates correct model', () {
      final booking = BookingModel.fromJson(sampleJson);

      expect(booking.id, 'booking-123');
      expect(booking.userId, 'user-456');
      expect(booking.providerId, 'provider-789');
      expect(booking.status, BookingStatus.pending);
      expect(booking.bookingType, BookingType.scheduled);
      expect(booking.description, 'Leaky faucet');
      expect(booking.address, '123 Main St');
      expect(booking.estimatedCostMin, 50.0);
      expect(booking.estimatedCostMax, 150.0);
      expect(booking.isLocked, true);
      expect(booking.lockedPrice, 150.0);
      expect(booking.providerName, 'Mike\'s Plumbing');
    });

    test('toJson produces correct map', () {
      final booking = BookingModel.fromJson(sampleJson);
      final json = booking.toJson();

      expect(json['user_id'], 'user-456');
      expect(json['provider_id'], 'provider-789');
      expect(json['status'], 'pending');
      expect(json['booking_type'], 'scheduled');
      expect(json['is_locked'], true);
    });

    test('copyWith creates modified copy', () {
      final booking = BookingModel.fromJson(sampleJson);
      final updated = booking.copyWith(
        status: BookingStatus.completed,
        finalCost: 125.0,
      );

      expect(updated.id, booking.id);
      expect(updated.status, BookingStatus.completed);
      expect(updated.finalCost, 125.0);
      expect(updated.description, booking.description);
    });
  });

  group('BookingStatus', () {
    test('fromString handles all cases', () {
      expect(BookingStatus.fromString('pending'), BookingStatus.pending);
      expect(BookingStatus.fromString('confirmed'), BookingStatus.confirmed);
      expect(BookingStatus.fromString('inProgress'), BookingStatus.inProgress);
      expect(BookingStatus.fromString('completed'), BookingStatus.completed);
      expect(BookingStatus.fromString('cancelled'), BookingStatus.cancelled);
      expect(BookingStatus.fromString('unknown'), BookingStatus.pending);
    });

    test('displayName returns correct string', () {
      expect(BookingStatus.pending.displayName, 'Pending');
      expect(BookingStatus.confirmed.displayName, 'Confirmed');
      expect(BookingStatus.inProgress.displayName, 'In Progress');
      expect(BookingStatus.completed.displayName, 'Completed');
    });
  });
}
