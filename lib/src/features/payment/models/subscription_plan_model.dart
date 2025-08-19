import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionPlanModel {
  final String planId;
  final String name;
  final double price;
  final String currency;
  final String duration; // 'monthly', 'yearly', etc.
  final List<String> features;
  final bool isActive;
  final DateTime? createdAt;

  SubscriptionPlanModel({
    required this.planId,
    required this.name,
    required this.price,
    required this.currency,
    required this.duration,
    required this.features,
    this.isActive = true,
    this.createdAt,
  });

  /// Empty constructor
  static SubscriptionPlanModel empty() {
    return SubscriptionPlanModel(
      planId: '',
      name: '',
      price: 0.0,
      currency: 'MYR',
      duration: '',
      features: [],
      isActive: false,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'name': name,
      'price': price,
      'currency': currency,
      'duration': duration,
      'features': features,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  /// From Snapshot
  factory SubscriptionPlanModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    if (data == null) return SubscriptionPlanModel.empty();

    return SubscriptionPlanModel(
      planId: data['planId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'MYR',
      duration: data['duration'] ?? '',
      features: List<String>.from(data['features'] ?? []),
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// From Map
  factory SubscriptionPlanModel.fromMap(Map<String, dynamic> data) {
    return SubscriptionPlanModel(
      planId: data['planId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'MYR',
      duration: data['duration'] ?? '',
      features: List<String>.from(data['features'] ?? []),
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Get formatted price string
  String get formattedPrice {
    return '${currency == 'MYR' ? 'RM' : currency}${price.toStringAsFixed(0)}';
  }

  /// Get display duration
  String get displayDuration {
    switch (duration.toLowerCase()) {
      case 'monthly':
        return 'month';
      case 'yearly':
        return 'year';
      default:
        return duration;
    }
  }
}