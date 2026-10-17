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
  final VoidCallback? onEdit;

  const WaypointCard({
    super.key,
    required this.waypoint,
    required this.isActive,
    required this.onSelect,
    required this.onDelete,
    this.onEdit,
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                  color: const Color(0xFF38BDF8).withOpacity(0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onSelect,
          onLongPress: onEdit,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Leading Category Icon + Status Dot
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF38BDF8).withOpacity(0.15)
                            : const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive
                              ? const Color(0xFF38BDF8).withOpacity(0.5)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        _getCategoryIcon(waypoint.category),
                        color: isActive ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8),
                        size: 24,
                      ),
                    ),
                    if (isActive)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF1E293B),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),

                // Center Column: Active badge, Pin Name, Note, Distance & Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Active Target Micro-Badge
                      if (isActive) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFF38BDF8).withOpacity(0.35),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.gps_fixed_rounded,
                                size: 10,
                                color: Color(0xFF38BDF8),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'ACTIVE TARGET',
                                style: TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],

                      // Waypoint Name (clean 2-line max with ellipsis)
                      Text(
                        waypoint.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 15,
                          height: 1.25,
                        ),
                      ),

                      if (waypoint.note != null && waypoint.note!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          waypoint.note!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                      ],

                      const SizedBox(height: 4),

                      // Distance & Date Row
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
                ),

                const SizedBox(width: 8),

                // Trailing Column: Selection indicator + Delete Button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Radio / Checkmark Icon showing selection state
                    Icon(
                      isActive
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isActive
                          ? const Color(0xFF38BDF8)
                          : const Color(0xFF475569),
                      size: 22,
                    ),

                    if (onEdit != null) ...[
                      const SizedBox(width: 2),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF94A3B8),
                          size: 19,
                        ),
                        splashRadius: 20,
                        tooltip: 'Edit pin',
                        onPressed: onEdit,
                      ),
                    ],

                    const SizedBox(width: 2),

                    // Delete Pin Button
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                      splashRadius: 20,
                      tooltip: 'Delete pin',
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
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
