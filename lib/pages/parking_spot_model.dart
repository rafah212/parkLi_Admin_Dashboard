enum ParkingSpotStatus { available, booked }

class ParkingSpot {
  final String id;
  final String placeId;
  final String section;
  final String label;
  final int row;
  final int column;
  final ParkingSpotStatus status;

  const ParkingSpot({
    required this.id,
    required this.placeId,
    required this.section,
    required this.label,
    required this.row,
    required this.column,
    required this.status,
  });

  factory ParkingSpot.fromJson(Map<String, dynamic> json) {
    return ParkingSpot(
      id: json['id'] as String,
      placeId: json['place_id'] as String,
      section: json['section'] as String,
      label: json['label'] as String,
      row: json['row'] as int,
      column: json['column_no'] as int,
      status: _statusFromString(json['status'] as String? ?? 'available'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'place_id': placeId,
      'section': section,
      'label': label,
      'row': row,
      'column_no': column,
      'status': status.name,
    };
  }

  static ParkingSpotStatus _statusFromString(String value) {
    switch (value) {
      case 'booked':
        return ParkingSpotStatus.booked;
      default:
        return ParkingSpotStatus.available;
    }
  }

  bool get isAvailable => status == ParkingSpotStatus.available;
  bool get isBooked => status == ParkingSpotStatus.booked;

  ParkingSpot copyWith({
    String? id,
    String? placeId,
    String? section,
    String? label,
    int? row,
    int? column,
    ParkingSpotStatus? status,
  }) {
    return ParkingSpot(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      section: section ?? this.section,
      label: label ?? this.label,
      row: row ?? this.row,
      column: column ?? this.column,
      status: status ?? this.status,
    );
  }
}