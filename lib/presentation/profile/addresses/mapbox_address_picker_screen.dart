import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../core/app/app_theme.dart';
import '../../../core/config/mapbox_config.dart';
import '../../../design/app_spacing.dart';
import '../../../models/addresses/map_picker_result_model.dart';
import '../../../widgets/widgets/app_button.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const double _kDefaultMapZoom = 15.5;
const double _kWorldViewZoom = 1.5;
const double _kCoordDriftEpsilon = 0.00001;
const double _kPinIconSize = 46.0;
const double _kPinBottomOffset = 46.0;
const int _kFlyToDurationMs = 500;
const int _kGeocodingTimeoutSeconds = 12;
const int _kLocationTimeoutSeconds = 15;
const String _kGeocodingLanguage = 'en';
const int _kGeocodingResultLimit = 1;

// ── Screen ────────────────────────────────────────────────────────────────────

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

class _MapboxAddressPickerScreenState
    extends State<MapboxAddressPickerScreen> {
  // ── Map state ──────────────────────────────────────────────────────────────

  MapboxMap? _mapboxMap;

  double? _pinnedLatitude;
  double? _pinnedLongitude;
  String _resolvedAddress = '';

  bool _isResolvingAddress = false;
  bool _isLoadingInitialLocation = true;
  bool _isLocatingUser = false;

  /// Prevents first idle callback from triggering unwanted pin updates.
  bool _suppressNextIdleEvent = false;

  /// Prevents map callbacks/state updates while the screen is closing.
  bool _isClosing = false;

  bool get _hasPin => _pinnedLatitude != null && _pinnedLongitude != null;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _resolveInitialLocation();
  }

  @override
  void dispose() {
    _isClosing = true;
    _mapboxMap = null;
    super.dispose();
  }

  // ── Initial location ───────────────────────────────────────────────────────

  Future<void> _resolveInitialLocation() async {
    final lat = widget.initialLatitude;
    final lng = widget.initialLongitude;

    if (lat != null && lng != null) {
      await _pinLocation(
        latitude: lat,
        longitude: lng,
        reverseGeocode: true,
      );
      return;
    }

    if (!mounted || _isClosing) return;

    setState(() {
      _isLoadingInitialLocation = false;
      _suppressNextIdleEvent = true;
    });
  }

  // ── My-location FAB ────────────────────────────────────────────────────────

  Future<void> _goToMyLocation() async {
    if (_isLocatingUser || _isClosing) return;

    setState(() => _isLocatingUser = true);

    try {
      final position = await _resolveDevicePosition();

      if (!mounted || _isClosing) return;

      if (position == null) {
        _showLocationUnavailableSnackBar();
        return;
      }

      await _pinLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        reverseGeocode: true,
      );
    } finally {
      if (mounted && !_isClosing) {
        setState(() => _isLocatingUser = false);
      }
    }
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

      final lastKnown = await geo.Geolocator.getLastKnownPosition();

      if (lastKnown != null) return lastKnown;

      return await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
        timeLimit: const Duration(seconds: _kLocationTimeoutSeconds),
      );
    } catch (_) {
      return null;
    }
  }

  void _showLocationUnavailableSnackBar() {
    if (!mounted || _isClosing) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Location unavailable. Please enable GPS in your device settings.',
        ),
      ),
    );
  }

  // ── Pin & camera ───────────────────────────────────────────────────────────

  Future<void> _pinLocation({
    required double latitude,
    required double longitude,
    required bool reverseGeocode,
  }) async {
    if (!mounted || _isClosing) return;

    setState(() {
      _pinnedLatitude = latitude;
      _pinnedLongitude = longitude;
      _isLoadingInitialLocation = false;
    });

    final map = _mapboxMap;

    if (map != null && !_isClosing) {
      await map.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(longitude, latitude),
          ),
          zoom: _kDefaultMapZoom,
        ),
        MapAnimationOptions(duration: _kFlyToDurationMs),
      );
    }

    if (reverseGeocode && !_isClosing) {
      await _reverseGeocode(
        latitude: latitude,
        longitude: longitude,
      );
    }
  }

  // ── Reverse geocoding ──────────────────────────────────────────────────────

  Future<void> _reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    if (!mounted || _isClosing) return;

    setState(() => _isResolvingAddress = true);

    final uri = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude,$latitude.json',
    ).replace(
      queryParameters: {
        'access_token': MapboxConfig.accessToken,
        'limit': '$_kGeocodingResultLimit',
        'language': _kGeocodingLanguage,
      },
    );

    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: _kGeocodingTimeoutSeconds));

      if (_isClosing || !mounted) return;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Reverse geocoding failed');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final features = data['features'] as List<dynamic>? ?? const [];

      final placeName = features.isNotEmpty
          ? (features.first as Map<String, dynamic>)['place_name']
          ?.toString() ??
          ''
          : '';

      if (!mounted || _isClosing) return;

      setState(() {
        _resolvedAddress = placeName.trim();
      });
    } catch (_) {
      if (!mounted || _isClosing) return;

      setState(() {
        _resolvedAddress = '';
      });
    } finally {
      if (mounted && !_isClosing) {
        setState(() => _isResolvingAddress = false);
      }
    }
  }

  // ── Map Callbacks ──────────────────────────────────────────────────────────

  Future<void> _onMapCreated(MapboxMap map) async {
    if (_isClosing) return;

    _mapboxMap = map;

    final lat = _pinnedLatitude;
    final lng = _pinnedLongitude;

    if (lat == null || lng == null) return;

    await map.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(lng, lat),
        ),
        zoom: _kDefaultMapZoom,
      ),
    );
  }

  Future<void> _onMapIdle(MapIdleEventData _) async {
    if (_isClosing || !mounted) return;

    final map = _mapboxMap;

    if (map == null) return;

    if (_suppressNextIdleEvent) {
      _suppressNextIdleEvent = false;
      return;
    }

    final cameraState = await map.getCameraState();

    if (_isClosing || !mounted) return;

    final centre = cameraState.center.coordinates;

    final lat = centre.lat.toDouble();
    final lng = centre.lng.toDouble();

    if (_hasPin &&
        (lat - _pinnedLatitude!).abs() < _kCoordDriftEpsilon &&
        (lng - _pinnedLongitude!).abs() < _kCoordDriftEpsilon) {
      return;
    }

    await _pinLocation(
      latitude: lat,
      longitude: lng,
      reverseGeocode: true,
    );
  }

  // ── Confirm ────────────────────────────────────────────────────────────────

  void _confirmSelection() {
    if (!_hasPin || _isClosing) return;

    _isClosing = true;

    Navigator.of(context).pop(
      MapPickerResultModel(
        latitude: _pinnedLatitude!,
        longitude: _pinnedLongitude!,
        address: _resolvedAddress,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitialLocation) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final initialCamera = _hasPin
        ? CameraOptions(
      center: Point(
        coordinates: Position(
          _pinnedLongitude!,
          _pinnedLatitude!,
        ),
      ),
      zoom: _kDefaultMapZoom,
    )
        : CameraOptions(
      center: Point(
        coordinates: Position(0, 20),
      ),
      zoom: _kWorldViewZoom,
    );

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: MapWidget(
              key: const ValueKey('address_map_widget'),
              styleUri: MapboxStyles.STANDARD,
              cameraOptions: initialCamera,
              onMapCreated: _onMapCreated,
              onMapIdleListener: _onMapIdle,
            ),
          ),

          // ── Back Button ──────────────────────────────────────────────────
          Positioned(
            top: topPadding + AppSpacing.md,
            left: AppSpacing.md,
            child: FloatingActionButton.small(
              heroTag: 'map_back_fab',
              onPressed: () {
                _isClosing = true;
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.arrow_back),
            ),
          ),

          // ── Center Pin ──────────────────────────────────────────────────
          if (_hasPin)
            IgnorePointer(
              child: Align(
                alignment: Alignment.center,
                child: Transform.translate(
                  offset: const Offset(
                    0,
                    -_kPinBottomOffset / 2,
                  ),
                  child: const Icon(
                    Icons.location_pin,
                    size: _kPinIconSize,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),

          // ── My Location FAB ─────────────────────────────────────────────
          Positioned(
            right: AppSpacing.md,
            bottom: bottomPadding + 196,
            child: FloatingActionButton.small(
              heroTag: 'my_location_fab',
              onPressed: _isLocatingUser ? null : _goToMyLocation,
              tooltip: 'My location',
              child: _isLocatingUser
                  ? const SizedBox(
                width: AppSpacing.md,
                height: AppSpacing.md,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.my_location),
            ),
          ),

          // ── Bottom Panel ────────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _LocationConfirmPanel(
              resolvedAddress: _resolvedAddress,
              isResolvingAddress: _isResolvingAddress,
              hasPin: _hasPin,
              pinnedLatitude: _pinnedLatitude,
              pinnedLongitude: _pinnedLongitude,
              onConfirm: _confirmSelection,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Panel ──────────────────────────────────────────────────────────────

class _LocationConfirmPanel extends StatelessWidget {
  const _LocationConfirmPanel({
    required this.resolvedAddress,
    required this.isResolvingAddress,
    required this.hasPin,
    required this.pinnedLatitude,
    required this.pinnedLongitude,
    required this.onConfirm,
  });

  final String resolvedAddress;
  final bool isResolvingAddress;
  final bool hasPin;
  final double? pinnedLatitude;
  final double? pinnedLongitude;
  final VoidCallback onConfirm;

  String get _addressLabel {
    if (resolvedAddress.isNotEmpty) return resolvedAddress;

    if (isResolvingAddress) {
      return 'Resolving address…';
    }

    return 'Move the map to choose a location';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _addressLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (hasPin) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${pinnedLatitude!.toStringAsFixed(5)}, '
                  '${pinnedLongitude!.toStringAsFixed(5)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Save Location',
            onPressed: hasPin ? onConfirm : null,
          ),
        ],
      ),
    );
  }
}