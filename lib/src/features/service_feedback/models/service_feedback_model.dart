import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceFeedbackModel {
  final String id;
  final String appointmentId;
  final String userId;
  final int serviceRating;
  final int repairEfficiencyRating;
  final int transparencyRating;
  final int overallExperienceRating;
  final String comment;
  final List<String> mediaPaths;
  final List<String> likes;
  final String staffReply;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final FeedbackStatus status;
  final bool canEdit;

  ServiceFeedbackModel({
    required this.id,
    required this.appointmentId,
    required this.userId,
    required this.serviceRating,
    required this.repairEfficiencyRating,
    required this.transparencyRating,
    required this.overallExperienceRating,
    required this.comment,
    required this.mediaPaths,
    required this.likes,
    required this.staffReply,
    required this.createdAt,
    this.updatedAt,
    this.status = FeedbackStatus.submitted,
    this.canEdit = false,
  });

  // Factory constructor from Firestore DocumentSnapshot
  factory ServiceFeedbackModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceFeedbackModel.fromJson(data, doc.id);
  }

  // Factory constructor from JSON with optional ID
  factory ServiceFeedbackModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    return ServiceFeedbackModel(
      id: docId ?? json['id'] ?? '',
      appointmentId: json['appointmentId'] ?? json['service_id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      serviceRating: json['serviceRating'] ?? json['service_rating'] ?? 0,
      repairEfficiencyRating: json['repairEfficiencyRating'] ?? json['repair_efficiency_rating'] ?? 0,
      transparencyRating: json['transparencyRating'] ?? json['transparency_rating'] ?? 0,
      overallExperienceRating: json['overallExperienceRating'] ?? json['overall_experience_rating'] ?? 0,
      comment: json['comment'] ?? '',
      mediaPaths: List<String>.from(json['mediaPaths'] ?? json['media_paths'] ?? []),
      likes: List<String>.from(json['likes'] ?? []),
      staffReply: json['staffReply'] ?? json['staff_reply'] ?? '',
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']),
      status: FeedbackStatus.fromString(json['status'] ?? 'submitted'),
      canEdit: json['canEdit'] ?? json['can_edit'] ?? false,
    );
  }

  // Factory constructor from controller
  factory ServiceFeedbackModel.fromController({
    required String appointmentId,
    required String userId,
    required int serviceRating,
    required int repairEfficiencyRating,
    required int transparencyRating,
    required int overallExperienceRating,
    required String comment,
    required List<File> mediaFiles,
  }) {
    return ServiceFeedbackModel(
      id: _generateId(),
      appointmentId: appointmentId,
      userId: userId,
      serviceRating: serviceRating,
      repairEfficiencyRating: repairEfficiencyRating,
      transparencyRating: transparencyRating,
      overallExperienceRating: overallExperienceRating,
      comment: comment,
      mediaPaths: mediaFiles.map((file) => file.path).toList(),
      likes: [],
      staffReply: '',
      createdAt: DateTime.now(),
    );
  }

  // Helper method to parse DateTime from various formats
  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    if (dateTime is Timestamp) return dateTime.toDate();
    if (dateTime is String) return DateTime.parse(dateTime);
    if (dateTime is DateTime) return dateTime;
    return DateTime.now();
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'userId': userId,
      'serviceRating': serviceRating,
      'repairEfficiencyRating': repairEfficiencyRating,
      'transparencyRating': transparencyRating,
      'overallExperienceRating': overallExperienceRating,
      'comment': comment,
      'mediaPaths': mediaPaths,
      'likes': likes,
      'staffReply': staffReply,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'status': status.toString(),
      'canEdit': canEdit,
    };
  }

  // Convert to API format
  Map<String, dynamic> toApiJson() {
    return {
      'service_id': appointmentId,
      'user_id': userId,
      'ratings': {
        'service': serviceRating,
        'repair_efficiency': repairEfficiencyRating,
        'transparency': transparencyRating,
        'overall_experience': overallExperienceRating,
      },
      'comment': comment,
      'media_count': mediaPaths.length,
      'created_at': createdAt.toIso8601String(),
      'average_rating': averageRating,
    };
  }

  // Copy with method
  ServiceFeedbackModel copyWith({
    String? id,
    String? appointmentId,
    String? userId,
    int? serviceRating,
    int? repairEfficiencyRating,
    int? transparencyRating,
    int? overallExperienceRating,
    String? comment,
    List<String>? mediaPaths,
    List<String>? likes,
    String? staffReply,
    DateTime? createdAt,
    DateTime? updatedAt,
    FeedbackStatus? status,
    bool? canEdit,
  }) {
    return ServiceFeedbackModel(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      userId: userId ?? this.userId,
      serviceRating: serviceRating ?? this.serviceRating,
      repairEfficiencyRating: repairEfficiencyRating ?? this.repairEfficiencyRating,
      transparencyRating: transparencyRating ?? this.transparencyRating,
      overallExperienceRating: overallExperienceRating ?? this.overallExperienceRating,
      comment: comment ?? this.comment,
      mediaPaths: mediaPaths ?? this.mediaPaths,
      likes: likes ?? this.likes,
      staffReply: staffReply ?? this.staffReply,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      canEdit: canEdit ?? this.canEdit,
    );
  }

  // Calculate remaining time for editing (24 hours from review submission)
  Duration get remainingTimeToEdit {
    final deadline = createdAt.add(const Duration(hours: 24));
    final now = DateTime.now();
    if (now.isAfter(deadline)) return Duration.zero;
    return deadline.difference(now);
  }

  // Computed properties
  double get averageRating {
    return (serviceRating + repairEfficiencyRating + transparencyRating + overallExperienceRating) / 4.0;
  }

  String get formattedAverageRating {
    return averageRating.toStringAsFixed(1);
  }

  String get formattedCreatedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}, ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')} ${createdAt.hour >= 12 ? 'PM' : 'AM'}';
  }

  bool get hasMedia => mediaPaths.isNotEmpty;
  int get mediaCount => mediaPaths.length;

  bool get isHighRating => averageRating >= 4.0;
  bool get isMediumRating => averageRating >= 3.0 && averageRating < 4.0;
  bool get isLowRating => averageRating < 3.0;

  String get ratingCategory {
    if (isHighRating) return 'Excellent';
    if (isMediumRating) return 'Good';
    return 'Needs Improvement';
  }

  bool get hasComment => comment.trim().isNotEmpty;
  bool get hasStaffReply => staffReply.trim().isNotEmpty;
  bool get hasLikes => likes.isNotEmpty;
  int get likeCount => likes.length;

  // Validation methods
  bool isValid() {
    return appointmentId.isNotEmpty &&
        userId.isNotEmpty &&
        _isValidRating(serviceRating) &&
        _isValidRating(repairEfficiencyRating) &&
        _isValidRating(transparencyRating) &&
        _isValidRating(overallExperienceRating);
  }

  bool _isValidRating(int rating) {
    return rating >= 1 && rating <= 5;
  }

  List<String> getValidationErrors() {
    List<String> errors = [];

    if (appointmentId.isEmpty) errors.add('Service ID is required');
    if (userId.isEmpty) errors.add('User ID is required');
    if (!_isValidRating(serviceRating)) errors.add('Service rating must be between 1-5');
    if (!_isValidRating(repairEfficiencyRating)) errors.add('Repair efficiency rating must be between 1-5');
    if (!_isValidRating(transparencyRating)) errors.add('Transparency rating must be between 1-5');
    if (!_isValidRating(overallExperienceRating)) errors.add('Overall experience rating must be between 1-5');

    return errors;
  }

  // Rating analysis
  Map<String, int> getRatingBreakdown() {
    return {
      'Service': serviceRating,
      'Repair Efficiency': repairEfficiencyRating,
      'Transparency': transparencyRating,
      'Overall Experience': overallExperienceRating,
    };
  }

  int getLowestRating() {
    return [serviceRating, repairEfficiencyRating, transparencyRating, overallExperienceRating]
        .reduce((a, b) => a < b ? a : b);
  }

  int getHighestRating() {
    return [serviceRating, repairEfficiencyRating, transparencyRating, overallExperienceRating]
        .reduce((a, b) => a > b ? a : b);
  }

  String getLowestRatingCategory() {
    final ratings = getRatingBreakdown();
    final lowestValue = getLowestRating();
    return ratings.entries.firstWhere((entry) => entry.value == lowestValue).key;
  }

  // Media handling
  List<File> getMediaFiles() {
    return mediaPaths.map((path) => File(path)).toList();
  }

  List<String> getImagePaths() {
    return mediaPaths.where((path) {
      final extension = path.split('.').last.toLowerCase();
      return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
    }).toList();
  }

  List<String> getVideoPaths() {
    return mediaPaths.where((path) {
      final extension = path.split('.').last.toLowerCase();
      return ['mp4', 'mov', 'avi', 'mkv'].contains(extension);
    }).toList();
  }

  bool hasImages() => getImagePaths().isNotEmpty;
  bool hasVideos() => getVideoPaths().isNotEmpty;

  // Like functionality
  bool isLikedBy(String userId) => likes.contains(userId);

  ServiceFeedbackModel addLike(String userId) {
    if (!likes.contains(userId)) {
      return copyWith(likes: [...likes, userId]);
    }
    return this;
  }

  ServiceFeedbackModel removeLike(String userId) {
    if (likes.contains(userId)) {
      final newLikes = List<String>.from(likes)..remove(userId);
      return copyWith(likes: newLikes);
    }
    return this;
  }

  // Utility methods
  String getSummary() {
    String summary = 'Rating: ${formattedAverageRating}/5.0 ($ratingCategory)';
    if (hasComment) {
      summary += '\nComment: ${comment.length > 50 ? '${comment.substring(0, 50)}...' : comment}';
    }
    if (hasMedia) {
      summary += '\nMedia: $mediaCount file(s)';
    }
    if (hasLikes) {
      summary += '\nLikes: $likeCount';
    }
    return summary;
  }

  static String _generateId() {
    return 'feedback_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (9999 - 1000) * (DateTime.now().microsecond / 1000000)).round()}';
  }

  @override
  String toString() {
    return 'ServiceFeedbackModel(id: $id, appointmentId: $appointmentId, averageRating: $formattedAverageRating, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceFeedbackModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Feedback Status Enum
enum FeedbackStatus {
  draft,
  submitted,
  reviewed,
  published,
  archived;

  static FeedbackStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return FeedbackStatus.draft;
      case 'submitted':
        return FeedbackStatus.submitted;
      case 'reviewed':
        return FeedbackStatus.reviewed;
      case 'published':
        return FeedbackStatus.published;
      case 'archived':
        return FeedbackStatus.archived;
      default:
        return FeedbackStatus.submitted;
    }
  }

  String get displayName {
    switch (this) {
      case FeedbackStatus.draft:
        return 'Draft';
      case FeedbackStatus.submitted:
        return 'Submitted';
      case FeedbackStatus.reviewed:
        return 'Reviewed';
      case FeedbackStatus.published:
        return 'Published';
      case FeedbackStatus.archived:
        return 'Archived';
    }
  }

  @override
  String toString() {
    switch (this) {
      case FeedbackStatus.draft:
        return 'draft';
      case FeedbackStatus.submitted:
        return 'submitted';
      case FeedbackStatus.reviewed:
        return 'reviewed';
      case FeedbackStatus.published:
        return 'published';
      case FeedbackStatus.archived:
        return 'archived';
    }
  }
}