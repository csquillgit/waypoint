import 'dart:convert';

enum WaypointCategory {
  car,
  trailhead,
  camp,
  custom,
}

class Waypoint {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final WaypointCategory category;
  final String? note;

  const Waypoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    this.category = WaypointCategory.custom,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'category': category.name,
      'note': note,
    };
  }

  factory Waypoint.fromMap(Map<String, dynamic> map) {
    return Waypoint(
      id: map['id'] as String,
      name: map['name'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      category: WaypointCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => WaypointCategory.custom,
      ),
      note: map['note'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory Waypoint.fromJson(String source) =>
      Waypoint.fromMap(json.decode(source) as Map<String, dynamic>);

  Waypoint copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    WaypointCategory? category,
    String? note,
  }) {
    return Waypoint(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }
}
