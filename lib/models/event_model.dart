class EventModel {
  final String id;
  final String name;
  final String date;
  final String time;
  final int capacity;
  final int registeredCount;
  final bool isRegistered;
  final String location;
  final String description;

  EventModel({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.capacity,
    required this.registeredCount,
    this.isRegistered = false,
    required this.location,
    required this.description,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      capacity: json['capacity'] is int ? json['capacity'] : int.tryParse(json['capacity'].toString()) ?? 0,
      registeredCount: json['registered_count'] is int
          ? json['registered_count']
          : int.tryParse(json['registered_count']?.toString() ?? '0') ?? 0,
      isRegistered: json['is_registered'] ?? json['isRegistered'] ?? false,
      location: json['location'] ?? 'Campus',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'time': time,
      'capacity': capacity,
      'registered_count': registeredCount,
      'is_registered': isRegistered,
      'location': location,
      'description': description,
    };
  }

  EventModel copyWith({
    String? id,
    String? name,
    String? date,
    String? time,
    int? capacity,
    int? registeredCount,
    bool? isRegistered,
    String? location,
    String? description,
  }) {
    return EventModel(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      time: time ?? this.time,
      capacity: capacity ?? this.capacity,
      registeredCount: registeredCount ?? this.registeredCount,
      isRegistered: isRegistered ?? this.isRegistered,
      location: location ?? this.location,
      description: description ?? this.description,
    );
  }
}
