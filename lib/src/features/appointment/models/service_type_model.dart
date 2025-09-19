// service_type_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/constants/firebase_field_names.dart';

class ServiceTypeModel {
  final String serviceId;
  final String serviceName;
  final double basePrice;
  final int duration; // 服务时长（分钟）
  final String category; // 例如: 'maintenance', 'repair', 'cleaning'

  ServiceTypeModel({
    required this.serviceId,
    required this.serviceName,
    required this.basePrice,
    required this.duration,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      FirebaseFieldNames.serviceId: serviceId,
      FirebaseFieldNames.serviceName: serviceName,
      FirebaseFieldNames.basePrice: basePrice,
      FirebaseFieldNames.duration: duration,
      FirebaseFieldNames.category: category,
    };
  }

  factory ServiceTypeModel.fromSnapshot(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;

    return ServiceTypeModel(
      serviceId: doc.id,
      serviceName: map[FirebaseFieldNames.serviceName] ?? '',
      basePrice: (map[FirebaseFieldNames.basePrice] ?? 0).toDouble(),
      duration: (map[FirebaseFieldNames.duration] ?? 0).toInt(),
      category: map[FirebaseFieldNames.category] ?? '',
    );
  }

  /// Get formatted price string
  String get formattedPrice {
    return 'RM${basePrice.toStringAsFixed(2)}';
  }

  /// Get formatted duration string
  String get formattedDuration {
    final hours = duration ~/ 60;
    final minutes = duration % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}