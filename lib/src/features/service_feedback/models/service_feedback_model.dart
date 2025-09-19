import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/constants/colors.dart';

class ServiceFeedbackModel {
  final String? id;
  final String appointmentId;

  // Ratings (默认为 0，表示未填写)
  final int serviceRating;
  final int repairEfficiencyRating;
  final int transparencyRating;
  final int overallExperienceRating;

  // 用户输入内容
  final String comment;
  final List<String> mediaFilenames;

  // 系统/其他用户行为
  final List<String> likes;
  final String staffReply;

  // 时间戳
  final DateTime? createdAt; // 改成可空，防止 serverTimestamp 未解析
  final DateTime? updatedAt;

  // 状态管理
  final FeedbackStatus status;
  final int editRemaining;
  final Map<String, int>? reportCounts;

  ServiceFeedbackModel({
    this.id,
    required this.appointmentId,
    this.serviceRating = 0,
    this.repairEfficiencyRating = 0,
    this.transparencyRating = 0,
    this.overallExperienceRating = 0,
    this.comment = '',
    this.mediaFilenames = const [],
    this.likes = const [],
    this.staffReply = '',
    DateTime? createdAt,
    this.updatedAt,
    this.status = FeedbackStatus.pending, // 默认 pending
    this.editRemaining = 2, // Default 2 times edit
    this.reportCounts,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Factory: from Firestore
  factory ServiceFeedbackModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ServiceFeedbackModel(
      id: doc.id, // Firestore 生成的 id
      appointmentId: data['appointmentId'] ?? '',
      serviceRating: data['serviceRating'] ?? 0,
      repairEfficiencyRating: data['repairEfficiencyRating'] ?? 0,
      transparencyRating: data['transparencyRating'] ?? 0,
      overallExperienceRating: data['overallExperienceRating'] ?? 0,
      comment: data['comment'] ?? '',
      mediaFilenames: List<String>.from(data['mediaFilenames'] ?? []),
      likes: List<String>.from(data['likes'] ?? []),
      staffReply: data['staffReply'] ?? '',
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      status: FeedbackStatus.fromString(data['status'] ?? 'pending'),
      editRemaining: data['editRemaining'] ?? 2,
      reportCounts: Map<String, int>.from(data['reportCounts'] ?? {}),
    );
  }

  /// Convert to Firestore JSON
  Map<String, dynamic> toJson({bool newRecord = false}) {
    return {
      'appointmentId': appointmentId,
      'serviceRating': serviceRating,
      'repairEfficiencyRating': repairEfficiencyRating,
      'transparencyRating': transparencyRating,
      'overallExperienceRating': overallExperienceRating,
      'comment': comment,
      'mediaFilenames': mediaFilenames,
      'likes': likes,
      'staffReply': staffReply,
      'createdAt': newRecord
          ? FieldValue.serverTimestamp() // 新纪录时交给 Firestore 自动生成
          : (createdAt != null ? Timestamp.fromDate(createdAt!) : null),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'status': status.toString(),
      'editRemaining': editRemaining,
      'reportCounts': reportCounts ?? {},
    };
  }

  /// Copy with
  ServiceFeedbackModel copyWith({
    String? id,
    String? appointmentId,
    int? serviceRating,
    int? repairEfficiencyRating,
    int? transparencyRating,
    int? overallExperienceRating,
    String? comment,
    List<String>? mediaFilenames,
    List<String>? likes,
    String? staffReply,
    DateTime? createdAt,
    DateTime? updatedAt,
    FeedbackStatus? status,
    int? editRemaining,
    Map<String, int>? reportCounts,
  }) {
    return ServiceFeedbackModel(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      serviceRating: serviceRating ?? this.serviceRating,
      repairEfficiencyRating:
      repairEfficiencyRating ?? this.repairEfficiencyRating,
      transparencyRating: transparencyRating ?? this.transparencyRating,
      overallExperienceRating:
      overallExperienceRating ?? this.overallExperienceRating,
      comment: comment ?? this.comment,
      mediaFilenames: mediaFilenames ?? this.mediaFilenames,
      likes: likes ?? this.likes,
      staffReply: staffReply ?? this.staffReply,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      editRemaining: editRemaining ?? this.editRemaining,
      reportCounts: reportCounts ?? this.reportCounts,
    );
  }

  // 时间解析
  static DateTime? _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return null;
    if (dateTime is Timestamp) return dateTime.toDate();
    if (dateTime is String) return DateTime.tryParse(dateTime);
    if (dateTime is DateTime) return dateTime;
    return null;
  }

  // 平均分（如果还没填写，返回 0.0）
  double get averageRating {
    if (serviceRating == 0 &&
        repairEfficiencyRating == 0 &&
        transparencyRating == 0 &&
        overallExperienceRating == 0) {
      return 0.0;
    }
    return (serviceRating +
        repairEfficiencyRating +
        transparencyRating +
        overallExperienceRating) /
        4.0;
  }

  /// Check if feedback has staff reply
  bool get hasStaffReply => staffReply.isNotEmpty;

  /// Get formatted creation date
  String get formattedCreatedDate {
    if (createdAt == null) return 'Unknown date';

    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
    }
  }

  /// Get formatted updated date
  String get formattedUpdatedDate {
    if (updatedAt == null) return 'Not updated';

    final now = DateTime.now();
    final difference = now.difference(updatedAt!);

    if (difference.inDays == 0) {
      return 'Updated today';
    } else if (difference.inDays == 1) {
      return 'Updated yesterday';
    } else {
      return 'Updated ${difference.inDays} days ago';
    }
  }

  /// Check if rating is high (4.0+)
  bool get isHighRating => averageRating >= 4.0;

  /// Check if rating is medium (2.5 - 3.9)
  bool get isMediumRating => averageRating >= 2.5 && averageRating < 4.0;

  /// Check if rating is low (< 2.5)
  bool get isLowRating => averageRating < 2.5;

  /// Check if all ratings are filled
  bool get hasAllRatings {
    return serviceRating > 0 &&
        repairEfficiencyRating > 0 &&
        transparencyRating > 0 &&
        overallExperienceRating > 0;
  }

  /// Check if feedback is disabled
  bool get isDisabled => status == FeedbackStatus.disabled;

  /// Check if feedback is submitted
  bool get isSubmitted => status == FeedbackStatus.submitted;

  /// Check if feedback is pending
  bool get isPending => status == FeedbackStatus.pending;
}

// Feedback Status Enum
enum FeedbackStatus {
  pending,
  submitted,
  disabled;

  static FeedbackStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return FeedbackStatus.pending;
      case 'submitted':
        return FeedbackStatus.submitted;
      case 'disabled':
        return FeedbackStatus.disabled;
      default:
        return FeedbackStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case FeedbackStatus.pending:
        return 'Pending';
      case FeedbackStatus.submitted:
        return 'Submitted';
      case FeedbackStatus.disabled:
        return 'Disabled';
    }
  }

  @override
  String toString() {
    switch (this) {
      case FeedbackStatus.pending:
        return 'pending';
      case FeedbackStatus.submitted:
        return 'submitted';
      case FeedbackStatus.disabled:
        return 'disabled';
    }
  }
}