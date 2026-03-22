class DeliveryLocation {
  final String label;       // display string shown to user
  final String? addressId;  // null if current GPS location
  final double? lat;
  final double? lng;
  final bool isCurrentLocation;

  const DeliveryLocation({
    required this.label,
    this.addressId,
    this.lat,
    this.lng,
    this.isCurrentLocation = false,
  });
}
