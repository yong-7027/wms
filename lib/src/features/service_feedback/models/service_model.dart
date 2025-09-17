import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String serviceType;
  final String carName;
  final String carModel;
  final String carPlateNo;
  final String serviceDesc;
  final DateTime serviceDate;
  final DateTime completedDate;
  final double totalCost;
  final ServiceStatus status;
  final String? imageUrl;
  final bool hasFeedback;

  ServiceModel({
    required this.id,
    required this.serviceType,
    required this.carName,
    required this.carModel,
    required this.carPlateNo,
    required this.serviceDesc,
    required this.serviceDate,
    required this.completedDate,
    required this.totalCost,
    required this.status,
    this.imageUrl,
    required this.hasFeedback,
  });

  // Factory constructor from JSON
  factory ServiceModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ServiceModel(
      id: doc.id,
      serviceType: data['serviceType'] ?? '',
      carName: data['carName'] ?? '',
      carModel: data['carModel'] ?? '',
      carPlateNo: data['carPlateNo'] ?? '',
      serviceDesc: data['serviceDesc'] ?? '',
      serviceDate: DateTime.parse(data['serviceDate']),
      completedDate: DateTime.parse(data['completedDate']),
      totalCost: (data['price'] ?? 0.0).toDouble(),
      status: ServiceStatus.fromString(data['status'] ?? 'pending'),
      imageUrl: data['imageUrl'],
      hasFeedback: data['hasFeedback'] ?? false, // 添加默认值
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceType': serviceType,
      'carName': carName,
      'carModel': carModel,
      'carPlateNo': carPlateNo,
      'serviceDesc': serviceDesc,
      'serviceDate': serviceDate.toIso8601String(),
      'completedDate': completedDate.toIso8601String(),
      'totalCost': totalCost,
      'status': status.toString(),
      'imageUrl': imageUrl,
      'hasFeedback': hasFeedback,
    };
  }

  // Copy with method for immutable updates
  ServiceModel copyWith({
    String? id,
    String? serviceType,
    String? carName,
    String? carModel,
    String? carPlateNo,
    String? serviceDesc,
    DateTime? serviceDate,
    DateTime? completedDate,
    String? mechanicName,
    String? mechanicId,
    double? totalCost,
    ServiceStatus? status,
    List<String>? serviceItems,
    String? notes,
    String? imageUrl,
    bool? hasFeedback,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      serviceType: serviceType ?? this.serviceType,
      carName: carName ?? this.carName,
      carModel: carModel ?? this.carModel,
      carPlateNo: carPlateNo ?? this.carPlateNo,
      serviceDesc: serviceDesc ?? this.serviceDesc,
      serviceDate: serviceDate ?? this.serviceDate,
      completedDate: completedDate ?? this.completedDate,
      totalCost: totalCost ?? this.totalCost,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      hasFeedback: hasFeedback ?? this.hasFeedback,
    );
  }

  // Calculate remaining time for rating (7 days from completion)
  Duration get remainingTimeToRate {
    final deadline = completedDate.add(Duration(days: 7));
    final now = DateTime.now();
    if (now.isAfter(deadline)) return Duration.zero;
    return deadline.difference(now);
  }

  bool get canRate => remainingTimeToRate.inSeconds > 0 && !hasFeedback;

  // Utility methods
  String get formattedServiceDate {
    return '${serviceDate.day}/${serviceDate.month}/${serviceDate.year}, ${serviceDate.hour.toString().padLeft(2, '0')}:${serviceDate.minute.toString().padLeft(2, '0')} ${serviceDate.hour >= 12 ? 'PM' : 'AM'}';
  }

  String get formattedCompletedDate {
    return '${completedDate.day}/${completedDate.month}/${completedDate.year}, ${completedDate.hour.toString().padLeft(2, '0')}:${completedDate.minute.toString().padLeft(2, '0')} ${completedDate.hour >= 12 ? 'PM' : 'AM'}';
  }

  String get formattedTotalCost {
    return 'RM ${totalCost.toStringAsFixed(2)}';
  }

  Duration get serviceDuration {
    return completedDate.difference(serviceDate);
  }

  String get formattedServiceDuration {
    final duration = serviceDuration;
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}';
    }
  }

  bool get isCompleted => status == ServiceStatus.completed;
  bool get isPending => status == ServiceStatus.pending;
  bool get isInProgress => status == ServiceStatus.inProgress;
  bool get isCancelled => status == ServiceStatus.cancelled;

  bool get canBeFeedbackGiven => isCompleted;

  // Validation methods
  bool isValid() {
    return id.isNotEmpty &&
        serviceType.isNotEmpty &&
        carName.isNotEmpty &&
        serviceDesc.isNotEmpty &&
        totalCost >= 0;
  }

  List<String> getValidationErrors() {
    List<String> errors = [];

    if (id.isEmpty) errors.add('Service ID is required');
    if (serviceType.isEmpty) errors.add('Service type is required');
    if (carName.isEmpty) errors.add('Car name is required');
    if (serviceDesc.isEmpty) errors.add('Service details are required');
    if (totalCost < 0) errors.add('Total cost cannot be negative');

    return errors;
  }

  @override
  String toString() {
    return 'ServiceModel(id: $id, serviceType: $serviceType, carName: $carName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Service Status Enum
enum ServiceStatus {
  pending,
  inProgress,
  completed,
  cancelled;

  static ServiceStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ServiceStatus.pending;
      case 'inProgress':
        return ServiceStatus.inProgress;
      case 'completed':
        return ServiceStatus.completed;
      case 'cancelled':
        return ServiceStatus.cancelled;
      default:
        return ServiceStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case ServiceStatus.pending:
        return 'Pending';
      case ServiceStatus.inProgress:
        return 'In Progress';
      case ServiceStatus.completed:
        return 'Completed';
      case ServiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  String toString() {
    switch (this) {
      case ServiceStatus.pending:
        return 'pending';
      case ServiceStatus.inProgress:
        return 'inProgress';
      case ServiceStatus.completed:
        return 'completed';
      case ServiceStatus.cancelled:
        return 'cancelled';
    }
  }
}