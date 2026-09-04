class AssignmentModel {
  final String id;
  final String course;
  final String title;
  final String deadline;
  final String status; // "Pending", "Submitted", "Completed"

  AssignmentModel({
    required this.id,
    required this.course,
    required this.title,
    required this.deadline,
    required this.status,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'] ?? '',
      course: json['course'] ?? '',
      title: json['title'] ?? '',
      deadline: json['deadline'] ?? '',
      status: json['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course': course,
      'title': title,
      'deadline': deadline,
      'status': status,
    };
  }

  AssignmentModel copyWith({
    String? id,
    String? course,
    String? title,
    String? deadline,
    String? status,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      course: course ?? this.course,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
    );
  }
}
