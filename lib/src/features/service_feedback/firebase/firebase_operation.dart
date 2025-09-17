import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/service_feedback_model.dart';

/// Service class for handling Firestore CRUD operations for service feedback
class FeedbackFirestoreService {
  // Firestore instance
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firebase Storage instance for media uploads
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection references
  static const String _feedbackCollection = 'service_feedback';
  static const String _usersCollection = 'users';
  static const String _servicesCollection = 'services';

  // Storage paths
  static const String _mediaStoragePath = 'feedback_media';

  /// Create a new service feedback review
  /// Returns the created feedback document ID
  Future<String> createReview(ServiceFeedbackModel feedback) async {
    try {
      // First check if user already has a review for this service
      final existingReview = await getUserReviewForService(
          feedback.userId,
          feedback.appointmentId
      );

      if (existingReview != null) {
        throw Exception('User has already reviewed this service');
      }

      // Upload media files if any
      List<String> uploadedMediaPaths = [];
      if (feedback.mediaPaths.isNotEmpty) {
        uploadedMediaPaths = await _uploadMediaFiles(
          feedback.mediaPaths.map((path) => File(path)).toList(),
          feedback.userId,
          feedback.appointmentId,
        );
      }

      // Create feedback document with uploaded media paths
      final feedbackToSave = feedback.copyWith(
        mediaPaths: uploadedMediaPaths,
        createdAt: DateTime.now(),
      );

      // Add to Firestore
      final docRef = await _firestore
          .collection(_feedbackCollection)
          .add(feedbackToSave.toJson());

      // Update user's review history
      await _updateUserReviewHistory(feedback.userId, docRef.id);

      // Update service rating statistics
      await _updateServiceRatingStats(feedback.appointmentId, feedback);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  /// Get a specific feedback by ID
  Future<ServiceFeedbackModel?> getFeedbackById(String feedbackId) async {
    try {
      final doc = await _firestore
          .collection(_feedbackCollection)
          .doc(feedbackId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;

      return ServiceFeedbackModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get feedback: $e');
    }
  }

  /// Get all feedback for a specific service
  Future<List<ServiceFeedbackModel>> getFeedbackForService(
      String appointmentId, {
        int? limit,
        String? orderBy = 'createdAt',
        bool descending = true,
      }) async {
    try {
      Query query = _firestore
          .collection(_feedbackCollection)
          .where('appointmentId', isEqualTo: appointmentId);

      // Apply ordering
      query = query.orderBy(orderBy!, descending: descending);

      // Apply limit if specified
      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ServiceFeedbackModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get service feedback: $e');
    }
  }

  /// Get all feedback from a specific user
  Future<List<ServiceFeedbackModel>> getFeedbackByUser(
      String userId, {
        int? limit,
        String? orderBy = 'createdAt',
        bool descending = true,
      }) async {
    try {
      Query query = _firestore
          .collection(_feedbackCollection)
          .where('userId', isEqualTo: userId);

      // Apply ordering
      query = query.orderBy(orderBy!, descending: descending);

      // Apply limit if specified
      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ServiceFeedbackModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get user feedback: $e');
    }
  }

  /// Check if user has already reviewed a specific service
  Future<ServiceFeedbackModel?> getUserReviewForService(
      String userId,
      String appointmentId
      ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_feedbackCollection)
          .where('userId', isEqualTo: userId)
          .where('appointmentId', isEqualTo: appointmentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id;

      return ServiceFeedbackModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to check existing review: $e');
    }
  }

  /// Update an existing feedback review
  Future<void> updateReview(
      String feedbackId,
      ServiceFeedbackModel updatedFeedback
      ) async {
    try {
      // Get current feedback to compare media changes
      final currentFeedback = await getFeedbackById(feedbackId);
      if (currentFeedback == null) {
        throw Exception('Feedback not found');
      }

      // Handle media updates if needed
      List<String> finalMediaPaths = updatedFeedback.mediaPaths;

      // If media has changed, handle uploads/deletions
      if (!_listEquals(currentFeedback.mediaPaths, updatedFeedback.mediaPaths)) {
        // Delete old media files
        await _deleteMediaFiles(currentFeedback.mediaPaths);

        // Upload new media files
        if (updatedFeedback.mediaPaths.isNotEmpty) {
          finalMediaPaths = await _uploadMediaFiles(
            updatedFeedback.mediaPaths.map((path) => File(path)).toList(),
            updatedFeedback.userId,
            updatedFeedback.appointmentId,
          );
        }
      }

      // Update document
      final feedbackToUpdate = updatedFeedback.copyWith(
        id: feedbackId,
        mediaPaths: finalMediaPaths,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_feedbackCollection)
          .doc(feedbackId)
          .update(feedbackToUpdate.toJson());

      // Update service rating statistics
      await _updateServiceRatingStats(
        updatedFeedback.appointmentId,
        updatedFeedback,
        isUpdate: true,
        previousFeedback: currentFeedback,
      );
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  /// Delete a feedback review
  Future<void> deleteReview(String feedbackId) async {
    try {
      // Get feedback data before deletion
      final feedback = await getFeedbackById(feedbackId);
      if (feedback == null) {
        throw Exception('Feedback not found');
      }

      // Delete associated media files
      if (feedback.mediaPaths.isNotEmpty) {
        await _deleteMediaFiles(feedback.mediaPaths);
      }

      // Delete from Firestore
      await _firestore
          .collection(_feedbackCollection)
          .doc(feedbackId)
          .delete();

      // Update user's review history
      await _removeFromUserReviewHistory(feedback.userId, feedbackId);

      // Update service rating statistics
      await _updateServiceRatingStats(
        feedback.appointmentId,
        feedback,
        isDelete: true,
      );
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  /// Get feedback statistics for a service
  Future<Map<String, dynamic>> getServiceRatingStats(String appointmentId) async {
    try {
      final feedbacks = await getFeedbackForService(appointmentId);

      if (feedbacks.isEmpty) {
        return {
          'totalReviews': 0,
          'averageRating': 0.0,
          'ratingBreakdown': {
            '1': 0, '2': 0, '3': 0, '4': 0, '5': 0
          },
          'categoryAverages': {
            'service': 0.0,
            'repairEfficiency': 0.0,
            'transparency': 0.0,
            'overallExperience': 0.0,
          }
        };
      }

      final totalReviews = feedbacks.length;
      double totalAverage = 0.0;
      double serviceTotal = 0.0;
      double repairTotal = 0.0;
      double transparencyTotal = 0.0;
      double overallTotal = 0.0;

      Map<String, int> ratingBreakdown = {
        '1': 0, '2': 0, '3': 0, '4': 0, '5': 0
      };

      // Calculate statistics
      for (final feedback in feedbacks) {
        final avgRating = feedback.averageRating;
        totalAverage += avgRating;
        serviceTotal += feedback.serviceRating;
        repairTotal += feedback.repairEfficiencyRating;
        transparencyTotal += feedback.transparencyRating;
        overallTotal += feedback.overallExperienceRating;

        // Count rating distribution based on overall average
        final roundedRating = avgRating.round().clamp(1, 5);
        ratingBreakdown[roundedRating.toString()] =
            (ratingBreakdown[roundedRating.toString()] ?? 0) + 1;
      }

      return {
        'totalReviews': totalReviews,
        'averageRating': totalAverage / totalReviews,
        'ratingBreakdown': ratingBreakdown,
        'categoryAverages': {
          'service': serviceTotal / totalReviews,
          'repairEfficiency': repairTotal / totalReviews,
          'transparency': transparencyTotal / totalReviews,
          'overallExperience': overallTotal / totalReviews,
        }
      };
    } catch (e) {
      throw Exception('Failed to get service rating stats: $e');
    }
  }

  /// Upload media files to Firebase Storage
  Future<List<String>> _uploadMediaFiles(
      List<File> mediaFiles,
      String userId,
      String appointmentId,
      ) async {
    List<String> uploadedPaths = [];

    try {
      for (int i = 0; i < mediaFiles.length; i++) {
        final file = mediaFiles[i];
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.${file.path.split('.').last}';
        final filePath = '$_mediaStoragePath/$appointmentId/$userId/$fileName';

        final ref = _storage.ref().child(filePath);
        final uploadTask = await ref.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();

        uploadedPaths.add(downloadUrl);
      }

      return uploadedPaths;
    } catch (e) {
      // Clean up any successfully uploaded files if there's an error
      for (final path in uploadedPaths) {
        try {
          await _storage.refFromURL(path).delete();
        } catch (cleanupError) {
          print('Failed to cleanup uploaded file: $cleanupError');
        }
      }
      throw Exception('Failed to upload media files: $e');
    }
  }

  /// Delete media files from Firebase Storage
  Future<void> _deleteMediaFiles(List<String> mediaPaths) async {
    for (final path in mediaPaths) {
      try {
        if (path.startsWith('https://')) {
          await _storage.refFromURL(path).delete();
        }
      } catch (e) {
        print('Failed to delete media file $path: $e');
        // Continue with other files even if one fails
      }
    }
  }

  /// Update user's review history in their profile
  Future<void> _updateUserReviewHistory(String userId, String feedbackId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'reviewHistory': FieldValue.arrayUnion([feedbackId]),
        'totalReviews': FieldValue.increment(1),
        'lastReviewDate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // User document might not exist, create it
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .set({
        'reviewHistory': [feedbackId],
        'totalReviews': 1,
        'lastReviewDate': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    }
  }

  /// Remove feedback from user's review history
  Future<void> _removeFromUserReviewHistory(String userId, String feedbackId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'reviewHistory': FieldValue.arrayRemove([feedbackId]),
        'totalReviews': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Failed to update user review history: $e');
    }
  }

  /// Update service rating statistics
  Future<void> _updateServiceRatingStats(
      String appointmentId,
      ServiceFeedbackModel feedback, {
        bool isUpdate = false,
        bool isDelete = false,
        ServiceFeedbackModel? previousFeedback,
      }) async {
    try {
      final serviceRef = _firestore.collection(_servicesCollection).doc(appointmentId);

      if (isDelete) {
        // Decrease counters and ratings
        await serviceRef.update({
          'totalReviews': FieldValue.increment(-1),
          'totalServiceRating': FieldValue.increment(-feedback.serviceRating),
          'totalRepairRating': FieldValue.increment(-feedback.repairEfficiencyRating),
          'totalTransparencyRating': FieldValue.increment(-feedback.transparencyRating),
          'totalOverallRating': FieldValue.increment(-feedback.overallExperienceRating),
          'lastReviewDate': DateTime.now().toIso8601String(),
        });
      } else if (isUpdate && previousFeedback != null) {
        // Update with difference
        await serviceRef.update({
          'totalServiceRating': FieldValue.increment(
              feedback.serviceRating - previousFeedback.serviceRating),
          'totalRepairRating': FieldValue.increment(
              feedback.repairEfficiencyRating - previousFeedback.repairEfficiencyRating),
          'totalTransparencyRating': FieldValue.increment(
              feedback.transparencyRating - previousFeedback.transparencyRating),
          'totalOverallRating': FieldValue.increment(
              feedback.overallExperienceRating - previousFeedback.overallExperienceRating),
          'lastReviewDate': DateTime.now().toIso8601String(),
        });
      } else {
        // New review - increment counters
        await serviceRef.update({
          'totalReviews': FieldValue.increment(1),
          'totalServiceRating': FieldValue.increment(feedback.serviceRating),
          'totalRepairRating': FieldValue.increment(feedback.repairEfficiencyRating),
          'totalTransparencyRating': FieldValue.increment(feedback.transparencyRating),
          'totalOverallRating': FieldValue.increment(feedback.overallExperienceRating),
          'lastReviewDate': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      // Service document might not exist, create it
      if (!isDelete && !isUpdate) {
        await _firestore
            .collection(_servicesCollection)
            .doc(appointmentId)
            .set({
          'totalReviews': 1,
          'totalServiceRating': feedback.serviceRating,
          'totalRepairRating': feedback.repairEfficiencyRating,
          'totalTransparencyRating': feedback.transparencyRating,
          'totalOverallRating': feedback.overallExperienceRating,
          'lastReviewDate': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      }
    }
  }

  /// Get paginated feedback for a service
  Future<List<ServiceFeedbackModel>> getPaginatedFeedback(
      String appointmentId, {
        DocumentSnapshot? startAfter,
        int limit = 10,
        String orderBy = 'createdAt',
        bool descending = true,
      }) async {
    try {
      Query query = _firestore
          .collection(_feedbackCollection)
          .where('appointmentId', isEqualTo: appointmentId)
          .orderBy(orderBy, descending: descending)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ServiceFeedbackModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get paginated feedback: $e');
    }
  }

  /// Search feedback by keyword in comments
  Future<List<ServiceFeedbackModel>> searchFeedback({
    String? appointmentId,
    String? keyword,
    int? minRating,
    int? maxRating,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore.collection(_feedbackCollection);

      // Apply filters
      if (appointmentId != null) {
        query = query.where('appointmentId', isEqualTo: appointmentId);
      }

      if (minRating != null) {
        query = query.where('overallExperienceRating', isGreaterThanOrEqualTo: minRating);
      }

      if (maxRating != null) {
        query = query.where('overallExperienceRating', isLessThanOrEqualTo: maxRating);
      }

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: endDate.toIso8601String());
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      final querySnapshot = await query.get();
      List<ServiceFeedbackModel> results = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ServiceFeedbackModel.fromJson(data);
      }).toList();

      // Filter by keyword if provided (client-side filtering for simplicity)
      if (keyword != null && keyword.isNotEmpty) {
        final keywordLower = keyword.toLowerCase();
        results = results.where((feedback) =>
            feedback.comment.toLowerCase().contains(keywordLower)
        ).toList();
      }

      return results;
    } catch (e) {
      throw Exception('Failed to search feedback: $e');
    }
  }

  /// Batch operations for bulk feedback management
  Future<void> batchUpdateFeedbackStatus(
      List<String> feedbackIds,
      FeedbackStatus newStatus,
      ) async {
    try {
      final batch = _firestore.batch();

      for (final feedbackId in feedbackIds) {
        final docRef = _firestore.collection(_feedbackCollection).doc(feedbackId);
        batch.update(docRef, {
          'status': newStatus.toString(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch update feedback status: $e');
    }
  }

  /// Helper method to compare lists
  bool _listEquals<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  /// Get real-time feedback stream for a service
  Stream<List<ServiceFeedbackModel>> getFeedbackStream(
      String appointmentId, {
        int limit = 20,
      }) {
    return _firestore
        .collection(_feedbackCollection)
        .where('appointmentId', isEqualTo: appointmentId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return ServiceFeedbackModel.fromJson(data);
        }).toList()
    );
  }

  /// Cleanup orphaned media files (utility method for maintenance)
  Future<void> cleanupOrphanedMedia() async {
    try {
      // This would require admin privileges and should be run as a Cloud Function
      print('Cleanup orphaned media files should be implemented as a Cloud Function');
    } catch (e) {
      throw Exception('Failed to cleanup orphaned media: $e');
    }
  }
}