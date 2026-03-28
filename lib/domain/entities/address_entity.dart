/// Entity representing User Address in Domain layer
/// Domain entities are independent of data/presentation layers
class AddressEntity {
  final int? addressId;
  final String username;
  final String label;
  final String streetAddress;
  final String city;
  final String state;
  final String country;
  final String zipCode;
  final String phone;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const AddressEntity({
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
    this.isDefault = false,
  });

  /// Create from similar entity with modifications
  AddressEntity copyWith({
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
    bool? isDefault,
  }) {
    return AddressEntity(
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
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AddressEntity &&
      addressId == other.addressId &&
      username == other.username &&
      label == other.label;

  @override
  int get hashCode =>
      addressId.hashCode ^ username.hashCode ^ label.hashCode;

  @override
  String toString() => 'AddressEntity(id: $addressId, label: $label, '
      'city: $city, country: $country, isDefault: $isDefault)';
}
