import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/ai_agent_engine.dart';
import '../providers/campus_provider.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<ToolCallResult> toolCalls;
  final bool isClarification;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.toolCalls = const [],
    this.isClarification = false,
  });
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final Uuid _uuid = const Uuid();

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  ChatProvider() {
    // Initial welcome message from CampusOS AI Agent
    _messages.add(
      ChatMessage(
        id: _uuid.v4(),
        text: "👋 Hi Shahzaib! I am your **CampusOS AI Assistant**.\n\n"
            "I read and act on real-time campus data in your database. Ask me anything about your classes, assignments, rooms, or events!",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> sendMessage(String userText, CampusProvider campusProvider) async {
    if (userText.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: userText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMsg);
    _isTyping = true;
    notifyListeners();

    // Process through AI Agent Engine
    final engine = AIAgentEngine(campusProvider);
    final response = await engine.processMessage(userText);

    _isTyping = false;
    _messages.add(
      ChatMessage(
        id: _uuid.v4(),
        text: response.responseText,
        isUser: false,
        timestamp: DateTime.now(),
        toolCalls: response.executedTools,
        isClarification: response.isClarificationRequested,
      ),
    );

    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}
