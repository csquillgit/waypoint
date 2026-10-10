import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/waypoint.dart';

class StorageService {
  static const String _waypointsKey = 'waypoint_saved_list';
  static const String _activeWaypointIdKey = 'waypoint_active_target_id';
  static const String _useImperialKey = 'waypoint_use_imperial';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  List<Waypoint> getWaypoints() {
    final rawJson = _prefs.getString(_waypointsKey);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = json.decode(rawJson) as List<dynamic>;
      final items = decoded
          .map((item) => Waypoint.fromMap(item as Map<String, dynamic>))
          .toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveWaypoint(Waypoint waypoint) async {
    final list = getWaypoints();
    list.removeWhere((item) => item.id == waypoint.id);
    list.insert(0, waypoint);
    await _saveList(list);
    // Automatically set as active target
    await setActiveWaypointId(waypoint.id);
  }

  Future<void> deleteWaypoint(String id) async {
    final list = getWaypoints();
    list.removeWhere((item) => item.id == id);
    await _saveList(list);

    if (getActiveWaypointId() == id) {
      if (list.isNotEmpty) {
        await setActiveWaypointId(list.first.id);
      } else {
        await _prefs.remove(_activeWaypointIdKey);
      }
    }
  }

  Future<void> _saveList(List<Waypoint> list) async {
    final encoded = json.encode(list.map((e) => e.toMap()).toList());
    await _prefs.setString(_waypointsKey, encoded);
  }

  String? getActiveWaypointId() {
    return _prefs.getString(_activeWaypointIdKey);
  }

  Future<void> setActiveWaypointId(String id) async {
    await _prefs.setString(_activeWaypointIdKey, id);
  }

  Waypoint? getActiveWaypoint() {
    final id = getActiveWaypointId();
    if (id == null) return null;
    final list = getWaypoints();
    final matches = list.where((w) => w.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  bool getUseImperial() {
    return _prefs.getBool(_useImperialKey) ?? true;
  }

  Future<void> setUseImperial(bool imperial) async {
    await _prefs.setBool(_useImperialKey, imperial);
  }
}
