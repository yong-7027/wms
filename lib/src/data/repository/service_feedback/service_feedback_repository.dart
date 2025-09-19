import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../../features/appointment/models/appointment_model.dart';
import '../../../features/service_feedback/models/service_feedback_model.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../appointment/appointment_repository.dart';

class ServiceFeedbackRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AppointmentRepository _appointmentRepository = AppointmentRepository();
  final Uuid _uuid = Uuid();

  static const String _collectionName = 'serviceFeedbacks';
  static const String _reportsCollectionName = 'feedbackReports';
  static const String _storageFolder =
      'feedback_media'; // Firebase Storage folder

  // Get collection reference
  CollectionReference get _collection => _firestore.collection(_collectionName);
  CollectionReference get _reportsCollection =>
      _firestore.collection(_reportsCollectionName);

  /// Upload media file to Firebase Storage
  Future<String> uploadMediaToStorage(File file, String filename) async {
    try {
      // Create reference to Firebase Storage
      final Reference storageRef = _storage.ref().child(
        '$_storageFolder/$filename',
      );

      // Upload file
      final UploadTask uploadTask = storageRef.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;

      // Return the filename (not the download URL)
      return filename;
    } catch (e) {
      throw Exception('Failed to upload media to storage: $e');
    }
  }

  /// Get download URL for media file
  Future<String> getMediaDownloadUrl(String filename) async {
    try {
      final Reference ref = _storage.ref().child('$_storageFolder/$filename');
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }

  /// Delete media file from Firebase Storage
  Future<void> deleteMediaFromStorage(String filename) async {
    try {
      final Reference ref = _storage.ref().child('$_storageFolder/$filename');
      await ref.delete();
      print('Deleted media file from storage: $filename');
    } catch (e) {
      print('Failed to delete media file from storage: $filename - $e');
    }
  }

  /// Create a new service feedback
  Future<String> createFeedback(ServiceFeedbackModel feedback) async {
    try {
      final feedbackDocRef = _collection.doc(); // Create new document reference
      await feedbackDocRef.set(feedback.toJson());
      return feedbackDocRef.id;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code);
    } catch (e) {
      throw TTexts.commonErrorMessage;
    }
  }

  /// Base method to get feedbacks by appointment IDs with real-time streaming
  Stream<List<ServiceFeedbackModel>> _getFeedbacksByAppointmentIds(
      List<String> appointmentIds, {
        List<FeedbackStatus>? statuses,
      }) {
    if (appointmentIds.isEmpty) {
      return Stream.value([]);
    }

    return Stream.fromIterable([appointmentIds]).asyncExpand((ids) {
      final controller = StreamController<List<ServiceFeedbackModel>>();
      final feedbacksMap = <String, ServiceFeedbackModel>{};
      final subscriptions = <StreamSubscription<QuerySnapshot>>[];

      // 为每个appointmentId创建查询
      for (final appointmentId in ids) {
        var query = _collection.where('appointmentId', isEqualTo: appointmentId);

        if (statuses != null && statuses.isNotEmpty) {
          query = query.where(
            'status',
            whereIn: statuses.map((s) => s.toString()).toList(),
          );
        }

        final subscription = query.snapshots().listen((querySnapshot) {
          for (final docChange in querySnapshot.docChanges) {
            final feedback = ServiceFeedbackModel.fromSnapshot(docChange.doc);

            if (docChange.type == DocumentChangeType.removed) {
              feedbacksMap.remove(docChange.doc.id);
            } else {
              feedbacksMap[docChange.doc.id] = feedback;
            }
          }

          // Filter by status if needed
          List<ServiceFeedbackModel> filteredFeedbacks = feedbacksMap.values.toList();

          if (statuses != null && statuses.isNotEmpty) {
            filteredFeedbacks = filteredFeedbacks
                .where((feedback) => statuses.contains(feedback.status))
                .toList();
          }

          // Sort by createdAt descending
          filteredFeedbacks.sort((a, b) =>
              (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));

          if (!controller.isClosed) {
            controller.add(filteredFeedbacks);
          }
        }, onError: (error) {
          if (!controller.isClosed) {
            controller.addError(error);
          }
        });

        subscriptions.add(subscription);
      }

      controller.onCancel = () {
        for (final subscription in subscriptions) {
          subscription.cancel();
        }
      };

      return controller.stream;
    });
  }

  /// Get all feedbacks by userId with real-time updates
  Stream<List<ServiceFeedbackModel>> getFeedbackByUser(String? userId) {
    try {
      if (userId == null) {
        return Stream.value([]);
      }

      return _appointmentRepository.streamAppointmentsByUserId(userId).asyncExpand(
            (appointments) {
          if (appointments.isEmpty) {
            return Stream.value(<ServiceFeedbackModel>[]);
          }

          final appointmentIds = appointments
              .map((appointment) => appointment.appointmentId)
              .toList();

          return _getFeedbacksByAppointmentIds(appointmentIds);
        },
      );
    } catch (e) {
      throw _handleException('Failed to get feedbacks by user', e);
    }
  }

  /// Get feedbacks for completed appointments only
  Stream<List<ServiceFeedbackModel>> getFeedbackForCompletedAppointments(String? userId) {
    try {
      if (userId == null) {
        return Stream.value([]);
      }

      return _appointmentRepository.streamAppointmentsByUserId(userId).asyncExpand(
            (appointments) {
          if (appointments.isEmpty) {
            return Stream.value(<ServiceFeedbackModel>[]);
          }

          final completedAppointments = appointments
              .where((appointment) => appointment.status.toLowerCase() == 'completed')
              .toList();

          if (completedAppointments.isEmpty) {
            return Stream.value(<ServiceFeedbackModel>[]);
          }

          final appointmentIds = completedAppointments
              .map((appointment) => appointment.appointmentId)
              .toList();

          return _getFeedbacksByAppointmentIds(appointmentIds);
        },
      );
    } catch (e) {
      throw _handleException('Failed to get feedbacks for completed appointments', e);
    }
  }

  /// Get feedbacks filtered by status
  Stream<List<ServiceFeedbackModel>> getUserFeedbackByStatus(String? userId, FeedbackStatus status,) {
    try {
      if (userId == null) {
        return Stream.value([]);
      }

      return _appointmentRepository.streamAppointmentsByUserId(userId).asyncExpand(
            (appointments) {
          if (appointments.isEmpty) {
            return Stream.value(<ServiceFeedbackModel>[]);
          }

          final completedAppointments = appointments
              .where((appointment) => appointment.status.toLowerCase() == 'completed')
              .toList();

          if (completedAppointments.isEmpty) {
            return Stream.value(<ServiceFeedbackModel>[]);
          }

          final appointmentIds = completedAppointments
              .map((appointment) => appointment.appointmentId)
              .toList();

          return _getFeedbacksByAppointmentIds(
            appointmentIds,
            statuses: [status],
          );
        },
      );
    } catch (e) {
      throw _handleException('Failed to get feedbacks by status', e);
    }
  }

  /// Get pending feedbacks (within 7 days) - Real-time stream
  Stream<List<ServiceFeedbackModel>> getPendingFeedbacks(String? userId) {
    try {
      if (userId == null) {
        return Stream.value([]);
      }

      return getUserFeedbackByStatus(userId, FeedbackStatus.pending).asyncMap((feedbacks) {
        final now = DateTime.now();
        return feedbacks.where((feedback) {
          if (feedback.createdAt == null) return false;
          final daysDifference = now.difference(feedback.createdAt!).inDays;
          return daysDifference <= 7;
        }).toList();
      });
    } catch (e) {
      throw _handleException('Failed to get pending feedbacks', e);
    }
  }

  /// Get submitted and disabled feedbacks - Real-time stream
  Stream<List<ServiceFeedbackModel>> getMySubmittedFeedbacks(String? userId) {
    try {
      if (userId == null) {
        return Stream.value([]);
      }

      return _appointmentRepository.streamAppointmentsByUserId(userId).asyncExpand(
            (appointments) {
          if (appointments.isEmpty) {
            return Stream.value(<ServiceFeedbackModel>[]);
          }

          final completedAppointments = appointments
              .where((appointment) => appointment.status.toLowerCase() == 'completed')
              .toList();

          if (completedAppointments.isEmpty) {
            return Stream.value(<ServiceFeedbackModel>[]);
          }

          final appointmentIds = completedAppointments
              .map((appointment) => appointment.appointmentId)
              .toList();

          return _getFeedbacksByAppointmentIds(
            appointmentIds,
            statuses: [FeedbackStatus.submitted, FeedbackStatus.disabled],
          );
        },
      );
    } catch (e) {
      throw _handleException('Failed to get submitted feedbacks', e);
    }
  }

  /// Get feedback by ID
  Future<ServiceFeedbackModel?> getFeedbackById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) return null;

      return ServiceFeedbackModel.fromSnapshot(doc);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw TTexts.commonErrorMessage;
    }
  }

  /// Update existing feedback
  Future<void> updateFeedback(ServiceFeedbackModel feedback) async {
    try {
      final id = feedback.id!;

      // Get existing feedback to compare media files and get current editRemaining
      final existingFeedback = await getFeedbackById(id);

      if (existingFeedback != null) {
        // Delete old media files that are no longer used
        final oldFilenames = existingFeedback.mediaFilenames ?? [];
        final newFilenames = feedback.mediaFilenames ?? [];

        for (String oldFilename in oldFilenames) {
          if (!newFilenames.contains(oldFilename)) {
            await deleteMediaFromStorage(oldFilename);
          }
        }

        // 创建更新后的反馈，减少编辑次数
        final updatedFeedback = feedback.copyWith(
          updatedAt: DateTime.now(),
          editRemaining: existingFeedback.editRemaining - 1, // 减少编辑次数
        );

        await _collection.doc(id).update(updatedFeedback.toJson());
      } else {
        throw Exception('Feedback not found');
      }
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code);
    } catch (e) {
      throw TTexts.commonErrorMessage;
    }
  }

  /// Delete feedback
  Future<void> deleteFeedback(String id) async {
    try {
      // Get feedback first to delete associated media
      final feedback = await getFeedbackById(id);
      if (feedback != null) {
        // Delete all media files from Firebase Storage
        for (String filename in feedback.mediaFilenames) {
          await deleteMediaFromStorage(filename);
        }
      }

      await _collection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw TTexts.commonErrorMessage;
    }
  }


  /// Add like to feedback
  Future<void> addLike(String feedbackId, String userId) async {
    try {
      await _collection.doc(feedbackId).update({
        'likes': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw _handleException('Failed to add like', e);
    }
  }

  /// Remove like from feedback
  Future<void> removeLike(String feedbackId, String userId) async {
    try {
      await _collection.doc(feedbackId).update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      throw _handleException('Failed to remove like', e);
    }
  }

  /// Report feedback
  Future<void> reportFeedback(String feedbackId, String reportedBy, String reason) async {
    try {
      final batch = _firestore.batch();

      // Check if user already reported this feedback
      final existingReport = await _reportsCollection
          .where('feedbackId', isEqualTo: feedbackId)
          .where('reportedBy', isEqualTo: reportedBy)
          .get();

      if (existingReport.docs.isNotEmpty) {
        throw Exception('You have already reported this feedback');
      }

      // Create report document
      final reportDoc = _reportsCollection.doc();
      batch.set(reportDoc, {
        'feedbackId': feedbackId,
        'reportedBy': reportedBy,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, reviewed, resolved
      });

      // Update feedback report count
      final feedbackDoc = _collection.doc(feedbackId);
      batch.update(feedbackDoc, {
        'reportCounts.${reason}': FieldValue.increment(1),
      });

      await batch.commit();
    } catch (e) {
      throw _handleException('Failed to report feedback', e);
    }
  }

  /// Get user's reported feedbacks
  Future<Set<String>> getUserReportedFeedbacks(String userId) async {
    try {
      final snapshot = await _reportsCollection
          .where('reportedBy', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .map((data) => data['feedbackId'] as String)
          .toSet();
    } catch (e) {
      throw _handleException('Failed to get user reported feedbacks', e);
    }
  }

  /// Add staff reply to feedback
  Future<void> addStaffReply(String feedbackId, String reply) async {
    try {
      await _collection.doc(feedbackId).update({
        'staffReply': reply,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleException('Failed to add staff reply', e);
    }
  }

  // /// Update feedback status
  // Future<void> updateStatus(String feedbackId, FeedbackStatus status) async {
  //   try {
  //     await _collection.doc(feedbackId).update({
  //       'status': status.toString(),
  //       'updatedAt': Timestamp.now(),
  //     });
  //   } catch (e) {
  //     throw _handleException('Failed to update status', e);
  //   }
  // }

  /// Get feedback statistics for a service
  Future<Map<String, dynamic>> getServiceFeedbackStats(String appointmentId) async {
    try {
      final query = _collection.where('appointmentId', isEqualTo: appointmentId,);
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
          .map((doc) => ServiceFeedbackModel.fromSnapshot(doc))
          .toList();

      double totalRating = 0;
      Map<int, int> ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      Map<String, int> statusDistribution = {};

      for (final feedback in feedbacks) {
        totalRating += feedback.averageRating;

        final roundedRating = feedback.averageRating.round();
        ratingDistribution[roundedRating] =
            (ratingDistribution[roundedRating] ?? 0) + 1;

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

  // /// Search feedbacks by comment content
  // Future<List<ServiceFeedbackModel>> searchFeedbacks(String searchTerm) async {
  //   try {
  //     // Note: Firestore doesn't support full-text search natively
  //     // This is a simple implementation that gets all docs and filters locally
  //     // For production, consider using Algolia or ElasticSearch
  //
  //     final snapshot = await _collection.get();
  //     final feedbacks = snapshot.docs
  //         .map((doc) => ServiceFeedbackModel.fromSnapshot(doc))
  //         .where(
  //           (feedback) =>
  //               feedback.comment.toLowerCase().contains(
  //                 searchTerm.toLowerCase(),
  //               ) ||
  //               feedback.staffReply.toLowerCase().contains(
  //                 searchTerm.toLowerCase(),
  //               ),
  //         )
  //         .toList();
  //
  //     return feedbacks;
  //   } catch (e) {
  //     throw _handleException('Failed to search feedbacks', e);
  //   }
  // }

  /// Get recent feedbacks (last 30 days) with real-time updates
  Stream<List<ServiceFeedbackModel>> getRecentFeedbacks({int limit = 20}) {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      return _collection
          .where('createdAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => ServiceFeedbackModel.fromSnapshot(doc))
                .toList(),
          );
    } catch (e) {
      throw _handleException('Failed to get recent feedbacks', e);
    }
  }

  // /// Get all submitted feedbacks with real-time updates (for reviews screen)
  // Stream<List<ServiceFeedbackModel>> getAllSubmittedFeedbacks() {
  //   try {
  //     return _collection
  //         .where('status', isEqualTo: 'submitted') // 只获取已提交的反馈
  //         .orderBy('updatedAt', descending: true)   // 按更新时间降序排序
  //         .snapshots()
  //         .map(
  //           (snapshot) => snapshot.docs
  //           .map((doc) => ServiceFeedbackModel.fromSnapshot(doc))
  //           .toList(),
  //     );
  //   } catch (e) {
  //     throw _handleException('Failed to get submitted feedbacks', e);
  //   }
  // }

  /// Get all feedbacks with real-time updates (for reviews screen)
  // Stream<List<ServiceFeedbackModel>> getAllFeedbacks({int limit = 100}) {
  //   try {
  //     return _collection
  //         .orderBy('createdAt', descending: true)
  //         .limit(limit)
  //         .snapshots()
  //         .map(
  //           (snapshot) => snapshot.docs
  //               .map((doc) => ServiceFeedbackModel.fromSnapshot(doc))
  //               .toList(),
  //         );
  //   } catch (e) {
  //     throw _handleException('Failed to get all feedbacks', e);
  //   }
  // }

  // /// Batch update feedbacks
  // Future<void> batchUpdateFeedbacks(
  //   List<String> feedbackIds,
  //   Map<String, dynamic> updates,
  // ) async {
  //   try {
  //     final batch = _firestore.batch();
  //
  //     for (final id in feedbackIds) {
  //       final docRef = _collection.doc(id);
  //       batch.update(docRef, {...updates, 'updatedAt': Timestamp.now()});
  //     }
  //
  //     await batch.commit();
  //   } catch (e) {
  //     throw _handleException('Failed to batch update feedbacks', e);
  //   }
  // }

  /// Get media download URLs for a list of filenames
  Future<List<String>> getMediaDownloadUrls(List<String> filenames) async {
    try {
      List<String> downloadUrls = [];

      for (String filename in filenames) {
        try {
          final String downloadUrl = await getMediaDownloadUrl(filename);
          downloadUrls.add(downloadUrl);
        } catch (e) {
          print('Failed to get download URL for $filename: $e');
          // Continue with other files even if one fails
        }
      }

      return downloadUrls;
    } catch (e) {
      throw _handleException('Failed to get media download URLs', e);
    }
  }

  /// Check if a media file exists in Firebase Storage
  Future<bool> mediaFileExistsInStorage(String filename) async {
    try {
      final Reference ref = _storage.ref().child('$_storageFolder/$filename');
      await ref.getDownloadURL(); // This will throw if file doesn't exist
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Batch delete media files from Firebase Storage
  Future<void> batchDeleteMediaFromStorage(List<String> filenames) async {
    for (String filename in filenames) {
      await deleteMediaFromStorage(filename);
    }
  }

  /// Get Firebase Storage folder path
  String get storageFolderPath => _storageFolder;

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
