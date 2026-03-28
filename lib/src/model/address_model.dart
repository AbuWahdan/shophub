/// API Model of User Address (Data Layer)
/// This class is JSON-serializable and represents the shape of API responses
class AddressModel {
  final int? addressId;
  final String username;
  final String label; // e.g., "Home", "Office", "Other"
  final String streetAddress;
  final String city;
  final String state;
  final String country;
  final String zipCode;
  final String phone;
  final double? latitude;
  final double? longitude;
  final int? isDefault; // 1 = default, 0 = not default
  final String? createdDate;
  final String? modifiedDate;

  const AddressModel({
    this.addressId,
    required this.username,
    required this.label,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.country,
    required this.zipCode,
    required this.phone,
    this.latitude,
    this.longitude,
    this.isDefault,
    this.createdDate,
    this.modifiedDate,
  });

  /// Create from JSON (API response)
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      addressId: _toInt(json['address_id'] ?? json['addressId']),
      username: _toString(json['username'] ?? ''),
      label: _toString(json['label'] ?? ''),
      streetAddress: _toString(json['street_address'] ?? json['streetAddress'] ?? ''),
      city: _toString(json['city'] ?? ''),
      state: _toString(json['state'] ?? ''),
      country: _toString(json['country'] ?? ''),
      zipCode: _toString(json['zip_code'] ?? json['zipCode'] ?? ''),
      phone: _toString(json['phone'] ?? ''),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      isDefault: _toInt(json['is_default'] ?? json['isDefault']),
      createdDate: _toString(json['created_date'] ?? json['createdDate']),
      modifiedDate: _toString(json['modified_date'] ?? json['modifiedDate']),
    );
  }

  /// Convert to JSON (for API request)
  Map<String, dynamic> toJson() {
    return {
      if (addressId != null) 'address_id': addressId,
      'username': username,
      'label': label,
      'street_address': streetAddress,
      'city': city,
      'state': state,
      'country': country,
      'zip_code': zipCode,
      'phone': phone,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (isDefault != null) 'is_default': isDefault,
    };
  }

  /// Create a copy with modifications
  AddressModel copyWith({
    int? addressId,
    String? username,
    String? label,
    String? streetAddress,
    String? city,
    String? state,
    String? country,
    String? zipCode,
    String? phone,
    double? latitude,
    double? longitude,
    int? isDefault,
    String? createdDate,
    String? modifiedDate,
  }) {
    return AddressModel(
      addressId: addressId ?? this.addressId,
      username: username ?? this.username,
      label: label ?? this.label,
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      zipCode: zipCode ?? this.zipCode,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      createdDate: createdDate ?? this.createdDate,
      modifiedDate: modifiedDate ?? this.modifiedDate,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AddressModel &&
      addressId == other.addressId &&
      username == other.username &&
      label == other.label;

  @override
  int get hashCode =>
      addressId.hashCode ^ username.hashCode ^ label.hashCode;

  @override
  String toString() => 'AddressModel(id: $addressId, label: $label, '
      'street: $streetAddress, city: $city, phone: $phone)';

  // Helper methods for null-safe parsing
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static String _toString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }
}
