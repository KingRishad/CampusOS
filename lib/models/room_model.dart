class RoomModel {
  final String id;
  final String roomNumber;
  final int capacity;
  final List<String> equipment;
  final bool isBooked;
  final String? bookedBy;
  final String? bookingTime;

  RoomModel({
    required this.id,
    required this.roomNumber,
    required this.capacity,
    required this.equipment,
    this.isBooked = false,
    this.bookedBy,
    this.bookingTime,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? '',
      roomNumber: json['room_number'] ?? json['roomNumber'] ?? '',
      capacity: json['capacity'] is int ? json['capacity'] : int.tryParse(json['capacity'].toString()) ?? 0,
      equipment: (json['equipment'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isBooked: json['is_booked'] ?? json['isBooked'] ?? false,
      bookedBy: json['booked_by'] ?? json['bookedBy'],
      bookingTime: json['booking_time'] ?? json['bookingTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_number': roomNumber,
      'capacity': capacity,
      'equipment': equipment,
      'is_booked': isBooked,
      'booked_by': bookedBy,
      'booking_time': bookingTime,
    };
  }

  RoomModel copyWith({
    String? id,
    String? roomNumber,
    int? capacity,
    List<String>? equipment,
    bool? isBooked,
    String? bookedBy,
    String? bookingTime,
  }) {
    return RoomModel(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      capacity: capacity ?? this.capacity,
      equipment: equipment ?? this.equipment,
      isBooked: isBooked ?? this.isBooked,
      bookedBy: bookedBy ?? this.bookedBy,
      bookingTime: bookingTime ?? this.bookingTime,
    );
  }
}
