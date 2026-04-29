import 'package:flutter/foundation.dart';

import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../services/analytics/analytics_service.dart';

enum BookingLoadingStatus { idle, loading, loaded, error }

class BookingProvider extends ChangeNotifier {
  BookingProvider({required this.bookingRepository});

  final BookingRepository bookingRepository;

  BookingLoadingStatus _status = BookingLoadingStatus.idle;
  List<BookingModel> _bookings = [];
  List<BookingModel> _activeBookings = [];
  BookingModel? _selectedBooking;
  String? _errorMessage;

  BookingLoadingStatus get status => _status;
  List<BookingModel> get bookings => _bookings;
  List<BookingModel> get activeBookings => _activeBookings;
  BookingModel? get selectedBooking => _selectedBooking;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == BookingLoadingStatus.loading;

  Future<void> loadBookings(String userId) async {
    _status = BookingLoadingStatus.loading;
    notifyListeners();

    final result = await bookingRepository.getUserBookings(userId);
    result.when(
      success: (bookings) {
        _bookings = bookings;
        _activeBookings = bookings
            .where((b) =>
                b.status == BookingStatus.pending ||
                b.status == BookingStatus.confirmed ||
                b.status == BookingStatus.inProgress)
            .toList();
        _status = BookingLoadingStatus.loaded;
      },
      failure: (e) {
        _errorMessage = e.message;
        _status = BookingLoadingStatus.error;
      },
    );
    notifyListeners();
  }

  Future<BookingModel?> createBooking(BookingModel booking) async {
    _status = BookingLoadingStatus.loading;
    notifyListeners();

    final result = await bookingRepository.createBooking(booking);
    return result.when(
      success: (newBooking) {
        _bookings = [newBooking, ..._bookings];
        _activeBookings = [newBooking, ..._activeBookings];
        _status = BookingLoadingStatus.loaded;

        AnalyticsService.instance.logBookingCreated(
          serviceCategory: booking.serviceName ?? 'unknown',
          bookingType: booking.bookingType.name,
          estimatedCost: booking.estimatedCostMin ?? 0.0,
        );

        notifyListeners();
        return newBooking;
      },
      failure: (e) {
        _errorMessage = e.message;
        _status = BookingLoadingStatus.error;
        notifyListeners();
        return null;
      },
    );
  }

  Future<void> cancelBooking(String bookingId) async {
    final result = await bookingRepository.cancelBooking(bookingId);
    result.when(
      success: (_) {
        _bookings = _bookings.map((b) {
          if (b.id == bookingId) {
            return b.copyWith(status: BookingStatus.cancelled);
          }
          return b;
        }).toList();
        _activeBookings.removeWhere((b) => b.id == bookingId);
        notifyListeners();
      },
      failure: (e) {
        _errorMessage = e.message;
        notifyListeners();
      },
    );
  }

  Future<void> lockPrice(String bookingId, double price) async {
    final result = await bookingRepository.lockPrice(
      bookingId: bookingId,
      price: price,
    );
    result.when(
      success: (_) {
        notifyListeners();
      },
      failure: (e) {
        _errorMessage = e.message;
        notifyListeners();
      },
    );
  }

  Future<List<Map<String, dynamic>>> matchProviders({
    required String serviceCategory,
    required double latitude,
    required double longitude,
    double? radiusKm,
  }) async {
    final result = await bookingRepository.matchProviders(
      serviceCategory: serviceCategory,
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
    return result.data ?? [];
  }

  void selectBooking(BookingModel booking) {
    _selectedBooking = booking;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
