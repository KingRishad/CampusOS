import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/campus_provider.dart';
import '../../theme/app_colors.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/edit_dialogs.dart';

class DataManagerScreen extends StatefulWidget {
  const DataManagerScreen({Key? key}) : super(key: key);

  @override
  State<DataManagerScreen> createState() => _DataManagerScreenState();
}

class _DataManagerScreenState extends State<DataManagerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final campus = Provider.of<CampusProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Campus Data Manager',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore, color: AppColors.primary),
            tooltip: 'Reset to Seed Data',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset Dataset?'),
                  content: const Text('This will restore all 5 systems back to initial seed data.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset')),
                  ],
                ),
              );
              if (confirm == true) {
                await campus.resetToSeedData();
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Schedule'),
            Tab(text: 'Rooms'),
            Tab(text: 'Events'),
            Tab(text: 'Announcements'),
            Tab(text: 'Assignments'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: SearchBarWidget(
              controller: _searchController,
              hintText: 'Filter records across systems...',
              onChanged: (val) => campus.setSearchQuery(val),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildScheduleTab(campus),
                _buildRoomTab(campus),
                _buildEventTab(campus),
                _buildAnnouncementTab(campus),
                _buildAssignmentTab(campus),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddDialog(context, _tabController.index, campus),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Record', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _openAddDialog(BuildContext context, int tabIndex, CampusProvider campus) async {
    switch (tabIndex) {
      case 0:
        final item = await EditDialogs.showScheduleDialog(context);
        if (item != null) await campus.addSchedule(item);
        break;
      case 1:
        final item = await EditDialogs.showRoomDialog(context);
        if (item != null) await campus.addRoom(item);
        break;
      case 2:
        final item = await EditDialogs.showEventDialog(context);
        if (item != null) await campus.addEvent(item);
        break;
      case 3:
        final item = await EditDialogs.showAnnouncementDialog(context);
        if (item != null) await campus.addAnnouncement(item);
        break;
      case 4:
        final item = await EditDialogs.showAssignmentDialog(context);
        if (item != null) await campus.addAssignment(item);
        break;
    }
  }

  // Tab 1: Schedule View
  Widget _buildScheduleTab(CampusProvider campus) {
    final list = campus.schedules.where((s) =>
        s.course.toLowerCase().contains(campus.searchQuery.toLowerCase()) ||
        s.instructor.toLowerCase().contains(campus.searchQuery.toLowerCase()) ||
        s.room.toLowerCase().contains(campus.searchQuery.toLowerCase())).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: list.length,
      itemBuilder: (ctx, idx) {
        final s = list[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            title: Text(s.course, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text('Instructor: ${s.instructor}\nTime: ${s.time} (${s.day})\nRoom: ${s.room}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  onPressed: () async {
                    final updated = await EditDialogs.showScheduleDialog(context, existing: s);
                    if (updated != null) await campus.editSchedule(updated);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => campus.deleteSchedule(s.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Tab 2: Room View
  Widget _buildRoomTab(CampusProvider campus) {
    final list = campus.rooms.where((r) =>
        r.roomNumber.toLowerCase().contains(campus.searchQuery.toLowerCase()) ||
        r.equipment.any((e) => e.toLowerCase().contains(campus.searchQuery.toLowerCase()))).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: list.length,
      itemBuilder: (ctx, idx) {
        final r = list[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.roomNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: r.isBooked ? AppColors.warningLight : AppColors.badgeGreenBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        r.isBooked ? 'Booked (${r.bookedBy ?? "User"})' : 'Available',
                        style: TextStyle(
                          color: r.isBooked ? AppColors.warning : AppColors.badgeGreenText,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Capacity: ${r.capacity} seats | Equipment: ${r.equipment.join(', ')}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!r.isBooked)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.bookmark_add, size: 16),
                        label: const Text('Book'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: () => campus.bookRoom(r.roomNumber, 'Student', 'Today 02:00 PM - 04:00 PM'),
                      )
                    else
                      OutlinedButton.icon(
                        icon: const Icon(Icons.bookmark_remove, size: 16),
                        label: const Text('Cancel Booking'),
                        onPressed: () => campus.cancelRoomBooking(r.roomNumber),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                      onPressed: () async {
                        final updated = await EditDialogs.showRoomDialog(context, existing: r);
                        if (updated != null) await campus.editRoom(updated);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => campus.deleteRoom(r.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Tab 3: Event View
  Widget _buildEventTab(CampusProvider campus) {
    final list = campus.events.where((e) =>
        e.name.toLowerCase().contains(campus.searchQuery.toLowerCase()) ||
        e.location.toLowerCase().contains(campus.searchQuery.toLowerCase())).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: list.length,
      itemBuilder: (ctx, idx) {
        final ev = list[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ev.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('${ev.date} at ${ev.time} | Location: ${ev.location}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Text(ev.description, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Registered: ${ev.registeredCount}/${ev.capacity}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ev.isRegistered ? Colors.grey : AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onPressed: () {
                            if (ev.isRegistered) {
                              campus.cancelEventRegistration(ev.id);
                            } else {
                              campus.registerEvent(ev.id);
                            }
                          },
                          child: Text(ev.isRegistered ? 'Unregister' : 'Register'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                          onPressed: () async {
                            final updated = await EditDialogs.showEventDialog(context, existing: ev);
                            if (updated != null) await campus.editEvent(updated);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => campus.deleteEvent(ev.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Tab 4: Announcement View
  Widget _buildAnnouncementTab(CampusProvider campus) {
    final list = campus.announcements.where((a) =>
        a.title.toLowerCase().contains(campus.searchQuery.toLowerCase()) ||
        a.body.toLowerCase().contains(campus.searchQuery.toLowerCase())).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: list.length,
      itemBuilder: (ctx, idx) {
        final a = list[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: a.priority == 'High' ? AppColors.errorLight : AppColors.badgeGreenBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${a.priority} Priority',
                        style: TextStyle(
                          color: a.priority == 'High' ? AppColors.error : AppColors.badgeGreenText,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(a.body, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(a.date, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                          onPressed: () async {
                            final updated = await EditDialogs.showAnnouncementDialog(context, existing: a);
                            if (updated != null) await campus.editAnnouncement(updated);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => campus.deleteAnnouncement(a.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Tab 5: Assignment View
  Widget _buildAssignmentTab(CampusProvider campus) {
    final list = campus.assignments.where((as) =>
        as.course.toLowerCase().contains(campus.searchQuery.toLowerCase()) ||
        as.title.toLowerCase().contains(campus.searchQuery.toLowerCase())).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: list.length,
      itemBuilder: (ctx, idx) {
        final as = list[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${as.course}: ${as.title}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('Deadline: ${as.deadline}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                ChoiceChip(
                  label: Text(as.status),
                  selected: as.status == 'Completed',
                  selectedColor: AppColors.badgeGreenBg,
                  onSelected: (_) {
                    final nextStatus = as.status == 'Pending' ? 'Completed' : 'Pending';
                    campus.updateAssignmentStatus(as.id, nextStatus);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () => campus.deleteAssignment(as.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
