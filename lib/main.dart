import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'services/compass_service.dart';
import 'services/location_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation for natural compass navigation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set tactical dark system bar colors
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F172A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final storageService = await StorageService.init();
  final locationService = LocationService();
  final compassService = CompassService();

  runApp(WaypointApp(
    storageService: storageService,
    locationService: locationService,
    compassService: compassService,
  ));
}

class WaypointApp extends StatelessWidget {
  final StorageService storageService;
  final LocationService locationService;
  final CompassService compassService;

  const WaypointApp({
    super.key,
    required this.storageService,
    required this.locationService,
    required this.compassService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waypoint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          secondary: Color(0xFF10B981),
          surface: Color(0xFF1E293B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: SplashScreen(
        storageService: storageService,
        locationService: locationService,
        compassService: compassService,
      ),
    );
  }
}
