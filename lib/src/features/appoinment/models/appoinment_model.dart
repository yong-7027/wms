import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wms/src/features/appoinment/models/service_type_model.dart';
import 'package:wms/src/features/appoinment/models/vehicle_model.dart';

// Appointment Model
class AppointmentModel {
  final String appointmentId;
  final DateTime? completedAt;
  final DateTime createdAt;
  final bool hasFeedback;
  final String? imagePath;
  final DateTime scheduledAt;
  final List<String> serviceTypeIds;
  final AppointmentStatus status;
  final double totalPrice;
  final String userId;
  final VehicleInfo vehicleInfo;

  AppointmentModel({
    required this.appointmentId,
    this.completedAt,
    required this.createdAt,
    required this.hasFeedback,
    this.imagePath,
    required this.scheduledAt,
    required this.serviceTypeIds,
    required this.status,
    required this.totalPrice,
    required this.userId,
    required this.vehicleInfo,
  });

  // Factory constructor from DocumentSnapshot
  factory AppointmentModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AppointmentModel(
      appointmentId: doc.id,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      hasFeedback: data['hasFeedback'] ?? false,
      imagePath: data['imagePath'],
      scheduledAt: (data['scheduledAt'] as Timestamp).toDate(),
      serviceTypeIds: List<String>.from(data['serviceTypeIds'] ?? []),
      status: AppointmentStatus.fromString(data['status'] ?? 'pending'),
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      userId: data['userId'] ?? '',
      vehicleInfo: VehicleInfo.fromMap(data['vehicleInfo'] ?? {}),
    );
  }

  // Factory constructor from Map
  factory AppointmentModel.fromMap(Map<String, dynamic> data, String documentId) {
    return AppointmentModel(
      appointmentId: documentId,
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      hasFeedback: data['hasFeedback'] ?? false,
      imagePath: data['imagePath'],
      scheduledAt: (data['scheduledAt'] as Timestamp).toDate(),
      serviceTypeIds: List<String>.from(data['serviceTypeIds'] ?? []),
      status: AppointmentStatus.fromString(data['status'] ?? 'pending'),
      totalPrice: (data['totalPrice'] ?? 0.0).toDouble(),
      userId: data['userId'] ?? '',
      vehicleInfo: VehicleInfo.fromMap(data['vehicleInfo'] ?? {}),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'hasFeedback': hasFeedback,
      'imagePath': imagePath,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'serviceTypeIds': serviceTypeIds,
      'status': status.toString(),
      'totalPrice': totalPrice,
      'userId': userId,
      'vehicleInfo': vehicleInfo.toMap(),
    };
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'hasFeedback': hasFeedback,
      'imagePath': imagePath,
      'scheduledAt': scheduledAt.toIso8601String(),
      'serviceTypeIds': serviceTypeIds,
      'status': status.toString(),
      'totalPrice': totalPrice,
      'userId': userId,
      'vehicleInfo': vehicleInfo.toMap(),
    };
  }

  // Copy with method for immutable updates
  AppointmentModel copyWith({
    String? appointmentId,
    DateTime? completedAt,
    DateTime? createdAt,
    bool? hasFeedback,
    String? imagePath,
    DateTime? scheduledAt,
    List<String>? serviceTypeIds,
    AppointmentStatus? status,
    double? totalPrice,
    String? userId,
    VehicleInfo? vehicleInfo,
  }) {
    return AppointmentModel(
      appointmentId: appointmentId ?? this.appointmentId,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      hasFeedback: hasFeedback ?? this.hasFeedback,
      imagePath: imagePath ?? this.imagePath,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      serviceTypeIds: serviceTypeIds ?? this.serviceTypeIds,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      userId: userId ?? this.userId,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
    );
  }

  // Calculate remaining time for rating (7 days from completion)
  Duration get remainingTimeToRate {
    if (completedAt == null) return Duration.zero;
    final deadline = completedAt!.add(Duration(days: 7));
    final now = DateTime.now();
    if (now.isAfter(deadline)) return Duration.zero;
    return deadline.difference(now);
  }

  bool get canRate => remainingTimeToRate.inSeconds > 0 && !hasFeedback && isCompleted;

  // Utility methods
  String get formattedScheduledDate {
    return '${scheduledAt.day}/${scheduledAt.month}/${scheduledAt.year}, ${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')} ${scheduledAt.hour >= 12 ? 'PM' : 'AM'}';
  }

  String get formattedCompletedDate {
    if (completedAt == null) return 'Not completed';
    return '${completedAt!.day}/${completedAt!.month}/${completedAt!.year}, ${completedAt!.hour.toString().padLeft(2, '0')}:${completedAt!.minute.toString().padLeft(2, '0')} ${completedAt!.hour >= 12 ? 'PM' : 'AM'}';
  }

  String get formattedCreatedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}, ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')} ${createdAt.hour >= 12 ? 'PM' : 'AM'}';
  }

  String get formattedTotalPrice {
    return 'RM ${totalPrice.toStringAsFixed(2)}';
  }

  Duration? get serviceDuration {
    if (completedAt == null) return null;
    return completedAt!.difference(scheduledAt);
  }

  String get formattedServiceDuration {
    final duration = serviceDuration;
    if (duration == null) return 'In progress';

    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }

  // Status helpers
  bool get isCompleted => status == AppointmentStatus.completed;
  bool get isPending => status == AppointmentStatus.pending;
  bool get isInProgress => status == AppointmentStatus.inProgress;
  bool get isCancelled => status == AppointmentStatus.cancelled;
  bool get canBeFeedbackGiven => isCompleted;

  // Check if appointment is overdue
  bool get isOverdue {
    if (isCompleted || isCancelled) return false;
    return DateTime.now().isAfter(scheduledAt);
  }

  // Check if appointment is today
  bool get isToday {
    final now = DateTime.now();
    return scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day;
  }

  // Check if appointment is upcoming (within next 24 hours)
  bool get isUpcoming {
    final now = DateTime.now();
    final difference = scheduledAt.difference(now);
    return difference.inHours <= 24 && difference.inHours > 0;
  }

  // Validation methods
  bool isValid() {
    return appointmentId.isNotEmpty &&
        userId.isNotEmpty &&
        serviceTypeIds.isNotEmpty &&
        totalPrice >= 0 &&
        vehicleInfo.licensePlate.isNotEmpty;
  }

  List<String> getValidationErrors() {
    List<String> errors = [];

    if (appointmentId.isEmpty) errors.add('Appointment ID is required');
    if (userId.isEmpty) errors.add('User ID is required');
    if (serviceTypeIds.isEmpty) errors.add('At least one service type is required');
    if (totalPrice < 0) errors.add('Total price cannot be negative');
    if (vehicleInfo.licensePlate.isEmpty) errors.add('Vehicle license plate is required');
    if (vehicleInfo.make.isEmpty) errors.add('Vehicle make is required');
    if (vehicleInfo.model.isEmpty) errors.add('Vehicle model is required');

    return errors;
  }

  @override
  String toString() {
    return 'AppointmentModel(appointmentId: $appointmentId, status: $status, scheduledAt: $scheduledAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppointmentModel && other.appointmentId == appointmentId;
  }

  @override
  int get hashCode => appointmentId.hashCode;
}
