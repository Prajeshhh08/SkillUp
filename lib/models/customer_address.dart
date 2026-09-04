class CustomerAddress {
  const CustomerAddress({
    required this.id,
    required this.customerId,
    required this.label,
    required this.streetAddress,
    this.apartmentUnit,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
    this.createdAt,
  });

  final String id;
  final String customerId;
  final String label;
  final String streetAddress;
  final String? apartmentUnit;
  final String city;
  final String state;
  final String postalCode;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final DateTime? createdAt;

  String get shortLine {
    if (apartmentUnit != null && apartmentUnit!.trim().isNotEmpty) {
      return '${apartmentUnit!.trim()}, $streetAddress';
    }
    return streetAddress;
  }

  String get fullDisplayLine {
    final parts = [
      if (apartmentUnit != null && apartmentUnit!.trim().isNotEmpty)
        apartmentUnit!.trim(),
      streetAddress,
      city,
      if (state.isNotEmpty) state,
      if (postalCode.isNotEmpty) postalCode,
    ];
    return parts.join(', ');
  }

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Home',
      streetAddress: json['street_address']?.toString() ?? '',
      apartmentUnit: json['apartment_unit']?.toString(),
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      postalCode: json['postal_code']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isDefault: json['is_default'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customer_id': customerId,
    'label': label,
    'street_address': streetAddress,
    if (apartmentUnit != null) 'apartment_unit': apartmentUnit,
    'city': city,
    'state': state,
    'postal_code': postalCode,
    'latitude': latitude,
    'longitude': longitude,
    'is_default': isDefault,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };
}

class AddressCreatePayload {
  const AddressCreatePayload({
    this.label = 'Home',
    required this.streetAddress,
    this.apartmentUnit,
    this.city = 'Bengaluru',
    this.state = 'Karnataka',
    required this.postalCode,
    this.latitude = 12.9716,
    this.longitude = 77.5946,
    this.isDefault = true,
  });

  final String label;
  final String streetAddress;
  final String? apartmentUnit;
  final String city;
  final String state;
  final String postalCode;
  final double latitude;
  final double longitude;
  final bool isDefault;

  Map<String, dynamic> toJson() => {
    'label': label,
    'street_address': streetAddress,
    if (apartmentUnit != null && apartmentUnit!.isNotEmpty)
      'apartment_unit': apartmentUnit,
    'city': city,
    'state': state,
    'postal_code': postalCode,
    'latitude': latitude,
    'longitude': longitude,
    'is_default': isDefault,
  };
}

class AddressUpdatePayload {
  const AddressUpdatePayload({
    this.label,
    this.streetAddress,
    this.apartmentUnit,
    this.city,
    this.state,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.isDefault,
  });

  final String? label;
  final String? streetAddress;
  final String? apartmentUnit;
  final String? city;
  final String? state;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final bool? isDefault;

  Map<String, dynamic> toJson() => {
    if (label != null) 'label': label,
    if (streetAddress != null) 'street_address': streetAddress,
    if (apartmentUnit != null) 'apartment_unit': apartmentUnit,
    if (city != null) 'city': city,
    if (state != null) 'state': state,
    if (postalCode != null) 'postal_code': postalCode,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (isDefault != null) 'is_default': isDefault,
  };
}
