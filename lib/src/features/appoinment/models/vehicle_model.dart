class VehicleInfo {
  final String licensePlate;
  final String make;
  final String model;
  final int year;

  VehicleInfo({
    required this.licensePlate,
    required this.make,
    required this.model,
    required this.year,
  });

  factory VehicleInfo.fromMap(Map<String, dynamic> data) {
    return VehicleInfo(
      licensePlate: data['licensePlate'] ?? '',
      make: data['make'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'licensePlate': licensePlate,
      'make': make,
      'model': model,
      'year': year,
    };
  }

  VehicleInfo copyWith({
    String? licensePlate,
    String? make,
    String? model,
    int? year,
  }) {
    return VehicleInfo(
      licensePlate: licensePlate ?? this.licensePlate,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
    );
  }

  String get formattedVehicle => '$make $model ($year)';

  @override
  String toString() {
    return 'VehicleInfo(licensePlate: $licensePlate, make: $make, model: $model, year: $year)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehicleInfo &&
        other.licensePlate == licensePlate &&
        other.make == make &&
        other.model == model &&
        other.year == year;
  }

  @override
  int get hashCode => Object.hash(licensePlate, make, model, year);
}