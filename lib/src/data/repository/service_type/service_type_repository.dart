import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../../../features/appointment/models/service_type_model.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/exceptions/firebase_exceptions.dart';
import '../../../utils/exceptions/format_exceptions.dart';
import '../../../utils/exceptions/platform_exceptions.dart';
import '../appointment/appointment_repository.dart';

class ServiceTypeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  static const String _collectionName = 'serviceTypes';

  // Get collection reference
  CollectionReference get _collection => _firestore.collection(_collectionName);

  /// Get all service types
  Future<List<ServiceTypeModel>> getAllServiceTypes() async {
    try {
      final snapshot = await _collection.get();
      return snapshot.docs
          .map((doc) => ServiceTypeModel.fromSnapshot(doc))
          .toList();
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

  /// Get service types by appointment ID
  Future<List<ServiceTypeModel>> getServiceTypesByAppointmentId(String appointmentId) async {
    try {
      // Get the appointment first to get service type IDs
      final appointment = await _appointmentRepository.getAppointmentById(appointmentId);

      if (appointment == null || appointment.serviceTypeIds.isEmpty) {
        return [];
      }

      // Fetch service types by IDs in batches (Firestore limit is 10 for 'in' queries)
      List<ServiceTypeModel> serviceTypes = [];
      const batchSize = 10;

      for (int i = 0; i < appointment.serviceTypeIds.length; i += batchSize) {
        final batch = appointment.serviceTypeIds
            .skip(i)
            .take(batchSize)
            .toList();

        final snapshot = await _collection
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        final batchServiceTypes = snapshot.docs
            .map((doc) => ServiceTypeModel.fromSnapshot(doc))
            .toList();

        serviceTypes.addAll(batchServiceTypes);
      }

      return serviceTypes;
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

  /// Get service type by ID
  Future<ServiceTypeModel?> getServiceTypeById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) return null;

      return ServiceTypeModel.fromSnapshot(doc);
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

  /// Get service types by category
  Future<List<ServiceTypeModel>> getServiceTypesByCategory(String category) async {
    try {
      final snapshot = await _collection
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs
          .map((doc) => ServiceTypeModel.fromSnapshot(doc))
          .toList();
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

  /// Stream service types (real-time updates)
  Stream<List<ServiceTypeModel>> streamServiceTypes() {
    try {
      return _collection
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => ServiceTypeModel.fromSnapshot(doc))
          .toList());
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

  /// Get all categories
  Future<List<String>> getAllCategories() async {
    try {
      final snapshot = await _collection.get();
      final categories = snapshot.docs
          .map((doc) => ServiceTypeModel.fromSnapshot(doc).category)
          .toSet()
          .toList();

      return categories;
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

  /// Create new service type (admin function)
  Future<String> createServiceType(ServiceTypeModel serviceType) async {
    try {
      final docRef = await _collection.add(serviceType.toJson());
      return docRef.id;
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

  /// Update service type (admin function)
  Future<void> updateServiceType(String id, ServiceTypeModel serviceType) async {
    try {
      await _collection.doc(id).update(serviceType.toJson());
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

  /// Delete service type (admin function)
  Future<void> deleteServiceType(String id) async {
    try {
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
}