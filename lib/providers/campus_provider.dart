import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/schedule_model.dart';
import '../models/room_model.dart';
import '../models/event_model.dart';
import '../models/announcement_model.dart';
import '../models/assignment_model.dart';
import '../models/activity_log_model.dart';
import '../services/storage_service.dart';
import '../services/seed_data_loader.dart';

class CampusProvider extends ChangeNotifier {
  final StorageService storageService;
  final Uuid _uuid = const Uuid();

  List<ScheduleModel> _schedules = [];
  List<RoomModel> _rooms = [];
  List<EventModel> _events = [];
  List<AnnouncementModel> _announcements = [];
  List<AssignmentModel> _assignments = [];
  List<ActivityLogModel> _activityLogs = [];

  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategoryFilter = 'All';

  CampusProvider({required this.storageService}) {
    initData();
  }

  // Getters
  List<ScheduleModel> get schedules => _schedules;
  List<RoomModel> get rooms => _rooms;
  List<EventModel> get events => _events;
  List<AnnouncementModel> get announcements => _announcements;
  List<AssignmentModel> get assignments => _assignments;
  List<ActivityLogModel> get activityLogs => _activityLogs;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategoryFilter => _selectedCategoryFilter;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  // Initial Load from Storage or Seed JSON
  Future<void> initData() async {
    _isLoading = true;
    notifyListeners();

    // Schedules
    final savedSchedules = storageService.loadSchedules();
    if (savedSchedules != null && savedSchedules.isNotEmpty) {
      _schedules = savedSchedules.map((e) => ScheduleModel.fromJson(e)).toList();
    } else {
      final raw = await SeedDataLoader.loadJsonAsset('assets/seed_data/schedule.json');
      _schedules = raw.map((e) => ScheduleModel.fromJson(e)).toList();
      await _persistSchedules();
    }

    // Rooms
    final savedRooms = storageService.loadRooms();
    if (savedRooms != null && savedRooms.isNotEmpty) {
      _rooms = savedRooms.map((e) => RoomModel.fromJson(e)).toList();
    } else {
      final raw = await SeedDataLoader.loadJsonAsset('assets/seed_data/rooms.json');
      _rooms = raw.map((e) => RoomModel.fromJson(e)).toList();
      await _persistRooms();
    }

    // Events
    final savedEvents = storageService.loadEvents();
    if (savedEvents != null && savedEvents.isNotEmpty) {
      _events = savedEvents.map((e) => EventModel.fromJson(e)).toList();
    } else {
      final raw = await SeedDataLoader.loadJsonAsset('assets/seed_data/events.json');
      _events = raw.map((e) => EventModel.fromJson(e)).toList();
      await _persistEvents();
    }

    // Announcements
    final savedAnnouncements = storageService.loadAnnouncements();
    if (savedAnnouncements != null && savedAnnouncements.isNotEmpty) {
      _announcements = savedAnnouncements.map((e) => AnnouncementModel.fromJson(e)).toList();
    } else {
      final raw = await SeedDataLoader.loadJsonAsset('assets/seed_data/announcements.json');
      _announcements = raw.map((e) => AnnouncementModel.fromJson(e)).toList();
      await _persistAnnouncements();
    }

    // Assignments
    final savedAssignments = storageService.loadAssignments();
    if (savedAssignments != null && savedAssignments.isNotEmpty) {
      _assignments = savedAssignments.map((e) => AssignmentModel.fromJson(e)).toList();
    } else {
      final raw = await SeedDataLoader.loadJsonAsset('assets/seed_data/assignments.json');
      _assignments = raw.map((e) => AssignmentModel.fromJson(e)).toList();
      await _persistAssignments();
    }

    // Activity Logs
    final savedLogs = storageService.loadActivityLogs();
    if (savedLogs != null && savedLogs.isNotEmpty) {
      _activityLogs = savedLogs.map((e) => ActivityLogModel.fromJson(e)).toList();
    } else {
      _activityLogs = [
        ActivityLogModel(
          id: _uuid.v4(),
          timestamp: DateTime.now(),
          title: 'CampusOS Initialized',
          description: 'Loaded seed data for 5 campus systems.',
          category: 'System',
          actionType: 'Init',
        )
      ];
      await _persistLogs();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Persistence helpers
  Future<void> _persistSchedules() => storageService.saveSchedules(_schedules.map((e) => e.toJson()).toList());
  Future<void> _persistRooms() => storageService.saveRooms(_rooms.map((e) => e.toJson()).toList());
  Future<void> _persistEvents() => storageService.saveEvents(_events.map((e) => e.toJson()).toList());
  Future<void> _persistAnnouncements() => storageService.saveAnnouncements(_announcements.map((e) => e.toJson()).toList());
  Future<void> _persistAssignments() => storageService.saveAssignments(_assignments.map((e) => e.toJson()).toList());
  Future<void> _persistLogs() => storageService.saveActivityLogs(_activityLogs.map((e) => e.toJson()).toList());

  void _logActivity(String title, String description, String category, String actionType) {
    _activityLogs.insert(
      0,
      ActivityLogModel(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        title: title,
        description: description,
        category: category,
        actionType: actionType,
      ),
    );
    _persistLogs();
  }

  // Reset Data to Seed
  Future<void> resetToSeedData() async {
    await storageService.clearAll();
    await initData();
  }

  // ==========================================
  // 1. SCHEDULE CRUD
  // ==========================================
  Future<void> addSchedule(ScheduleModel item) async {
    final newItem = item.id.isEmpty ? item.copyWith(id: 'sched-${_uuid.v4().substring(0, 6)}') : item;
    _schedules.insert(0, newItem);
    await _persistSchedules();
    _logActivity('Added Class Schedule', '${newItem.course} at ${newItem.time} in ${newItem.room}', 'Schedule', 'Add');
    notifyListeners();
  }

  Future<void> editSchedule(ScheduleModel item) async {
    final index = _schedules.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _schedules[index] = item;
      await _persistSchedules();
      _logActivity('Updated Class Schedule', '${item.course} updated time/room (${item.time}, ${item.room})', 'Schedule', 'Edit');
      notifyListeners();
    }
  }

  Future<void> deleteSchedule(String id) async {
    final item = _schedules.firstWhere((e) => e.id == id, orElse: () => ScheduleModel(id: '', course: 'Unknown', time: '', room: '', day: '', instructor: ''));
    _schedules.removeWhere((e) => e.id == id);
    await _persistSchedules();
    _logActivity('Deleted Class Schedule', 'Removed ${item.course} schedule', 'Schedule', 'Delete');
    notifyListeners();
  }

  // ==========================================
  // 2. ROOM CRUD & ACTIONS
  // ==========================================
  Future<void> addRoom(RoomModel item) async {
    final newItem = item.id.isEmpty ? item.copyWith(id: 'room-${_uuid.v4().substring(0, 6)}') : item;
    _rooms.insert(0, newItem);
    await _persistRooms();
    _logActivity('Added Room', '${newItem.roomNumber} (Capacity: ${newItem.capacity})', 'Room', 'Add');
    notifyListeners();
  }

  Future<void> editRoom(RoomModel item) async {
    final index = _rooms.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _rooms[index] = item;
      await _persistRooms();
      _logActivity('Updated Room', 'Modified details for ${item.roomNumber}', 'Room', 'Edit');
      notifyListeners();
    }
  }

  Future<void> deleteRoom(String id) async {
    final item = _rooms.firstWhere((e) => e.id == id, orElse: () => RoomModel(id: '', roomNumber: 'Room', capacity: 0, equipment: []));
    _rooms.removeWhere((e) => e.id == id);
    await _persistRooms();
    _logActivity('Deleted Room', 'Removed ${item.roomNumber}', 'Room', 'Delete');
    notifyListeners();
  }

  Future<bool> bookRoom(String roomNumber, String bookedBy, String bookingTime) async {
    final index = _rooms.indexWhere((e) => e.roomNumber.toLowerCase() == roomNumber.toLowerCase());
    if (index != -1) {
      if (_rooms[index].isBooked) return false;
      _rooms[index] = _rooms[index].copyWith(
        isBooked: true,
        bookedBy: bookedBy,
        bookingTime: bookingTime,
      );
      await _persistRooms();
      _logActivity('Booked Room', '${_rooms[index].roomNumber} booked by $bookedBy for $bookingTime', 'Room', 'Book');
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> cancelRoomBooking(String roomNumber) async {
    final index = _rooms.indexWhere((e) => e.roomNumber.toLowerCase() == roomNumber.toLowerCase());
    if (index != -1) {
      _rooms[index] = _rooms[index].copyWith(
        isBooked: false,
        bookedBy: null,
        bookingTime: null,
      );
      await _persistRooms();
      _logActivity('Cancelled Room Booking', 'Booking cancelled for ${_rooms[index].roomNumber}', 'Room', 'Cancel');
      notifyListeners();
      return true;
    }
    return false;
  }

  // ==========================================
  // 3. EVENT CRUD & ACTIONS
  // ==========================================
  Future<void> addEvent(EventModel item) async {
    final newItem = item.id.isEmpty ? item.copyWith(id: 'event-${_uuid.v4().substring(0, 6)}') : item;
    _events.insert(0, newItem);
    await _persistEvents();
    _logActivity('Created Event', '${newItem.name} on ${newItem.date}', 'Event', 'Add');
    notifyListeners();
  }

  Future<void> editEvent(EventModel item) async {
    final index = _events.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _events[index] = item;
      await _persistEvents();
      _logActivity('Updated Event', 'Edited ${item.name}', 'Event', 'Edit');
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String id) async {
    final item = _events.firstWhere((e) => e.id == id, orElse: () => EventModel(id: '', name: 'Event', date: '', time: '', capacity: 0, registeredCount: 0, location: '', description: ''));
    _events.removeWhere((e) => e.id == id);
    await _persistEvents();
    _logActivity('Deleted Event', 'Removed event: ${item.name}', 'Event', 'Delete');
    notifyListeners();
  }

  Future<bool> registerEvent(String eventIdOrName) async {
    final index = _events.indexWhere((e) => e.id == eventIdOrName || e.name.toLowerCase().contains(eventIdOrName.toLowerCase()));
    if (index != -1) {
      final ev = _events[index];
      if (ev.registeredCount >= ev.capacity && !ev.isRegistered) return false;
      _events[index] = ev.copyWith(
        isRegistered: true,
        registeredCount: ev.isRegistered ? ev.registeredCount : ev.registeredCount + 1,
      );
      await _persistEvents();
      _logActivity('Registered for Event', 'User registered for ${ev.name}', 'Event', 'Register');
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> cancelEventRegistration(String eventIdOrName) async {
    final index = _events.indexWhere((e) => e.id == eventIdOrName || e.name.toLowerCase().contains(eventIdOrName.toLowerCase()));
    if (index != -1) {
      final ev = _events[index];
      if (!ev.isRegistered) return false;
      _events[index] = ev.copyWith(
        isRegistered: false,
        registeredCount: (ev.registeredCount - 1).clamp(0, 9999),
      );
      await _persistEvents();
      _logActivity('Cancelled Registration', 'Cancelled registration for ${ev.name}', 'Event', 'Cancel');
      notifyListeners();
      return true;
    }
    return false;
  }

  // ==========================================
  // 4. ANNOUNCEMENT CRUD
  // ==========================================
  Future<void> addAnnouncement(AnnouncementModel item) async {
    final newItem = item.id.isEmpty ? item.copyWith(id: 'ann-${_uuid.v4().substring(0, 6)}') : item;
    _announcements.insert(0, newItem);
    await _persistAnnouncements();
    _logActivity('Posted Announcement', newItem.title, 'Announcement', 'Add');
    notifyListeners();
  }

  Future<void> editAnnouncement(AnnouncementModel item) async {
    final index = _announcements.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _announcements[index] = item;
      await _persistAnnouncements();
      _logActivity('Updated Announcement', 'Modified ${item.title}', 'Announcement', 'Edit');
      notifyListeners();
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    final item = _announcements.firstWhere((e) => e.id == id, orElse: () => AnnouncementModel(id: '', title: 'Notice', body: '', date: '', priority: 'Low'));
    _announcements.removeWhere((e) => e.id == id);
    await _persistAnnouncements();
    _logActivity('Deleted Announcement', 'Removed notice: ${item.title}', 'Announcement', 'Delete');
    notifyListeners();
  }

  // ==========================================
  // 5. ASSIGNMENT CRUD
  // ==========================================
  Future<void> addAssignment(AssignmentModel item) async {
    final newItem = item.id.isEmpty ? item.copyWith(id: 'assign-${_uuid.v4().substring(0, 6)}') : item;
    _assignments.insert(0, newItem);
    await _persistAssignments();
    _logActivity('Added Assignment', '${newItem.course}: ${newItem.title}', 'Assignment', 'Add');
    notifyListeners();
  }

  Future<void> editAssignment(AssignmentModel item) async {
    final index = _assignments.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      _assignments[index] = item;
      await _persistAssignments();
      _logActivity('Updated Assignment', 'Updated ${item.title}', 'Assignment', 'Edit');
      notifyListeners();
    }
  }

  Future<void> deleteAssignment(String id) async {
    final item = _assignments.firstWhere((e) => e.id == id, orElse: () => AssignmentModel(id: '', course: '', title: 'Assignment', deadline: '', status: ''));
    _assignments.removeWhere((e) => e.id == id);
    await _persistAssignments();
    _logActivity('Deleted Assignment', 'Removed ${item.title}', 'Assignment', 'Delete');
    notifyListeners();
  }

  Future<void> updateAssignmentStatus(String id, String status) async {
    final index = _assignments.indexWhere((e) => e.id == id);
    if (index != -1) {
      _assignments[index] = _assignments[index].copyWith(status: status);
      await _persistAssignments();
      _logActivity('Assignment Status Changed', '${_assignments[index].title} set to $status', 'Assignment', 'Edit');
      notifyListeners();
    }
  }
}
