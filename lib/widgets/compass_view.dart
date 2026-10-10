import 'dart:math';
import 'package:flutter/material.dart';

class CompassView extends StatelessWidget {
  final double deviceHeading; // in degrees (0..360)
  final double targetBearing; // in degrees (0..360)
  final double distanceMeters;
  final String formattedDistance;
  final bool hasTarget;

  const CompassView({
    super.key,
    required this.deviceHeading,
    required this.targetBearing,
    required this.distanceMeters,
    required this.formattedDistance,
    required this.hasTarget,
  });

  @override
  Widget build(BuildContext context) {
    // Arrival threshold: within 15 meters (approx 50 feet)
    final bool isArrived = hasTarget && distanceMeters <= 15.0;

    // Relative angle the arrow should rotate:
    // (targetBearing - deviceHeading)
    final double relativeAngleDeg = (targetBearing - deviceHeading) % 360.0;
    final double relativeAngleRad = relativeAngleDeg * pi / 180.0;

    return Center(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          margin: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF111827), // deep tactical navy
            boxShadow: [
              BoxShadow(
                color: isArrived
                    ? const Color(0xFF10B981).withOpacity(0.35)
                    : const Color(0xFF38BDF8).withOpacity(0.15),
                blurRadius: 32,
                spreadRadius: 4,
              ),
            ],
            border: Border.all(
              color: isArrived
                  ? const Color(0xFF10B981)
                  : const Color(0xFF1E293B),
              width: 2.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating compass dial (rotates inverse to device heading)
              Transform.rotate(
                angle: -deviceHeading * pi / 180.0,
                child: CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: _CompassDialPainter(),
                ),
              ),

              // The Target Directional Arrow (rotates by relative angle)
              if (hasTarget)
                Transform.rotate(
                  angle: relativeAngleRad,
                  child: CustomPaint(
                    size: const Size(double.infinity, double.infinity),
                    painter: _TargetArrowPainter(isArrived: isArrived),
                  ),
                ),

              // Central Info HUD Hub
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0F172A),
                  border: Border.all(
                    color: isArrived
                        ? const Color(0xFF10B981)
                        : const Color(0xFF334155),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!hasTarget) ...[
                      const Icon(
                        Icons.pin_drop_outlined,
                        color: Color(0xFF94A3B8),
                        size: 32,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "NO PIN SET",
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ] else if (isArrived) ...[
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF10B981),
                        size: 36,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "ARRIVED",
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        formattedDistance,
                        style: const TextStyle(
                          color: Color(0xFF6EE7B7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else ...[
                      Text(
                        formattedDistance,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${relativeAngleDeg.round()}° to target",
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;

    final tickPaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final cardinalPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final northPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Draw degree ticks
    for (int deg = 0; deg < 360; deg += 10) {
      final rad = deg * pi / 180.0;
      final isCardinal = deg % 90 == 0;
      final isMajor = deg % 30 == 0;

      final double tickLength = isCardinal ? 16 : (isMajor ? 10 : 5);
      final p1 = Offset(
        center.dx + radius * cos(rad),
        center.dy + radius * sin(rad),
      );
      final p2 = Offset(
        center.dx + (radius - tickLength) * cos(rad),
        center.dy + (radius - tickLength) * sin(rad),
      );

      if (deg == 270) {
        // True North is 270 rad in screen coordinates (upwards)
        canvas.drawLine(p1, p2, northPaint);
      } else if (isCardinal) {
        canvas.drawLine(p1, p2, cardinalPaint);
      } else {
        canvas.drawLine(p1, p2, tickPaint);
      }
    }

    // Draw Cardinal Labels (N, E, S, W)
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    const labels = {'N': 270, 'E': 0, 'S': 90, 'W': 180};
    labels.forEach((label, deg) {
      final rad = deg * pi / 180.0;
      final labelOffset = Offset(
        center.dx + (radius - 28) * cos(rad),
        center.dy + (radius - 28) * sin(rad),
      );

      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          color: label == 'N' ? const Color(0xFFEF4444) : Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        labelOffset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TargetArrowPainter extends CustomPainter {
  final bool isArrived;

  _TargetArrowPainter({required this.isArrived});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final arrowRadius = size.width / 2 - 24;

    final arrowColor = isArrived
        ? const Color(0xFF10B981) // emerald
        : const Color(0xFF38BDF8); // neon cyan

    final arrowPaint = Paint()
      ..color = arrowColor
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = arrowColor.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // Tip of arrow points UP (screen top = 0 angle in rotated canvas)
    final tip = Offset(center.dx, center.dy - arrowRadius);
    final leftBase = Offset(center.dx - 18, center.dy - 88);
    final rightBase = Offset(center.dx + 18, center.dy - 88);
    final innerCenter = Offset(center.dx, center.dy - 76);

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(leftBase.dx, leftBase.dy)
      ..lineTo(innerCenter.dx, innerCenter.dy)
      ..lineTo(rightBase.dx, rightBase.dy)
      ..close();

    // Draw glowing shadow then arrow
    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant _TargetArrowPainter oldDelegate) =>
      oldDelegate.isArrived != isArrived;
}
