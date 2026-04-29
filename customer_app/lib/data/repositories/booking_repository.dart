import '../../core/errors/error_handler.dart';
import '../../core/errors/result.dart';
import '../../core/network/api_client.dart';
import '../models/booking_model.dart';

class BookingRepository {
  BookingRepository({required this.apiClient});

  final ApiClient apiClient;

  Future<Result<List<BookingModel>>> getUserBookings(String userId) async {
    return ErrorHandler.guard(() async {
      final data = await apiClient.query(
        'bookings',
        filters: {'user_id': userId},
        orderBy: 'created_at',
        ascending: false,
      );
      return data.map((json) => BookingModel.fromJson(json)).toList();
    });
  }

  Future<Result<BookingModel>> getBooking(String bookingId) async {
    return ErrorHandler.guard(() async {
      final data = await apiClient.query(
        'bookings',
        filters: {'id': bookingId},
      );
      if (data.isEmpty) throw Exception('Booking not found');
      return BookingModel.fromJson(data.first);
    });
  }

  Future<Result<BookingModel>> createBooking(BookingModel booking) async {
    return ErrorHandler.guard(() async {
      final data = await apiClient.insert('bookings', booking.toJson());
      return BookingModel.fromJson(data);
    });
  }

  Future<Result<BookingModel>> updateBooking(BookingModel booking) async {
    return ErrorHandler.guard(() async {
      final data = await apiClient.update(
        'bookings',
        booking.id,
        booking.toJson(),
      );
      return BookingModel.fromJson(data);
    });
  }

  Future<Result<void>> cancelBooking(String bookingId) async {
    return ErrorHandler.guard(() async {
      await apiClient.update('bookings', bookingId, {
        'status': BookingStatus.cancelled.name,
      });
    });
  }

  Future<Result<List<BookingModel>>> getActiveBookings(String userId) async {
    return ErrorHandler.guard(() async {
      final data = await apiClient.query(
        'bookings',
        filters: {'user_id': userId},
        orderBy: 'created_at',
        ascending: false,
      );
      return data
          .map((json) => BookingModel.fromJson(json))
          .where((b) =>
              b.status == BookingStatus.pending ||
              b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.inProgress)
          .toList();
    });
  }

  Future<Result<Map<String, dynamic>>> lockPrice({
    required String bookingId,
    required double price,
  }) async {
    return ErrorHandler.guard(() async {
      final data = await apiClient.update('bookings', bookingId, {
        'is_locked': true,
        'locked_price': price,
        'locked_at': DateTime.now().toIso8601String(),
      });
      return data;
    });
  }

  Future<Result<List<Map<String, dynamic>>>> matchProviders({
    required String serviceCategory,
    required double latitude,
    required double longitude,
    double? radiusKm,
  }) async {
    return ErrorHandler.guard(() async {
      final response = await apiClient.invokeFunction(
        'match-providers',
        body: {
          'service_category': serviceCategory,
          'latitude': latitude,
          'longitude': longitude,
          'radius_km': radiusKm ?? 25.0,
        },
      );
      return List<Map<String, dynamic>>.from(
        response['providers'] as List? ?? [],
      );
    });
  }
}
