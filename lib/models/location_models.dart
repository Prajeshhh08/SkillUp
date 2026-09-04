/// Location and Geocoding data models for SkillUp.
class ReverseGeocodeResult {
  final String formattedAddress;
  final String? streetAddress;
  final String? city;
  final String? state;
  final String? postalCode;
  final double latitude;
  final double longitude;

  const ReverseGeocodeResult({
    required this.formattedAddress,
    this.streetAddress,
    this.city,
    this.state,
    this.postalCode,
    required this.latitude,
    required this.longitude,
  });

  factory ReverseGeocodeResult.fromJson(Map<String, dynamic> json) {
    return ReverseGeocodeResult(
      formattedAddress: json['formatted_address'] as String? ?? '',
      streetAddress: json['street_address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formatted_address': formattedAddress,
      if (streetAddress != null) 'street_address': streetAddress,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (postalCode != null) 'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() =>
      'ReverseGeocodeResult($formattedAddress, lat: $latitude, lng: $longitude)';
}

/// Simple model for app-wide geographic coordinates
class AppCoordinates {
  final double latitude;
  final double longitude;

  const AppCoordinates({required this.latitude, required this.longitude});

  static const AppCoordinates defaultBengaluru = AppCoordinates(
    latitude: 12.9716,
    longitude: 77.5946,
  );

  @override
  String toString() => 'AppCoordinates($latitude, $longitude)';
}
