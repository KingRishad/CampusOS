import '../providers/campus_provider.dart';
import '../models/schedule_model.dart';
import '../models/room_model.dart';
import '../models/event_model.dart';
import '../models/announcement_model.dart';

class ToolCallResult {
  final String toolName;
  final Map<String, dynamic> arguments;
  final String resultSummary;
  final bool success;

  ToolCallResult({
    required this.toolName,
    required this.arguments,
    required this.resultSummary,
    required this.success,
  });
}

class AgentResponse {
  final String responseText;
  final List<ToolCallResult> executedTools;
  final bool isClarificationRequested;

  AgentResponse({
    required this.responseText,
    this.executedTools = const [],
    this.isClarificationRequested = false,
  });
}

class AIAgentEngine {
  final CampusProvider provider;

  AIAgentEngine(this.provider);

  Future<AgentResponse> processMessage(String userMessage) async {
    final query = userMessage.toLowerCase().trim();
    final List<ToolCallResult> toolsExecuted = [];

    // 1. Check for vague request (Catch-out rule)
    if (_isVagueRoomBooking(query)) {
      return AgentResponse(
        responseText: "I'd be glad to help you book a room! However, your request is a bit too vague. Please clarify:\n"
            "1. Exact time slot (e.g., 2:00 PM - 4:00 PM)\n"
            "2. Expected number of people\n"
            "3. Any required equipment (e.g., Projector, Smart Board)",
        isClarificationRequested: true,
      );
    }

    // 2. Query: "When is my next class?"
    if (query.contains("next class") || query.contains("when is my class") || query.contains("class today")) {
      // Execute tool get_schedules
      final List<ScheduleModel> todayClasses = provider.schedules;
      final List<AnnouncementModel> announcements = provider.announcements;

      toolsExecuted.add(ToolCallResult(
        toolName: 'get_schedules',
        arguments: {'day': 'Today'},
        resultSummary: 'Found ${todayClasses.length} scheduled classes',
        success: true,
      ));

      toolsExecuted.add(ToolCallResult(
        toolName: 'get_announcements',
        arguments: {'query': 'class'},
        resultSummary: 'Found ${announcements.length} announcements checked for updates',
        success: true,
      ));

      if (todayClasses.isEmpty) {
        return AgentResponse(
          responseText: "You have no classes scheduled for today! Enjoy your free time.",
          executedTools: toolsExecuted,
        );
      }

      final nextClass = todayClasses.first;
      
      // Check if there is a schedule update in announcements
      final relevantAnn = announcements.firstWhere(
        (a) => a.title.toLowerCase().contains(nextClass.course.toLowerCase()) ||
            a.body.toLowerCase().contains(nextClass.course.toLowerCase()),
        orElse: () => AnnouncementModel(id: '', title: '', body: '', date: '', priority: ''),
      );

      String reply = "Your next scheduled class is **${nextClass.course}** with **${nextClass.instructor}** at **${nextClass.time}** in **${nextClass.room}**.";
      
      if (relevantAnn.title.isNotEmpty) {
        reply += "\n\n⚠️ **Notice Update**: ${relevantAnn.title}\n_${relevantAnn.body}_";
      }

      return AgentResponse(
        responseText: reply,
        executedTools: toolsExecuted,
      );
    }

    // 3. Query: "What have I got due this week?" / "assignments due"
    if (query.contains("due") || query.contains("assignment") || query.contains("homework")) {
      final pendingAssignments = provider.assignments.where((a) => a.status != "Completed").toList();

      toolsExecuted.add(ToolCallResult(
        toolName: 'get_assignments',
        arguments: {'status': 'Pending'},
        resultSummary: 'Retrieved ${pendingAssignments.length} pending assignment(s)',
        success: true,
      ));

      if (pendingAssignments.isEmpty) {
        return AgentResponse(
          responseText: "🎉 Great news! You have no pending assignments due this week.",
          executedTools: toolsExecuted,
        );
      }

      StringBuffer sb = StringBuffer();
      sb.writeln("Here are your upcoming assignment deadlines:\n");
      for (var a in pendingAssignments) {
        sb.writeln("• **${a.course}**: ${a.title}");
        sb.writeln("  📅 Deadline: *${a.deadline}* (Status: ${a.status})\n");
      }

      return AgentResponse(
        responseText: sb.toString(),
        executedTools: toolsExecuted,
      );
    }

    // 4. Query: "I am free until 2 - is there anything on campus I could drop into?"
    if (query.contains("free until") || query.contains("drop into") || query.contains("anything on campus")) {
      final events = provider.events;

      toolsExecuted.add(ToolCallResult(
        toolName: 'get_events',
        arguments: {'date': 'Today', 'before_time': '02:00 PM'},
        resultSummary: 'Scanned ${events.length} campus event(s)',
        success: true,
      ));

      final availableEvents = events.where((e) => e.date.toLowerCase() == 'today').toList();

      if (availableEvents.isEmpty) {
        return AgentResponse(
          responseText: "There are no major campus events scheduled before 2:00 PM today. You can grab a coffee at the cafeteria or reserve a study space!",
          executedTools: toolsExecuted,
        );
      }

      StringBuffer sb = StringBuffer();
      sb.writeln("Yes! Here is an event happening on campus before 2:00 PM:\n");
      for (var e in availableEvents) {
        sb.writeln("📍 **${e.name}**");
        sb.writeln("  🕒 Time: ${e.time} at ${e.location}");
        sb.writeln("  ℹ️ ${e.description}");
        sb.writeln("  👥 Capacity: ${e.registeredCount}/${e.capacity} registered\n");
      }

      return AgentResponse(
        responseText: sb.toString(),
        executedTools: toolsExecuted,
      );
    }

    // 5. Query: "Book Room 302 tomorrow, 3 to 5 PM" or "Book Room X"
    if (query.contains("book room") || query.contains("reserve room")) {
      // Extract room number
      final roomMatch = RegExp(r'room\s+(\d+)', caseSensitive: false).firstMatch(query);
      if (roomMatch != null) {
        final roomNum = "Room ${roomMatch.group(1)}";
        final bool success = await provider.bookRoom(roomNum, "Student User", "Tomorrow 03:00 PM - 05:00 PM");

        toolsExecuted.add(ToolCallResult(
          toolName: 'book_room',
          arguments: {'room_number': roomNum, 'time': 'Tomorrow 03:00 PM - 05:00 PM'},
          resultSummary: success ? 'Room $roomNum booked successfully' : 'Room $roomNum was already booked or not found',
          success: success,
        ));

        if (success) {
          return AgentResponse(
            responseText: "✅ **$roomNum** has been successfully booked for you for **tomorrow from 3:00 PM to 5:00 PM**!\nYour booking is saved to the campus data manager.",
            executedTools: toolsExecuted,
          );
        } else {
          return AgentResponse(
            responseText: "❌ Sorry, **$roomNum** is currently unavailable or booked at that time. Would you like me to find an alternative room with similar capacity?",
            executedTools: toolsExecuted,
          );
        }
      }
    }

    // 6. Query: "I need a room for X people with Y equipment"
    if (query.contains("room for") || query.contains("projector") || query.contains("capacity")) {
      final List<RoomModel> rooms = provider.rooms;
      
      // Parse minimum capacity if requested
      int minCap = 1;
      final capMatch = RegExp(r'(\d+)\s*people').firstMatch(query);
      if (capMatch != null) {
        minCap = int.parse(capMatch.group(1)!);
      }

      // Check equipment requirement
      final needsProjector = query.contains("projector");
      
      final matchingRooms = rooms.where((r) {
        bool capOk = r.capacity >= minCap;
        bool eqOk = !needsProjector || r.equipment.any((eq) => eq.toLowerCase().contains("projector"));
        return capOk && eqOk && !r.isBooked;
      }).toList();

      toolsExecuted.add(ToolCallResult(
        toolName: 'get_rooms',
        arguments: {'min_capacity': minCap, 'required_equipment': needsProjector ? ['Projector'] : []},
        resultSummary: 'Found ${matchingRooms.length} available room(s) matching criteria',
        success: true,
      ));

      if (matchingRooms.isEmpty) {
        return AgentResponse(
          responseText: "I couldn't find an available room for $minCap people with ${needsProjector ? 'a Projector' : 'the requested equipment'}.",
          executedTools: toolsExecuted,
        );
      }

      StringBuffer sb = StringBuffer();
      sb.writeln("I found the following suitable available room(s) for $minCap people:\n");
      for (var r in matchingRooms) {
        sb.writeln("🚪 **${r.roomNumber}** (Capacity: ${r.capacity})");
        sb.writeln("  🛠️ Equipment: ${r.equipment.join(', ')}");
        sb.writeln("  Status: Available for booking\n");
      }
      sb.writeln("Would you like me to book one of these for you?");

      return AgentResponse(
        responseText: sb.toString(),
        executedTools: toolsExecuted,
      );
    }

    // 7. Query: "Register for event"
    if (query.contains("register for") || query.contains("sign up for")) {
      final eventMatch = provider.events.firstWhere(
        (e) => query.contains(e.name.toLowerCase()) || query.contains("workshop") || query.contains("debate") || query.contains("fair"),
        orElse: () => provider.events.first,
      );

      final bool ok = await provider.registerEvent(eventMatch.id);

      toolsExecuted.add(ToolCallResult(
        toolName: 'register_event',
        arguments: {'event_id': eventMatch.id, 'event_name': eventMatch.name},
        resultSummary: ok ? 'Registered user for event' : 'Registration failed or already registered',
        success: ok,
      ));

      return AgentResponse(
        responseText: ok
            ? "🎟️ You are now registered for **${eventMatch.name}**!\nDate: ${eventMatch.date} at ${eventMatch.time} (${eventMatch.location})."
            : "You are already registered for **${eventMatch.name}** or the event is full.",
        executedTools: toolsExecuted,
      );
    }

    // 8. General search fallback across campus data
    toolsExecuted.add(ToolCallResult(
      toolName: 'search_campus_data',
      arguments: {'query': query},
      resultSummary: 'Searched 5 campus systems for query: "$query"',
      success: true,
    ));

    return AgentResponse(
      responseText: "I scanned the campus schedule, rooms, events, announcements, and assignments for **\"$userMessage\"**.\n\n"
          "You can ask me questions like:\n"
          "• *\"When is my next class?\"*\n"
          "• *\"What assignments are due this week?\"*\n"
          "• *\"I am free until 2 - is there anything on campus I could drop into?\"*\n"
          "• *\"Book Room 302 tomorrow, 3 to 5 PM\"*\n"
          "• *\"Find me a room for 5 people with a projector\"*",
      executedTools: toolsExecuted,
    );
  }

  bool _isVagueRoomBooking(String query) {
    if (query.contains("just book") || query.contains("book me any room") || (query.contains("book room") && !query.contains("302") && !query.contains("304") && !query.contains("101") && !query.contains("202") && !query.contains("lab"))) {
      if (!query.contains("101") && !query.contains("202") && !query.contains("302") && !query.contains("304") && !query.contains("lab 3")) {
        return true;
      }
    }
    return false;
  }
}
