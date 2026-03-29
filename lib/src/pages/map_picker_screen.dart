import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/delivery_location.dart';
import '../shared/widgets/app_snackbar.dart';
import '../themes/theme.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  static const LatLng _fallbackLocation = LatLng(31.9539, 35.9106);

  GoogleMapController? _mapController;
  LatLng _selectedPosition = _fallbackLocation;
  String _selectedAddress = '';
  bool _isResolvingAddress = false;
  bool _isLoadingCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _useCurrentLocation(silentFailure: true);
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation({bool silentFailure = false}) async {
    if (_isLoadingCurrentLocation) {
      return;
    }

    setState(() {
      _isLoadingCurrentLocation = true;
    });

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!silentFailure && mounted) {
          AppSnackBar.show(
            context,
            message:
                'Location permission is required to use your current location',
            type: AppSnackBarType.warning,
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final target = LatLng(position.latitude, position.longitude);

      if (!mounted) return;
      setState(() {
        _selectedPosition = target;
      });
      await _mapController?.animateCamera(CameraUpdate.newLatLng(target));
      await _resolveAddress(target);
    } catch (error) {
      if (!silentFailure && mounted) {
        AppSnackBar.show(
          context,
          message: 'Failed to load current location',
          type: AppSnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCurrentLocation = false;
        });
      }
    }
  }

  Future<void> _resolveAddress(LatLng position) async {
    setState(() {
      _isResolvingAddress = true;
      _selectedPosition = position;
    });

    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      final place = placemarks.isNotEmpty ? placemarks.first : null;
      final parts = <String>[
        if ((place?.street ?? '').trim().isNotEmpty) place!.street!.trim(),
        if ((place?.locality ?? '').trim().isNotEmpty) place!.locality!.trim(),
        if ((place?.administrativeArea ?? '').trim().isNotEmpty)
          place!.administrativeArea!.trim(),
        if ((place?.country ?? '').trim().isNotEmpty) place!.country!.trim(),
      ];

      setState(() {
        _selectedAddress = parts.isEmpty
            ? '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}'
            : parts.join(', ');
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _selectedAddress =
            '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResolvingAddress = false;
        });
      }
    }
  }

  void _confirmSelection() {
    Navigator.of(context).pop(
      DeliveryLocation(
        label: _selectedAddress.isEmpty
            ? '${_selectedPosition.latitude.toStringAsFixed(6)}, ${_selectedPosition.longitude.toStringAsFixed(6)}'
            : _selectedAddress,
        lat: _selectedPosition.latitude,
        lng: _selectedPosition.longitude,
        isCurrentLocation: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Location')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onTap: _resolveAddress,
            markers: {
              Marker(
                markerId: const MarkerId('selected_address'),
                position: _selectedPosition,
              ),
            },
          ),
          Positioned(
            right: AppSpacing.md,
            top: AppSpacing.md,
            child: FloatingActionButton.small(
              heroTag: 'current_location_fab',
              onPressed: _isLoadingCurrentLocation
                  ? null
                  : () => _useCurrentLocation(),
              child: _isLoadingCurrentLocation
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: Card(
              child: Padding(
                padding: AppTheme.padding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected address',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _isResolvingAddress
                          ? 'Resolving address...'
                          : (_selectedAddress.isEmpty
                                ? 'Tap on the map to choose a location'
                                : _selectedAddress),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${_selectedPosition.latitude.toStringAsFixed(6)}, ${_selectedPosition.longitude.toStringAsFixed(6)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isResolvingAddress
                            ? null
                            : _confirmSelection,
                        child: const Text('Use This Location'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
