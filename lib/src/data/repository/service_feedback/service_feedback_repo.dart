import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import '../../../features/service_feedback/models/service_feedback_model.dart';

class ServiceFeedbackRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String _collectionName = 'serviceFeedbacks';
  static const String _storageFolder = 'feedback_media';

  // Get collection reference
  CollectionReference get _collection => _firestore.collection(_collectionName);

  /// Create a new service feedback and update appointment
  Future<String> createFeedback(ServiceFeedbackModel feedback) async {
    try {
      // Use Firestore batch for atomic operations
      final batch = _firestore.batch();

      // Upload media files first if any
      List<String> uploadedMediaUrls = [];
      if (feedback.mediaPaths.isNotEmpty) {
        uploadedMediaUrls = await _uploadMediaFiles(
          feedback.mediaPaths.map((path) => File(path)).toList(),
          feedback.id,
        );
      }

      // Create feedback with uploaded media URLs
      final feedbackWithMedia = feedback.copyWith(mediaPaths: uploadedMediaUrls);
      final feedbackDocRef = _collection.doc(); // Create new document reference
      batch.set(feedbackDocRef, feedbackWithMedia.toJson());

      // Update appointment hasFeedback status
      // final appointmentDocRef = _firestore.collection('appointments').doc(feedback.appointmentId);
      // batch.update(appointmentDocRef, {'hasFeedback': true});

      // Commit both operations
      await batch.commit();

      return feedbackDocRef.id;
    } catch (e) {
      throw _handleException('Failed to create feedback', e);
    }
  }

  /// Get feedback by ID
  Future<ServiceFeedbackModel?> getFeedbackById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) return null;

      return ServiceFeedbackModel.fromFirestore(doc);
    } catch (e) {
      throw _handleException('Failed to get feedback', e);
    }
  }

  /// Update existing feedback
  Future<void> updateFeedback(String id, ServiceFeedbackModel feedback) async {
    try {
      // Handle media updates if needed
      List<String> finalMediaUrls = List.from(feedback.mediaPaths);

      // Check if there are new local files to upload
      final localFiles = feedback.mediaPaths
          .where((path) => !path.startsWith('http'))
          .map((path) => File(path))
          .toList();

      if (localFiles.isNotEmpty) {
        final uploadedUrls = await _uploadMediaFiles(localFiles, id);

        // Replace local paths with uploaded URLs
        for (int i = 0; i < feedback.mediaPaths.length; i++) {
          if (!feedback.mediaPaths[i].startsWith('http')) {
            final localFileIndex = localFiles.indexWhere(
                    (file) => file.path == feedback.mediaPaths[i]
            );
            if (localFileIndex != -1) {
              finalMediaUrls[i] = uploadedUrls[localFileIndex];
            }
          }
        }
      }

      final updatedFeedback = feedback.copyWith(
        mediaPaths: finalMediaUrls,
        updatedAt: DateTime.now(),
      );

      await _collection.doc(id).update(updatedFeedback.toJson());
    } catch (e) {
      throw _handleException('Failed to update feedback', e);
    }
  }

  /// Delete feedback
  Future<void> deleteFeedback(String id) async {
    try {
      // Get feedback first to delete associated media
      final feedback = await getFeedbackById(id);
      if (feedback != null) {
        await _deleteMediaFiles(feedback.mediaPaths);
      }

      await _collection.doc(id).delete();
    } catch (e) {
      throw _handleException('Failed to delete feedback', e);
    }
  }

  /// Get all feedbacks with optional filters
  Stream<List<ServiceFeedbackModel>> getAllFeedbacks({
    String? appointmentId,
    String? userId,
    FeedbackStatus? status,
    int? limit,
    DocumentSnapshot? startAfter,
  }) {
    try {
      Query query = _collection.orderBy('createdAt', descending: true);

      // Apply filters
      if (appointmentId != null) {
        query = query.where('appointmentId', isEqualTo: appointmentId);
      }
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status.toString());
      }
      if (limit != null) {
        query = query.limit(limit);
      }
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => ServiceFeedbackModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw _handleException('Failed to get feedbacks', e);
    }
  }

  /// Get feedbacks by service ID
  Stream<List<ServiceFeedbackModel>> getFeedbacksByService(String appointmentId, {int? limit}) {
    return getAllFeedbacks(appointmentId: appointmentId, limit: limit);
  }

  /// Get feedbacks by user ID
  Stream<List<ServiceFeedbackModel>> getFeedbacksByUser(String userId, {int? limit}) {
    return getAllFeedbacks(userId: userId, limit: limit);
  }

  /// Get feedbacks by status
  Stream<List<ServiceFeedbackModel>> getFeedbacksByStatus(FeedbackStatus status, {int? limit}) {
    return getAllFeedbacks(status: status, limit: limit);
  }

  /// Add like to feedback
  Future<void> addLike(String feedbackId, String userId) async {
    try {
      await _collection.doc(feedbackId).update({
        'likes': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      throw _handleException('Failed to add like', e);
    }
  }

  /// Remove like from feedback
  Future<void> removeLike(String feedbackId, String userId) async {
    try {
      await _collection.doc(feedbackId).update({
        'likes': FieldValue.arrayRemove([userId])
      });
    } catch (e) {
      throw _handleException('Failed to remove like', e);
    }
  }

  /// Add staff reply to feedback
  Future<void> addStaffReply(String feedbackId, String reply) async {
    try {
      await _collection.doc(feedbackId).update({
        'staffReply': reply,
        'updatedAt': Timestamp.now(),
        'status': FeedbackStatus.reviewed.toString(),
      });
    } catch (e) {
      throw _handleException('Failed to add staff reply', e);
    }
  }

  /// Update feedback status
  Future<void> updateStatus(String feedbackId, FeedbackStatus status) async {
    try {
      await _collection.doc(feedbackId).update({
        'status': status.toString(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw _handleException('Failed to update status', e);
    }
  }

  /// Get feedback statistics for a service
  Future<Map<String, dynamic>> getServiceFeedbackStats(String appointmentId) async {
    try {
      final query = _collection.where('appointmentId', isEqualTo: appointmentId);
      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        return {
          'totalFeedbacks': 0,
          'averageRating': 0.0,
          'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
          'statusDistribution': {},
        };
      }

      final feedbacks = snapshot.docs
          .map((doc) => ServiceFeedbackModel.fromFirestore(doc))
          .toList();

      double totalRating = 0;
      Map<int, int> ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      Map<String, int> statusDistribution = {};

      for (final feedback in feedbacks) {
        totalRating += feedback.averageRating;

        final roundedRating = feedback.averageRating.round();
        ratingDistribution[roundedRating] = (ratingDistribution[roundedRating] ?? 0) + 1;

        final status = feedback.status.displayName;
        statusDistribution[status] = (statusDistribution[status] ?? 0) + 1;
      }

      return {
        'totalFeedbacks': feedbacks.length,
        'averageRating': totalRating / feedbacks.length,
        'ratingDistribution': ratingDistribution,
        'statusDistribution': statusDistribution,
        'highRatingCount': feedbacks.where((f) => f.isHighRating).length,
        'mediumRatingCount': feedbacks.where((f) => f.isMediumRating).length,
        'lowRatingCount': feedbacks.where((f) => f.isLowRating).length,
      };
    } catch (e) {
      throw _handleException('Failed to get feedback stats', e);
    }
  }

  /// Search feedbacks by comment content
  Future<List<ServiceFeedbackModel>> searchFeedbacks(String searchTerm) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a simple implementation that gets all docs and filters locally
      // For production, consider using Algolia or ElasticSearch

      final snapshot = await _collection.get();
      final feedbacks = snapshot.docs
          .map((doc) => ServiceFeedbackModel.fromFirestore(doc))
          .where((feedback) =>
      feedback.comment.toLowerCase().contains(searchTerm.toLowerCase()) ||
          feedback.staffReply.toLowerCase().contains(searchTerm.toLowerCase())
      )
          .toList();

      return feedbacks;
    } catch (e) {
      throw _handleException('Failed to search feedbacks', e);
    }
  }

  /// Get recent feedbacks (last 30 days)
  Stream<List<ServiceFeedbackModel>> getRecentFeedbacks({int limit = 20}) {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      return _collection
          .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => ServiceFeedbackModel.fromFirestore(doc))
          .toList());
    } catch (e) {
      throw _handleException('Failed to get recent feedbacks', e);
    }
  }

  /// Batch update feedbacks
  Future<void> batchUpdateFeedbacks(
      List<String> feedbackIds,
      Map<String, dynamic> updates
      ) async {
    try {
      final batch = _firestore.batch();

      for (final id in feedbackIds) {
        final docRef = _collection.doc(id);
        batch.update(docRef, {
          ...updates,
          'updatedAt': Timestamp.now(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw _handleException('Failed to batch update feedbacks', e);
    }
  }

  /// Upload media files to Firebase Storage
  Future<List<String>> _uploadMediaFiles(List<File> files, String feedbackId) async {
    final uploadTasks = <Future<String>>[];

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final fileName = '${feedbackId}_${i}_${path.basename(file.path)}';
      final ref = _storage.ref().child('$_storageFolder/$fileName');

      uploadTasks.add(_uploadSingleFile(file, ref));
    }

    return await Future.wait(uploadTasks);
  }

  /// Upload single file and return download URL
  Future<String> _uploadSingleFile(File file, Reference ref) async {
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  /// Delete media files from Firebase Storage
  Future<void> _deleteMediaFiles(List<String> mediaUrls) async {
    for (final url in mediaUrls) {
      if (url.startsWith('http')) {
        try {
          final ref = _storage.refFromURL(url);
          await ref.delete();
        } catch (e) {
          // Continue deleting other files even if one fails
          print('Failed to delete media file: $url - $e');
        }
      }
    }
  }

  /// Handle exceptions and provide meaningful error messages
  Exception _handleException(String message, dynamic error) {
    print('ServiceFeedbackRepository Error: $message - $error');

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return Exception('$message: Permission denied');
        case 'not-found':
          return Exception('$message: Resource not found');
        case 'network-request-failed':
          return Exception('$message: Network error');
        default:
          return Exception('$message: ${error.message}');
      }
    }

    return Exception('$message: $error');
  }

  /// Dispose resources (if needed)
  void dispose() {
    // Clean up any resources if necessary
  }
}