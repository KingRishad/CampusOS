class AnnouncementModel {
  final String id;
  final String title;
  final String body;
  final String date;
  final String priority; // "High", "Medium", "Low"

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.priority,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      date: json['date'] ?? '',
      priority: json['priority'] ?? 'Medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'date': date,
      'priority': priority,
    };
  }

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? body,
    String? date,
    String? priority,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      date: date ?? this.date,
      priority: priority ?? this.priority,
    );
  }
}
