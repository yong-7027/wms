import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/constants/firebase_field_names.dart';

class VehicleInfoModel {
  final String licensePlate;
  final String make;
  final String model;
  final int? year;

  VehicleInfoModel({
    required this.licensePlate,
    required this.make,
    required this.model,
    this.year,
  });

  Map<String, dynamic> toJson() {
    return {
      FirebaseFieldNames.licensePlate: licensePlate,
      FirebaseFieldNames.make: make,
      FirebaseFieldNames.model: model,
      FirebaseFieldNames.year: year,
    };
  }

  factory VehicleInfoModel.fromMap(Map<String, dynamic> map) {
    return VehicleInfoModel(
      licensePlate: map[FirebaseFieldNames.licensePlate] ?? '',
      make: map[FirebaseFieldNames.make] ?? '',
      model: map[FirebaseFieldNames.model] ?? '',
      year: map[FirebaseFieldNames.year]?.toInt(),
    );
  }
}