import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/waypoint.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import '../widgets/edit_waypoint_dialog.dart';
import '../widgets/waypoint_card.dart';

class HistoryScreen extends StatefulWidget {
  final StorageService storageService;
  final LocationService locationService;
  final VoidCallback onTargetSelected;

  const HistoryScreen({
    super.key,
    required this.storageService,
    required this.locationService,
    required this.onTargetSelected,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Waypoint> _waypoints = [];
  String? _activeId;
  Position? _currentPosition;
  bool _useImperial = true;

  @override
  void initState() {
    super.initState();
    _refreshList();
    widget.storageService.addListener(_refreshList);
    _fetchCurrentPosition();
  }

  @override
  void dispose() {
    widget.storageService.removeListener(_refreshList);
    super.dispose();
  }

  void _refreshList() {
    setState(() {
      _waypoints = widget.storageService.getWaypoints();
      _activeId = widget.storageService.getActiveWaypointId();
      _useImperial = widget.storageService.getUseImperial();
    });
  }

  Future<void> _fetchCurrentPosition() async {
    final pos = await widget.locationService.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = pos;
      });
    }
  }

  Future<void> _selectTarget(String id) async {
    await widget.storageService.setActiveWaypointId(id);
    _refreshList();
    widget.onTargetSelected();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Target locked on homing compass!'),
          backgroundColor: Color(0xFF38BDF8),
        ),
      );
    }
  }

  Future<void> _editWaypoint(Waypoint waypoint) async {
    final updated = await showDialog<Waypoint>(
      context: context,
      builder: (context) => EditWaypointDialog(waypoint: waypoint),
    );

    if (updated != null) {
      await widget.storageService.updateWaypoint(updated);
      _refreshList();
    }
  }

  Future<void> _deleteWaypoint(Waypoint waypoint) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Delete Pin?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${waypoint.name}"?',
          style: const TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.storageService.deleteWaypoint(waypoint.id);
      _refreshList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'SAVED PINS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            fontSize: 18,
          ),
        ),
      ),
      body: _waypoints.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pin_drop_outlined,
                      size: 48,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No saved pins yet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Drop a pin on the radar screen to save your spot.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFF38BDF8),
              backgroundColor: const Color(0xFF1E293B),
              onRefresh: () async {
                await _fetchCurrentPosition();
                _refreshList();
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _waypoints.length,
                itemBuilder: (context, index) {
                  final waypoint = _waypoints[index];
                  final isActive = waypoint.id == _activeId;
                  return WaypointCard(
                    waypoint: waypoint,
                    isActive: isActive,
                    currentLat: _currentPosition?.latitude,
                    currentLon: _currentPosition?.longitude,
                    useImperial: _useImperial,
                    onSelect: () => _selectTarget(waypoint.id),
                    onDelete: () => _deleteWaypoint(waypoint),
                    onEdit: () => _editWaypoint(waypoint),
                  );
                },
              ),
            ),
    );
  }
}
