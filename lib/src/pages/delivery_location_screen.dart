// import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart' as geocoding;

// import '../design/app_colors.dart';
// import '../design/app_spacing.dart';
// import '../design/app_text_styles.dart';
// import '../model/delivery_location.dart';
// import '../shared/widgets/app_button.dart';
// import '../shared/widgets/app_snackbar.dart';
// import '../shared/widgets/app_text_field.dart';
// import '../themes/theme.dart';

// class DeliveryLocationScreen extends StatefulWidget {
//   final List<DeliveryLocation> savedAddresses;

//   const DeliveryLocationScreen({
//     required this.savedAddresses,
//     super.key,
//   });

//   @override
//   State<DeliveryLocationScreen> createState() =>
//       _DeliveryLocationScreenState();
// }

// class _DeliveryLocationScreenState extends State<DeliveryLocationScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late DeliveryLocation? _selectedLocation;
//   bool _isLoadingLocation = false;
//   bool _isConfirming = false;
//   final _newAddressController = TextEditingController();
//   late List<DeliveryLocation> _localAddresses;

//   String _mapAddress = '';

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _selectedLocation = null;
//     // ✅ FIX: Handle addresses passed from checkout properly
//     _localAddresses = widget.savedAddresses != null && widget.savedAddresses!.isNotEmpty
//         ? List.from(widget.savedAddresses!)
//         : [];
    
//     // Auto-select first address if available
//     if (_localAddresses.isNotEmpty) {
//       _selectedLocation = _localAddresses.first;
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _newAddressController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleUseCurrentLocation() async {
//     if (!mounted) return;

//     setState(() => _isLoadingLocation = true);

//     try {
//       // Check and request location permission
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           if (!mounted) return;
//           AppSnackBar.show(
//             context,
//             message: 'Location permission required',
//             type: AppSnackBarType.warning,
//           );
//           setState(() => _isLoadingLocation = false);
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         if (!mounted) return;
//         AppSnackBar.show(
//           context,
//           message: 'Location permission permanently denied',
//           type: AppSnackBarType.error,
//         );
//         setState(() => _isLoadingLocation = false);
//         return;
//       }

//       // Get current position
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       if (!mounted) return;

//       // Reverse geocode to get address
//       try {
//         final placemarks = await geocoding.placemarkFromCoordinates(
//           position.latitude,
//           position.longitude,
//         );

//         String addressLabel = 'Current Location';
//         if (placemarks.isNotEmpty) {
//           final place = placemarks.first;
//           addressLabel =
//               '${place.street}, ${place.locality}, ${place.postalCode}';
//         }

//         final location = DeliveryLocation(
//           label: addressLabel,
//           addressId: null,
//           lat: position.latitude,
//           lng: position.longitude,
//         );

//         setState(() {
//           _selectedLocation = location;
//           _mapAddress = addressLabel;
//           _isLoadingLocation = false;
//         });

//         AppSnackBar.show(
//           context,
//           message: 'Location loaded successfully',
//           type: AppSnackBarType.success,
//         );
//       } catch (e) {
//         if (kDebugMode) debugPrint('Geocoding error: $e');
//         // Store location without address lookup on geocoding failure
//         final location = DeliveryLocation(
//           label:
//               'Location (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})',
//           addressId: null,
//           lat: position.latitude,
//           lng: position.longitude,
//         );

//         setState(() {
//           _selectedLocation = location;
//           _mapAddress = location.label;
//           _isLoadingLocation = false;
//         });
//       }
//     } catch (error) {
//       if (!mounted) return;
//       if (kDebugMode) debugPrint('Error getting location: $error');
//       setState(() => _isLoadingLocation = false);
//       AppSnackBar.show(
//         context,
//         message: 'Failed to get location',
//         type: AppSnackBarType.error,
//       );
//     }
//   }

//   void _handleAddNewAddress() {
//     final label = _newAddressController.text.trim();
//     if (label.isEmpty) {
//       AppSnackBar.show(
//         context,
//         message: 'Please enter an address',
//         type: AppSnackBarType.warning,
//       );
//       return;
//     }

//     final newLocation = DeliveryLocation(
//       label: label,
//       addressId: DateTime.now().millisecondsSinceEpoch.toString(),
//       lat: null,
//       lng: null,
//     );

//     setState(() {
//       _localAddresses.add(newLocation);
//       _selectedLocation = newLocation;
//       _newAddressController.clear();
//     });

//     AppSnackBar.show(
//       context,
//       message: 'Address added successfully',
//       type: AppSnackBarType.success,
//     );
//   }

//   Future<void> _handleConfirm() async {
//     if (_selectedLocation == null) {
//       AppSnackBar.show(
//         context,
//         message: 'Please select a delivery address',
//         type: AppSnackBarType.warning,
//       );
//       return;
//     }

//     // ✅ FIX: Ensure location has valid lat/lng before confirming
//     final location = _selectedLocation;
//     final hasCoordinates = location?.lat != null && location?.lng != null;
    
//     if (!hasCoordinates && (_selectedLocation?.lat == null || _selectedLocation?.lng == null)) {
//       AppSnackBar.show(
//         context,
//         message: 'Please provide coordinates or use "Use Current Location"',
//         type: AppSnackBarType.warning,
//       );
//       return;
//     }

//     setState(() => _isConfirming = true);

//     try {
//       // Simulate backend confirmation delay
//       await Future.delayed(const Duration(milliseconds: 500));

//       if (!mounted) return;
//       Navigator.pop(context, _selectedLocation);
//     } finally {
//       if (mounted) setState(() => _isConfirming = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Delivery Location'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'Saved Addresses', icon: Icon(Icons.home)),
//             Tab(text: 'Map', icon: Icon(Icons.location_on)),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           // Tab 1: Saved Addresses
//           _buildSavedAddressesTab(),
//           // Tab 2: Map
//           _buildMapTab(),
//         ],
//       ),
//       bottomNavigationBar: Padding(
//         padding: AppTheme.padding,
//         child: SafeArea(
//           child: SizedBox(
//             width: double.infinity,
//             child: AppButton(
//               label: 'Confirm Location',
//               onPressed: (_selectedLocation == null || _isConfirming)
//                   ? null
//                   : _handleConfirm,
//               leading: _isConfirming
//                   ? const SizedBox(
//                       width: 18,
//                       height: 18,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                   : null,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSavedAddressesTab() {
//     return SingleChildScrollView(
//       padding: AppTheme.padding,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Your Saved Addresses',
//             style: AppTextStyles.titleMedium,
//           ),
//           const SizedBox(height: AppSpacing.md),
//           if (_localAddresses.isEmpty)
//             Center(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.home_outlined,
//                       size: 64,
//                       color: Colors.grey.shade400,
//                     ),
//                     const SizedBox(height: AppSpacing.md),
//                     Text(
//                       'No saved addresses yet',
//                       style: AppTextStyles.bodyMedium
//                           .copyWith(color: Colors.grey.shade600),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           else
//             ..._localAddresses.map((address) {
//               final isSelected = _selectedLocation?.label == address.label;
//               return GestureDetector(
//                 onTap: () => setState(() => _selectedLocation = address),
//                 child: Container(
//                   margin: const EdgeInsets.only(bottom: AppSpacing.md),
//                   padding: AppSpacing.insetsMd,
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: isSelected ? AppColors.primary : Colors.grey[300]!,
//                       width: isSelected ? 2 : 1,
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                     color: isSelected
//                         ? AppColors.primary.withOpacity(0.05)
//                         : Colors.transparent,
//                   ),
//                   child: Row(
//                     children: [
//                       Radio(
//                         value: address.label,
//                         groupValue:
//                             _selectedLocation?.label ?? '',
//                         onChanged: (value) =>
//                             setState(() => _selectedLocation = address),
//                       ),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               address.label,
//                               style: AppTextStyles.bodyMedium,
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//           const SizedBox(height: AppSpacing.lg),
//           Text(
//             'Add New Address',
//             style: AppTextStyles.titleSmall,
//           ),
//           const SizedBox(height: AppSpacing.md),
//           Row(
//             children: [
//               Expanded(
//                 child: AppTextField(
//                   controller: _newAddressController,
//                   label: 'Address',
//                   hintText: 'Enter delivery address',
//                   prefixIcon: const Icon(Icons.location_on_outlined),
//                 ),
//               ),
//               const SizedBox(width: AppSpacing.md),
//               Padding(
//                 padding: const EdgeInsets.only(top: AppSpacing.lg),
//                 child: SizedBox(
//                   height: 56,
//                   child: AppButton(
//                     label: 'Add',
//                     onPressed: _handleAddNewAddress,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: AppSpacing.xl),
//         ],
//       ),
//     );
//   }

//   Widget _buildMapTab() {
//     return Stack(
//       children: [
//         // Map placeholder - replace with actual Google Maps when keys are configured
//         Container(
//           color: Colors.grey[200],
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.map_outlined,
//                   size: 80,
//                   color: Colors.grey.shade400,
//                 ),
//                 const SizedBox(height: AppSpacing.lg),
//                 Padding(
//                   padding: AppTheme.padding,
//                   child: Text(
//                     'Google Maps integration requires API keys. Add to AndroidManifest.xml and AppDelegate.swift',
//                     style: AppTextStyles.bodySmall
//                         .copyWith(color: Colors.grey.shade600),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         // Location confirmation card at bottom
//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           child: Container(
//             margin: AppTheme.padding,
//             padding: AppSpacing.insetsMd,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withAlpha(25),
//                   blurRadius: 8,
//                   offset: const Offset(0, -2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Selected Location',
//                   style: AppTextStyles.titleSmall,
//                 ),
//                 const SizedBox(height: AppSpacing.sm),
//                 Text(
//                   _mapAddress.isNotEmpty
//                       ? _mapAddress
//                       : 'Tap to select a location',
//                   style: AppTextStyles.bodySmall,
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: AppSpacing.md),
//                 SizedBox(
//                   width: double.infinity,
//                   child: AppButton(
//                     label: _isLoadingLocation ? 'Loading...' : 'Use Current Location',
//                     onPressed:
//                         _isLoadingLocation ? null : _handleUseCurrentLocation,
//                     leading: _isLoadingLocation
//                         ? const SizedBox(
//                             width: 18,
//                             height: 18,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : const Icon(Icons.gps_fixed),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
