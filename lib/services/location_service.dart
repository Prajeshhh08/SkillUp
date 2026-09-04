import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location_models.dart';
import 'api_client.dart';

/// Result state when attempting to obtain device location
enum LocationStatus {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timeout,
  error,
}

/// Service managing device GPS location, permissions, and reverse-geocoding.
class LocationService {
  LocationService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;

  static LocationService instance = LocationService();

  final ApiClient _apiClient;
  AppCoordinates? _lastKnownPosition;

  /// Cached coordinates from the most recent successful location fix.
  AppCoordinates? get lastKnownPosition => _lastKnownPosition;

  /// Default fallback coordinates (Bengaluru central, 12.9716, 77.5946).
  AppCoordinates get fallbackLocation => AppCoordinates.defaultBengaluru;

  /// Check whether system location services (GPS) are enabled.
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled().timeout(
        const Duration(seconds: 3),
        onTimeout: () => false,
      );
    } catch (e) {
      debugPrint('[LocationService] isLocationServiceEnabled error: $e');
      return false;
    }
  }

  /// Check current location permission status without prompting.
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission().timeout(
        const Duration(seconds: 3),
        onTimeout: () => LocationPermission.denied,
      );
    } catch (e) {
      debugPrint('[LocationService] checkPermission error: $e');
      return LocationPermission.denied;
    }
  }

  /// Request runtime location permissions from the user.
  Future<LocationPermission> requestPermission() async {
    try {
      final current = await Geolocator.checkPermission().timeout(
        const Duration(seconds: 3),
        onTimeout: () => LocationPermission.denied,
      );
      if (current == LocationPermission.denied) {
        return await Geolocator.requestPermission().timeout(
          const Duration(seconds: 3),
          onTimeout: () => LocationPermission.denied,
        );
      }
      return current;
    } catch (e) {
      debugPrint('[LocationService] requestPermission error: $e');
      return LocationPermission.denied;
    }
  }

  /// Retrieve the current GPS coordinates.
  /// If location is disabled or permission denied, returns null.
  Future<AppCoordinates?> getCurrentPosition({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[LocationService] Location services are disabled.');
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('[LocationService] Location permissions are denied.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('[LocationService] Location permissions permanently denied.');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeout,
        ),
      );

      final coords = AppCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      _lastKnownPosition = coords;
      return coords;
    } on TimeoutException catch (_) {
      debugPrint('[LocationService] Location request timed out.');
      // Attempt to retrieve last known position if current request timed out
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          final coords = AppCoordinates(
            latitude: last.latitude,
            longitude: last.longitude,
          );
          _lastKnownPosition = coords;
          return coords;
        }
      } catch (_) {}
      return null;
    } catch (e) {
      debugPrint('[LocationService] Failed to acquire position: $e');
      return null;
    }
  }

  /// Reverse geocode GPS coordinates to address metadata.
  /// First attempts native on-device geocoding (Google Play Services / Android Geocoder).
  /// If native geocoding is unavailable or in a non-mobile environment, falls back to the backend reverse-geocode endpoint.
  Future<ReverseGeocodeResult?> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    // 1. Try native on-device reverse geocoding
    try {
      final placemarks = await Geocoding()
          .placemarkFromCoordinates(latitude, longitude)
          .timeout(const Duration(seconds: 4));
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final streetParts = <String>[];
        if (place.thoroughfare != null &&
            place.thoroughfare!.trim().isNotEmpty) {
          streetParts.add(place.thoroughfare!.trim());
        } else if (place.street != null && place.street!.trim().isNotEmpty) {
          streetParts.add(place.street!.trim());
        }
        if (place.subLocality != null &&
            place.subLocality!.trim().isNotEmpty) {
          final sub = place.subLocality!.trim();
          if (!streetParts.contains(sub)) {
            streetParts.add(sub);
          }
        }
        if (streetParts.isEmpty &&
            place.name != null &&
            place.name!.trim().isNotEmpty) {
          streetParts.add(place.name!.trim());
        }
        final street = streetParts.join(', ');
        final city = (place.locality != null &&
                place.locality!.trim().isNotEmpty)
            ? place.locality!.trim()
            : (place.subAdministrativeArea != null &&
                    place.subAdministrativeArea!.trim().isNotEmpty)
                ? place.subAdministrativeArea!.trim()
                : (place.subLocality != null &&
                        place.subLocality!.trim().isNotEmpty)
                    ? place.subLocality!.trim()
                    : 'Bengaluru';
        final state = (place.administrativeArea != null &&
                place.administrativeArea!.trim().isNotEmpty)
            ? place.administrativeArea!.trim()
            : 'Karnataka';
        final postal = (place.postalCode != null &&
                place.postalCode!.trim().isNotEmpty)
            ? place.postalCode!.trim()
            : '560001';

        final formattedParts = [
          if (street.isNotEmpty) street,
          city,
          state,
          postal,
        ];

        return ReverseGeocodeResult(
          formattedAddress: formattedParts.join(', '),
          streetAddress: street.isNotEmpty ? street : null,
          city: city,
          state: state,
          postalCode: postal,
          latitude: latitude,
          longitude: longitude,
        );
      }
    } catch (e) {
      debugPrint('[LocationService] Native geocoding fallback to backend: $e');
    }

    // 2. Fallback to SkillUp backend reverse-geocoding API
    try {
      final res = await _apiClient.get(
        '/locations/reverse-geocode',
        queryParameters: {'lat': latitude, 'lng': longitude},
      );
      return ReverseGeocodeResult.fromJson(res);
    } catch (e) {
      debugPrint('[LocationService] Reverse geocode API error: $e');
      return null;
    }
  }

  /// Helper to manually set coordinates (useful in testing or manual overrides).
  void setKnownPosition(double latitude, double longitude) {
    _lastKnownPosition = AppCoordinates(
      latitude: latitude,
      longitude: longitude,
    );
  }
}
