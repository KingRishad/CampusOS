class ScheduleModel {
  final String id;
  final String course;
  final String time;
  final String room;
  final String day;
  final String instructor;

  ScheduleModel({
    required this.id,
    required this.course,
    required this.time,
    required this.room,
    required this.day,
    required this.instructor,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] ?? '',
      course: json['course'] ?? '',
      time: json['time'] ?? '',
      room: json['room'] ?? '',
      day: json['day'] ?? '',
      instructor: json['instructor'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course': course,
      'time': time,
      'room': room,
      'day': day,
      'instructor': instructor,
    };
  }

  ScheduleModel copyWith({
    String? id,
    String? course,
    String? time,
    String? room,
    String? day,
    String? instructor,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      course: course ?? this.course,
      time: time ?? this.time,
      room: room ?? this.room,
      day: day ?? this.day,
      instructor: instructor ?? this.instructor,
    );
  }
}
