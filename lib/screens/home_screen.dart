import 'package:flutter/material.dart';
import '../services/compass_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import 'history_screen.dart';
import 'radar_screen.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;
  final LocationService locationService;
  final CompassService compassService;

  const HomeScreen({
    super.key,
    required this.storageService,
    required this.locationService,
    required this.compassService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      RadarScreen(
        storageService: widget.storageService,
        locationService: widget.locationService,
        compassService: widget.compassService,
      ),
      HistoryScreen(
        storageService: widget.storageService,
        locationService: widget.locationService,
        onTargetSelected: () {
          setState(() {
            _currentIndex = 0; // jump back to radar screen when target is selected
          });
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF1E293B), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF0F172A),
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFF38BDF8),
          unselectedItemColor: const Color(0xFF64748B),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_rounded),
              label: 'Beacon Radar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmarks_rounded),
              label: 'Saved Pins',
            ),
          ],
        ),
      ),
    );
  }
}
