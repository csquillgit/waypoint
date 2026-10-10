import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/waypoint.dart';
import '../utils/geo_math.dart';

class WaypointCard extends StatelessWidget {
  final Waypoint waypoint;
  final bool isActive;
  final double? currentLat;
  final double? currentLon;
  final bool useImperial;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  const WaypointCard({
    super.key,
    required this.waypoint,
    required this.isActive,
    required this.onSelect,
    required this.onDelete,
    this.currentLat,
    this.currentLon,
    this.useImperial = true,
  });

  @override
  Widget build(BuildContext context) {
    String? distanceText;
    if (currentLat != null && currentLon != null) {
      final meters = GeoMath.calculateDistance(
        lat1: currentLat!,
        lon1: currentLon!,
        lat2: waypoint.latitude,
        lon2: waypoint.longitude,
      );
      distanceText = GeoMath.formatDistance(meters, imperial: useImperial);
    }

    final formattedDate = DateFormat('MMM d, h:mm a').format(waypoint.createdAt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1E293B) : const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFF38BDF8) : const Color(0xFF1E293B),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF38BDF8).withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF38BDF8).withOpacity(0.2)
                : const Color(0xFF1F2937),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(waypoint.category),
            color: isActive ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8),
            size: 26,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                waypoint.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'LOCKED TARGET',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (waypoint.note != null && waypoint.note!.isNotEmpty) ...[
              Text(
                waypoint.note!,
                style: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                if (distanceText != null) ...[
                  Text(
                    distanceText,
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const Text(
                    ' • ',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isActive)
              IconButton(
                icon: const Icon(
                  Icons.navigation_rounded,
                  color: Color(0xFF38BDF8),
                ),
                tooltip: 'Lock as target',
                onPressed: onSelect,
              ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFEF4444),
                size: 20,
              ),
              tooltip: 'Delete pin',
              onPressed: onDelete,
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
