import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler.dart';
import '../../core/errors/result.dart';

class LocationService {
  LocationService._();

  static final LocationService _instance = LocationService._();
  static LocationService get instance => _instance;

  Position? _lastPosition;
  Position? get lastPosition => _lastPosition;

  Future<Result<Position>> getCurrentLocation() async {
    return ErrorHandler.guard(() async {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationException(
          'Location services are disabled',
          code: 'LOCATION_DISABLED',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw const LocationException(
            'Location permission denied',
            code: 'PERMISSION_DENIED',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw const LocationException(
          'Location permissions are permanently denied',
          code: 'PERMISSION_DENIED_FOREVER',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      _lastPosition = position;
      return position;
    });
  }

  Future<Result<String>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    return ErrorHandler.guard(() async {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) {
        throw const LocationException('No address found');
      }

      final place = placemarks.first;
      final parts = [
        place.street,
        place.locality,
        place.administrativeArea,
        place.postalCode,
      ].where((p) => p != null && p.isNotEmpty);

      return parts.join(', ');
    });
  }

  Future<Result<List<Location>>> getCoordinatesFromAddress(
    String address,
  ) async {
    return ErrorHandler.guard(() async {
      return locationFromAddress(address);
    });
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) /
        1000; // Convert to km
  }
}
