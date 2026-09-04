class ActivityLogModel {
  final String id;
  final DateTime timestamp;
  final String title;
  final String description;
  final String category; // Schedule, Room, Event, Announcement, Assignment
  final String actionType; // Add, Edit, Delete, Book, Register

  ActivityLogModel({
    required this.id,
    required this.timestamp,
    required this.title,
    required this.description,
    required this.category,
    required this.actionType,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'] ?? '',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'System',
      actionType: json['actionType'] ?? 'Info',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'title': title,
      'description': description,
      'category': category,
      'actionType': actionType,
    };
  }
}
