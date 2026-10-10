import 'package:flutter/material.dart';
import '../models/waypoint.dart';

class AddWaypointDialog extends StatefulWidget {
  final double currentLat;
  final double currentLon;
  final WaypointCategory? defaultCategory;

  const AddWaypointDialog({
    super.key,
    required this.currentLat,
    required this.currentLon,
    this.defaultCategory,
  });

  @override
  State<AddWaypointDialog> createState() => _AddWaypointDialogState();
}

class _AddWaypointDialogState extends State<AddWaypointDialog> {
  late final TextEditingController _nameController;
  final TextEditingController _notesController = TextEditingController();
  late WaypointCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.defaultCategory ?? WaypointCategory.car;
    _nameController = TextEditingController(text: _getDefaultName(_selectedCategory));
  }

  String _getDefaultName(WaypointCategory category) {
    switch (category) {
      case WaypointCategory.car:
        return 'Parked Car';
      case WaypointCategory.trailhead:
        return 'Trailhead Start';
      case WaypointCategory.camp:
        return 'Campsite';
      case WaypointCategory.custom:
        return 'My Waypoint';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add_location_alt_rounded,
                    color: Color(0xFF38BDF8),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Drop New Pin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Category selector
            const Text(
              'CATEGORY',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: WaypointCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                      _nameController.text = _getDefaultName(cat);
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF38BDF8)
                          : const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF334155),
                      ),
                    ),
                    child: Icon(
                      _getCategoryIcon(cat),
                      color: isSelected ? const Color(0xFF0F172A) : Colors.white70,
                      size: 22,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Pin Name Field
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Pin Name',
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Notes / details field
            TextField(
              controller: _notesController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Notes (e.g. Row 4, Section B)',
                labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // GPS Coordinates subtitle
            Text(
              'GPS: ${widget.currentLat.toStringAsFixed(5)}, ${widget.currentLon.toStringAsFixed(5)}',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final name = _nameController.text.trim();
                    if (name.isEmpty) return;

                    final waypoint = Waypoint(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      latitude: widget.currentLat,
                      longitude: widget.currentLon,
                      createdAt: DateTime.now(),
                      category: _selectedCategory,
                      note: _notesController.text.trim().isEmpty
                          ? null
                          : _notesController.text.trim(),
                    );
                    Navigator.of(context).pop(waypoint);
                  },
                  child: const Text(
                    'Save Pin',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
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
