import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceTypeModel {
  final String serviceId;
  final String serviceName;
  final double basePrice;
  final int duration; // in minutes

  ServiceTypeModel({
    required this.serviceId,
    required this.serviceName,
    required this.basePrice,
    required this.duration,
  });

  // Factory constructor from DocumentSnapshot
  factory ServiceTypeModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ServiceTypeModel(
      serviceId: doc.id,
      serviceName: data['serviceName'] ?? '',
      basePrice: (data['basePrice'] ?? 0.0).toDouble(),
      duration: data['duration'] ?? 0,
    );
  }

  // Factory constructor from Map
  factory ServiceTypeModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ServiceTypeModel(
      serviceId: documentId,
      serviceName: data['serviceName'] ?? '',
      basePrice: (data['basePrice'] ?? 0.0).toDouble(),
      duration: data['duration'] ?? 0,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'basePrice': basePrice,
      'duration': duration,
    };
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'basePrice': basePrice,
      'duration': duration,
    };
  }

  // Copy with method for immutable updates
  ServiceTypeModel copyWith({
    String? serviceId,
    String? serviceName,
    double? basePrice,
    int? duration,
  }) {
    return ServiceTypeModel(
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      basePrice: basePrice ?? this.basePrice,
      duration: duration ?? this.duration,
    );
  }

  // Utility methods
  String get formattedBasePrice {
    return 'RM ${basePrice.toStringAsFixed(2)}';
  }

  String get formattedDuration {
    if (duration < 60) {
      return '$duration min${duration > 1 ? 's' : ''}';
    } else {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      if (minutes == 0) {
        return '$hours hour${hours > 1 ? 's' : ''}';
      } else {
        return '$hours hour${hours > 1 ? 's' : ''} $minutes min${minutes > 1 ? 's' : ''}';
      }
    }
  }

  Duration get durationAsDuration => Duration(minutes: duration);

  // Validation methods
  bool isValid() {
    return serviceId.isNotEmpty &&
        serviceName.isNotEmpty &&
        basePrice >= 0 &&
        duration > 0;
  }

  List<String> getValidationErrors() {
    List<String> errors = [];

    if (serviceId.isEmpty) errors.add('Service ID is required');
    if (serviceName.isEmpty) errors.add('Service name is required');
    if (basePrice < 0) errors.add('Base price cannot be negative');
    if (duration <= 0) errors.add('Duration must be greater than 0');

    return errors;
  }

  @override
  String toString() {
    return 'ServiceTypeModel(serviceId: $serviceId, serviceName: $serviceName, basePrice: $basePrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceTypeModel && other.serviceId == serviceId;
  }

  @override
  int get hashCode => serviceId.hashCode;
}

// Appointment Status Enum
enum AppointmentStatus {
  pending,
  inProgress,
  completed,
  cancelled;

  static AppointmentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppointmentStatus.pending;
      case 'inprogress':
      case 'in_progress':
        return AppointmentStatus.inProgress;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.inProgress:
        return 'In Progress';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  String toString() {
    switch (this) {
      case AppointmentStatus.pending:
        return 'pending';
      case AppointmentStatus.inProgress:
        return 'inProgress';
      case AppointmentStatus.completed:
        return 'completed';
      case AppointmentStatus.cancelled:
        return 'cancelled';
    }
  }
}