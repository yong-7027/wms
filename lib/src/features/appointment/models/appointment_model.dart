import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/constants/firebase_field_names.dart';
import 'vehicle_info_model.dart';

class AppointmentModel {
  final String appointmentId;
  final String userId;
  final List<String> serviceTypeIds; // 存储服务类型的ID引用
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'in_progress', 'completed', 'cancelled'
  final DateTime scheduledAt;
  final DateTime? createdAt;
  final VehicleInfoModel vehicleInfo;
  final String? notes;

  AppointmentModel({
    required this.appointmentId,
    required this.userId,
    required this.serviceTypeIds,
    required this.totalPrice,
    required this.status,
    required this.scheduledAt,
    required this.vehicleInfo,
    this.createdAt,
    this.notes,
  });

  static AppointmentModel empty() {
    return AppointmentModel(
      appointmentId: '',
      userId: '',
      serviceTypeIds: [],
      totalPrice: 0.0,
      status: 'pending',
      scheduledAt: DateTime.now(),
      vehicleInfo: VehicleInfoModel(
        licensePlate: '',
        make: '',
        model: '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FirebaseFieldNames.appointmentId: appointmentId,
      FirebaseFieldNames.userId: userId,
      FirebaseFieldNames.serviceTypes: serviceTypeIds, // 存储ID列表
      FirebaseFieldNames.totalPrice: totalPrice,
      FirebaseFieldNames.status: status,
      FirebaseFieldNames.scheduledAt: Timestamp.fromDate(scheduledAt),
      FirebaseFieldNames.vehicleInfo: vehicleInfo.toJson(),
      FirebaseFieldNames.createdAt: createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(), // 如果为空，使用服务器时间
    };
  }

  factory AppointmentModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data();
    if (map == null) return AppointmentModel.empty();

    // 处理车辆信息
    final vehicleMap = map[FirebaseFieldNames.vehicleInfo] as Map<
        String,
        dynamic>?;
    final vehicleInfo = vehicleMap != null
        ? VehicleInfoModel.fromMap(vehicleMap)
        : VehicleInfoModel(licensePlate: '', make: '', model: '');

    // 处理服务类型ID列表
    final serviceTypesData = map[FirebaseFieldNames.serviceTypes] as List<
        dynamic>?;
    final serviceTypeIds = serviceTypesData?.map((id) => id.toString())
        .toList() ?? [];

    return AppointmentModel(
      appointmentId: doc.id,
      // 使用文档ID作为预约ID
      userId: map[FirebaseFieldNames.userId] ?? '',
      serviceTypeIds: serviceTypeIds,
      totalPrice: (map[FirebaseFieldNames.totalPrice] ?? 0).toDouble(),
      status: map[FirebaseFieldNames.status] ?? 'pending',
      scheduledAt: (map[FirebaseFieldNames.scheduledAt] as Timestamp).toDate(),
      vehicleInfo: vehicleInfo,
      createdAt: map[FirebaseFieldNames.createdAt] != null
          ? (map[FirebaseFieldNames.createdAt] as Timestamp).toDate()
          : null,
    );
  }

  /// Get formatted price string
  String get formattedPrice {
    return 'RM${totalPrice.toStringAsFixed(2)}';
  }

  /// Get formatted date string
  String get formattedDate {
    return '${scheduledAt.day}/${scheduledAt.month}/${scheduledAt.year}';
  }

  /// Get formatted time string
  String get formattedTime {
    return '${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute
        .toString().padLeft(2, '0')}';
  }
}