class Aircraft {
  final int? id;
  final String registrationNumber;
  final String model;
  final String manufacturer;
  final int yearOfManufacture;
  final String status;
  final DateTime? syncedAt;
  final DateTime createdAt;

  Aircraft({
    this.id,
    required this.registrationNumber,
    required this.model,
    required this.manufacturer,
    required this.yearOfManufacture,
    this.status = 'active',
    this.syncedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'registrationNumber': registrationNumber,
      'model': model,
      'manufacturer': manufacturer,
      'yearOfManufacture': yearOfManufacture,
      'status': status,
      'syncedAt': syncedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Aircraft.fromMap(Map<String, dynamic> map) {
    return Aircraft(
      id: map['id'],
      registrationNumber: map['registrationNumber'],
      model: map['model'],
      manufacturer: map['manufacturer'],
      yearOfManufacture: map['yearOfManufacture'],
      status: map['status'],
      syncedAt: map['syncedAt'] != null ? DateTime.parse(map['syncedAt']) : null,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
