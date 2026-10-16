import 'dart:math';
import 'package:flutter/material.dart';
import '../services/compass_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final StorageService storageService;
  final LocationService locationService;
  final CompassService compassService;

  const SplashScreen({
    super.key,
    required this.storageService,
    required this.locationService,
    required this.compassService,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToHome();
      }
    });

    // Pre-warm location permission & sensors in background
    widget.locationService.getCurrentPosition();
  }

  void _navigateToHome() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(
          storageService: widget.storageService,
          locationService: widget.locationService,
          compassService: widget.compassService,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToHome, // Tap anywhere to skip
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0F19), // Deep tactical black/navy
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress = _controller.value;
              // Radar sweep angle completes 1.5 full rotations (0 -> 3 * pi)
              final sweepAngle = progress * 3 * pi;

              // Text fade-in starts after 0.2
              final textOpacity = ((progress - 0.2) / 0.4).clamp(0.0, 1.0);

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Radar Graphic with Pinging Waypoints
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(260, 260),
                            painter: _RadarGridPainter(
                              progress: progress,
                              sweepAngle: sweepAngle,
                            ),
                          ),

                          // Ping 1: Car Waypoint (Upper-Left)
                          _WaypointPing(
                            offset: const Offset(-55, -60),
                            icon: Icons.directions_car_filled_rounded,
                            color: const Color(0xFF38BDF8), // Cyan
                            appearThreshold: 0.22,
                            progress: progress,
                          ),

                          // Ping 2: Trailhead Waypoint (Lower-Right)
                          _WaypointPing(
                            offset: const Offset(65, 55),
                            icon: Icons.hiking_rounded,
                            color: const Color(0xFF10B981), // Emerald
                            appearThreshold: 0.48,
                            progress: progress,
                          ),

                          // Ping 3: Campsite Waypoint (Upper-Right)
                          _WaypointPing(
                            offset: const Offset(60, -45),
                            icon: Icons.cottage_rounded,
                            color: const Color(0xFFF59E0B), // Amber
                            appearThreshold: 0.65,
                            progress: progress,
                          ),

                          // Central Homing Beacon Pulse
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1E293B),
                              border: Border.all(
                                color: const Color(0xFF38BDF8),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF38BDF8).withOpacity(0.5),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.navigation_rounded,
                                color: Color(0xFF38BDF8),
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Title & Branding with Smooth Fade In
                    Opacity(
                      opacity: textOpacity,
                      child: Column(
                        children: [
                          const Text(
                            'WAYPOINT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 6.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'OFFLINE HOMING BEACON',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Subtle Skip Hint
                    Opacity(
                      opacity: ((progress - 0.5) / 0.5).clamp(0.0, 0.4),
                      child: const Text(
                        'Tap anywhere to start',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WaypointPing extends StatelessWidget {
  final Offset offset;
  final IconData icon;
  final Color color;
  final double appearThreshold;
  final double progress;

  const _WaypointPing({
    required this.offset,
    required this.icon,
    required this.color,
    required this.appearThreshold,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    if (progress < appearThreshold) return const SizedBox.shrink();

    // Calculate individual ping pulse
    final pingProgress = ((progress - appearThreshold) / (1.0 - appearThreshold)).clamp(0.0, 1.0);
    final scale = (pingProgress * 4).clamp(0.0, 1.0);
    final rippleRadius = (pingProgress * 28) % 24;
    final rippleOpacity = (1.0 - (rippleRadius / 24)).clamp(0.0, 0.8);

    return Transform.translate(
      offset: offset,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Expanding ripple ring
          Container(
            width: rippleRadius * 2,
            height: rippleRadius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(rippleOpacity),
                width: 1.5,
              ),
            ),
          ),

          // Main Marker Badge
          Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 1.8),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarGridPainter extends CustomPainter {
  final double progress;
  final double sweepAngle;

  _RadarGridPainter({
    required this.progress,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 10;

    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final outerRingPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Concentric Range Rings
    canvas.drawCircle(center, maxRadius * 0.35, gridPaint);
    canvas.drawCircle(center, maxRadius * 0.70, gridPaint);
    canvas.drawCircle(center, maxRadius, outerRingPaint);

    // Crosshairs
    canvas.drawLine(
      Offset(center.dx - maxRadius, center.dy),
      Offset(center.dx + maxRadius, center.dy),
      gridPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - maxRadius),
      Offset(center.dx, center.dy + maxRadius),
      gridPaint,
    );

    // Radar Sweep Beam
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: pi / 2,
        colors: [
          const Color(0xFF38BDF8).withOpacity(0.0),
          const Color(0xFF38BDF8).withOpacity(0.35),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(sweepAngle);

    final sweepPath = Path()
      ..moveTo(0, 0)
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: maxRadius),
        0,
        pi / 2,
        false,
      )
      ..close();

    canvas.drawPath(sweepPath, sweepPaint);

    // Leading edge beam line
    final edgePaint = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.7)
      ..strokeWidth = 1.8;
    canvas.drawLine(
      Offset.zero,
      Offset(maxRadius * cos(pi / 2), maxRadius * sin(pi / 2)),
      edgePaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RadarGridPainter oldDelegate) => true;
}
