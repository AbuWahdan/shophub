class Address {
  String id;
  String name;
  String phone;
  String street;
  String city;
  String state;
  String zipCode;
  String country;
  bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.isDefault = false,
  });

  String get fullAddress => '$street, $city, $state $zipCode, $country';
}
