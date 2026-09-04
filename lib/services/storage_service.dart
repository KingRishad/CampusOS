import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keySchedules = 'campus_schedules';
  static const String _keyRooms = 'campus_rooms';
  static const String _keyEvents = 'campus_events';
  static const String _keyAnnouncements = 'campus_announcements';
  static const String _keyAssignments = 'campus_assignments';
  static const String _keyActivityLogs = 'campus_activity_logs';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Generic Save List
  Future<bool> saveList(String key, List<Map<String, dynamic>> dataList) async {
    final String jsonString = json.encode(dataList);
    return await _prefs.setString(key, jsonString);
  }

  // Generic Load List
  List<Map<String, dynamic>>? loadList(String key) {
    final String? jsonString = _prefs.getString(key);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Storage load error for $key: $e');
      return null;
    }
  }

  // Specific Getters / Setters
  Future<bool> saveSchedules(List<Map<String, dynamic>> data) => saveList(_keySchedules, data);
  List<Map<String, dynamic>>? loadSchedules() => loadList(_keySchedules);

  Future<bool> saveRooms(List<Map<String, dynamic>> data) => saveList(_keyRooms, data);
  List<Map<String, dynamic>>? loadRooms() => loadList(_keyRooms);

  Future<bool> saveEvents(List<Map<String, dynamic>> data) => saveList(_keyEvents, data);
  List<Map<String, dynamic>>? loadEvents() => loadList(_keyEvents);

  Future<bool> saveAnnouncements(List<Map<String, dynamic>> data) => saveList(_keyAnnouncements, data);
  List<Map<String, dynamic>>? loadAnnouncements() => loadList(_keyAnnouncements);

  Future<bool> saveAssignments(List<Map<String, dynamic>> data) => saveList(_keyAssignments, data);
  List<Map<String, dynamic>>? loadAssignments() => loadList(_keyAssignments);

  Future<bool> saveActivityLogs(List<Map<String, dynamic>> data) => saveList(_keyActivityLogs, data);
  List<Map<String, dynamic>>? loadActivityLogs() => loadList(_keyActivityLogs);

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
