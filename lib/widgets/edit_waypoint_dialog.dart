import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/waypoint.dart';

class EditWaypointDialog extends StatefulWidget {
  final Waypoint waypoint;

  const EditWaypointDialog({
    super.key,
    required this.waypoint,
  });

  @override
  State<EditWaypointDialog> createState() => _EditWaypointDialogState();
}

class _EditWaypointDialogState extends State<EditWaypointDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late WaypointCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.waypoint.category;
    _nameController = TextEditingController(text: widget.waypoint.name);
    _notesController = TextEditingController(text: widget.waypoint.note ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    final trimmedName = _nameController.text.trim();
    if (trimmedName.isEmpty) return;

    final trimmedNote = _notesController.text.trim();
    final updated = widget.waypoint.copyWith(
      name: trimmedName,
      category: _selectedCategory,
      note: trimmedNote.isEmpty ? null : trimmedNote,
    );

    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(widget.waypoint.createdAt);

    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_location_alt_rounded,
                      color: Color(0xFF38BDF8),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Edit Pin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Category Selector
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
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(cat),
                            color: isSelected ? Colors.black : Colors.white,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getCategoryLabel(cat),
                            style: TextStyle(
                              color: isSelected ? Colors.black : const Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Pin Name Field
              const Text(
                'PIN NAME',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  hintText: 'e.g. Parked Car, Trailhead',
                  hintStyle: const TextStyle(color: Color(0xFF475569)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear_rounded, color: Color(0xFF64748B), size: 18),
                    onPressed: () => _nameController.clear(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes Field
              const Text(
                'NOTES (OPTIONAL)',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 2,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  hintText: 'e.g. Level 3 Section B, Near big oak',
                  hintStyle: const TextStyle(color: Color(0xFF475569)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Read-only GPS & Timestamp Metadata
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Saved: $dateStr\nGPS: ${widget.waypoint.latitude.toStringAsFixed(5)}, ${widget.waypoint.longitude.toStringAsFixed(5)}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF94A3B8),
                        side: const BorderSide(color: Color(0xFF334155)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38BDF8),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      onPressed: _save,
                      child: const Text(
                        'Save',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
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

  String _getCategoryLabel(WaypointCategory cat) {
    switch (cat) {
      case WaypointCategory.car:
        return 'Car';
      case WaypointCategory.trailhead:
        return 'Trail';
      case WaypointCategory.camp:
        return 'Camp';
      case WaypointCategory.custom:
        return 'Pin';
    }
  }
}
