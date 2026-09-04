import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_os/services/storage_service.dart';
import 'package:campus_os/providers/campus_provider.dart';
import 'package:campus_os/services/ai_agent_engine.dart';
import 'package:campus_os/models/schedule_model.dart';
import 'package:campus_os/models/room_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CampusOS Core Systems & AI Agent Tests', () {
    late StorageService storageService;
    late CampusProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = await StorageService.init();
      provider = CampusProvider(storageService: storageService);
      
      // Manually populate provider for headless unit test
      await provider.addSchedule(ScheduleModel(
        id: 'sched-1',
        course: 'CSE321',
        time: '09:00 AM - 10:30 AM',
        room: 'Room 101',
        day: 'Today',
        instructor: 'Dr. Alan Turing',
      ));

      await provider.addRoom(RoomModel(
        id: 'room-302',
        roomNumber: 'Room 302',
        capacity: 15,
        equipment: ['Projector', 'AC'],
        isBooked: false,
      ));
    });

    test('CRUD: Add Schedule and verify in provider', () {
      expect(provider.schedules.any((s) => s.course == 'CSE321'), isTrue);
    });

    test('CRUD: Book Room and verify persistence', () async {
      final success = await provider.bookRoom('Room 302', 'Test User', 'Tomorrow 3 to 5 PM');
      expect(success, isTrue);
      expect(provider.rooms.firstWhere((r) => r.roomNumber == 'Room 302').isBooked, isTrue);
    });

    test('AI Agent: Handle "When is my next class?" query', () async {
      final engine = AIAgentEngine(provider);
      final response = await engine.processMessage('When is my next class?');
      expect(response.responseText, contains('CSE321'));
      expect(response.executedTools.any((t) => t.toolName == 'get_schedules'), isTrue);
    });

    test('AI Agent: Handle vague room booking query', () async {
      final engine = AIAgentEngine(provider);
      final response = await engine.processMessage('Just book me any room tomorrow afternoon.');
      expect(response.isClarificationRequested, isTrue);
      expect(response.responseText, contains('vague'));
    });
  });
}
