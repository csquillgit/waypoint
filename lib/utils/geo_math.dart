import 'dart:math';

class GeoMath {
  static const double earthRadiusMeters = 6371000.0;

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  static double _radiansToDegrees(double radians) {
    return radians * 180.0 / pi;
  }

  /// Calculates the initial bearing from current position to target position in degrees (0..360)
  static double calculateBearing({
    required double startLat,
    required double startLon,
    required double targetLat,
    required double targetLon,
  }) {
    final lat1 = _degreesToRadians(startLat);
    final lat2 = _degreesToRadians(targetLat);
    final dLon = _degreesToRadians(targetLon - startLon);

    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    final bearingRad = atan2(y, x);
    final bearingDeg = (_radiansToDegrees(bearingRad) + 360.0) % 360.0;
    return bearingDeg;
  }

  /// Calculates the direct distance between two coordinates in meters using the Haversine formula
  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final rLat1 = _degreesToRadians(lat1);
    final rLat2 = _degreesToRadians(lat2);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(rLat1) * cos(rLat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  /// Calculates the relative angle for the compass needle to point towards the target.
  /// (Target bearing - Device heading)
  static double calculateRelativeAngle({
    required double deviceHeading,
    required double targetBearing,
  }) {
    final diff = (targetBearing - deviceHeading) % 360.0;
    return (diff + 360.0) % 360.0;
  }

  /// Formats distance in imperial (ft / miles) or metric (m / km)
  static String formatDistance(double meters, {bool imperial = true}) {
    if (imperial) {
      final feet = meters * 3.28084;
      if (feet < 1000) {
        return '${feet.round()} ft';
      } else {
        final miles = meters / 1609.344;
        return '${miles.toStringAsFixed(1)} mi';
      }
    } else {
      if (meters < 1000) {
        return '${meters.round()} m';
      } else {
        final km = meters / 1000.0;
        return '${km.toStringAsFixed(1)} km';
      }
    }
  }

  /// Converts an angle in degrees into a cardinal direction label (N, NE, E, etc.)
  static String getCardinalDirection(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N'];
    final normalized = (degrees % 360.0 + 360.0) % 360.0;
    final index = ((normalized + 22.5) / 45.0).floor();
    return directions[index];
  }
}
