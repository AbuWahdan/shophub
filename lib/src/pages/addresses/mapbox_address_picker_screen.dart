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
  bool _isLocatingUser = false;

  // True when GPS is unavailable and no initial coords were provided.
  // Shows an informational message in the bottom card.
  bool _gpsUnavailable = false;

  @override
  void initState() {
    super.initState();
    _resolveInitialLocation();
  }

  // ── Initial location ───────────────────────────────────────────────────────

  Future<void> _resolveInitialLocation() async {
    // 1. Caller passed explicit coords (editing an existing address)
    final initialLat = widget.initialLatitude;
    final initialLng = widget.initialLongitude;
    if (initialLat != null && initialLng != null) {
      await _setSelection(
        latitude: initialLat,
        longitude: initialLng,
        reverseGeocode: true,
      );
      return;
    }

    // 2. Try GPS
    final position = await _resolveDevicePosition();
    if (position != null) {
      await _setSelection(
        latitude: position.latitude,
        longitude: position.longitude,
        reverseGeocode: true,
      );
      return;
    }

    // 3. GPS truly unavailable — show world view + message, no silent fallback
    if (!mounted) return;
    setState(() {
      _isLoadingInitialLocation = false;
      _gpsUnavailable = true;
    });
  }

  Future<geo.Position?> _resolveDevicePosition() async {
    try {
      final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }
      if (permission != geo.LocationPermission.always &&
          permission != geo.LocationPermission.whileInUse) {
        return null;
      }

      // Try last known first (instant) — better UX than waiting 12s on cold start
      final last = await geo.Geolocator.getLastKnownPosition();
      if (last != null) return last;

      return await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (_) {
      return null;
    }
  }

  // ── FAB: go to my location ─────────────────────────────────────────────────

  Future<void> _goToMyLocation() async {
    if (_isLocatingUser) return;
    setState(() => _isLocatingUser = true);

    try {
      final position = await _resolveDevicePosition();
      if (!mounted) return;

      if (position == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location unavailable. Please enable GPS in your device settings.',
            ),
          ),
        );
        return;
      }

      setState(() => _gpsUnavailable = false);
      await _setSelection(
        latitude: position.latitude,
        longitude: position.longitude,
        reverseGeocode: true,
      );
    } finally {
      if (mounted) setState(() => _isLocatingUser = false);
    }
  }

  // ── Selection & camera ─────────────────────────────────────────────────────

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
      await mapboxMap.flyTo(
        CameraOptions(
          center: Point(coordinates: Position(longitude, latitude)),
          zoom: 15.5,
        ),
        MapAnimationOptions(duration: 500),
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
        throw Exception('Geocoding failed');
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>? ?? const [];
      final placeName = features.isNotEmpty
          ? (features.first as Map<String, dynamic>)['place_name']
                    ?.toString() ??
                ''
          : '';
      if (!mounted) return;
      setState(() => _selectedAddress = placeName.trim());
    } catch (_) {
      if (!mounted) return;
      setState(() => _selectedAddress = '');
    } finally {
      if (mounted) setState(() => _isResolvingAddress = false);
    }
  }

  // ── Map callbacks ──────────────────────────────────────────────────────────

  Future<void> _handleMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    final lat = _selectedLatitude;
    final lng = _selectedLongitude;
    if (lat == null || lng == null) return;
    await mapboxMap.setCamera(
      CameraOptions(center: Point(coordinates: Position(lng, lat)), zoom: 15.5),
    );
  }

  Future<void> _handleMapIdle(MapIdleEventData _) async {
    final mapboxMap = _mapboxMap;
    if (mapboxMap == null) return;

    final cameraState = await mapboxMap.getCameraState();
    final center = cameraState.center.coordinates;
    final lat = center.lat.toDouble();
    final lng = center.lng.toDouble();

    // Sub-pixel epsilon prevents infinite geocode loops from camera drift
    if (_selectedLatitude != null &&
        _selectedLongitude != null &&
        (lat - _selectedLatitude!).abs() < 0.00001 &&
        (lng - _selectedLongitude!).abs() < 0.00001) {
      return;
    }

    await _setSelection(latitude: lat, longitude: lng, reverseGeocode: true);
  }

  // ── Confirm ────────────────────────────────────────────────────────────────

  void _confirmSelection() {
    final lat = _selectedLatitude;
    final lng = _selectedLongitude;
    if (lat == null || lng == null) return;

    Navigator.of(context).pop(
      MapPickerResult(
        latitude: lat,
        longitude: lng,
        address: _selectedAddress.trim(),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final lat = _selectedLatitude;
    final lng = _selectedLongitude;
    final hasSelection = lat != null && lng != null;

    // World view when GPS unavailable and no initial coords
    final initialCamera = hasSelection
        ? CameraOptions(
            center: Point(coordinates: Position(lng, lat)),
            zoom: 15.5,
          )
        : CameraOptions(center: Point(coordinates: Position(0, 20)), zoom: 1.5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick location'),
        // Back arrow silently discards — no dialog
        actions: [
          TextButton(
            onPressed: hasSelection ? _confirmSelection : null,
            child: const Text('Confirm'),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'my_location_fab',
            onPressed: _isLocatingUser ? null : _goToMyLocation,
            tooltip: 'My location',
            child: _isLocatingUser
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
          ),
          const SizedBox(height: AppSpacing.sm),
          FloatingActionButton.extended(
            heroTag: 'confirm_fab',
            onPressed: hasSelection ? _confirmSelection : null,
            icon: const Icon(Icons.check),
            label: const Text('Use location'),
          ),
        ],
      ),
      body: _isLoadingInitialLocation
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                MapWidget(
                  key: const ValueKey('address_map_widget'),
                  styleUri: MapboxStyles.STANDARD,
                  cameraOptions: initialCamera,
                  onMapCreated: _handleMapCreated,
                  onMapIdleListener: _handleMapIdle,
                ),

                // Pin — only visible when a location is selected
                if (hasSelection)
                  const IgnorePointer(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 46),
                        child: Icon(
                          Icons.location_pin,
                          size: 46,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),

                // Bottom card
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
                            // GPS unavailable notice
                            if (_gpsUnavailable)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_off_outlined,
                                      size: 16,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Expanded(
                                      child: Text(
                                        'GPS is off. Enable location services '
                                        'or move the map to pick manually.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.error,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            Text(
                              _selectedAddress.isNotEmpty
                                  ? _selectedAddress
                                  : (_isResolvingAddress
                                        ? 'Resolving address…'
                                        : 'Move the map to choose a location'),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),

                            if (hasSelection) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                '${lat.toStringAsFixed(5)}, '
                                '${lng.toStringAsFixed(5)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],

                            const SizedBox(height: AppSpacing.md),
                            AppButton(
                              label: 'Use this location',
                              onPressed: hasSelection
                                  ? _confirmSelection
                                  : null,
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
