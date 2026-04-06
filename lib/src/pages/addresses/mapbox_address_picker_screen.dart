import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../config/mapbox_config.dart';
import '../../design/app_spacing.dart';
import '../../shared/widgets/app_button.dart';
import 'map_picker_result.dart';

class MapboxAddressPickerScreen extends StatefulWidget {
  const MapboxAddressPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<MapboxAddressPickerScreen> createState() =>
      _MapboxAddressPickerScreenState();
}

class _MapboxAddressPickerScreenState extends State<MapboxAddressPickerScreen> {
  MapboxMap? _mapboxMap;
  double? _selectedLatitude;
  double? _selectedLongitude;
  String _selectedAddress = '';
  bool _isResolvingAddress = false;
  bool _isLoadingInitialLocation = true;

  @override
  void initState() {
    super.initState();
    _resolveInitialLocation();
  }

  Future<void> _resolveInitialLocation() async {
    final initialLatitude = widget.initialLatitude;
    final initialLongitude = widget.initialLongitude;

    if (initialLatitude != null && initialLongitude != null) {
      await _setSelection(
        latitude: initialLatitude,
        longitude: initialLongitude,
        reverseGeocode: true,
      );
      return;
    }

    final currentPosition = await _resolveDevicePosition();
    if (currentPosition != null) {
      await _setSelection(
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
        reverseGeocode: true,
      );
      return;
    }

    await _setSelection(
      latitude: MapboxConfig.fallbackLatitude,
      longitude: MapboxConfig.fallbackLongitude,
      reverseGeocode: true,
    );
  }

  Future<geo.Position?> _resolveDevicePosition() async {
    try {
      final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      var permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }

      if (permission != geo.LocationPermission.always &&
          permission != geo.LocationPermission.whileInUse) {
        return null;
      }

      try {
        return await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high,
          timeLimit: const Duration(seconds: 12),
        );
      } catch (_) {
        return await geo.Geolocator.getLastKnownPosition();
      }
    } catch (_) {
      return null;
    }
  }

  Future<void> _setSelection({
    required double latitude,
    required double longitude,
    required bool reverseGeocode,
  }) async {
    if (!mounted) return;

    setState(() {
      _selectedLatitude = latitude;
      _selectedLongitude = longitude;
      _isLoadingInitialLocation = false;
    });

    final mapboxMap = _mapboxMap;
    if (mapboxMap != null) {
      await mapboxMap.setCamera(
        CameraOptions(
          center: Point(coordinates: Position(longitude, latitude)),
          zoom: 15.5,
        ),
      );
    }

    if (reverseGeocode) {
      await _reverseGeocode(latitude: latitude, longitude: longitude);
    }
  }

  Future<void> _reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    if (!mounted) return;

    setState(() => _isResolvingAddress = true);

    final uri =
        Uri.parse(
          'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude,$latitude.json',
        ).replace(
          queryParameters: {
            'access_token': MapboxConfig.accessToken,
            'limit': '1',
            'language': 'en',
          },
        );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Mapbox geocoding failed.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final features = (data['features'] as List<dynamic>? ?? const []);
      final placeName = features.isNotEmpty
          ? (features.first as Map<String, dynamic>)['place_name']
                    ?.toString() ??
                ''
          : '';

      if (!mounted) return;
      setState(() {
        _selectedAddress = placeName.trim();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _selectedAddress = '';
      });
    } finally {
      if (mounted) {
        setState(() => _isResolvingAddress = false);
      }
    }
  }

  Future<void> _handleMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    final latitude = _selectedLatitude;
    final longitude = _selectedLongitude;
    if (latitude == null || longitude == null) {
      return;
    }

    await mapboxMap.setCamera(
      CameraOptions(
        center: Point(coordinates: Position(longitude, latitude)),
        zoom: 15.5,
      ),
    );
  }

  Future<void> _handleMapIdle(MapIdleEventData _) async {
    final mapboxMap = _mapboxMap;
    if (mapboxMap == null) return;

    final cameraState = await mapboxMap.getCameraState();
    final center = cameraState.center.coordinates;

    if (_selectedLatitude == center.lat && _selectedLongitude == center.lng) {
      return;
    }

    await _setSelection(
      latitude: center.lat.toDouble(),
      longitude: center.lng.toDouble(),
      reverseGeocode: true,
    );
  }

  void _confirmSelection() {
    final latitude = _selectedLatitude;
    final longitude = _selectedLongitude;
    if (latitude == null || longitude == null) {
      return;
    }

    Navigator.of(context).pop(
      MapPickerResult(
        latitude: latitude,
        longitude: longitude,
        address: _selectedAddress.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latitude = _selectedLatitude;
    final longitude = _selectedLongitude;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick location'),
        actions: [
          TextButton(
            onPressed: _selectedLatitude == null || _selectedLongitude == null
                ? null
                : _confirmSelection,
            child: const Text('Confirm'),
          ),
        ],
      ),
      body: latitude == null || longitude == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                MapWidget(
                  key: const ValueKey('address_map_widget'),
                  styleUri: MapboxStyles.STANDARD,
                  cameraOptions: CameraOptions(
                    center: Point(coordinates: Position(longitude, latitude)),
                    zoom: 15.5,
                  ),
                  onMapCreated: _handleMapCreated,
                  onMapIdleListener: _handleMapIdle,
                ),
                const IgnorePointer(
                  child: Center(
                    child: Icon(
                      Icons.location_pin,
                      size: 46,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                if (_isLoadingInitialLocation)
                  const Positioned(
                    top: AppSpacing.md,
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    child: LinearProgressIndicator(),
                  ),
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: SafeArea(
                    top: false,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedAddress.trim().isNotEmpty
                                  ? _selectedAddress
                                  : (_isResolvingAddress
                                        ? 'Resolving address...'
                                        : 'Move the map to choose a location'),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppButton(
                              label: 'Use this location',
                              onPressed:
                                  _selectedLatitude == null ||
                                      _selectedLongitude == null
                                  ? null
                                  : _confirmSelection,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
