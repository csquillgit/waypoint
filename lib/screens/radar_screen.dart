import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/waypoint.dart';
import '../services/compass_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../utils/geo_math.dart';
import '../widgets/compass_view.dart';
import '../widgets/add_waypoint_dialog.dart';
import '../widgets/tactical_legal_sheet.dart';

class RadarScreen extends StatefulWidget {
  final StorageService storageService;
  final LocationService locationService;
  final CompassService compassService;

  const RadarScreen({
    super.key,
    required this.storageService,
    required this.locationService,
    required this.compassService,
  });

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  StreamSubscription<Position>? _positionSub;
  StreamSubscription<double?>? _compassSub;

  Position? _currentPosition;
  double _deviceHeading = 0.0;
  Waypoint? _activeWaypoint;
  bool _useImperial = true;
  bool _isLoadingGps = true;
  String? _gpsError;

  @override
  void initState() {
    super.initState();
    _useImperial = widget.storageService.getUseImperial();
    _loadActiveWaypoint();
    widget.storageService.addListener(_onStorageChanged);
    _startSensors();
  }

  void _onStorageChanged() {
    if (mounted) {
      _loadActiveWaypoint();
    }
  }

  void _loadActiveWaypoint() {
    setState(() {
      _activeWaypoint = widget.storageService.getActiveWaypoint();
      _useImperial = widget.storageService.getUseImperial();
    });
  }

  Future<void> _startSensors() async {
    final hasPerm = await widget.locationService.checkPermission();
    if (!hasPerm) {
      setState(() {
        _isLoadingGps = false;
        _gpsError = 'Location permission is required to calculate direction.';
      });
      return;
    }

    // Get initial position
    final initialPos = await widget.locationService.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = initialPos;
        _isLoadingGps = false;
      });
    }

    // Listen to GPS stream
    _positionSub = widget.locationService.getPositionStream().listen(
      (pos) {
        if (mounted) {
          setState(() {
            _currentPosition = pos;
            _gpsError = null;
          });
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _gpsError = 'GPS signal lost';
          });
        }
      },
    );

    // Listen to Compass stream
    _compassSub = widget.compassService.getHeadingStream().listen((heading) {
      if (heading != null && mounted) {
        setState(() {
          _deviceHeading = (heading + 360.0) % 360.0;
        });
      }
    });
  }

  @override
  void dispose() {
    widget.storageService.removeListener(_onStorageChanged);
    _positionSub?.cancel();
    _compassSub?.cancel();
    super.dispose();
  }

  Future<void> _dropPin(WaypointCategory category) async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waiting for GPS lock before dropping pin...'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final newWaypoint = await showDialog<Waypoint>(
      context: context,
      builder: (context) => AddWaypointDialog(
        currentLat: _currentPosition!.latitude,
        currentLon: _currentPosition!.longitude,
        defaultCategory: category,
      ),
    );

    if (newWaypoint != null) {
      await widget.storageService.saveWaypoint(newWaypoint);
      _loadActiveWaypoint();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pin saved: ${newWaypoint.name}'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double targetBearing = 0.0;
    double distanceMeters = 0.0;
    String formattedDistance = '--';

    if (_currentPosition != null && _activeWaypoint != null) {
      distanceMeters = GeoMath.calculateDistance(
        lat1: _currentPosition!.latitude,
        lon1: _currentPosition!.longitude,
        lat2: _activeWaypoint!.latitude,
        lon2: _activeWaypoint!.longitude,
      );

      targetBearing = GeoMath.calculateBearing(
        startLat: _currentPosition!.latitude,
        startLon: _currentPosition!.longitude,
        targetLat: _activeWaypoint!.latitude,
        targetLon: _activeWaypoint!.longitude,
      );

      formattedDistance = GeoMath.formatDistance(
        distanceMeters,
        imperial: _useImperial,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // ultra dark tactical canvas
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.navigation_rounded,
                color: Color(0xFF38BDF8),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'WAYPOINT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _useImperial ? Icons.straighten_rounded : Icons.square_foot_rounded,
              color: const Color(0xFF94A3B8),
            ),
            tooltip: _useImperial ? 'Using Imperial (ft/mi)' : 'Using Metric (m/km)',
            onPressed: () async {
              setState(() {
                _useImperial = !_useImperial;
              });
              await widget.storageService.setUseImperial(_useImperial);
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF334155)),
            ),
            onSelected: (value) {
              if (value == 'legal') {
                TacticalLegalSheet.show(context, waypointLegal);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'legal',
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Color(0xFF38BDF8), size: 18),
                    SizedBox(width: 10),
                    Text(
                      'Legal & Advisory',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Target Beacon Banner
            if (_activeWaypoint != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF334155),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(_activeWaypoint!.category),
                      color: const Color(0xFF38BDF8),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _activeWaypoint!.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          if (_activeWaypoint!.note != null)
                            Text(
                              _activeWaypoint!.note!,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          GeoMath.getCardinalDirection(targetBearing),
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${targetBearing.round()}°',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Drop a pin below to activate the directional arrow.',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Live Compass Visualizer
            Expanded(
              child: _isLoadingGps
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF38BDF8),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Acquiring Satellite GPS Fix...',
                            style: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    )
                  : _gpsError != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              _gpsError!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFFEF4444)),
                            ),
                          ),
                        )
                      : CompassView(
                          deviceHeading: _deviceHeading,
                          targetBearing: targetBearing,
                          distanceMeters: distanceMeters,
                          formattedDistance: formattedDistance,
                          hasTarget: _activeWaypoint != null,
                        ),
            ),

            // Quick Pin Action Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const Text(
                    'DROP A NEW LOCATION PIN',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.directions_car_filled_rounded,
                          label: 'Parked Car',
                          color: const Color(0xFF38BDF8),
                          onPressed: () => _dropPin(WaypointCategory.car),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.hiking_rounded,
                          label: 'Trailhead',
                          color: const Color(0xFF10B981),
                          onPressed: () => _dropPin(WaypointCategory.trailhead),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.add_location_alt_rounded,
                          label: 'Custom',
                          color: const Color(0xFFA855F7),
                          onPressed: () => _dropPin(WaypointCategory.custom),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(WaypointCategory cat) {
    switch (cat) {
      case WaypointCategory.car:
        return Icons.directions_car_filled_rounded;
      case WaypointCategory.trailhead:
        return Icons.hiking_rounded;
      case WaypointCategory.camp:
        return Icons.cottage_rounded;
      case WaypointCategory.custom:
        return Icons.pin_drop_rounded;
    }
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
