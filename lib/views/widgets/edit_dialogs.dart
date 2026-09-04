import 'package:flutter/material.dart';
import '../../models/schedule_model.dart';
import '../../models/room_model.dart';
import '../../models/event_model.dart';
import '../../models/announcement_model.dart';
import '../../models/assignment_model.dart';
import '../../theme/app_colors.dart';

class EditDialogs {
  // 1. Schedule Add / Edit Dialog
  static Future<ScheduleModel?> showScheduleDialog(BuildContext context, {ScheduleModel? existing}) async {
    final courseCtrl = TextEditingController(text: existing?.course ?? '');
    final timeCtrl = TextEditingController(text: existing?.time ?? '09:00 AM - 10:30 AM');
    final roomCtrl = TextEditingController(text: existing?.room ?? 'Room 101');
    final dayCtrl = TextEditingController(text: existing?.day ?? 'Today');
    final instructorCtrl = TextEditingController(text: existing?.instructor ?? 'Dr. Alan Turing');

    return showDialog<ScheduleModel>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existing == null ? 'Add New Class Schedule' : 'Edit Class Schedule'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: courseCtrl, decoration: const InputDecoration(labelText: 'Course Name (e.g. CSE321)')),
              const SizedBox(height: 12),
              TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Time (e.g. 09:00 AM - 10:30 AM)')),
              const SizedBox(height: 12),
              TextField(controller: roomCtrl, decoration: const InputDecoration(labelText: 'Room (e.g. Room 304)')),
              const SizedBox(height: 12),
              TextField(controller: dayCtrl, decoration: const InputDecoration(labelText: 'Day (e.g. Today / Monday)')),
              const SizedBox(height: 12),
              TextField(controller: instructorCtrl, decoration: const InputDecoration(labelText: 'Instructor')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (courseCtrl.text.isNotEmpty) {
                Navigator.pop(
                  ctx,
                  ScheduleModel(
                    id: existing?.id ?? '',
                    course: courseCtrl.text.trim(),
                    time: timeCtrl.text.trim(),
                    room: roomCtrl.text.trim(),
                    day: dayCtrl.text.trim(),
                    instructor: instructorCtrl.text.trim(),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // 2. Room Add / Edit Dialog
  static Future<RoomModel?> showRoomDialog(BuildContext context, {RoomModel? existing}) async {
    final numberCtrl = TextEditingController(text: existing?.roomNumber ?? '');
    final capacityCtrl = TextEditingController(text: existing?.capacity.toString() ?? '30');
    final equipmentCtrl = TextEditingController(text: existing?.equipment.join(', ') ?? 'Projector, AC');

    return showDialog<RoomModel>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existing == null ? 'Add New Room' : 'Edit Room'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: numberCtrl, decoration: const InputDecoration(labelText: 'Room Number (e.g. Room 302)')),
              const SizedBox(height: 12),
              TextField(controller: capacityCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Seating Capacity')),
              const SizedBox(height: 12),
              TextField(controller: equipmentCtrl, decoration: const InputDecoration(labelText: 'Equipment (comma separated)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (numberCtrl.text.isNotEmpty) {
                final eqList = equipmentCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                Navigator.pop(
                  ctx,
                  RoomModel(
                    id: existing?.id ?? '',
                    roomNumber: numberCtrl.text.trim(),
                    capacity: int.tryParse(capacityCtrl.text.trim()) ?? 20,
                    equipment: eqList,
                    isBooked: existing?.isBooked ?? false,
                    bookedBy: existing?.bookedBy,
                    bookingTime: existing?.bookingTime,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // 3. Event Add / Edit Dialog
  static Future<EventModel?> showEventDialog(BuildContext context, {EventModel? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final dateCtrl = TextEditingController(text: existing?.date ?? 'Today');
    final timeCtrl = TextEditingController(text: existing?.time ?? '02:00 PM - 04:00 PM');
    final capCtrl = TextEditingController(text: existing?.capacity.toString() ?? '50');
    final locCtrl = TextEditingController(text: existing?.location ?? 'Auditorium A');
    final descCtrl = TextEditingController(text: existing?.description ?? '');

    return showDialog<EventModel>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existing == null ? 'Create Campus Event' : 'Edit Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Event Title')),
              const SizedBox(height: 12),
              TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Date (e.g. Today / Tomorrow)')),
              const SizedBox(height: 12),
              TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Time (e.g. 02:00 PM)')),
              const SizedBox(height: 12),
              TextField(controller: capCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacity')),
              const SizedBox(height: 12),
              TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Location')),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                Navigator.pop(
                  ctx,
                  EventModel(
                    id: existing?.id ?? '',
                    name: nameCtrl.text.trim(),
                    date: dateCtrl.text.trim(),
                    time: timeCtrl.text.trim(),
                    capacity: int.tryParse(capCtrl.text.trim()) ?? 50,
                    registeredCount: existing?.registeredCount ?? 0,
                    isRegistered: existing?.isRegistered ?? false,
                    location: locCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // 4. Announcement Add / Edit Dialog
  static Future<AnnouncementModel?> showAnnouncementDialog(BuildContext context, {AnnouncementModel? existing}) async {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final bodyCtrl = TextEditingController(text: existing?.body ?? '');
    String priority = existing?.priority ?? 'Medium';

    return showDialog<AnnouncementModel>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(existing == null ? 'Post Announcement' : 'Edit Announcement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 12),
                TextField(controller: bodyCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Announcement Details')),
                const SizedBox(height: 16),
                const Text('Priority Level:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: ['High', 'Medium', 'Low'].map((p) {
                    final isSel = priority == p;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(p),
                        selected: isSel,
                        selectedColor: p == 'High' ? AppColors.errorLight : AppColors.primaryLight,
                        onSelected: (sel) {
                          if (sel) setState(() => priority = p);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isNotEmpty) {
                  Navigator.pop(
                    ctx,
                    AnnouncementModel(
                      id: existing?.id ?? '',
                      title: titleCtrl.text.trim(),
                      body: bodyCtrl.text.trim(),
                      date: existing?.date ?? 'Just Now',
                      priority: priority,
                    ),
                  );
                }
              },
              child: const Text('Publish'),
            ),
          ],
        ),
      ),
    );
  }

  // 5. Assignment Add / Edit Dialog
  static Future<AssignmentModel?> showAssignmentDialog(BuildContext context, {AssignmentModel? existing}) async {
    final courseCtrl = TextEditingController(text: existing?.course ?? 'CSE321');
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final deadlineCtrl = TextEditingController(text: existing?.deadline ?? 'Tomorrow, 11:59 PM');

    return showDialog<AssignmentModel>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existing == null ? 'Add Assignment' : 'Edit Assignment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: courseCtrl, decoration: const InputDecoration(labelText: 'Course Code')),
              const SizedBox(height: 12),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Assignment Title')),
              const SizedBox(height: 12),
              TextField(controller: deadlineCtrl, decoration: const InputDecoration(labelText: 'Deadline')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                Navigator.pop(
                  ctx,
                  AssignmentModel(
                    id: existing?.id ?? '',
                    course: courseCtrl.text.trim(),
                    title: titleCtrl.text.trim(),
                    deadline: deadlineCtrl.text.trim(),
                    status: existing?.status ?? 'Pending',
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
